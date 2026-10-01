# ringenv - Command: harvest
# Harvests built-in libraries, C/C++ extensions, and GUI runtimes (Qt/Raylib/GameEngine)
# from the host full Ring installation directly into the isolated virtual environment

load "stdlibcore.ring"

# Main entry point for 'ringenv harvest'
func cmdHarvest aArgs
    cCaller = getCallerDir()
    if cCaller != "" and direxists(cCaller)
        chdir(cCaller)
    ok

    if len(aArgs) < 2
        showHarvestHelp()
        return
    ok

    cSub = lower(aArgs[2])

    switch cSub
        on "help"
            showHarvestHelp()
        on "--help"
            showHarvestHelp()
        on "-h"
            showHarvestHelp()
        on "list"
            harvestList()
        on "scan"
            harvestScan()
        on "--scan"
            harvestScan()
        on "-s"
            harvestScan()
        other
            harvestRun(aArgs)
    off

# Display help and usage instructions for harvest command
func showHarvestHelp
    uiBanner("ringenv harvest - Global Ring Library Harvester", "Import full-install extensions & GUI runtimes into virtual environments")
    ? ""
    ? "  " + uiStyle("Usage:", C_BOLD + C_WHITE)
    ? "    " + uiStyle("ringenv harvest <library_or_extension>", C_BOLD + C_BYELLOW)
    ? "    " + uiStyle("ringenv harvest <lib> --android", C_BOLD + C_BYELLOW)
    ? "    " + uiStyle("ringenv harvest scan", C_BOLD + C_BYELLOW)
    ? "    " + uiStyle("ringenv harvest -f <manifest_file>", C_BOLD + C_BYELLOW)
    ? "    " + uiStyle("ringenv harvest list", C_BOLD + C_BYELLOW)
    ? ""
    ? "  " + uiStyle("Popular Harvestable Targets:", C_BOLD + C_WHITE)
    ? "    " + uiStyle("guilib / lightguilib / qt", C_BOLD + C_BCYAN) + "  RingQt GUI framework, Qt5 runtime DLLs & platform plugins"
    ? "    " + uiStyle("raylib", C_BOLD + C_BCYAN) + "                    Raylib 5 2D/3D hardware-accelerated game engine"
    ? "    " + uiStyle("gameengine / allegro", C_BOLD + C_BCYAN) + "      Ring 2D Game Engine and Allegro multimedia runtime"
    ? "    " + uiStyle("libui / nappgui", C_BOLD + C_BCYAN) + "           Lightweight native C GUI widgets"
    ? "    " + uiStyle("libuv / threads", C_BOLD + C_BCYAN) + "           Asynchronous I/O and multi-threading runtimes"
    ? "    " + uiStyle("freeglut / opengl", C_BOLD + C_BCYAN) + "         OpenGL 1.1-4.6 and FreeGLUT graphics bindings"
    ? "    " + uiStyle("winapi / winlib", C_BOLD + C_BCYAN) + "           Windows Win32 API, Registry and system integrations"
    ? ""
    ? "  " + uiStyle("Examples:", C_BOLD + C_WHITE)
    ? "    ringenv harvest guilib"
    ? "    ringenv harvest raylib"
    ? "    ringenv harvest -f env_packages.txt"
    ? "    ringenv harvest list"
    ? uiStyle("======================================================================", C_CYAN)

# Locate the host full Ring installation
func getHostRingDir
    # 1. Environment variable if set by ringenv.bat
    cHostEnv = sysget("HOST_RING_DIR")
    if cHostEnv != "" and direxists(cHostEnv)
        return normalizePath(cHostEnv)
    ok

    # 2. Derive from ring executable directory
    cBinDir = exefolder()
    cParent = normalizePath(cBinDir + "/..")
    if direxists(cParent + "/libraries") and (direxists(cParent + "/extensions") or direxists(cParent + "/bin/load"))
        return cParent
    ok

    # 3. Standard Windows installation paths
    if iswindows()
        aCommonPaths = ["C:/ring", "D:/ring", "E:/ring", "C:/Program Files/Ring"]
        for cP in aCommonPaths
            if direxists(cP + "/libraries") and direxists(cP + "/extensions")
                return normalizePath(cP)
            ok
        next
    ok

    # 4. Standard Linux / macOS paths
    aUnixPaths = ["/usr/local/ring", "/opt/ring", "/usr/share/ring"]
    for cP in aUnixPaths
        if direxists(cP + "/libraries") and direxists(cP + "/extensions")
            return normalizePath(cP)
        ok
    next

    return ""

