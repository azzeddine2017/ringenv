# ringenv - Isolated Virtual Environment & Version Manager for Ring Programming Language
# Main CLI Router and Argument Parser

load "stdlibcore.ring"
load "libcurl.ring"
load "ziplib.ring"

load "src/core/os_helper.ring"
load "src/core/zipengine.ring"
load "src/core/downloader.ring"
load "src/core/extractor.ring"
load "src/commands/cmd_install.ring"
load "src/commands/cmd_remove.ring"
load "src/commands/cmd_list.ring"
load "src/commands/cmd_list_remote.ring"
load "src/commands/cmd_venv.ring"

func main
    aArgs = parseCliArgs()

    if len(aArgs) = 0
        showHelp()
        return
    ok

    cCommand = lower(aArgs[1])

    switch cCommand
        on "help"
            showHelp()

        on "--help"
            showHelp()

        on "-h"
            showHelp()

        on "version"
            showVersion()

        on "--version"
            showVersion()

        on "-v"
            showVersion()

        on "list"
            if len(aArgs) >= 2 and (lower(aArgs[2]) = "--remote" or lower(aArgs[2]) = "-r")
                cmdListRemote()
            else
                cmdList()
            ok

        on "list-remote"
            cmdListRemote()

        on "available"
            cmdListRemote()

        on "install"
            if len(aArgs) < 2
                ? "Error: Missing version argument."
                ? "Usage:   ringenv install <version> [--light] [--force]"
                ? "Example: ringenv install 1.27"
                return
            ok

            cVersion = aArgs[2]
            lLight = false
            lForce = false
            for i = 3 to len(aArgs)
                cArg = lower(aArgs[i])
                if cArg = "--light"
                    lLight = true
                but cArg = "--force" or cArg = "-f"
                    lForce = true
                ok
            next

            cmdInstall(cVersion, lLight, lForce)

        on "remove"
            if len(aArgs) < 2
                ? "Error: Missing version argument."
                ? "Usage:   ringenv remove <version>"
                ? "Example: ringenv remove 1.27"
                return
            ok
            cmdRemove(aArgs[2])

        on "uninstall"
            if len(aArgs) < 2
                ? "Error: Missing version argument."
                ? "Usage:   ringenv remove <version>"
                ? "Example: ringenv remove 1.27"
                return
            ok
            cmdRemove(aArgs[2])

        on "venv"
            aVenvArgs = []
            for i = 2 to len(aArgs)
                aVenvArgs + aArgs[i]
            next
            cmdVenv(aVenvArgs)

        other
            ? "Unknown command: " + cCommand
            ? "Run 'ringenv help' to view available commands."
    off

# Extract user arguments from sysargv
func parseCliArgs
    aArgs = []
    nStart = 2
    nArgCount = len(sysargv)

    if nArgCount >= 2
        cArg1 = lower(sysargv[1])
        cArg2 = lower(sysargv[2])

        # If executed via "ring main.ring <command> ..."
        if (substr(cArg1, "ring") > 0 or substr(cArg1, "ring.exe") > 0) and substr(cArg2, ".ring") > 0
            nStart = 3
        but substr(cArg1, ".ring") > 0
            nStart = 2
        else
            # Executable standalone or direct invocation
            nStart = 2
        ok
    ok

    for i = nStart to nArgCount
        aArgs + sysargv[i]
    next

    return aArgs

func showVersion
    ? "ringenv version 1.0.0"
    ? "Platform: " + getPlatformName()
    ? "Storage:  " + getRingenvDir()

func showHelp
    ? "======================================================================"
    ? "  ringenv - Isolated Virtual Environment & Version Manager for Ring   "
    ? "======================================================================"
    ? ""
    ? "Usage:"
    ? "  ringenv <command> [arguments] [options]"
    ? "  ring main.ring <command> [arguments] [options]"
    ? ""
    ? "Commands:"
    ? "  install <version> [options]    Download and install a Ring version"
    ? "  remove  <version>              Uninstall and remove an installed version"
    ? "  list                           Display all locally installed Ring versions"
    ? "  list-remote                    Display available Ring versions on GitHub"
    ? "  venv create <path> [options]   Create an isolated virtual environment"
    ? "  version                        Display ringenv version and platform info"
    ? "  help                           Display this help manual"
    ? ""
    ? "Command Details & Examples:"
    ? ""
    ? "  1. Install Ring version:"
    ? "     ringenv install 1.27"
    ? "     ringenv install 1.27 --force          # Reinstall even if already installed"
    ? "     ringenv install 1.26 --light"
    ? ""
    ? "  2. Remove installed Ring version:"
    ? "     ringenv remove 1.27"
    ? "     ringenv uninstall 1.26"
    ? ""
    ? "  3. List installed and available versions:"
    ? "     ringenv list                          # Locally installed versions"
    ? "     ringenv list-remote                   # Remote releases on GitHub"
    ? "     ringenv list --remote                 # Alternative remote listing"
    ? ""
    ? "  4. Create virtual environment:"
    ? "     ringenv venv create .rvenv --version 1.27"
    ? "     ringenv venv create .rvenv --clear    # Clear and recreate fresh"
    ? "     ringenv venv create myproject_env -v 1.26"
    ? "     ringenv venv create .rvenv"
    ? ""
    ? "  5. Activating virtual environment:"
    ? "     Windows CMD:         <path>\Scripts\activate.bat"
    ? "     Windows PowerShell:  <path>\Scripts\activate.ps1"
    ? "     Linux / macOS:       source <path>/bin/activate"
    ? ""
    ? "  6. Deactivating virtual environment:"
    ? "     deactivate"
    ? ""
    ? "Online Repository:"
    ? "  https://github.com/Azzeddine2017/ringenv"
    ? "======================================================================"