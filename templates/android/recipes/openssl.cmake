# ============================================================================
# OpenSSL / wolfSSL Recipe (auto-deployed by ringenv harvest --android)
# ============================================================================
# Provides TLS/Crypto implementation for Android using wolfSSL OpenSSL compatibility layer.

set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty")
set(WOLFSSL_TAG "v5.9.2-stable")

set(BUILD_SHARED_LIBS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# --- wolfSSL (with OpenSSL Extra API enabled) ---
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
set(WOLFSSL_OPENSSLALL yes)
add_subdirectory("${WOLFSSL_DIR}" "${CMAKE_BINARY_DIR}/wolfssl" EXCLUDE_FROM_ALL)

# Register with main target
list(APPEND RING_EXT_INCLUDES "${WOLFSSL_DIR}" "${WOLFSSL_DIR}/wolfssl" "${CMAKE_BINARY_DIR}/wolfssl")
list(APPEND RING_EXT_LIBS wolfssl)
