# ============================================================================
# libcurl + wolfSSL Recipe (auto-deployed by ringenv harvest --android)
# ============================================================================
# Builds wolfSSL (TLS) and libcurl (HTTP) from source for Android NDK.
# wolfSSL is GPLv2 or commercial — check against your app's license.

set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty")

set(CURL_TAG "curl-8_22_0")
set(WOLFSSL_TAG "v5.9.2-stable")

set(BUILD_SHARED_LIBS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# --- wolfSSL (TLS backend for curl) ---
set(WOLFSSL_DIR "${THIRDPARTY_DIR}/wolfssl")
if(NOT EXISTS "${WOLFSSL_DIR}/CMakeLists.txt")
    message(STATUS "Cloning wolfSSL ${WOLFSSL_TAG} to ${WOLFSSL_DIR}...")
    execute_process(
        COMMAND git clone --branch ${WOLFSSL_TAG} --depth 1
            https://github.com/wolfSSL/wolfssl.git "${WOLFSSL_DIR}"
        RESULT_VARIABLE _wolfssl_clone_res)
    if(NOT _wolfssl_clone_res EQUAL 0)
        message(FATAL_ERROR "Failed to clone wolfSSL ${WOLFSSL_TAG}")
    endif()
endif()
set(WOLFSSL_EXAMPLES no)
set(WOLFSSL_CRYPT_TESTS no)
set(WOLFSSL_SYS_CA_CERTS yes)
set(WOLFSSL_OPENSSLEXTRA yes)
add_subdirectory("${WOLFSSL_DIR}" "${CMAKE_BINARY_DIR}/wolfssl" EXCLUDE_FROM_ALL)

# Pre-seed so curl's FindWolfSSL finds the in-tree target
set(WOLFSSL_INCLUDE_DIR "${WOLFSSL_DIR}")
set(WOLFSSL_LIBRARY wolfssl)

# --- libcurl (HTTP client) ---
set(CURL_DIR "${THIRDPARTY_DIR}/curl")
if(NOT EXISTS "${CURL_DIR}/CMakeLists.txt")
    message(STATUS "Cloning libcurl ${CURL_TAG} to ${CURL_DIR}...")
    execute_process(
        COMMAND git clone --branch ${CURL_TAG} --depth 1
            https://github.com/curl/curl.git "${CURL_DIR}"
        RESULT_VARIABLE _curl_clone_res)
    if(NOT _curl_clone_res EQUAL 0)
        message(FATAL_ERROR "Failed to clone libcurl ${CURL_TAG}")
    endif()
endif()
set(BUILD_CURL_EXE OFF)
set(BUILD_LIBCURL_DOCS OFF)
set(BUILD_MISC_DOCS OFF)
set(CURL_DISABLE_INSTALL ON)
set(CURL_USE_WOLFSSL ON)
set(CURL_CA_NATIVE ON)
set(CURL_BROTLI OFF)
set(CURL_ZSTD OFF)
set(USE_NGHTTP2 OFF)
set(CURL_DISABLE_LDAP ON)
set(USE_LIBIDN2 OFF)
set(CURL_USE_LIBPSL OFF)
set(CURL_USE_LIBSSH2 OFF)
add_subdirectory("${CURL_DIR}" "${CMAKE_BINARY_DIR}/curl" EXCLUDE_FROM_ALL)

# Register with main target
list(APPEND RING_EXT_INCLUDES "${WOLFSSL_DIR}" "${CMAKE_BINARY_DIR}/wolfssl")
list(APPEND RING_EXT_LIBS CURL::libcurl wolfssl)