# Locate the target virtual environment
func getTargetVenvDir
    # 1. Check RVENV_DIR environment variable
    cVenv = sysget("RVENV_DIR")
    if cVenv != "" and direxists(cVenv)
        return normalizePath(cVenv)
    ok

    # 2. Check local project directory for .rvenv or rvenv
    cCaller = getCallerDir()
    if direxists(cCaller + "/.rvenv")
        return normalizePath(cCaller + "/.rvenv")
    but direxists(cCaller + "/rvenv")
        return normalizePath(cCaller + "/rvenv")
    ok

    return ""

# List all harvestable libraries from the host installation
func harvestList
    cHost = getHostRingDir()
    if cHost = ""
        ? uiError("Could not locate a full Ring installation on this system.")
        return false
    ok

    uiBanner("Available Host Libraries & Extensions", "Host: " + toNativePath(cHost))
    ? ""
    ? "  " + uiStyle("CATEGORY", C_BOLD + C_WHITE) + "        " + uiStyle("LIBRARY / EXTENSION", C_BOLD + C_WHITE) + "    " + uiStyle("DESCRIPTION", C_BOLD + C_WHITE)
    uiDivider()

    aCatalog = [
        ["GUI & Widgets", "guilib / lightguilib", "Full Qt5 framework, widgets, webview, multimedia"],
        ["GUI & Widgets", "libui", "Ultra-lightweight native C desktop GUI"],
        ["GUI & Widgets", "nappgui", "Cross-platform lightweight native GUI"],
        ["Game & 3D",     "raylib", "Modern 2D/3D hardware-accelerated game engine"],
        ["Game & 3D",     "gameengine", "Ring 2D Game Engine powered by Allegro"],
        ["Game & 3D",     "freeglut / opengl", "OpenGL 1.1-4.6 3D graphics and FreeGLUT windowing"],
        ["System & Async","threads", "RingThreadPro, POSIX threads & concurrency"],
        ["System & Async","libuv", "Asynchronous event-driven I/O engine"],
        ["System & Async","subprocess", "Process spawning and inter-process communication"],
        ["System & Async","winapi / winlib", "Windows Win32 system APIs and Registry management"],
        ["Web & Server",  "weblib", "Fast CGI web framework and HTTP routing"],
        ["Web & Server",  "httplib", "C++ HTTP/HTTPS server and client library"],
        ["Math & Science","ringtensor", "Multi-dimensional tensor algebra and matrix math"],
        ["Math & Science","bignumber", "Arbitrary precision arithmetic and big numbers"],
        ["General",       "foxring", "FoxPro syntax and data manipulation compatibility"],
        ["General",       "fastpro", "High-performance optimized collection utilities"]
    ]

    for aItem in aCatalog
        cCat = aItem[1]
        cLib = aItem[2]
        cDesc = aItem[3]
        while len(cCat) < 16 cCat = cCat + " " end
        while len(cLib) < 26 cLib = cLib + " " end
        ? "  " + uiStyle(cCat, C_CYAN) + uiStyle(cLib, C_BOLD + C_WHITE) + uiStyle(cDesc, C_DIM)
    next

    uiDivider()
    ? "  Run " + uiStyle("ringenv harvest <library>", C_BOLD + C_BYELLOW) + " to import any library into your active environment."
    ? ""
    return true

