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
        other
            harvestRun(aArgs)
    off

# Display help and usage instructions for harvest command
func showHarvestHelp
    uiBanner("ringenv harvest - Global Ring Library Harvester", "Import full-install extensions & GUI runtimes into virtual environments")
    ? ""
    ? "  " + uiStyle("Usage:", C_BOLD + C_WHITE)
    ? "    " + uiStyle("ringenv harvest <library_or_extension>", C_BOLD + C_BYELLOW)
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

    uiBanner("Harvesting Libraries from Host Ring", "Host: " + toNativePath(cHost) + " -> Target: " + toNativePath(cTargetVenv))
    ? ""

    nHarvested = 0
    for cLibName in aTargets
        ? "  " + uiStyle("Harvesting: ", C_BOLD + C_WHITE) + uiStyle(cLibName, C_BOLD + C_BYELLOW) + "..."
        if harvestLibrary(cHost, cTargetVenv, cLibName)
            nHarvested++
            ? "  " + uiStyle("[✔] Success:  ", C_BGREEN) + uiStyle(cLibName, C_BOLD + C_WHITE) + " imported into virtual environment."
        else
            ? "  " + uiStyle("[!] Warning:  ", C_BYELLOW) + "Could not find matching files for '" + cLibName + "' in host installation."
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

    # 7. Generalized Auto-Discovery Fallback:
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
