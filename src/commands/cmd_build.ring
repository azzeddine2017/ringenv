# ringenv - Command: build / scaffold
# Production Project Lifecycle Management for Desktop (ring2exe-plus) & Mobile (ring2apk)

load "stdlibcore.ring"

# Main entry point for 'ringenv build' command
func cmdBuild aArgs
    # Switch to caller working directory so relative paths and builds run in caller project
    cCaller = getCallerDir()
    if cCaller != "" and direxists(cCaller)
        chdir(cCaller)
    ok

    if len(aArgs) < 2
        showBuildHelp()
        return
    ok

    cSub = lower(aArgs[2])

    switch cSub
        on "help"
            showBuildHelp()

        on "--help"
            showBuildHelp()

        on "-h"
            showBuildHelp()

        on "desktop"
            buildDesktop(aArgs)

        on "exe"
            buildDesktop(aArgs)

        on "apk"
            buildApk(aArgs)

        on "android"
            buildApk(aArgs)

        on "setup-android"
            buildSetupAndroid()

        on "setup"
            buildSetupAndroid()

        on "scaffold"
            cType = "all"
            if len(aArgs) >= 3
                cType = lower(aArgs[3])
            ok
            buildScaffold(cType)

        other
            ? uiError("Unknown build target: '" + cSub + "'")
            ? "Run " + uiStyle("ringenv build help", C_BOLD + C_BYELLOW) + " to view available build commands."
    off

# Display help and usage instructions for build command
func showBuildHelp
    uiBanner("ringenv build - Project Lifecycle & Packaging", "Desktop Executables & Android APKs")
    ? ""
    ? "  " + uiStyle("Usage:", C_BOLD + C_WHITE)
    ? "    " + uiStyle("ringenv build <target> [options]", C_BOLD + C_BYELLOW)
    ? "    " + uiStyle("ringenv scaffold [desktop|apk|all]", C_BOLD + C_BYELLOW)
    ? ""
    ? "  " + uiStyle("Build Targets:", C_BOLD + C_WHITE)
    ? "    " + uiStyle("desktop / exe", C_BOLD + C_BCYAN) + "        Build standalone desktop executable (powered by ring2exe-plus)"
    ? "    " + uiStyle("apk / android", C_BOLD + C_BCYAN) + "        Build standalone Android APK package (powered by ring2apk)"
    ? "    " + uiStyle("setup-android", C_BOLD + C_BCYAN) + "        Verify and launch Android SDK/NDK/JDK toolchain installer"
    ? "    " + uiStyle("scaffold [type]", C_BOLD + C_BCYAN) + "      Generate configuration files and build automation scripts"
    ? ""
    ? "  " + uiStyle("Scaffold Types:", C_BOLD + C_WHITE)
    ? "    " + uiStyle("scaffold desktop", C_BOLD + C_BMAGENTA) + "   Create ring2exe.conf and desktop build scripts (.bat & .sh)"
    ? "    " + uiStyle("scaffold apk", C_BOLD + C_BMAGENTA) + "       Create ring2apk.ring and Android build scripts (.bat & .sh)"
    ? "    " + uiStyle("scaffold all", C_BOLD + C_BMAGENTA) + "       Create full desktop and mobile build configuration suite"
    ? ""
    ? "  " + uiStyle("Examples:", C_BOLD + C_WHITE)
    ? "    ringenv build desktop"
    ? "    ringenv build apk"
    ? "    ringenv build setup-android"
    ? "    ringenv scaffold all"
    ? uiStyle("======================================================================", C_CYAN)