# Execute harvest command for one or more targets
func harvestRun aArgs
    cHost = getHostRingDir()
    if cHost = ""
        ? uiError("Could not locate a full Ring installation on this system.")
        ? "Please ensure Ring Full Installation is installed (e.g. in C:\ring)."
        return false
    ok

    cTargetVenv = getTargetVenvDir()
    if cTargetVenv = ""
        ? uiError("No active virtual environment detected.")
        ? "Please activate a virtual environment first, e.g.:"
        ? "  " + uiStyle(".rvenv\Scripts\activate.bat", C_BOLD + C_BYELLOW)
        return false
    ok

    # Parse arguments: single package, multiple packages, or manifest file
    aTargets = []
    lFileMode = false
    lAndroidMode = false
    cManifestFile = ""

    nLen = len(aArgs)
    i = 2
    while i <= nLen
        cArg = aArgs[i]
        if cArg = "-f" or cArg = "--file"
            if i < nLen
                i = i + 1
                cManifestFile = aArgs[i]
                lFileMode = true
            ok
        but cArg = "--android" or cArg = "--native" or cArg = "-a"
            lAndroidMode = true
        but substr(cArg, "-f=") > 0
            cManifestFile = substr(cArg, 4)
            lFileMode = true
        but substr(cArg, "--file=") > 0
            cManifestFile = substr(cArg, 8)
            lFileMode = true
        but substr(cArg, 1, 1) != "-"
            aTargets + cArg
        ok
        i = i + 1
    end

    if lFileMode
        if not fexists(cManifestFile)
            ? uiError("Manifest file not found: " + cManifestFile)
            return false
        ok
        cFileContent = read(cManifestFile)
        aLines = split(cFileContent, nl)
        for cLine in aLines
            cTrim = trim(cLine)
            if cTrim = "" or substr(cTrim, 1, 1) = "#" or substr(cTrim, 1, 2) = "//"
                loop
            ok
            aTargets + cTrim
        next
    ok

    if len(aTargets) = 0
        showHarvestHelp()
        return false
    ok

    if lAndroidMode
        uiBanner("Harvesting C Extensions for Android", "Host: " + toNativePath(cHost) + " -> Target: src/cpp/ext/ (libmain.so)")
    else
        uiBanner("Harvesting Libraries from Host Ring", "Host: " + toNativePath(cHost) + " -> Target: " + toNativePath(cTargetVenv))
    ok
    ? ""

    nHarvested = 0
    for cLibName in aTargets
        ? "  " + uiStyle("Harvesting: ", C_BOLD + C_WHITE) + uiStyle(cLibName, C_BOLD + C_BYELLOW) + "..."
        if lAndroidMode
            if harvestAndroidNative(cHost, cLibName)
                nHarvested++
                ? "  " + uiStyle("[✔] Success:  ", C_BGREEN) + uiStyle(cLibName, C_BOLD + C_WHITE) + " C wrapper imported to src/cpp/ext/ for libmain.so."
            else
                ? "  " + uiStyle("[!] Warning:  ", C_BYELLOW) + "Could not find C extension source for '" + cLibName + "' in host extensions."
            ok
        else
            if harvestLibrary(cHost, cTargetVenv, cLibName)
                nHarvested++
                ? "  " + uiStyle("[✔] Success:  ", C_BGREEN) + uiStyle(cLibName, C_BOLD + C_WHITE) + " imported into virtual environment."
            else
                ? "  " + uiStyle("[!] Warning:  ", C_BYELLOW) + "Could not find matching files for '" + cLibName + "' in host installation."
            ok
        ok
        ? ""
    next

    uiDivider()
    uiSuccess("Harvesting completed: " + nHarvested + " library(ies) successfully integrated.")
    uiDivider()
    return true

