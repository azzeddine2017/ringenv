# test_ringenv.ring - Automated test suite for ringenv

load "stdlibcore.ring"
load "../src/core/os_helper.ring"
load "../src/commands/cmd_list.ring"
load "../src/commands/cmd_venv.ring"

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

    # Cleanup test artifacts
    deleteFolder("./tests/test_tmp")
    assertTrue("deleteFolder removes directory recursively", not direxists("./tests/test_tmp"))

    ? "================================================="
    ? "Test Results: " + nPassed + " passed, " + nFailed + " failed."
    ? "================================================="