# Parse simple key = value configuration file (like ring2exe.conf)
func parseConfigFile cFilePath
    aConfig = []
    if not fexists(cFilePath)
        return aConfig
    ok

    cContent = read(cFilePath)
    aLines = split(cContent, nl)
    for cLine in aLines
        cTrimmed = trim(cLine)
        # Skip empty lines and comments
        if cTrimmed = "" or substr(cTrimmed, 1, 1) = "#" or substr(cTrimmed, 1, 2) = "//"
            loop
        ok
        nEq = substr(cTrimmed, "=")
        if nEq > 0
            cKey = lower(trim(substr(cTrimmed, 1, nEq - 1)))
            cVal = trim(substr(cTrimmed, nEq + 1))
            # Strip quotes if present
            if (substr(cVal, 1, 1) = '"' and substr(cVal, len(cVal), 1) = '"') or
               (substr(cVal, 1, 1) = "'" and substr(cVal, len(cVal), 1) = "'")
                cVal = substr(cVal, 2, len(cVal) - 2)
            ok
            aConfig[cKey] = cVal
        ok
    next
    return aConfig

# Build Standalone Desktop Executable
func buildDesktop aArgs
    uiBanner("Building Desktop Application", "Using ring2exe-plus compiler")
    ? ""

    cConfPath = "ring2exe.conf"
    aConf = parseConfigFile(cConfPath)

    # Determine source file
    cSource = "src/main.ring"
    if aConf["source"] != NULL and aConf["source"] != ""
        cSource = aConf["source"]
    but fexists("main.ring")
        cSource = "main.ring"
    but fexists("app.ring")
        cSource = "app.ring"
    ok

    if not fexists(cSource)
        ? uiError("Source file not found: " + cSource)
        ? "Please make sure your entry point file exists or configure 'source' in ring2exe.conf."
        return false
    ok

    # Determine output name
    cOutput = "MyApp"
    if aConf["output"] != NULL and aConf["output"] != ""
        cOutput = aConf["output"]
    ok

    # Determine options
    lGui = true
    if aConf["gui"] != NULL and lower(aConf["gui"]) = "false"
        lGui = false
    ok

    lAutoLibs = true
    if aConf["auto-libs"] != NULL and lower(aConf["auto-libs"]) = "false"
        lAutoLibs = false
    ok

    lRelease = true
    if aConf["release"] != NULL and lower(aConf["release"]) = "false"
        lRelease = false
    ok

    cIcon = ""
    if aConf["icon"] != NULL and aConf["icon"] != ""
        cIcon = aConf["icon"]
    but fexists("assets/logo.ico")
        cIcon = "assets/logo.ico"
    but fexists("public/logo.ico")
        cIcon = "public/logo.ico"
    ok

    # Prepare command
    cCmd = "ring2exe " + toNativePath(cSource)
    if lGui
        cCmd = cCmd + " -gui"
    ok
    if lAutoLibs
        cCmd = cCmd + " -auto-libs"
    ok
    if cIcon != "" and fexists(cIcon)
        cCmd = cCmd + " -icon=" + toNativePath(cIcon)
    ok
    cCmd = cCmd + " -output=" + cOutput
    if lRelease
        cCmd = cCmd + " -release"
    ok

    # Display build plan
    ? "  " + uiStyle("Source File:  ", C_BOLD + C_WHITE) + uiStyle(cSource, C_BCYAN)
    ? "  " + uiStyle("Output Name:  ", C_BOLD + C_WHITE) + uiStyle(cOutput, C_BYELLOW)
    ? "  " + uiStyle("GUI Mode:     ", C_BOLD + C_WHITE) + uiStyle("" + lGui, C_BGREEN)
    ? "  " + uiStyle("Auto-Libs:    ", C_BOLD + C_WHITE) + uiStyle("" + lAutoLibs, C_BGREEN)
    if cIcon != ""
        ? "  " + uiStyle("App Icon:     ", C_BOLD + C_WHITE) + uiStyle(cIcon, C_DIM)
    ok
    ? "  " + uiStyle("Optimization: ", C_BOLD + C_WHITE) + uiStyle("Release (-O3)", C_BGREEN)
    ? ""
    # Pre-flight check: Test compile source file to catch missing libraries or syntax errors early
    cCheckFile = "ringenv_build_check.tmp"
    systemSilent('ring "' + toNativePath(cSource) + '" -go -norun > ' + cCheckFile + ' 2>&1')
    if fexists(cCheckFile)
        cCheckLog = read(cCheckFile)
        remove(cCheckFile)
        if substr(cCheckLog, "Error (") > 0 or substr(cCheckLog, "Error(") > 0
            ? uiError("Source code compilation error in '" + cSource + "':")
            ? ""
            ? cCheckLog
            ? uiWarn("Build aborted. Please resolve the compilation error above.")
            return false
        ok
    ok

    system(cCmd)

    # Destination directory
    cPlatform = getPlatformName()
    cDistDir = "release/" + cOutput + "-" + cPlatform + "-x64"
    ensureDir("release")
    ensureDir(cDistDir)

    # Resolve executable extension and source paths
    cSrcDir = getFileDir(cSource)
    cBase = getFileBaseName(cSource)
    cExt = ""
    if iswindows()
        cExt = ".exe"
    ok
    cExeName = cOutput + cExt

    # Search for compiled executable across all possible locations
    aExeCandidates = [
        cOutput + cExt,
        cSrcDir + "/" + cOutput + cExt,
        cBase + cExt,
        cSrcDir + "/" + cBase + cExt,
        "target/windows/" + cOutput + cExt,
        "target/windows/" + cBase + cExt,
        "target/linux/" + cOutput,
        "target/linux/" + cBase
    ]

    cFoundExe = ""
    for cCandidate in aExeCandidates
        if fexists(cCandidate)
            cFoundExe = cCandidate
            exit
        ok
    next

    if cFoundExe != ""
        cDestExe = cDistDir + "/" + cExeName
        if fexists(cDestExe)
            remove(cDestExe)
        ok
        copyFile(cFoundExe, cDestExe)

        # Clean intermediate executable from source/root directory
        if cFoundExe != cDestExe
            remove(cFoundExe)
        ok
    ok

    # Search for compiled ringo bytecode across all possible locations
    aRingoCandidates = [
        "ring.ringo",
        cSrcDir + "/ring.ringo",
        cOutput + ".ringo",
        cSrcDir + "/" + cOutput + ".ringo",
        cBase + ".ringo",
        cSrcDir + "/" + cBase + ".ringo"
    ]

    for cRingo in aRingoCandidates
        if fexists(cRingo)
            copyFile(cRingo, cDistDir + "/ring.ringo")
            if cRingo != (cDistDir + "/ring.ringo")
                remove(cRingo)
            ok
        ok
    next

    # Clean intermediate resource scripts
    aClean = ["main.rc", "main.res", "app.rc", "app.res", cOutput + ".rc", cOutput + ".res",
              cSrcDir + "/main.rc", cSrcDir + "/main.res", cSrcDir + "/app.rc", cSrcDir + "/app.res"]
    for cF in aClean
        if fexists(cF) remove(cF) ok
        if fexists(cDistDir + "/" + cF) remove(cDistDir + "/" + cF) ok
    next

    # Bundle active Ring runtime libraries (DLLs on Windows, SO on Linux) exclusively into cDistDir
    uiDivider()
    ? "  " + uiStyle("Bundling Runtime Dependencies & Assets...", C_BOLD + C_WHITE)
    cBinDir = exefolder()
    if iswindows()
        # Copy core ring DLL to release package
        if fexists(cBinDir + "/ring.dll")
            copyFile(cBinDir + "/ring.dll", cDistDir + "/ring.dll")
        ok
        # Copy library DLLs if present to release package
        aDllNames = dir(cBinDir)
        for aItem in aDllNames
            cItemName = aItem[1]
            cLower = lower(cItemName)
            if substr(cLower, ".dll") > 0
                if substr(cLower, "webview") > 0 or substr(cLower, "libsql") > 0 or
                   substr(cLower, "sqlite") > 0 or substr(cLower, "ssl") > 0 or
                   substr(cLower, "crypto") > 0 or substr(cLower, "socket") > 0 or
                   substr(cLower, "curl") > 0
                    copyFile(cBinDir + "/" + cItemName, cDistDir + "/" + cItemName)
                ok
            ok
        next
    ok

    # Copy assets folder if present
    if direxists("assets")
        copyFolder("assets", cDistDir + "/assets")
    ok
    if direxists("public")
        copyFolder("public", cDistDir + "/public")
    ok

    # Create convenient launcher script
    if iswindows()
        cLauncher = cDistDir + "/Launch_" + cOutput + ".bat"
        cBatchContent = "@echo off" + nl + 'cd /d "%~dp0"' + nl + 'start "" "' + cExeName + '"' + nl
        write(cLauncher, cBatchContent)

        # Root GUI launcher
        cRootLauncher = "Launch_" + cOutput + ".bat"
        cRootBatch = "@echo off" + nl + 'cd /d "%~dp0' + toNativePath(cDistDir) + '"' + nl + 'start "" "' + cExeName + '"' + nl
        write(cRootLauncher, cRootBatch)

        # Root CLI launcher (allows typing MyApp in project root without DLL pollution)
        cTermLauncher = cOutput + ".bat"
        cTermBatch = "@echo off" + nl + 'pushd "%~dp0' + toNativePath(cDistDir) + '"' + nl + '"%~dp0' + toNativePath(cDistDir) + '\' + cExeName + '" %*' + nl + 'popd' + nl
        write(cTermLauncher, cTermBatch)
    else
        cLauncher = cDistDir + "/launch_" + lower(cOutput) + ".sh"
        cShContent = "#!/bin/sh" + nl + 'cd "$(dirname "$0")"' + nl + './' + cExeName + ' "$@"' + nl
        write(cLauncher, cShContent)
        system('chmod +x "' + cLauncher + '" 2>/dev/null')
        if fexists(cDistDir + "/" + cExeName)
            system('chmod +x "' + cDistDir + '/' + cExeName + '" 2>/dev/null')
        ok

        # Root launcher script
        cRootSh = lower(cOutput) + ".sh"
        cRootShContent = "#!/bin/sh" + nl + 'SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"' + nl + '"$SCRIPT_DIR/' + cDistDir + '/' + cExeName + '" "$@"' + nl
        write(cRootSh, cRootShContent)
        system('chmod +x "' + cRootSh + '" 2>/dev/null')
    ok

    ? ""
    uiBanner("Desktop Build Completed", "Distribution package ready")
    ? ""
    ? "  " + uiStyle("Package Location: ", C_BOLD + C_WHITE) + uiStyle(toNativePath(cDistDir), C_BOLD + C_BGREEN)
    ? "  " + uiStyle("Executable:       ", C_BOLD + C_WHITE) + uiStyle(cExeName, C_BOLD + C_BYELLOW)
    if iswindows()
        ? "  " + uiStyle("One-Click Launch: ", C_BOLD + C_WHITE) + uiStyle("Launch_" + cOutput + ".bat", C_BCYAN)
    else
        ? "  " + uiStyle("Launcher Script:  ", C_BOLD + C_WHITE) + uiStyle("launch_" + lower(cOutput) + ".sh", C_BCYAN)
    ok
    uiDivider()
    return true