# Import specific library and its dependencies
func harvestLibrary cHost, cVenv, cLib
    cLower = lower(trim(cLib))
    lFoundAny = false

    # Target directories in virtual environment
    cDestBin = cVenv + "/bin"
    cDestScripts = cVenv + "/Scripts"
    ensureDir(cDestBin)
    ensureDir(cDestBin + "/load")
    if iswindows()
        ensureDir(cDestScripts)
        ensureDir(cDestScripts + "/load")
    ok
    ensureDir(cVenv + "/libraries")
    ensureDir(cVenv + "/extensions")

    # 1. Specialized Recipe: Qt / guilib / lightguilib
    if cLower = "guilib" or cLower = "lightguilib" or cLower = "qt" or cLower = "ringqt"
        # A. Loaders
        aQtLoaders = ["guilib.ring", "lightguilib.ring", "qtcore.ring"]
        for cLdr in aQtLoaders
            if fexists(cHost + "/bin/load/" + cLdr)
                copyFile(cHost + "/bin/load/" + cLdr, cDestBin + "/load/" + cLdr)
                if iswindows() copyFile(cHost + "/bin/load/" + cLdr, cDestScripts + "/load/" + cLdr) ok
                lFoundAny = true
            ok
        next

        # B. Qt & RingQt DLLs
        if iswindows()
            aHostBins = dir(cHost + "/bin")
            for aItem in aHostBins
                cName = aItem[1]
                cItemLower = lower(cName)
                if substr(cItemLower, ".dll") > 0
                    if substr(cItemLower, "ringqt") > 0 or substr(cItemLower, "qt5") > 0
                        copyFile(cHost + "/bin/" + cName, cDestBin + "/" + cName)
                        copyFile(cHost + "/bin/" + cName, cDestScripts + "/" + cName)
                        lFoundAny = true
                    ok
                ok
            next

            # C. Qt platforms plugins (CRITICAL for GUI windowing on Windows)
            if direxists(cHost + "/bin/platforms")
                copyFolder(cHost + "/bin/platforms", cDestBin + "/platforms")
                copyFolder(cHost + "/bin/platforms", cDestScripts + "/platforms")
            ok
            # D. Qt imageformats & styles plugins if present
            if direxists(cHost + "/bin/imageformats")
                copyFolder(cHost + "/bin/imageformats", cDestBin + "/imageformats")
                copyFolder(cHost + "/bin/imageformats", cDestScripts + "/imageformats")
            ok
            if direxists(cHost + "/bin/styles")
                copyFolder(cHost + "/bin/styles", cDestBin + "/styles")
                copyFolder(cHost + "/bin/styles", cDestScripts + "/styles")
            ok
        ok

        # E. libraries/guilib
        if direxists(cHost + "/libraries/guilib")
            copyFolder(cHost + "/libraries/guilib", cVenv + "/libraries/guilib")
            lFoundAny = true
        ok

        # F. extensions/ringqt
        if direxists(cHost + "/extensions/ringqt")
            copyFolder(cHost + "/extensions/ringqt", cVenv + "/extensions/ringqt")
            lFoundAny = true
        ok

        # G. Qt Core Dependency: ObjectsLib (required by MVC controllerparent)
        harvestLibrary(cHost, cVenv, "objectslib")

        return lFoundAny
    ok

    # 2. Specialized Recipe: Raylib
    if cLower = "raylib" or cLower = "ringraylib" or cLower = "ringraylib5"
        if fexists(cHost + "/bin/load/raylib.ring")
            copyFile(cHost + "/bin/load/raylib.ring", cDestBin + "/load/raylib.ring")
            if iswindows() copyFile(cHost + "/bin/load/raylib.ring", cDestScripts + "/load/raylib.ring") ok
            lFoundAny = true
        ok
        if iswindows()
            aHostBins = dir(cHost + "/bin")
            for aItem in aHostBins
                cName = aItem[1]
                if substr(lower(cName), "raylib") > 0 and substr(lower(cName), ".dll") > 0
                    copyFile(cHost + "/bin/" + cName, cDestBin + "/" + cName)
                    copyFile(cHost + "/bin/" + cName, cDestScripts + "/" + cName)
                    lFoundAny = true
                ok
            next
        ok
        if direxists(cHost + "/extensions/ringraylib5")
            copyFolder(cHost + "/extensions/ringraylib5", cVenv + "/extensions/ringraylib5")
            lFoundAny = true
        ok
        return lFoundAny
    ok

    # 3. Specialized Recipe: GameEngine / Allegro
    if cLower = "gameengine" or cLower = "allegro" or cLower = "ringallegro"
        if fexists(cHost + "/bin/load/gameengine.ring")
            copyFile(cHost + "/bin/load/gameengine.ring", cDestBin + "/load/gameengine.ring")
            if iswindows() copyFile(cHost + "/bin/load/gameengine.ring", cDestScripts + "/load/gameengine.ring") ok
            lFoundAny = true
        ok
        if fexists(cHost + "/bin/load/gamelib.ring")
            copyFile(cHost + "/bin/load/gamelib.ring", cDestBin + "/load/gamelib.ring")
            if iswindows() copyFile(cHost + "/bin/load/gamelib.ring", cDestScripts + "/load/gamelib.ring") ok
            lFoundAny = true
        ok
        if direxists(cHost + "/libraries/gameengine")
            copyFolder(cHost + "/libraries/gameengine", cVenv + "/libraries/gameengine")
            lFoundAny = true
        ok
        if iswindows()
            aHostBins = dir(cHost + "/bin")
            for aItem in aHostBins
                cName = aItem[1]
                if (substr(lower(cName), "allegro") > 0 or substr(lower(cName), "gameengine") > 0) and substr(lower(cName), ".dll") > 0
                    copyFile(cHost + "/bin/" + cName, cDestBin + "/" + cName)
                    copyFile(cHost + "/bin/" + cName, cDestScripts + "/" + cName)
                    lFoundAny = true
                ok
            next
        ok
        if direxists(cHost + "/extensions/ringallegro")
            copyFolder(cHost + "/extensions/ringallegro", cVenv + "/extensions/ringallegro")
            lFoundAny = true
        ok
        return lFoundAny
    ok

    # 4. Specialized Recipe: LibUI
    if cLower = "libui" or cLower = "ringlibui"
        if fexists(cHost + "/bin/load/libui.ring")
            copyFile(cHost + "/bin/load/libui.ring", cDestBin + "/load/libui.ring")
            if iswindows() copyFile(cHost + "/bin/load/libui.ring", cDestScripts + "/load/libui.ring") ok
            lFoundAny = true
        ok
        if iswindows()
            aHostBins = dir(cHost + "/bin")
            for aItem in aHostBins
                cName = aItem[1]
                if substr(lower(cName), "libui") > 0 and substr(lower(cName), ".dll") > 0
                    copyFile(cHost + "/bin/" + cName, cDestBin + "/" + cName)
                    copyFile(cHost + "/bin/" + cName, cDestScripts + "/" + cName)
                    lFoundAny = true
                ok
            next
        ok
        if direxists(cHost + "/extensions/ringlibui")
            copyFolder(cHost + "/extensions/ringlibui", cVenv + "/extensions/ringlibui")
            lFoundAny = true
        ok
        return lFoundAny
    ok

    # 5. Specialized Recipe: LibUV
    if cLower = "libuv" or cLower = "ringlibuv"
        if fexists(cHost + "/bin/load/libuv.ring")
            copyFile(cHost + "/bin/load/libuv.ring", cDestBin + "/load/libuv.ring")
            if iswindows() copyFile(cHost + "/bin/load/libuv.ring", cDestScripts + "/load/libuv.ring") ok
            lFoundAny = true
        ok
        if iswindows()
            aHostBins = dir(cHost + "/bin")
            for aItem in aHostBins
                cName = aItem[1]
                if substr(lower(cName), "libuv") > 0 and substr(lower(cName), ".dll") > 0
                    copyFile(cHost + "/bin/" + cName, cDestBin + "/" + cName)
                    copyFile(cHost + "/bin/" + cName, cDestScripts + "/" + cName)
                    lFoundAny = true
                ok
            next
        ok
        if direxists(cHost + "/extensions/ringlibuv")
            copyFolder(cHost + "/extensions/ringlibuv", cVenv + "/extensions/ringlibuv")
            lFoundAny = true
        ok
        return lFoundAny
    ok

    # 6. Specialized Recipe: Threads / RingThreadPro
    if cLower = "threads" or cLower = "ringthreadpro" or cLower = "ringthreads"
        if fexists(cHost + "/bin/load/threads.ring")
            copyFile(cHost + "/bin/load/threads.ring", cDestBin + "/load/threads.ring")
            if iswindows() copyFile(cHost + "/bin/load/threads.ring", cDestScripts + "/load/threads.ring") ok
            lFoundAny = true
        ok
        if fexists(cHost + "/bin/load/RingThreadPro.ring")
            copyFile(cHost + "/bin/load/RingThreadPro.ring", cDestBin + "/load/RingThreadPro.ring")
            if iswindows() copyFile(cHost + "/bin/load/RingThreadPro.ring", cDestScripts + "/load/RingThreadPro.ring") ok
            lFoundAny = true
        ok
        if direxists(cHost + "/libraries/RingThreadPro")
            copyFolder(cHost + "/libraries/RingThreadPro", cVenv + "/libraries/RingThreadPro")
            lFoundAny = true
        ok
        if iswindows() and fexists(cHost + "/bin/ring_threads.dll")
            copyFile(cHost + "/bin/ring_threads.dll", cDestBin + "/ring_threads.dll")
            copyFile(cHost + "/bin/ring_threads.dll", cDestScripts + "/ring_threads.dll")
            lFoundAny = true
        ok
        if direxists(cHost + "/extensions/ringthreads")
            copyFolder(cHost + "/extensions/ringthreads", cVenv + "/extensions/ringthreads")
            lFoundAny = true
        ok
        return lFoundAny
    ok

    # 7. Specialized Recipe: ObjectsLib
    if cLower = "objectslib" or cLower = "objects"
        if fexists(cHost + "/bin/load/objectslib.ring")
            copyFile(cHost + "/bin/load/objectslib.ring", cDestBin + "/load/objectslib.ring")
            if iswindows() copyFile(cHost + "/bin/load/objectslib.ring", cDestScripts + "/load/objectslib.ring") ok
            lFoundAny = true
        ok
        if direxists(cHost + "/libraries/objectslib")
            copyFolder(cHost + "/libraries/objectslib", cVenv + "/libraries/objectslib")
            lFoundAny = true
        ok
        return lFoundAny
    ok

    # 8. Generalized Auto-Discovery Fallback:
    # A. Check bin/load/<name>.ring
    aPossibleLoaders = [cLower + ".ring", cLower + "lib.ring", "ring" + cLower + ".ring"]
    for cLdr in aPossibleLoaders
        if fexists(cHost + "/bin/load/" + cLdr)
            copyFile(cHost + "/bin/load/" + cLdr, cDestBin + "/load/" + cLdr)
            if iswindows() copyFile(cHost + "/bin/load/" + cLdr, cDestScripts + "/load/" + cLdr) ok
            lFoundAny = true
        ok
    next

    # B. Check libraries/<name>
    if direxists(cHost + "/libraries/" + cLower)
        copyFolder(cHost + "/libraries/" + cLower, cVenv + "/libraries/" + cLower)
        lFoundAny = true
    ok

    # C. Check extensions/<name> or extensions/ring<name>
    if direxists(cHost + "/extensions/" + cLower)
        copyFolder(cHost + "/extensions/" + cLower, cVenv + "/extensions/" + cLower)
        lFoundAny = true
    but direxists(cHost + "/extensions/ring" + cLower)
        copyFolder(cHost + "/extensions/ring" + cLower, cVenv + "/extensions/ring" + cLower)
        lFoundAny = true
    ok

    # D. Check dynamic libraries in bin/
    if iswindows()
        aHostBins = dir(cHost + "/bin")
        for aItem in aHostBins
            cName = aItem[1]
            cItemLower = lower(cName)
            if substr(cItemLower, ".dll") > 0
                if substr(cItemLower, cLower) > 0 or substr(cItemLower, "ring_" + cLower) > 0 or substr(cItemLower, "ring" + cLower) > 0
                    copyFile(cHost + "/bin/" + cName, cDestBin + "/" + cName)
                    copyFile(cHost + "/bin/" + cName, cDestScripts + "/" + cName)
                    lFoundAny = true
                ok
            ok
        next
    ok

    return lFoundAny

