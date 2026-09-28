# ringenv - Command: remove / uninstall
# Uninstalls and removes a specified Ring version from storage

func cmdRemove cVersion
    if cVersion = ""
        ? "Error: Please specify the version to remove."
        ? "Usage:   ringenv remove <version>"
        ? "Example: ringenv remove 1.27"
        return false
    ok

    initRingenvDirs()

    cVersionsDir = getVersionsDir()
    cTargetDir = cVersionsDir + "/" + cVersion

    if not direxists(cTargetDir)
        ? "Error: Ring version " + cVersion + " is not installed."
        ? "Run 'ringenv list' to view all installed versions."
        return false
    ok

    ? "================================================="
    ? "Removing Ring " + cVersion
    ? "Path: " + toNativePath(cTargetDir)
    ? "================================================="

    lSuccess = deleteFolder(cTargetDir)

    if lSuccess and not direxists(cTargetDir)
        ? "Successfully removed Ring " + cVersion + "!"
    else
        ? "Warning: Could not completely delete directory: " + toNativePath(cTargetDir)
        ? "Please ensure no processes are currently using files in this folder."
        return false
    ok

    # Also clean matching archive in cache directory if exists
    cCacheDir = getCacheDir()
    if direxists(cCacheDir)
        aCacheItems = dir(cCacheDir)
        for aItem in aCacheItems
            cName = aItem[1]
            if aItem[2] = 0 and substr(cName, cVersion) > 0 and substr(cName, ".zip") > 0
                remove(cCacheDir + "/" + cName)
            ok
        next
    ok

    ? "================================================="
    return true