# Build Android APK using ring2apk
func buildApk aArgs
    uiBanner("Building Android APK Package", "Using ring2apk toolchain")
    ? ""

    # Check for ring2apk.ring configuration
    if not fexists("ring2apk.ring") and not fexists("android/ring2apk.ring")
        ? uiError("Configuration file 'ring2apk.ring' was not found.")
        ? "Run " + uiStyle("ringenv scaffold apk", C_BOLD + C_BYELLOW) + " to generate a starter configuration."
        return false
    ok

    cConfFile = "ring2apk.ring"
    if not fexists("ring2apk.ring") and fexists("android/ring2apk.ring")
        cConfFile = "android/ring2apk.ring"
    ok

    # Validate Android SDK / JDK environment variables
    cAndroidHome = sysget("ANDROID_HOME")
    if cAndroidHome = ""
        cAndroidHome = sysget("ANDROID_SDK_ROOT")
    ok

    # Fallback registry lookup on Windows
    if cAndroidHome = "" and iswindows()
        cUser = sysget("USERPROFILE")
        if fexists(cUser + "/Android") or direxists(cUser + "/Android")
            cAndroidHome = cUser + "/Android"
        ok
    ok

    cJavaHome = sysget("JAVA_HOME")

    cAndroidStatus = ""
    if cAndroidHome != ""
        cAndroidStatus = uiStyle(cAndroidHome, C_BGREEN)
    else
        cAndroidStatus = uiStyle("Not detected in PATH", C_BYELLOW)
    ok

    cJavaStatus = ""
    if cJavaHome != ""
        cJavaStatus = uiStyle(cJavaHome, C_BGREEN)
    else
        cJavaStatus = uiStyle("Not detected in PATH", C_BYELLOW)
    ok

    ? "  " + uiStyle("Android SDK:   ", C_BOLD + C_WHITE) + cAndroidStatus
    ? "  " + uiStyle("Java JDK:      ", C_BOLD + C_WHITE) + cJavaStatus
    ? "  " + uiStyle("Config File:   ", C_BOLD + C_WHITE) + uiStyle(cConfFile, C_BCYAN)
    ? ""

    # Stage ring/ directory temporarily only if needed
    lTemporaryRingDir = false
    if not direxists("ring") and fexists("src/main.ring")
        ensureDir("ring")
        copyFolder("src", "ring")
        lTemporaryRingDir = true
    ok

    # Ensure Android resource files exist (styles.xml, strings.xml)
    ensureDir("res/values")
    if not fexists("res/values/styles.xml")
        cStyles = '<?xml version="1.0" encoding="utf-8"?>' + nl +
                  '<resources>' + nl +
                  '    <style name="AppTheme" parent="@android:style/Theme.DeviceDefault.NoActionBar">' + nl +
                  '    </style>' + nl +
                  '</resources>' + nl
        write("res/values/styles.xml", cStyles)
    ok
    if not fexists("res/values/strings.xml")
        cStrings = '<?xml version="1.0" encoding="utf-8"?>' + nl +
                   '<resources>' + nl +
                   '    <string name="app_name">MyApp</string>' + nl +
                   '</resources>' + nl
        write("res/values/strings.xml", cStrings)
    ok

    # Stage assets/ directory if present
    if direxists("assets")
        ensureDir("android/assets")
        copyFolder("assets", "android/assets")
    ok

    # Pre-flight check: Test compile source file before Android packaging
    cSourceCheck = "ring/main.ring"
    cCheckFile = "ringenv_apk_check.tmp"
    systemSilent('ring "' + toNativePath(cSourceCheck) + '" -go -norun > ' + cCheckFile + ' 2>&1')
    if fexists(cCheckFile)
        cCheckLog = read(cCheckFile)
        remove(cCheckFile)
        if substr(cCheckLog, "Error (") > 0 or substr(cCheckLog, "Error(") > 0
            ? uiError("Source code compilation error in '" + cSourceCheck + "':")
            ? ""
            ? cCheckLog
            ? uiWarn("APK Build aborted. Please install required libraries or fix code errors above.")
            return false
        ok
    ok

    uiDivider()
    ? "  " + uiStyle("Executing ring2apk Android compilation...", C_BOLD + C_WHITE)
    ? ""

    cCmd = "ring2apk build --rebuild"
    system(cCmd)

    # Locate generated APK file
    cApkFile = ""
    if direxists("build")
        aBuildItems = dir("build")
        for aItem in aBuildItems
            if substr(lower(aItem[1]), ".apk") > 0
                cApkFile = "build/" + aItem[1]
                exit
            ok
        next
    ok

    # Cleanup temporary staged ring directory
    if lTemporaryRingDir and direxists("ring")
        deleteFolder("ring")
    ok

    ? ""
    uiBanner("Android Build Process Finished", "Check build/ directory for generated APK")
    ? ""
    if cApkFile != ""
        ? "  " + uiStyle("Generated APK: ", C_BOLD + C_WHITE) + uiStyle(toNativePath(cApkFile), C_BOLD + C_BGREEN)
    else
        ? "  " + uiStyle("Output Folder: ", C_BOLD + C_WHITE) + uiStyle(toNativePath("build"), C_BOLD + C_BGREEN)
    ok
    uiDivider()
    return true