# Automatically scan project sources for load statements and harvest missing host libraries
func harvestScan
    cHost = getHostRingDir()
    if cHost = ""
        ? uiError("Could not locate a full Ring installation on this system.")
        return false
    ok

    cTargetVenv = getTargetVenvDir()
    if cTargetVenv = ""
        ? uiError("No active virtual environment detected.")
        return false
    ok

    uiBanner("Scanning Project Dependencies", "Analyzing load statements for missing host libraries...")
    ? ""

    # Collect all .ring files from project root and src/
    aFilesToScan = []
    aRootFiles = dir(".")
    for aItem in aRootFiles
        cName = aItem[1]
        if right(lower(cName), 5) = ".ring"
            aFilesToScan + cName
        ok
    next
    if direxists("src")
        aSrcFiles = dir("src")
        for aItem in aSrcFiles
            cName = aItem[1]
            if right(lower(cName), 5) = ".ring"
                aFilesToScan + ("src/" + cName)
            ok
        next
    ok

    aDiscoveredLoads = []
    for cFilePath in aFilesToScan
        if not fexists(cFilePath) loop ok
        cContent = read(cFilePath)
        aLines = split(cContent, nl)
        for cLine in aLines
            cTrim = trim(cLine)
            cLowerLine = lower(cTrim)
            if substr(cLowerLine, "load ") = 1
                nQ1 = substr(cTrim, '"')
                if nQ1 > 0
                    nQ2 = substr(substr(cTrim, nQ1 + 1), '"')
                    if nQ2 > 0
                        cLoaded = substr(cTrim, nQ1 + 1, nQ2 - 1)
                        cLoaded = lower(trim(cLoaded))
                        if find(aDiscoveredLoads, cLoaded) = 0
                            aDiscoveredLoads + cLoaded
                        ok
                    ok
                ok
            ok
        next
    next

    nAutoHarvested = 0
    for cLoadItem in aDiscoveredLoads
        if fexists(cLoadItem) or fexists("src/" + cLoadItem) or fexists("../" + cLoadItem)
            loop
        ok

        cLibLookup = cLoadItem
        if right(cLibLookup, 5) = ".ring"
            cLibLookup = left(cLibLookup, len(cLibLookup) - 5)
        ok

        lInVenv = fexists(cTargetVenv + "/bin/load/" + cLoadItem) or
                  direxists(cTargetVenv + "/libraries/" + cLibLookup) or
                  fexists(cTargetVenv + "/libraries/" + cLoadItem)

        if not lInVenv
            lInHost = fexists(cHost + "/bin/load/" + cLoadItem) or
                      direxists(cHost + "/libraries/" + cLibLookup)

            if lInHost
                ? "  " + uiStyle("Auto-detected missing library: ", C_BOLD + C_WHITE) + uiStyle(cLibLookup, C_BOLD + C_BYELLOW)
                if harvestLibrary(cHost, cTargetVenv, cLibLookup)
                    nAutoHarvested++
                    ? "  " + uiStyle("[✔] Auto-harvested: ", C_BGREEN) + uiStyle(cLibLookup, C_BOLD + C_WHITE) + " into virtual environment."
                ok
                ? ""
            ok
        ok
    next

    if nAutoHarvested > 0
        uiDivider()
        uiSuccess("Auto-harvest complete: " + nAutoHarvested + " missing library(ies) resolved.")
        uiDivider()
    else
        ? "  " + uiStyle("[✔] All scanned dependencies are already resolved in environment.", C_BGREEN)
        ? ""
    ok

    return true

