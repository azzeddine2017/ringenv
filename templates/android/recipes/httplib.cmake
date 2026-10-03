# ============================================================================
# cpp-httplib Recipe (auto-deployed by ringenv harvest --android)
# ============================================================================
# C++17 HTTP/HTTPS client and server library (yhirose/cpp-httplib).

# httplib requires C++17
set(RING_EXT_CXX_STANDARD 17 CACHE STRING "" FORCE)

# Link zlib (standard on Android NDK)
list(APPEND RING_EXT_LIBS z)