# Launch Android Environment Setup Tool
func buildSetupAndroid
    uiBanner("Android Toolchain Setup", "ring2apk Environment Configuration")
    ? ""

    # Look for setup-env.ring in local or active ringpm packages
    aSearchPaths = [
        "tools/ringpm/packages/ring2apk/tools/setup-env.ring",
        exefolder() + "/../tools/ringpm/packages/ring2apk/tools/setup-env.ring",
        "C:/ring/tools/ringpm/packages/ring2apk/tools/setup-env.ring"
    ]

    cSetupFile = ""
    for cPath in aSearchPaths
        if fexists(cPath)
            cSetupFile = cPath
            exit
        ok
    next

    if cSetupFile = ""
        ? uiError("ring2apk setup tool was not found.")
        ? "Please install ring2apk first by running:"
        ? "  " + uiStyle("ringenv hub install ring2apk", C_BOLD + C_BCYAN)
        return false
    ok

    ? "  " + uiStyle("Found setup tool: ", C_BOLD + C_WHITE) + uiStyle(toNativePath(cSetupFile), C_BGREEN)
    ? "  " + uiStyle("Launching interactive setup...", C_BOLD + C_BYELLOW)
    ? ""

    cSetupDir = getFileDir(cSetupFile)
    cPrevDir = currentdir()
    if cSetupDir != "" and direxists(cSetupDir)
        chdir(cSetupDir)
    ok

    system('ring setup-env.ring')

    if cPrevDir != "" and direxists(cPrevDir)
        chdir(cPrevDir)
    ok
    return true