# Harvest C/C++ extension wrapper from host into src/cpp/ext/ for Android libmain.so compilation
func harvestAndroidNative cHost, cLib
    cLower = lower(trim(cLib))
    # Strip leading ring_ or ring if user specified
    if left(cLower, 5) = "ring_"
        cLower = substr(cLower, 6)
    but left(cLower, 4) = "ring"
        cLower = substr(cLower, 5)
    ok

    # Locate source in host extensions
    cExtHost = ""
    if direxists(cHost + "/extensions/ring" + cLower)
        cExtHost = cHost + "/extensions/ring" + cLower
    but direxists(cHost + "/extensions/" + cLower)
        cExtHost = cHost + "/extensions/" + cLower
    ok

    if cExtHost = ""
        return false
    ok

    # Target directory in project
    cDestExt = "src/cpp/ext/" + cLower
    ensureAndroidNativeScaffold(cHost)
    ensureDir(cDestExt)

    # Copy C/C++ sources, headers, and helper directories
    aItems = dir(cExtHost)
    for aItem in aItems
        cName = aItem[1]
        cItemLower = lower(cName)
        # Skip batch/shell build scripts
        if right(cItemLower, 4) = ".bat" or right(cItemLower, 3) = ".sh" or right(cItemLower, 3) = ".cf"
            loop
        ok
        # Copy .c, .cpp, .h, .hpp, .rh
        if right(cItemLower, 2) = ".c" or right(cItemLower, 4) = ".cpp" or
           right(cItemLower, 2) = ".h" or right(cItemLower, 4) = ".hpp" or
           right(cItemLower, 3) = ".rh"
            copyFile(cExtHost + "/" + cName, cDestExt + "/" + cName)
        # Copy helper subdirectories (tinycthread, lib, etc.)
        but direxists(cExtHost + "/" + cName)
            if cName != "." and cName != ".." and cName != "test" and cName != "tests" and cName != "build"
                copyFolder(cExtHost + "/" + cName, cDestExt + "/" + cName)
            ok
        ok
        # Also copy .ring wrapper into src/ or ring/ (with Android LoadLib safety patch)
        if right(cItemLower, 5) = ".ring"
            cRingSrc = read(cExtHost + "/" + cName)
            if substr(lower(cRingSrc), "isandroid()") = 0 and substr(lower(cRingSrc), "loadlib(") > 0
                if substr(lower(cRingSrc), "if iswindows()") > 0
                    cRingSrc = substr(cRingSrc, "if iswindows()", "if isandroid()" + nl + "	# Statically compiled into libmain.so" + nl + "but iswindows()")
                but substr(lower(cRingSrc), "if iswindows ()") > 0
                    cRingSrc = substr(cRingSrc, "if iswindows ()", "if isandroid()" + nl + "	# Statically compiled into libmain.so" + nl + "but iswindows()")
                ok
            ok
            if direxists("ring")
                write("ring/" + cName, cRingSrc)
            ok
            if direxists("src")
                write("src/" + cName, cRingSrc)
            ok
        ok
    next

    return true

