# ============================================================================
# WebView Recipe (auto-deployed by ringenv harvest --android)
# ============================================================================
# Builds ring_webview for Android from ysdragon/webview.

set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty")

set(WEBVIEW_TAG "v1.6.1")

set(WEBVIEW_DIR "${THIRDPARTY_DIR}/webview")
if(NOT EXISTS "${WEBVIEW_DIR}/CMakeLists.txt")
    message(STATUS "Cloning ring_webview ${WEBVIEW_TAG} to ${WEBVIEW_DIR}...")
    execute_process(
        COMMAND git clone --branch ${WEBVIEW_TAG} --depth 1
            --recurse-submodules
            https://github.com/ysdragon/webview.git "${WEBVIEW_DIR}"
        RESULT_VARIABLE _clone_res)
    if(NOT _clone_res EQUAL 0)
        message(FATAL_ERROR "Failed to clone ring_webview ${WEBVIEW_TAG}")
    endif()
endif()

add_subdirectory("${WEBVIEW_DIR}" "${CMAKE_BINARY_DIR}/ring_webview")

# Register with main target
list(APPEND RING_EXT_LIBS ring_webview_android)