# Generate build configuration and shell scripts
func buildScaffold cType
    cTarget = lower(trim(cType))
    if cTarget = "" or cTarget = "all"
        lDesktop = true
        lApk = true
    but cTarget = "desktop" or cTarget = "exe"
        lDesktop = true
        lApk = false
    but cTarget = "apk" or cTarget = "android"
        lDesktop = false
        lApk = true
    else
        ? uiError("Invalid scaffold target: '" + cType + "'. Supported: desktop, apk, all")
        return false
    ok

    uiBanner("Scaffolding Build Automation", "Generating configs and scripts")
    ? ""

    ensureDir("scripts")

    if lDesktop
        # 1. ring2exe.conf
        if not fexists("ring2exe.conf")
            cConf = "# ==============================================================================" + nl +
                    "# Ring2EXE Plus Build Configuration" + nl +
                    "# ==============================================================================" + nl + nl +
                    "# Entry point Ring script" + nl +
                    "source = src/main.ring" + nl + nl +
                    "# Output executable name" + nl +
                    "output = MyApp" + nl + nl +
                    "# GUI mode: hides the black console window on Windows" + nl +
                    "gui = true" + nl + nl +
                    "# Automatically detect and bundle required Ring libraries" + nl +
                    "auto-libs = true" + nl + nl +
                    "# Application brand icon" + nl +
                    "icon = assets/logo.ico" + nl + nl +
                    "# Build optimized release binary (-O3)" + nl +
                    "release = true" + nl + nl +
                    "# Keep intermediate artifacts" + nl +
                    "keep = false" + nl

            write("ring2exe.conf", cConf)
            ? "  " + uiStyle("[+] Created: ", C_BGREEN) + uiStyle("ring2exe.conf", C_BOLD + C_WHITE)
        else
            ? "  " + uiStyle("[*] Exists:  ", C_BYELLOW) + uiStyle("ring2exe.conf", C_DIM)
        ok

        # 2. scripts/build_desktop.bat
        cBat = '@echo off' + nl +
               '@chcp 65001 >nul' + nl +
               'setlocal enabledelayedexpansion' + nl + nl +
               'echo ========================================================================' + nl +
               'echo        DESKTOP BUILDER (Powered by ringenv / ring2exe-plus)' + nl +
               'echo ========================================================================' + nl + nl +
               'set PROJECT_ROOT=%~dp0..' + nl +
               'cd /d "%PROJECT_ROOT%"' + nl + nl +
               'ringenv build desktop' + nl
        write("scripts/build_desktop.bat", cBat)
        ? "  " + uiStyle("[+] Created: ", C_BGREEN) + uiStyle("scripts/build_desktop.bat", C_BOLD + C_WHITE)

        # 3. scripts/build_desktop.sh
        cSh = '#!/usr/bin/env bash' + nl +
              'set -e' + nl +
              'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"' + nl +
              'PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"' + nl +
              'cd "$PROJECT_ROOT"' + nl + nl +
              'echo "========================================================================"' + nl +
              'echo "       DESKTOP BUILDER (Powered by ringenv / ring2exe-plus)"' + nl +
              'echo "========================================================================"' + nl + nl +
              'ringenv build desktop' + nl
        write("scripts/build_desktop.sh", cSh)
        if not iswindows()
            system('chmod +x "scripts/build_desktop.sh" 2>/dev/null')
        ok
        ? "  " + uiStyle("[+] Created: ", C_BGREEN) + uiStyle("scripts/build_desktop.sh", C_BOLD + C_WHITE)
    ok

    if lApk
        # 1. ring2apk.ring
        if not fexists("ring2apk.ring")
            cApkConf = '/* ' + nl +
                       '    Android Build Configuration for ring2apk' + nl +
                       '*/' + nl + nl +
                       'Ring2ApkConfig = [' + nl +
                       '    # App identity' + nl +
                       '    :name        = "MyApp",' + nl +
                       '    :label       = "My Application",' + nl +
                       '    :packageId   = "com.company.myapp",' + nl +
                       '    :versionCode = 1,' + nl +
                       '    :versionName = "1.0.0",' + nl + nl +
                       '    # Android SDK versions' + nl +
                       '    :minSdk      = 21,' + nl +
                       '    :targetSdk   = 34,' + nl +
                       '    :compileSdk  = 34,' + nl + nl +
                       '    # Target CPU architectures' + nl +
                       '    :targets     = ["arm64-v8a", "armeabi-v7a", "x86_64"],' + nl + nl +
                       '    # Directories' + nl +
                       '    :srcDir      = "src",' + nl +
                       '    :resDir      = "res",' + nl +
                       '    :assetsDir   = "assets",' + nl +
                       '    :outputDir   = "build",' + nl + nl +
                       '    # Entry point Ring code' + nl +
                       '    :ringSrcDir  = "src",' + nl +
                       '    :entryPoint  = "main.ring",' + nl + nl +
                       '    # Display configuration' + nl +
                       '    :theme       = "@style/AppTheme",' + nl +
                       '    :orientation = "unspecified",' + nl + nl +
                       '    # Required Android permissions' + nl +
                       '    :permissions = [' + nl +
                       '        "android.permission.INTERNET",' + nl +
                       '        "android.permission.ACCESS_NETWORK_STATE"' + nl +
                       '    ]' + nl +
                       ']' + nl
            write("ring2apk.ring", cApkConf)
            ? "  " + uiStyle("[+] Created: ", C_BGREEN) + uiStyle("ring2apk.ring", C_BOLD + C_WHITE)
        else
            ? "  " + uiStyle("[*] Exists:  ", C_BYELLOW) + uiStyle("ring2apk.ring", C_DIM)
        ok

        # 2. scripts/build_apk.bat
        cApkBat = '@echo off' + nl +
                  '@chcp 65001 >nul' + nl +
                  'setlocal enabledelayedexpansion' + nl + nl +
                  'echo ========================================================================' + nl +
                  'echo        ANDROID APK BUILDER (Powered by ringenv / ring2apk)' + nl +
                  'echo ========================================================================' + nl + nl +
                  'set PROJECT_ROOT=%~dp0..' + nl +
                  'cd /d "%PROJECT_ROOT%"' + nl + nl +
                  'ringenv build apk' + nl
        write("scripts/build_apk.bat", cApkBat)
        ? "  " + uiStyle("[+] Created: ", C_BGREEN) + uiStyle("scripts/build_apk.bat", C_BOLD + C_WHITE)

        # 3. scripts/build_apk.sh
        cApkSh = '#!/usr/bin/env bash' + nl +
                 'set -e' + nl +
                 'SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"' + nl +
                 'PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"' + nl +
                 'cd "$PROJECT_ROOT"' + nl + nl +
                 'echo "========================================================================"' + nl +
                 'echo "       ANDROID APK BUILDER (Powered by ringenv / ring2apk)"' + nl +
                 'echo "========================================================================"' + nl + nl +
                 'ringenv build apk' + nl
        write("scripts/build_apk.sh", cApkSh)
        if not iswindows()
            system('chmod +x "scripts/build_apk.sh" 2>/dev/null')
        ok
        ? "  " + uiStyle("[+] Created: ", C_BGREEN) + uiStyle("scripts/build_apk.sh", C_BOLD + C_WHITE)

        # 4. scripts/setup_android_env.bat
        cSetupBat = '@echo off' + nl +
                    'echo ========================================================================' + nl +
                    'echo        ANDROID ENVIRONMENT SETUP (Powered by ringenv)' + nl +
                    'echo ========================================================================' + nl + nl +
                    'ringenv build setup-android' + nl +
                    'pause' + nl
        write("scripts/setup_android_env.bat", cSetupBat)
        ? "  " + uiStyle("[+] Created: ", C_BGREEN) + uiStyle("scripts/setup_android_env.bat", C_BOLD + C_WHITE)

        # 5. res/values/styles.xml & strings.xml
        ensureDir("res/values")
        if not fexists("res/values/styles.xml")
            cStyles = '<?xml version="1.0" encoding="utf-8"?>' + nl +
                      '<resources>' + nl +
                      '    <style name="AppTheme" parent="@android:style/Theme.DeviceDefault.NoActionBar">' + nl +
                      '    </style>' + nl +
                      '</resources>' + nl
            write("res/values/styles.xml", cStyles)
            ? "  " + uiStyle("[+] Created: ", C_BGREEN) + uiStyle("res/values/styles.xml", C_BOLD + C_WHITE)
        ok
        if not fexists("res/values/strings.xml")
            cStrings = '<?xml version="1.0" encoding="utf-8"?>' + nl +
                       '<resources>' + nl +
                       '    <string name="app_name">MyApp</string>' + nl +
                       '</resources>' + nl
            write("res/values/strings.xml", cStrings)
            ? "  " + uiStyle("[+] Created: ", C_BGREEN) + uiStyle("res/values/strings.xml", C_BOLD + C_WHITE)
        ok
    ok

    ? ""
    uiSuccess("Scaffold files generated successfully!")
    uiDivider()
    return true

# Extract directory part from file path
func getFileDir cPath
    cNorm = normalizePath(cPath)
    nPos = 0
    for k = len(cNorm) to 1 step -1
        if substr(cNorm, k, 1) = "/"
            nPos = k
            exit
        ok
    next
    if nPos > 0
        return substr(cNorm, 1, nPos - 1)
    ok
    return "."

# Extract basename without extension from file path
func getFileBaseName cPath
    cNorm = normalizePath(cPath)
    nSlash = 0
    for k = len(cNorm) to 1 step -1
        if substr(cNorm, k, 1) = "/"
            nSlash = k
            exit
        ok
    next
    cFile = cNorm
    if nSlash > 0
        cFile = substr(cNorm, nSlash + 1)
    ok
    nDot = 0
    for k = len(cFile) to 1 step -1
        if substr(cFile, k, 1) = "."
            nDot = k
            exit
        ok
    next
    if nDot > 0
        return substr(cFile, 1, nDot - 1)
    ok
    return cFile