# Ensure all Android NDK native scaffolding, CMake files, and Ring VM sources exist
func ensureAndroidNativeScaffold cHost
    ensureDir("src")
    ensureDir("src/cpp")
    ensureDir("src/cpp/ext")
    ensureDir("src/cpp/cmake")
    ensureDir("src/cpp/ring")

    # 1. RingExtensions.cmake & ext.c.in
    cRing2ApkPkg = cHost + "/tools/ringpm/packages/ring2apk"
    if fexists(cRing2ApkPkg + "/examples/webview/src/cpp/cmake/RingExtensions.cmake") and not fexists("src/cpp/cmake/RingExtensions.cmake")
        copyFile(cRing2ApkPkg + "/examples/webview/src/cpp/cmake/RingExtensions.cmake", "src/cpp/cmake/RingExtensions.cmake")
    ok
    if fexists(cRing2ApkPkg + "/examples/webview/src/cpp/cmake/ext.c.in") and not fexists("src/cpp/cmake/ext.c.in")
        copyFile(cRing2ApkPkg + "/examples/webview/src/cpp/cmake/ext.c.in", "src/cpp/cmake/ext.c.in")
    ok

    # 2. Ring VM sources (src/ and include/) from host language directory
    if not direxists("src/cpp/ring/src") or not direxists("src/cpp/ring/include")
        cLangSrc = cHost + "/language/src"
        cLangInc = cHost + "/language/include"
        if direxists(cLangSrc) and direxists(cLangInc)
            ensureDir("src/cpp/ring/src")
            ensureDir("src/cpp/ring/include")
            aFiles = dir(cLangSrc)
            for aItem in aFiles
                cFile = aItem[1]
                if aItem[2] = 0 and cFile != "ring.c" and cFile != "ringw.c"
                    copyFile(cLangSrc + "/" + cFile, "src/cpp/ring/src/" + cFile)
                ok
            next
            copyFolder(cLangInc, "src/cpp/ring/include")
        ok
    ok

    # 3. Native main.c with stdout/stderr -> logcat redirection
    if not fexists("src/cpp/main.c")
        cMain = '/* Ring Android Native Application Entry Point */' + nl +
                '#include <android_native_app_glue.h>' + nl +
                '#include <android/log.h>' + nl +
                '#include <stdio.h>' + nl +
                '#include <stdlib.h>' + nl +
                '#include <string.h>' + nl +
                '#include <unistd.h>' + nl +
                '#include <pthread.h>' + nl + nl +
                '#include "ring.h"' + nl +
                '#include "ringappcode.h"' + nl + nl +
                '#define LOG_TAG "RingApp"' + nl +
                '#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)' + nl +
                '#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)' + nl + nl +
                'static int pfd[2];' + nl +
                'static pthread_t thr;' + nl + nl +
                'static void *thread_func(void *arg) {' + nl +
                '    (void)arg;' + nl +
                '    ssize_t rdsz;' + nl +
                '    char buf[256];' + nl +
                '    while ((rdsz = read(pfd[0], buf, sizeof(buf) - 1)) > 0) {' + nl +
                '        buf[rdsz] = 0;' + nl +
                '        __android_log_write(ANDROID_LOG_DEBUG, "RingOutput", buf);' + nl +
                '    }' + nl +
                '    return 0;' + nl +
                '}' + nl + nl +
                'static void start_logger(void) {' + nl +
                '    setvbuf(stdout, 0, _IOLBF, 0);' + nl +
                '    setvbuf(stderr, 0, _IONBF, 0);' + nl +
                '    pipe(pfd);' + nl +
                '    dup2(pfd[1], 1);' + nl +
                '    dup2(pfd[1], 2);' + nl +
                '    pthread_create(&thr, 0, thread_func, 0);' + nl +
                '}' + nl + nl +
                'void android_main(struct android_app *app) {' + nl +
                '    (void)app;' + nl +
                '    start_logger();' + nl +
                '    LOGI("=== Ring App Starting ===");' + nl + nl +
                '    RingState *pState = ring_state_new();' + nl +
                '    if (!pState) {' + nl +
                '        LOGE("Failed to create Ring state");' + nl +
                '        return;' + nl +
                '    }' + nl +
                '    pState->lRun = 1;' + nl +
                '    ringappcode_run(pState);' + nl +
                '    ring_state_delete(pState);' + nl +
                '    LOGI("=== Ring App Finished ===");' + nl +
                '}' + nl
        write("src/cpp/main.c", cMain)
    ok

    # 4. CMakeLists.txt configured for RingExtensions
    if not fexists("src/cpp/CMakeLists.txt")
        cCMake = 'cmake_minimum_required(VERSION 3.22)' + nl +
                 'project(ringapp C CXX)' + nl + nl +
                 'set(CMAKE_C_STANDARD 99)' + nl +
                 'set(CMAKE_C_STANDARD_REQUIRED ON)' + nl + nl +
                 'list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")' + nl +
                 'include(RingExtensions)' + nl + nl +
                 'if((ANDROID_ABI STREQUAL "armeabi-v7a" OR ANDROID_ABI STREQUAL "x86") AND ANDROID_PLATFORM_LEVEL LESS 24)' + nl +
                 '    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -U_FILE_OFFSET_BITS")' + nl +
                 'endif()' + nl + nl +
                 'set(RING_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ring")' + nl +
                 'if(NOT EXISTS "${RING_DIR}/src")' + nl +
                 '    message(FATAL_ERROR "Ring sources not found! Expected at ${RING_DIR}/src")' + nl +
                 'endif()' + nl + nl +
                 'file(GLOB RING_SOURCES ${RING_DIR}/src/*.c)' + nl +
                 'list(FILTER RING_SOURCES EXCLUDE REGEX ".*/ext\\\\.c$")' + nl + nl +
                 'add_library(ring STATIC ${RING_SOURCES})' + nl +
                 'target_include_directories(ring PUBLIC "${RING_DIR}/include")' + nl +
                 'target_link_libraries(ring PUBLIC android log)' + nl + nl +
                 'set(NATIVE_APP_GLUE_DIR "${ANDROID_NDK}/sources/android/native_app_glue")' + nl +
                 'add_library(native_app_glue STATIC' + nl +
                 '    ${NATIVE_APP_GLUE_DIR}/android_native_app_glue.c' + nl +
                 ')' + nl +
                 'target_include_directories(native_app_glue PUBLIC ${NATIVE_APP_GLUE_DIR})' + nl + nl +
                 'add_library(main SHARED' + nl +
                 '    main.c' + nl +
                 '    ${CMAKE_SOURCE_DIR}/../../build/gen/ringappcode.c' + nl +
                 ')' + nl + nl +
                 'target_include_directories(main PRIVATE' + nl +
                 '    ${CMAKE_CURRENT_SOURCE_DIR}' + nl +
                 '    ${CMAKE_SOURCE_DIR}/../../build/gen' + nl +
                 '    ${RING_DIR}/include' + nl +
                 '    ${NATIVE_APP_GLUE_DIR}' + nl +
                 ')' + nl + nl +
                 'target_link_libraries(main PRIVATE' + nl +
                 '    ring' + nl +
                 '    -Wl,--whole-archive' + nl +
                 '    native_app_glue' + nl +
                 '    -Wl,--no-whole-archive' + nl +
                 '    android' + nl +
                 '    log' + nl +
                 ')' + nl + nl +
                 'set(RING_EXT_EXCLUDE tinycthread.c)' + nl +
                 'ring_target_add_extensions(main)' + nl
        write("src/cpp/CMakeLists.txt", cCMake)
    ok

