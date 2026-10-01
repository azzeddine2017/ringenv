# ringenv - Command: hub / libs / community
# Discovery and management of external community libraries created for Ring



# Constants fallback in case not defined in libcurl.ring
if not isglobal(:CURLOPT_URL)               CURLOPT_URL = 10002 ok
if not isglobal(:CURLOPT_USERAGENT)         CURLOPT_USERAGENT = 10018 ok
if not isglobal(:CURLOPT_FOLLOWLOCATION)    CURLOPT_FOLLOWLOCATION = 52 ok
if not isglobal(:CURLOPT_NOPROGRESS)        CURLOPT_NOPROGRESS = 43 ok
if not isglobal(:CURLOPT_SSL_VERIFYPEER)    CURLOPT_SSL_VERIFYPEER = 64 ok
if not isglobal(:CURLOPT_SSL_VERIFYHOST)    CURLOPT_SSL_VERIFYHOST = 81 ok

# Global registry source indicator
cHubRegistrySource = "GitHub Official Registry (Live)"

# Curated list of known community-developed libraries
func getCuratedCommunityLibs
    return [
        [
            :name = "xlsxlib",
            :author = "Azzeddine2017",
            :desc = "Modern XLSX (Excel) workbook creation and manipulation library",
            :site = "github.com/Azzeddine2017/xlsxlib"
        ],
        [
            :name = "docxlib",
            :author = "Azzeddine2017",
            :desc = "DOCX (Word) document generation library with rich formatting",
            :site = "github.com/Azzeddine2017/docxlib"
        ],
        [
            :name = "pptxlib",
            :author = "Azzeddine2017",
            :desc = "PPTX (PowerPoint) presentation generator for Ring",
            :site = "github.com/Azzeddine2017/pptxlib"
        ],
        [
            :name = "pdflib",
            :author = "Azzeddine2017",
            :desc = "Pure Ring PDF document generator and page designer",
            :site = "github.com/Azzeddine2017/pdflib"
        ],
        [
            :name = "svglib",
            :author = "Azzeddine2017",
            :desc = "SVG (Scalable Vector Graphics) creation and vector drawing library",
            :site = "github.com/Azzeddine2017/svglib"
        ],
        [
            :name = "ringqr",
            :author = "Azzeddine2017",
            :desc = "QR Code generator (ISO/IEC 18004 Model 2) supporting SVG, ASCII, PNG",
            :site = "github.com/Azzeddine2017/ringqr"
        ],
        [
            :name = "ringbc",
            :author = "Azzeddine2017",
            :desc = "Barcode generator supporting EAN-13, CODE128, and vector rendering",
            :site = "github.com/Azzeddine2017/ringbc"
        ],
        [
            :name = "ringfm",
            :author = "Azzeddine2017",
            :desc = "Real typography font metrics and text measurement library",
            :site = "github.com/Azzeddine2017/ringfm"
        ],
        [
            :name = "ascii2label",
            :author = "Azzeddine2017",
            :desc = "ASCII text layout design and label formatting utility",
            :site = "github.com/Azzeddine2017/ascii2label"
        ],
        [
            :name = "ring-cffi",
            :author = "ysdragon",
            :desc = "Foreign Function Interface (FFI) to call C dynamic libraries directly",
            :site = "github.com/ysdragon/ring-cffi"
        ],
        [
            :name = "bolt",
            :author = "ysdragon",
            :desc = "Blazing-fast asynchronous HTTP web framework for Ring backend services",
            :site = "github.com/ysdragon/bolt"
        ],
        [
            :name = "dbflib",
            :author = "BertMariani",
            :desc = "Database file (DBF / FPT) reader, parser, and exporter library",
            :site = "github.com/BertMariani/dbflib"
        ],
        [
            :name = "ringquantum",
            :author = "Azzeddine2017",
            :desc = "Quantum computing algorithms and circuit simulator for Ring",
            :site = "github.com/Azzeddine2017/ringquantum"
        ],
        [
            :name = "ringscript",
            :author = "mayouni",
            :desc = "Run Ring programs and virtual machine inside web browsers",
            :site = "github.com/mayouni/ringscript"
        ],
        [
            :name = "ringserv",
            :author = "mayouni",
            :desc = "Modern stand-alone microservices and application server",
            :site = "github.com/mayouni/ringserv"
        ],
        [
            :name = "ring2apk",
            :author = "ysdragon",
            :desc = "Build Android APK packages directly from Ring applications",
            :site = "github.com/ysdragon/ring2apk"
        ],
        [
            :name = "ring-libsql",
            :author = "ysdragon",
            :desc = "LibSQL client library for Ring with SQLite compatibility",
            :site = "github.com/ysdragon/ring-libsql"
        ],
        [
            :name = "ring-python",
            :author = "ysdragon",
            :desc = "Python language bindings and runtime bridge for Ring",
            :site = "github.com/ysdragon/ring-python"
        ],
        [
            :name = "steamlib",
            :author = "ringpackages",
            :desc = "Steamworks API integration and Steam achievements for Windows",
            :site = "github.com/ringpackages/steamlib"
        ],
        [
            :name = "emoji",
            :author = "ringeg",
            :desc = "Lightweight Unicode emoji processing, translation, and rendering",
            :site = "github.com/ringeg/emoji"
        ],
        [
            :name = "ringenv",
            :author = "Azzeddine2017",
            :desc = "Isolated virtual environment and multi-version manager for Ring",
            :site = "github.com/Azzeddine2017/ringenv"
        ]
    ]



