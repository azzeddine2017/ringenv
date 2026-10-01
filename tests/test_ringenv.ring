# test_ringenv.ring - Automated test suite for ringenv

load "stdlibcore.ring"
load "../package.ring"
load "../src/core/os_helper.ring"
load "../src/core/ui_style.ring"
load "../src/commands/cmd_list.ring"
load "../src/commands/cmd_venv.ring"
load "../src/commands/cmd_hub.ring"

nPassed = 0
nFailed = 0

runAllTests()

func assertEqual cTestName, actual, expected
    if actual = expected
        ? "[PASS] " + cTestName
        nPassed = nPassed + 1
    else
        ? "[FAIL] " + cTestName + " (Expected: " + expected + ", Got: " + actual + ")"
        nFailed = nFailed + 1
    ok

func assertTrue cTestName, condition
    if condition
        ? "[PASS] " + cTestName
        nPassed = nPassed + 1
    else
        ? "[FAIL] " + cTestName + " (Expected true, Got false)"
        nFailed = nFailed + 1
    ok

func runAllTests
    ? "================================================="
    ? "Running ringenv Test Suite"
    ? "================================================="

    # Test 1: Platform detection
    cPlatform = getPlatformName()
    assertTrue("Platform detection returns known OS", cPlatform = "windows" or cPlatform = "linux" or cPlatform = "macos")

    # Test 1b: Centralized version
    assertEqual("Centralized package version matches getRingenvVersion()", getRingenvVersion(), aPackageInfo[:version])

    # Test 2: Binary name
    cBin = getBinaryName()
    if iswindows()
        assertEqual("Binary name on Windows is ring.exe", cBin, "ring.exe")
    else
        assertEqual("Binary name on Unix is ring", cBin, "ring")
    ok

    # Test 3: Home directory resolution
    cHome = getHomeDir()
    assertTrue("Home directory is non-empty", len(cHome) > 0)

    # Test 4: ringenv directory resolution
    cBase = getRingenvDir()
    assertTrue("ringenv root contains .ringenv", substr(cBase, ".ringenv") > 0)
    assertTrue("versions dir contains /versions", substr(getVersionsDir(), "versions") > 0)
    assertTrue("cache dir contains /cache", substr(getCacheDir(), "cache") > 0)

    # Test 5: Directory creation and path normalization
    cTestDir = "./tests/test_tmp/sub1/sub2"
    ensureDir(cTestDir)
    assertTrue("ensureDir creates nested directories", direxists(cTestDir))

    # Test 6: File copy
    cSrcFile = "./tests/test_tmp/sample.txt"
    cDestFile = "./tests/test_tmp/sub1/copied.txt"
    write(cSrcFile, "ringenv unit test")
    copyFile(cSrcFile, cDestFile)
    assertTrue("copyFile copies file content correctly", fexists(cDestFile) and read(cDestFile) = "ringenv unit test")

    # Test 7: Activation scripts generation
    cVenvTestDir = "./tests/test_tmp/sample_env"
    generateActivationScripts(cVenvTestDir, "sample_env")
    assertTrue("generateActivationScripts creates bin/activate", fexists(cVenvTestDir + "/bin/activate"))
    assertTrue("generateActivationScripts creates Scripts/activate.bat", fexists(cVenvTestDir + "/Scripts/activate.bat"))
    assertTrue("generateActivationScripts creates Scripts/activate.ps1", fexists(cVenvTestDir + "/Scripts/activate.ps1"))

    cUnixContent = read(cVenvTestDir + "/bin/activate")
    assertTrue("Unix activate script sets RVENV_DIR", substr(cUnixContent, "RVENV_DIR=") > 0)
    assertTrue("Unix activate script sets RINGPATH", substr(cUnixContent, "RINGPATH=") > 0)

    cBatContent = read(cVenvTestDir + "/Scripts/activate.bat")
    assertTrue("Windows activate.bat sets RVENV_DIR", substr(cBatContent, "RVENV_DIR=") > 0)
    assertTrue("Windows activate.bat sets RINGPATH", substr(cBatContent, "RINGPATH=") > 0)

    # Test 8: Caller path resolution
    cAbsTest = "C:/TestDir"
    if not iswindows()
        cAbsTest = "/tmp/test"
    ok
    assertEqual("resolveCallerPath keeps absolute paths intact", resolveCallerPath(cAbsTest), cAbsTest)

    # Test 9: cmdRemove validation for non-existent version
    load "../src/commands/cmd_remove.ring"
    lRemoveResult = cmdRemove("999.999.nonexistent")
    assertTrue("cmdRemove returns false for non-existent version", lRemoveResult = false)

    # Test 10: Remote release tag parsing
    load "../src/commands/cmd_list_remote.ring"
    cMockJson = '[{"tag_name":"v1.27"},{"tag_name":"v1.26"},{"tag_name":"1.25"}]'
    aParsed = parseReleaseTags(cMockJson)
    assertEqual("parseReleaseTags extracts 3 tags", len(aParsed), 3)
    assertEqual("parseReleaseTags strips v prefix", aParsed[1], "1.27")
    assertEqual("parseReleaseTags keeps non-v tag", aParsed[3], "1.25")

    # Test 11: ANSI UI styling helpers
    cStyled = uiStyle("test", C_BOLD)
    assertTrue("uiStyle wraps text with escape codes", substr(cStyled, "test") > 0 and substr(cStyled, C_RESET) > 0)
    assertEqual("uiBadge formats text in brackets", uiBadge("ready", C_GREEN), uiStyle("[ready]", C_GREEN))

    # Test 12: Community hub libraries list
    aCommunityLibs = getCuratedCommunityLibs()
    assertTrue("Community hub contains curated external libraries", len(aCommunityLibs) >= 10)
    lHasXlsx = false
    lHasQuantum = false
    for aLib in aCommunityLibs
        if aLib[:name] = "xlsxlib"
            lHasXlsx = true
            assertEqual("xlsxlib author is Azzeddine2017", aLib[:author], "Azzeddine2017")
        but aLib[:name] = "ringquantum"
            lHasQuantum = true
            assertEqual("ringquantum author is Azzeddine2017", aLib[:author], "Azzeddine2017")
        ok
    next
    assertTrue("Community hub includes xlsxlib", lHasXlsx)
    assertTrue("Community hub includes ringquantum", lHasQuantum)

    # Test 13: Registry block field extractor
    cSampleBlock = ':name = "testlib", :description = "Test Description", :ProviderUserName = "TestDev"'
    assertEqual("extractRegistryField extracts name", extractRegistryField(cSampleBlock, "name"), "testlib")
    assertEqual("extractRegistryField extracts description", extractRegistryField(cSampleBlock, "description"), "Test Description")
    assertEqual("extractRegistryField extracts author case-insensitively", extractRegistryField(cSampleBlock, "providerusername"), "TestDev")

    # Test 14: Numeric index and name package resolution
    aSampleLibs = [[:name = "firstlib", :author = "dev1"], [:name = "ring-libsql", :author = "yousif"]]
    aFoundByNum = findLibByIdOrName(aSampleLibs, "2")
    assertEqual("findLibByIdOrName resolves numeric index 2", aFoundByNum[:name], "ring-libsql")
    aFoundByName = findLibByIdOrName(aSampleLibs, "ring-libsql")
    assertEqual("findLibByIdOrName resolves package with hyphen", aFoundByName[:name], "ring-libsql")

    # Test 15: Markdown README overview extractor
    cSampleReadme = "# MyPackage" + nl + "> A great library for Ring" + nl + nl + "Features and details..." + nl + "## Installation" + nl + "Install instructions"
    cOverview = extractReadmeOverview(cSampleReadme)
    assertTrue("extractReadmeOverview extracts body before H2", substr(cOverview, "A great library for Ring") > 0)
    assertTrue("extractReadmeOverview stops before Installation", substr(cOverview, "Install instructions") = 0)

    # Test 16: Community vs Official library filtering
    aCommPkg = [:name = "xlsxlib", :author = "Azzeddine2017", :desc = "Excel"]
    aOfficialPkg = [:name = "analogclock", :author = "ringpackages", :desc = "Clock game"]
    assertTrue("isCommunityLib returns true for community author", isCommunityLib(aCommPkg))
    assertTrue("isCommunityLib returns false for core ringpackages", not isCommunityLib(aOfficialPkg))
    aMixed = [aCommPkg, aOfficialPkg]
    aOnlyComm = filterLibs(aMixed, "community")
    assertEqual("filterLibs community returns 1 package", len(aOnlyComm), 1)
    assertEqual("filterLibs community includes xlsxlib", aOnlyComm[1][:name], "xlsxlib")
    aOnlyOfficial = filterLibs(aMixed, "official")
    assertEqual("filterLibs official returns 1 package", len(aOnlyOfficial), 1)
    assertEqual("filterLibs official includes analogclock", aOnlyOfficial[1][:name], "analogclock")

    # Cleanup test artifacts
    deleteFolder("./tests/test_tmp")
    assertTrue("deleteFolder removes directory recursively", not direxists("./tests/test_tmp"))

    ? "================================================="
    ? "Test Results: " + nPassed + " passed, " + nFailed + " failed."
    ? "================================================="


