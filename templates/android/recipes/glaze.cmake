# ============================================================================
# Glaze Recipe (auto-deployed by ringenv harvest --android)
# ============================================================================
# Header-only C++23 JSON library from stephenberry/glaze.

set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty")

set(GLAZE_TAG "v7.5.0")

set(GLAZE_DIR "${THIRDPARTY_DIR}/glaze")
if(NOT EXISTS "${GLAZE_DIR}/CMakeLists.txt")
    message(STATUS "Cloning Glaze ${GLAZE_TAG} to ${GLAZE_DIR}...")
    execute_process(
        COMMAND git clone --branch ${GLAZE_TAG} --depth 1
            https://github.com/stephenberry/glaze.git "${GLAZE_DIR}"
        RESULT_VARIABLE _glaze_clone_res)
    if(NOT _glaze_clone_res EQUAL 0)
        message(FATAL_ERROR "Failed to clone Glaze ${GLAZE_TAG}")
    endif()
endif()

# Register with main target (header-only: include dir only, no link target)
list(APPEND RING_EXT_INCLUDES "${GLAZE_DIR}/include")

# Glaze requires C++23
set(RING_EXT_CXX_STANDARD 23 CACHE STRING "" FORCE)