# Case-insensitive field extractor from a registry block
func extractRegistryField cBlock, cFieldName
    cLowerBlock = lower(cBlock)
    cSearch = ":" + lower(cFieldName)
    nPos = substr(cLowerBlock, cSearch)
    if nPos = 0
        return ""
    ok
    cSub = substr(cBlock, nPos)
    nEqual = substr(cSub, "=")
    if nEqual = 0
        return ""
    ok
    cAfterEqual = substr(cSub, nEqual + 1)
    nQ1 = substr(cAfterEqual, '"')
    if nQ1 = 0
        return ""
    ok
    cAfterQ1 = substr(cAfterEqual, nQ1 + 1)
    nQ2 = substr(cAfterQ1, '"')
    if nQ2 = 0
        return ""
    ok
    return substr(cAfterQ1, 1, nQ2 - 1)

# Fetch registry from GitHub with local and curated fallbacks (Silent & Fast)
func fetchRegistryLibs
    initRingenvDirs()
    cCachePath = getCacheDir() + "/registry.ring"
    cUrl = "https://raw.githubusercontent.com/ring-lang/ring/master/tools/ringpm/registry/registry.ring"

    # 1. Download silently if cache does not exist yet
    if not fexists(cCachePath)
        cContent = fetchUrlContentSilent(cUrl)
        if cContent != "" and substr(cContent, "aPackagesRegistry") > 0
            write(cCachePath, cContent)
            cHubRegistrySource = "GitHub Official Registry"
        ok
    else
        cHubRegistrySource = "Local Cache"
    ok

    # 2. Read and parse from cached file if available
    if fexists(cCachePath)
        cContent = read(cCachePath)
        if cContent != "" and substr(cContent, "aPackagesRegistry") > 0
            aParsed = parseRemoteRegistry(cContent)
            if len(aParsed) > 0
                return aParsed
            ok
        ok
    ok

    # 3. Fallback to active Ring installation's local registry file
    cLocalReg = exefolder() + "/../tools/ringpm/registry/registry.ring"
    if fexists(cLocalReg)
        cContent = read(cLocalReg)
        if cContent != "" and substr(cContent, "aPackagesRegistry") > 0
            aParsed = parseRemoteRegistry(cContent)
            if len(aParsed) > 0
                cHubRegistrySource = "Local Ring Installation Registry"
                return aParsed
            ok
        ok
    ok

    # 4. Fallback to curated list if completely offline
    cHubRegistrySource = "Offline Curated Community List"
    return getCuratedCommunityLibs()

