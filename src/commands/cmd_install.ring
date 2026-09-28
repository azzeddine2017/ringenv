# ringenv - Command: install
# Downloads and sets up specified Ring version


# Determine release asset filename according to OS and flags
func getReleaseAsset cVersion, lLight
    cPlat = getPlatformName()

    if cPlat = "windows"
        return "Ring_" + cVersion + "_LightRelease_Windows_Binary_64bit.zip"
    but cPlat = "linux"
        return "Ring_" + cVersion + "_Ubuntu.zip"
    but cPlat = "macos"
        return "Ring_" + cVersion + "_macOS_Applesilicon.zip"
    else
        return "Ring_" + cVersion + "_LightRelease_Windows_Binary_64bit.zip"
    ok

# Execute install command
func cmdInstall cVersion, lLight, lForce
    if cVersion = ""
        ? "Error: Please specify the version to install."
        ? "Example: ringenv install 1.27"
        return false
    ok

    initRingenvDirs()

    cVersionDir = getVersionsDir() + "/" + cVersion
    cBinFile = getBinaryName()
    cAsset = getReleaseAsset(cVersion, lLight)
    cCacheZip = getCacheDir() + "/" + cAsset

    # Check if already installed
    if direxists(cVersionDir)
        if lForce
            ? "Force reinstall requested. Removing previous installation of Ring " + cVersion + "..."
            deleteFolder(cVersionDir)
            if fexists(cCacheZip)
                remove(cCacheZip)
            ok
        but fexists(cVersionDir + "/bin/" + cBinFile) or fexists(cVersionDir + "/" + cBinFile)
            ? "Ring " + cVersion + " is already installed at: " + cVersionDir
            ? "Use 'ringenv install " + cVersion + " --force' to force a fresh reinstall."
            ? "Use 'ringenv venv create <target> --version " + cVersion + "' to create a virtual environment."
            return true
        ok
    ok

    ? "================================================="
    ? "Installing Ring " + cVersion + " for " + getPlatformName()
    ? "Asset: " + cAsset
    ? "================================================="

    # Primary download URL
    cUrl = "https://github.com/ring-lang/ring/releases/download/v" + cVersion + "/" + cAsset
    ? "Downloading from: " + cUrl

    lSuccess = downloadFile(cUrl, cCacheZip)

    # Fallback without 'v' prefix in tag
    if not lSuccess
        cUrlFallback = "https://github.com/ring-lang/ring/releases/download/" + cVersion + "/" + cAsset
        ? "Retrying download from: " + cUrlFallback
        lSuccess = downloadFile(cUrlFallback, cCacheZip)
    ok

    if not lSuccess
        ? "Error: Failed to download Ring version " + cVersion + "."
        ? "Please check that the version exists on GitHub releases:"
        ? "https://github.com/ring-lang/ring/releases"
        return false
    ok

    ? "Extracting archive to: " + cVersionDir
    ensureDir(cVersionDir)
    extractZip(cCacheZip, cVersionDir)

    # Remove cached archive file
    if fexists(cCacheZip)
        ? "Cleaning up cache: " + cCacheZip
        remove(cCacheZip)
    ok

    # Validate extracted binary
    cBinPath = cVersionDir + "/bin/" + cBinFile
    if not fexists(cBinPath)
        if fexists(cVersionDir + "/" + cBinFile)
            cBinPath = cVersionDir + "/" + cBinFile
        ok
    ok

    ? "================================================="
    ? "Successfully installed Ring " + cVersion + "!"
    ? "Binary: " + cBinPath
    ? "================================================="
    return true
