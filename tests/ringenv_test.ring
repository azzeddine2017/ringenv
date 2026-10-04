# ringenv_test.ring - اختبار أولي بسيط للتحقق من تشغيل ringtest

load "src/core/os_helper.ring"

describe("OS Helper - Basic Test", func {

    it("should get platform name", func {
        cPlatform = getPlatformName()
        expect(cPlatform != "").toBeTruthy()
    })

    it("should get binary name", func {
        cBin = getBinaryName()
        expect(cBin != "").toBeTruthy()
    })

    it("should get home directory", func {
        cHome = getHomeDir()
        expect(len(cHome) > 0).toBeTruthy()
    })

})