# Parse registry items looking for all packages in the registry
func parseRemoteRegistry cContent
    aResults = []
    nStart = substr(cContent, "[")

    while nStart > 0
        cSub = substr(cContent, nStart + 1)
        nEnd = substr(cSub, "]")
        if nEnd = 0
            exit
        ok
        cBlock = substr(cSub, 1, nEnd - 1)

        cName = extractRegistryField(cBlock, "name")
        if cName != "" and cName != "name"
            cDesc = extractRegistryField(cBlock, "description")
            cAuthor = extractRegistryField(cBlock, "ProviderUserName")
            if cAuthor = ""
                cAuthor = extractRegistryField(cBlock, "providerusername")
            ok
            if cAuthor = ""
                cAuthor = "ringpackages"
            ok

            # Enrich author and description from curated community list if missing or default
            aCurated = getCuratedCommunityLibs()
            for aCur in aCurated
                if lower(aCur[:name]) = lower(cName)
                    if cAuthor = "ringpackages" or cAuthor = ""
                        cAuthor = aCur[:author]
                    ok
                    if aCur[:desc] != "" and cDesc = ""
                        cDesc = aCur[:desc]
                    ok
                    exit
                ok
            next

            cSite = extractRegistryField(cBlock, "providerwebsite")
            if cSite = ""
                cSite = "github.com"
            ok

            aResults + [
                :name = cName,
                :author = cAuthor,
                :desc = cDesc,
                :site = cSite + "/" + cAuthor + "/" + cName
            ]
        ok

        nNext = substr(cSub, "[")
        if nNext > 0
            nStart = nStart + nNext
        else
            nStart = 0
        ok
    end

    # Append any curated community libraries not present in remote registry
    for aCur in getCuratedCommunityLibs()
        lFound = false
        for aItem in aResults
            if lower(aItem[:name]) = lower(aCur[:name])
                lFound = true
                exit
            ok
        next
        if not lFound
            aResults + aCur
        ok
    next

    if len(aResults) = 0
        return getCuratedCommunityLibs()
    ok
    return aResults

# Determine whether a package is a community-developed external library
func isCommunityLib aLib
    cAuthor = lower(aLib[:author])
    cName = lower(aLib[:name])

    # 1. Any package authored by someone other than ringpackages
    if cAuthor != "" and cAuthor != "ringpackages"
        return true
    ok

    # 2. Any package in curated community list
    for aCur in getCuratedCommunityLibs()
        if lower(aCur[:name]) = cName
            return true
        ok
    next

    return false

# Filter libraries based on mode: community (default), official, all, or search
func filterLibs aLibs, cMode
    if cMode = "all" or cMode = "search"
        return aLibs
    ok

    aFiltered = []
    for aLib in aLibs
        lIsComm = isCommunityLib(aLib)
        if cMode = "community" and lIsComm
            aFiltered + aLib
        but cMode = "official" and not lIsComm
            aFiltered + aLib
        ok
    next
    return aFiltered

