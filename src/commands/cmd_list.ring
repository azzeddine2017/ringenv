# ringenv - Command: list
# Scans and prints locally installed Ring versions

func cmdList
    initRingenvDirs()
    cVersionsDir = getVersionsDir()

    if not direxists(cVersionsDir)
        ? "No Ring versions installed."
        ? "Run 'ringenv install <version>' to install one."
        return true
    ok

    aItems = dir(cVersionsDir)
    aVersions = []
    for aItem in aItems
        cName = aItem[1]
        nType = aItem[2]
        if cName != "." and cName != ".." and nType = 1
            aVersions + cName
        ok
    next

    if len(aVersions) = 0
        ? "No Ring versions installed."
        ? "Run 'ringenv install <version>' to install one."
        return true
    ok

    ? "================================================="
    ? "Installed Ring Versions (" + cVersionsDir + "):"
    ? "================================================="

    cBinFile = getBinaryName()
    for cVer in aVersions
        cVerDir = cVersionsDir + "/" + cVer

        # Automatically normalize if needed
        normalizeVersionFolder(cVerDir)

        cRuntimeDir = findVersionRuntimeDir(cVerDir)
        cBinPath = cRuntimeDir + "/bin/" + cBinFile

        cStatus = ""
        if fexists(cBinPath) or fexists(cRuntimeDir + "/" + cBinFile)
            cStatus = " [ready]"
        else
            cStatus = " [incomplete]"
        ok
        ? "  * " + cVer + cStatus
    next

    ? "================================================="
    ? "Total: " + len(aVersions) + " version(s) installed."
    return true
