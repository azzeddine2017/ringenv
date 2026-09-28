# ringenv - Command: list-remote
# Lists available Ring releases from official GitHub releases

# Constants fallback in case not defined in libcurl.ring
if not isglobal(:CURLOPT_URL)               CURLOPT_URL = 10002 ok
if not isglobal(:CURLOPT_USERAGENT)         CURLOPT_USERAGENT = 10018 ok
if not isglobal(:CURLOPT_FOLLOWLOCATION)    CURLOPT_FOLLOWLOCATION = 52 ok
if not isglobal(:CURLOPT_NOPROGRESS)        CURLOPT_NOPROGRESS = 43 ok
if not isglobal(:CURLOPT_SSL_VERIFYPEER)    CURLOPT_SSL_VERIFYPEER = 64 ok
if not isglobal(:CURLOPT_SSL_VERIFYHOST)    CURLOPT_SSL_VERIFYHOST = 81 ok

# Parse tag names from GitHub Releases JSON response
func parseReleaseTags cJson
    aTags = []
    cTarget = '"tag_name"'
    nTargetLen = len(cTarget)
    nPos = substr(cJson, cTarget)

    while nPos > 0
        cSub = substr(cJson, nPos + nTargetLen)
        nQuote1 = substr(cSub, '"')
        if nQuote1 > 0
            cRest = substr(cSub, nQuote1 + 1)
            nQuote2 = substr(cRest, '"')
            if nQuote2 > 0
                cTag = substr(cRest, 1, nQuote2 - 1)
                # Strip leading 'v' or 'V' prefix if present
                if len(cTag) > 1 and (substr(cTag, 1, 1) = "v" or substr(cTag, 1, 1) = "V")
                    cTag = substr(cTag, 2)
                ok
                if find(aTags, cTag) = 0 and len(cTag) > 0
                    aTags + cTag
                ok
            ok
        ok
        nNext = substr(cSub, cTarget)
        if nNext > 0
            nPos = nPos + nTargetLen + nNext - 1
        else
            nPos = 0
        ok
    end

    return aTags

# Fetch remote releases from GitHub API with fallback
func fetchRemoteReleases
    cApiUrl = "https://api.github.com/repos/ring-lang/ring/releases?per_page=50"
    cResponse = ""

    hCurl = curl_easy_init()
    if ispointer(hCurl)
        curl_easy_setopt(hCurl, CURLOPT_URL, cApiUrl)
        curl_easy_setopt(hCurl, CURLOPT_USERAGENT, "ringenv/1.0")
        curl_easy_setopt(hCurl, CURLOPT_FOLLOWLOCATION, 1)
        curl_easy_setopt(hCurl, CURLOPT_SSL_VERIFYPEER, 0)
        curl_easy_setopt(hCurl, CURLOPT_SSL_VERIFYHOST, 0)
        curl_easy_setopt(hCurl, CURLOPT_NOPROGRESS, 1)

        cResponse = curl_easy_perform_silent(hCurl)
        curl_easy_cleanup(hCurl)
    ok

    aVersions = []
    if cResponse != "" and substr(cResponse, "tag_name") > 0
        aVersions = parseReleaseTags(cResponse)
    ok

    if len(aVersions) > 0
        return aVersions
    ok

    # Known official release versions fallback
    return [
        "1.27", "1.26", "1.25", "1.24", "1.23", "1.22",
        "1.21", "1.20", "1.19", "1.18", "1.17", "1.16",
        "1.15", "1.14", "1.13", "1.12", "1.11", "1.10",
        "1.9", "1.8"
    ]

# Execute list-remote command
func cmdListRemote
    initRingenvDirs()

    ? "================================================="
    ? "Available Ring Versions (GitHub Releases):"
    ? "================================================="

    aReleases = fetchRemoteReleases()

    cVersionsDir = getVersionsDir()
    aInstalled = []
    if direxists(cVersionsDir)
        aItems = dir(cVersionsDir)
        for aItem in aItems
            if aItem[1] != "." and aItem[1] != ".." and aItem[2] = 1
                aInstalled + aItem[1]
            ok
        next
    ok

    for cVer in aReleases
        lInstalled = (find(aInstalled, cVer) > 0)
        if lInstalled
            ? "  * " + cVer + "  [installed]"
        else
            ? "    " + cVer
        ok
    next

    ? "================================================="
    ? "To install a version, run:"
    ? "  ringenv install <version>"
    ? "================================================="
    return true