# Display list of community libraries and packages
func cmdHub aArgs
    cMode = "community"
    cSubCmd = ""
    cQuery = ""

    # Parse flags
    for cArg in aArgs
        cLowerArg = lower(cArg)
        if cLowerArg = "--all" or cLowerArg = "-a"
            cMode = "all"
        but cLowerArg = "--official" or cLowerArg = "-o"
            cMode = "official"
        ok
    next

    # Filter out flags from arguments
    aFiltered = []
    for cArg in aArgs
        cLowerArg = lower(cArg)
        if cLowerArg != "--all" and cLowerArg != "-a" and cLowerArg != "--official" and cLowerArg != "-o" and cLowerArg != "--no-color"
            aFiltered + cArg
        ok
    next

    if len(aFiltered) >= 2
        cSubCmd = lower(aFiltered[2])
    ok
    if len(aFiltered) >= 3
        cQuery = lower(aFiltered[3])
    ok

    # If sub-command is one of the modes
    if cSubCmd = "all"
        cMode = "all"
        cSubCmd = ""
    but cSubCmd = "official"
        cMode = "official"
        cSubCmd = ""
    ok

    # Handle info command
    if cSubCmd = "info"
        if cQuery = ""
            ? uiError("Error: Missing package name or number.")
            ? "Usage: ringenv hub info <# or name>"
            return false
        ok
        return showLibInfo(cQuery)
    ok

    # Handle install command
    if cSubCmd = "install" or cSubCmd = "add"
        if cQuery = ""
            ? uiError("Error: Missing package name or number to install.")
            ? "Usage: ringenv hub install <# or name>"
            return false
        ok
        return installCommunityLib(cQuery)
    ok

    # Handle search or direct query
    if cSubCmd = "search" or cSubCmd = "find"
        cMode = "search"
        # cQuery is already aFiltered[3]
    but cSubCmd != "" and cSubCmd != "list" and cSubCmd != "hub" and cSubCmd != "libs"
        cMode = "search"
        cQuery = cSubCmd
    ok

    aAllLibs = fetchRegistryLibs()
    aLibs = filterLibs(aAllLibs, cMode)

    if cMode = "community"
        uiBanner("Ring Community Libraries Hub", "External libraries & packages developed by the Ring community")
    but cMode = "official"
        uiBanner("Ring Official Packages & Samples", "Core extensions, tools, games, and samples by @ringpackages")
    but cMode = "all"
        uiBanner("Ring Package Registry (All)", "Complete package registry for the Ring programming language")
    else
        uiBanner("Ring Hub Search Results", "Showing matching libraries for: '" + cQuery + "'")
    ok

    ? "  " + uiStyle("Source: ", C_DIM) + uiStyle(cHubRegistrySource, C_BOLD + C_BYELLOW)
    ? ""

    ? "  " + uiStyle("  #", C_BOLD + C_WHITE) + "  " + uiStyle("PACKAGE", C_BOLD + C_WHITE) + "              " + uiStyle("AUTHOR", C_BOLD + C_WHITE) + "           " + uiStyle("DESCRIPTION", C_BOLD + C_WHITE)
    uiDivider()

    nShown = 0
    for i = 1 to len(aLibs)
        aLib = aLibs[i]
        cName = aLib[:name]
        cAuthor = aLib[:author]
        cDesc = aLib[:desc]

        # Filter by search query if in search mode
        if cMode = "search" and cQuery != ""
            cSearchTarget = lower(cName + " " + cAuthor + " " + cDesc)
            if substr(cSearchTarget, cQuery) = 0
                loop
            ok
        ok

        nShown = nShown + 1

        # Format row index column (3 chars right-aligned)
        cIdx = "" + i
        if len(cIdx) = 1
            cIdx = "  " + cIdx
        but len(cIdx) = 2
            cIdx = " " + cIdx
        ok

        # Format package name column (20 chars)
        cNameCol = cName
        while len(cNameCol) < 20
            cNameCol = cNameCol + " "
        end

        # Format author column (16 chars)
        cAuthorCol = "@" + cAuthor
        while len(cAuthorCol) < 16
            cAuthorCol = cAuthorCol + " "
        end

        # Truncate description if too long
        if len(cDesc) > 50
            cDesc = substr(cDesc, 1, 47) + "..."
        ok

        ? "  " + uiStyle(cIdx, C_BYELLOW) + "  " + uiStyle(cNameCol, C_BOLD + C_BCYAN) + " " + uiAuthor(cAuthorCol) + " " + uiStyle(cDesc, C_DIM)
    next

    uiDivider()

    if cMode = "search"
        if nShown = 0
            ? "  " + uiInfo("Found 0 matching libraries for: '" + cQuery + "'")
        else
            ? "  " + uiInfo("Found " + nShown + " matching libraries.")
        ok
    but cMode = "community"
        ? "  " + uiInfo("Showing " + nShown + " community libraries. (Use 'ringenv hub --all' for all packages)")
    else
        ? "  " + uiInfo("Showing " + nShown + " packages.")
    ok

    ? ""
    ? "  " + uiStyle("Usage Commands:", C_BOLD + C_WHITE)
    ? "    " + uiStyle("ringenv hub install <# or name>", C_BOLD + C_BCYAN) + "   Install library by row number or name"
    ? "    " + uiStyle("ringenv hub info <# or name>", C_BOLD + C_BCYAN) + "      View library details & repository README"
    ? "    " + uiStyle("ringenv hub search <query>", C_BCYAN) + "        Search across all packages by keyword"
    if cMode = "community"
        ? "    " + uiStyle("ringenv hub --all", C_DIM) + "                  Show all 250+ packages (including games & samples)"
        ? "    " + uiStyle("ringenv hub --official", C_DIM) + "             Show official Ring packages and samples only"
    else
        ? "    " + uiStyle("ringenv hub", C_DIM) + "                        Show community libraries only (default)"
    ok
    ? uiStyle("======================================================================", C_CYAN)
    return true

# Resolve library by numeric index or package name
func findLibByIdOrName aLibs, cIdOrName
    cTrimmed = trim(cIdOrName)
    if len(cTrimmed) = 0
        return []
    ok

    # Check if input is a numeric index
    lIsNum = true
    for k = 1 to len(cTrimmed)
        nCode = ascii(substr(cTrimmed, k, 1))
        if nCode < 48 or nCode > 57
            lIsNum = false
            exit
        ok
    next

    if lIsNum
        nIdx = number(cTrimmed)
        if nIdx >= 1 and nIdx <= len(aLibs)
            return aLibs[nIdx]
        ok
    ok

    # Search by package name (case-insensitive)
    cSearch = lower(cTrimmed)
    for aLib in aLibs
        if lower(aLib[:name]) = cSearch
            return aLib
        ok
    next

    return []

