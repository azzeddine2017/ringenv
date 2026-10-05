# ============================================================================
# Raylib Extension Recipe (auto-deployed by ringenv harvest --android)
# ============================================================================
# Builds raylib 5.0 from source for Android NDK with patches for:
#   - NDK 27+ (ALooper_pollAll removed → ALooper_pollOnce)
#   - MatrixNormalize missing from raymath.h v1.5

set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty")

set(RAYLIB_TAG "5.0")
set(RAYGUI_TAG "4.0")

set(RAYLIB_DIR "${THIRDPARTY_DIR}/raylib")
set(RAYGUI_DIR "${THIRDPARTY_DIR}/raygui")

# Clone raylib if not present
if(NOT EXISTS "${RAYLIB_DIR}/CMakeLists.txt")
    message(STATUS "Cloning raylib ${RAYLIB_TAG} to ${RAYLIB_DIR}...")
    execute_process(
        COMMAND git clone --branch ${RAYLIB_TAG} --depth 1
            https://github.com/raysan5/raylib.git "${RAYLIB_DIR}"
        RESULT_VARIABLE _raylib_clone_res)
    if(NOT _raylib_clone_res EQUAL 0)
        message(FATAL_ERROR "Failed to clone raylib ${RAYLIB_TAG}")
    endif()
endif()

# Clone raygui if not present
if(NOT EXISTS "${RAYGUI_DIR}/src/raygui.h")
    message(STATUS "Cloning raygui ${RAYGUI_TAG} to ${RAYGUI_DIR}...")
    execute_process(
        COMMAND git clone --branch ${RAYGUI_TAG} --depth 1
            https://github.com/raysan5/raygui.git "${RAYGUI_DIR}"
        RESULT_VARIABLE _raygui_clone_res)
    if(NOT _raygui_clone_res EQUAL 0)
        message(FATAL_ERROR "Failed to clone raygui ${RAYGUI_TAG}")
    endif()
endif()

# Raylib build options for Android
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_GAMES OFF CACHE BOOL "" FORCE)
set(PLATFORM "Android" CACHE STRING "" FORCE)
set(OPENGL_VERSION "ES 2.0" CACHE STRING "" FORCE)

# Allow old cmake_minimum_required in vendored raylib 5.0
if(NOT DEFINED CMAKE_POLICY_VERSION_MINIMUM)
    set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
endif()

# Patch raylib 5.0 for NDK 27+ (ALooper_pollAll removed)
set(RAYLIB_PATCHED_DIR "${CMAKE_CURRENT_BINARY_DIR}/raylib-patched")
file(COPY "${RAYLIB_DIR}/CMakeLists.txt" "${RAYLIB_DIR}/CMakeOptions.txt"
     "${RAYLIB_DIR}/raylib.pc.in" "${RAYLIB_DIR}/README.md"
     "${RAYLIB_DIR}/LICENSE" DESTINATION "${RAYLIB_PATCHED_DIR}")
file(COPY "${RAYLIB_DIR}/cmake" DESTINATION "${RAYLIB_PATCHED_DIR}")
file(COPY "${RAYLIB_DIR}/src" DESTINATION "${RAYLIB_PATCHED_DIR}")
file(READ "${RAYLIB_PATCHED_DIR}/src/platforms/rcore_android.c" _RCORE_ANDROID)
string(REPLACE "ALooper_pollAll(" "ALooper_pollOnce(" _RCORE_ANDROID "${_RCORE_ANDROID}")
file(WRITE "${RAYLIB_PATCHED_DIR}/src/platforms/rcore_android.c" "${_RCORE_ANDROID}")

# Patch MatrixNormalize if missing from raymath.h
file(READ "${RAYLIB_PATCHED_DIR}/src/raymath.h" _RAYMATH)
if(NOT _RAYMATH MATCHES "MatrixNormalize")
    string(REPLACE "RMAPI Matrix MatrixInvert(Matrix mat)"
        "RMAPI Matrix MatrixNormalize(Matrix mat);\nRMAPI Matrix MatrixInvert(Matrix mat)"
        _RAYMATH "${_RAYMATH}")
    string(REPLACE "// Get identity matrix"
        "// Normalize provided matrix\nRMAPI Matrix MatrixNormalize(Matrix mat)\n{\n    Matrix result = { 0 };\n    float det = MatrixDeterminant(mat);\n    result.m0 = mat.m0/det;\n    result.m1 = mat.m1/det;\n    result.m2 = mat.m2/det;\n    result.m3 = mat.m3/det;\n    result.m4 = mat.m4/det;\n    result.m5 = mat.m5/det;\n    result.m6 = mat.m6/det;\n    result.m7 = mat.m7/det;\n    result.m8 = mat.m8/det;\n    result.m9 = mat.m9/det;\n    result.m10 = mat.m10/det;\n    result.m11 = mat.m11/det;\n    result.m12 = mat.m12/det;\n    result.m13 = mat.m13/det;\n    result.m14 = mat.m14/det;\n    result.m15 = mat.m15/det;\n    return result;\n}\n\n// Get identity matrix"
        _RAYMATH "${_RAYMATH}")
    file(WRITE "${RAYLIB_PATCHED_DIR}/src/raymath.h" "${_RAYMATH}")
endif()

# Patch stb_image_resize2.h to disable buggy FP16/SIMD on 32-bit ARM (armeabi-v7a)
file(READ "${RAYLIB_PATCHED_DIR}/src/external/stb_image_resize2.h" _STB_RESIZE)
string(PREPEND _STB_RESIZE "#if (defined(__arm__) || defined(_M_ARM)) && !defined(__aarch64__)\n#ifndef STBIR_NO_SIMD\n#define STBIR_NO_SIMD 1\n#endif\n#endif\n")
file(WRITE "${RAYLIB_PATCHED_DIR}/src/external/stb_image_resize2.h" "${_STB_RESIZE}")

add_subdirectory(${RAYLIB_PATCHED_DIR} raylib-build)

# Register with main target
list(APPEND RING_EXT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/ring_raylib.c")
list(APPEND RING_EXT_INCLUDES "${RAYLIB_PATCHED_DIR}/src" "${RAYGUI_DIR}/src")
list(APPEND RING_EXT_LIBS raylib EGL GLESv2 OpenSLES)
