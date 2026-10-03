# ============================================================================
# libuv Recipe (auto-deployed by ringenv harvest --android)
# ============================================================================
# Multi-platform asynchronous I/O library for Android NDK.

set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty")
set(LIBUV_TAG "v1.48.0")
set(LIBUV_DIR "${THIRDPARTY_DIR}/libuv")

if(NOT EXISTS "${LIBUV_DIR}/CMakeLists.txt")
    message(STATUS "Cloning libuv ${LIBUV_TAG} to ${LIBUV_DIR}...")
    execute_process(
        COMMAND git clone --branch ${LIBUV_TAG} --depth 1
            https://github.com/libuv/libuv.git "${LIBUV_DIR}"
        RESULT_VARIABLE _libuv_clone_res)
    if(NOT _libuv_clone_res EQUAL 0)
        message(FATAL_ERROR "Failed to clone libuv ${LIBUV_TAG}")
    endif()
endif()

set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(LIBUV_BUILD_SHARED OFF CACHE BOOL "" FORCE)
add_subdirectory("${LIBUV_DIR}" "${CMAKE_BINARY_DIR}/libuv" EXCLUDE_FROM_ALL)

# Register with main target
list(APPEND RING_EXT_INCLUDES "${LIBUV_DIR}/include")
list(APPEND RING_EXT_LIBS uv_a)