# Fetch raw URL text silently using libcurl
func fetchUrlContentSilent cUrl
    hCurl = curl_easy_init()
    if ispointer(hCurl)
        curl_easy_setopt(hCurl, CURLOPT_URL, cUrl)
        curl_easy_setopt(hCurl, CURLOPT_USERAGENT, "ringenv/" + getRingenvVersion())
        curl_easy_setopt(hCurl, CURLOPT_FOLLOWLOCATION, 1)
        curl_easy_setopt(hCurl, CURLOPT_SSL_VERIFYPEER, 0)
        curl_easy_setopt(hCurl, CURLOPT_SSL_VERIFYHOST, 0)
        curl_easy_setopt(hCurl, CURLOPT_NOPROGRESS, 1)

        cResult = curl_easy_perform_silent(hCurl)
        curl_easy_cleanup(hCurl)
        return cResult
    ok
    return ""

# Extract overview paragraph from markdown README content
func extractReadmeOverview cContent
    aLines = split(cContent, nl)
    cOverview = ""
    nCollected = 0
    lStarted = false

    for cLine in aLines
        cTrimmed = trim(cLine)

        # Skip empty lines before body starts
        if cTrimmed = ""
            if lStarted and nCollected >= 2
                exit
            ok
            loop
        ok

        # Skip HTML tags (e.g. <div align="center">, </div>, <p>, <img ...>, etc.)
        if substr(cTrimmed, 1, 1) = "<" and substr(cTrimmed, len(cTrimmed), 1) = ">"
            loop
        ok
        cLower = lower(cTrimmed)
        if substr(cLower, 1, 4) = "<div" or substr(cLower, 1, 5) = "</div" or substr(cLower, 1, 4) = "<img" or substr(cLower, 1, 7) = "<center" or substr(cLower, 1, 8) = "</center" or substr(cLower, 1, 2) = "<p" or substr(cLower, 1, 3) = "</p"
            loop
        ok

        # Skip markdown reference links (e.g. [ring]: https://...)
        if substr(cTrimmed, 1, 1) = "[" and substr(cTrimmed, "]: http") > 0
            loop
        ok

        # Skip badge images [![...](...)] and inline images ![...](...)
        if substr(cTrimmed, "[![") > 0 or substr(cTrimmed, "![") = 1
            loop
        ok

        # Skip headers before body starts, and stop if a new section starts
        if substr(cTrimmed, 1, 1) = "#"
            if not lStarted
                loop
            else
                exit
            ok
        ok

        # Handle setext H1/H2 underlines (e.g. "Title" followed by "===" or "---")
        if substr(cTrimmed, 1, 3) = "===" or (not lStarted and substr(cTrimmed, 1, 3) = "---")
            if nCollected = 1
                cOverview = ""
                nCollected = 0
                lStarted = false
            ok
            loop
        ok

        # Stop when reaching horizontal dividers (--- or ***)
        if lStarted and (substr(cTrimmed, 1, 3) = "---" or substr(cTrimmed, 1, 3) = "***")
            exit
        ok

        # Clean blockquote quote character '>'
        if substr(cTrimmed, 1, 1) = ">"
            cTrimmed = trim(substr(cTrimmed, 2))
        ok

        if cTrimmed != ""
            lStarted = true
            if cOverview != ""
                cOverview = cOverview + nl + "    " + cTrimmed
            else
                cOverview = "    " + cTrimmed
            ok
            nCollected = nCollected + 1
            if nCollected >= 6
                exit
            ok
        ok
    next

    return cOverview

# Fetch repository README description (local or GitHub)
func fetchRepoReadmeDescription cAuthor, cPkgName
    # Check local packages first
    aLocalPaths = [
        "tools/ringpm/packages/" + cPkgName + "/README.md",
        "packages/" + cPkgName + "/README.md",
        exefolder() + "/../tools/ringpm/packages/" + cPkgName + "/README.md"
    ]
    for cPath in aLocalPaths
        if fexists(cPath)
            cLocal = read(cPath)
            if cLocal != ""
                cOverview = extractReadmeOverview(cLocal)
                if cOverview != ""
                    return cOverview
                ok
            ok
        ok
    next

    # Fetch from GitHub remote repository
    cOwner = cAuthor
    if cOwner = "" or cOwner = "ringpackages"
        cOwner = "ringpackages"
    ok

    aUrls = [
        "https://raw.githubusercontent.com/" + cOwner + "/" + cPkgName + "/master/README.md",
        "https://raw.githubusercontent.com/" + cOwner + "/" + cPkgName + "/main/README.md",
        "https://raw.githubusercontent.com/ringpackages/" + cPkgName + "/master/README.md"
    ]

    for cUrl in aUrls
        cContent = fetchUrlContentSilent(cUrl)
        if cContent != "" and substr(cContent, "404") = 0
            cOverview = extractReadmeOverview(cContent)
            if cOverview != ""
                return cOverview
            ok
        ok
    next

    return ""

# Show detailed info about a specific library
func showLibInfo cIdOrName
    aAllLibs = fetchRegistryLibs()
    aCommLibs = filterLibs(aAllLibs, "community")

    # If numeric, first search in community libs (default table view)
    aLib = findLibByIdOrName(aCommLibs, cIdOrName)
    if len(aLib) = 0
        aLib = findLibByIdOrName(aAllLibs, cIdOrName)
    ok

    if len(aLib) > 0
        uiBanner("Library Details: " + aLib[:name], "Developed by @" + aLib[:author])
        ? ""
        ? "  " + uiStyle("Name:        ", C_BOLD + C_WHITE) + uiStyle(aLib[:name], C_BOLD + C_BCYAN)
        ? "  " + uiStyle("Author:      ", C_BOLD + C_WHITE) + uiAuthor(aLib[:author])
        ? "  " + uiStyle("Repository:  ", C_BOLD + C_WHITE) + uiStyle("https://" + aLib[:site], C_UNDERLINE + C_BCYAN)
        ? "  " + uiStyle("Registry:    ", C_BOLD + C_WHITE) + uiStyle(aLib[:desc], C_DIM)

        cRepoOverview = fetchRepoReadmeDescription(aLib[:author], aLib[:name])
        if cRepoOverview != ""
            ? ""
            ? "  " + uiStyle("Repository Overview (from README.md):", C_BOLD + C_BYELLOW)
            uiDivider()
            ? uiStyle(cRepoOverview, C_WHITE)
            uiDivider()
        ok

        ? ""
        ? "  " + uiStyle("Installation Command:", C_BOLD + C_BGREEN)
        if aLib[:author] != "" and aLib[:author] != "ringpackages"
            ? "    " + uiStyle("ringpm install " + aLib[:name] + " from " + aLib[:author], C_BOLD + C_BYELLOW)
        else
            ? "    " + uiStyle("ringpm install " + aLib[:name], C_BOLD + C_BYELLOW)
        ok
        ? "    " + uiStyle("ringenv hub install " + aLib[:name], C_BOLD + C_BCYAN)
        uiDivider()
        return true
    ok

    ? uiError("Error: Package '" + cIdOrName + "' was not found in registry.")
    ? "Run 'ringenv hub' to see community libraries or 'ringenv hub --all' for all packages."
    return false

# Install a community library using ringpm
func installCommunityLib cIdOrName
    aAllLibs = fetchRegistryLibs()
    aCommLibs = filterLibs(aAllLibs, "community")

    aLib = findLibByIdOrName(aCommLibs, cIdOrName)
    if len(aLib) = 0
        aLib = findLibByIdOrName(aAllLibs, cIdOrName)
    ok

    if len(aLib) = 0
        ? uiError("Error: Package '" + cIdOrName + "' was not found in registry.")
        ? "Run 'ringenv hub' to see community libraries or 'ringenv hub --all' for all packages."
        return false
    ok

    cName = aLib[:name]
    cAuthor = aLib[:author]

    # Sync cached registry to active ringpm if present
    cCachedReg = getCacheDir() + "/registry.ring"
    cEnvReg = exefolder() + "/../tools/ringpm/registry/registry.ring"
    if fexists(cCachedReg) and direxists(exefolder() + "/../tools/ringpm/registry")
        copyFile(cCachedReg, cEnvReg)
    ok

    uiBanner("Installing Package", cName + " by @" + cAuthor)
    ? ""

    cCmd = "ringpm install " + cName
    if cAuthor != "" and cAuthor != "ringpackages"
        cCmd = cCmd + " from " + cAuthor
    ok

    ? "  " + uiStyle("Executing: ", C_BOLD + C_WHITE) + uiStyle(cCmd, C_BOLD + C_BYELLOW)
    ? ""

    system(cCmd)

    ? ""
    ? uiSuccess("Finished installation request for: " + cName)
    return true
