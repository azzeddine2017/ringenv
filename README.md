# ringenv

> **ringenv** is an isolated virtual environment and version manager for the [Ring Programming Language](https://ring-lang.github.io).

Built natively in Ring, `ringenv` enables developers to download and manage multiple Ring language versions, create lightweight project-specific virtual environments with isolated binaries, runtime libraries, and shell activation scripts across Windows, Linux, and macOS.

---

## Features

- **Version Management**: Download and install specific Ring versions directly from official GitHub releases.
- **Virtual Environments**: Create project-isolated virtual environments (`.rvenv`) with their own `bin/` or `Scripts/` folders, `lib/`, and `packages/`.
- **Cross-Platform Activation**:
  - Windows Command Prompt (`activate.bat` / `deactivate.bat`)
  - Windows PowerShell (`activate.ps1` with prompt customization)
  - Linux & macOS Bash/Zsh (`bin/activate` with `deactivate` function)
- **Native Ecosystem Integration**: Built with native Ring standard libraries (`libcurl.ring`, `ziplib.ring`, and `stdlibcore.ring`).
- **Download Progress Meter**: Real-time download progress displaying downloaded megabytes, total size, and completion percentage.
- **Relocatable Environments**: Shell activation scripts compute the environment path dynamically, allowing environments to remain functional across workspace moves.

---

## Target Architecture

```
~/.ringenv/                     # Global storage directory
├── versions/                   # Installed Ring runtimes (~/.ringenv/versions/<version>/)
│   ├── 1.26/
│   └── 1.27/
└── cache/                      # Download cache for release archives

<project_dir>/.rvenv/           # Project-level isolated virtual environment
├── bin/                        # Binary directory (ring binary and Unix activation)
│   ├── ring
│   ├── activate
│   ├── activate.bat
│   └── activate.ps1
├── Scripts/                    # Windows-compatible Scripts directory
│   ├── ring.exe
│   ├── activate.bat
│   ├── deactivate.bat
│   └── activate.ps1
├── lib/                        # Runtime and standard libraries
├── packages/                   # Isolated packages directory
└── ringenv.cfg                 # Environment metadata configuration
```

---

## Directory Structure

```
ringenv/
├── main.ring                   # CLI router and argument parser
├── README.md                   # Project documentation
├── .gitignore                  # Git ignore rules
├── src/
│   ├── core/
│   │   ├── os_helper.ring      # OS detection, paths, directory creation, file operations
│   │   ├── downloader.ring     # LibCurl wrapper with progress callback and HTTP validation
│   │   ├── zipengine.ring      # ZipEngine class wrapper for archive handling
│   │   └── extractor.ring      # Archive unpacking and permission management
│   └── commands/
│       ├── cmd_install.ring    # Downloads and installs target Ring version
│       ├── cmd_list.ring       # Lists locally installed Ring versions
│       └── cmd_venv.ring       # Creates project virtual environments
└── tests/
    └── test_ringenv.ring       # Automated test suite
```

---

## Requirements

- **Ring Programming Language** (v1.19+ recommended, including 1.26 and 1.27)
- Ring standard extensions:
  - `libcurl.ring`
  - `ziplib.ring`
  - `stdlibcore.ring`

---

## Installation

### Method 1: Install via Ring Package Manager (`ringpm`)
Once hosted on GitHub, install directly from your repository:
```bash
ringpm install ringenv from <github_username>
```
After installation, `ringenv` is immediately available in your terminal from any directory:
```bash
ringenv --version
ringenv help
```

### Method 2: Local Installation (Development)
To install the tool into your local Ring environment directly from this source repository:
- **Windows**:
  ```cmd
  setup.bat
  ```
- **Linux / macOS**:
  ```bash
  chmod +x setup.sh
  ./setup.sh
  ```

---

## Command Reference

### 1. Show Help & Version
```bash
ring main.ring help
ring main.ring version
```

### 2. Install a Ring Version
Downloads the matching release archive from GitHub releases, extracts it into `~/.ringenv/versions/<version>/`, and removes the temporary cache archive upon completion.

```bash
# Install Ring version 1.27 (light release by default on Windows)
ring main.ring install 1.27

# Explicitly specify light release flag
ring main.ring install 1.27 --light
```

#### GitHub Releases Mapping:
- **Windows (64-bit Light)**: `Ring_<version>_LightRelease_Windows_Binary_64bit.zip`
- **Linux (Ubuntu/Debian)**: `Ring_<version>_Ubuntu.zip`
- **macOS (Apple Silicon)**: `Ring_<version>_macOS_Applesilicon.zip`
- **Fallback URL**: `https://github.com/ring-lang/ring/releases/download/v<version>/<asset_name>`

### 3. Remove a Ring Version
Uninstalls a previously downloaded Ring version from `~/.ringenv/versions/<version>/` and removes any associated cached files:

```bash
# Remove Ring version 1.27
ringenv remove 1.27

# Alternatively
ringenv uninstall 1.27
```

### 4. List Installed Versions
Inspects `~/.ringenv/versions/` and displays all installed Ring runtimes:

```bash
ringenv list
```

Example output:
```
=================================================
Installed Ring Versions (~/.ringenv/versions):
=================================================
  * 1.27 [ready]
=================================================
Total: 1 version(s) installed.
```

### 4. Create a Virtual Environment
Creates an isolated project virtual environment with runtime files, binary executables, and shell activation scripts.

```bash
# Create default .rvenv directory using specified version
ring main.ring venv create .rvenv --version 1.27

# Create virtual environment in custom folder
ring main.ring venv create myenv --version 1.27

# If only one version is installed, --version is automatically detected
ring main.ring venv create .rvenv
```

---

## Activating and Deactivating Environments

### Windows Command Prompt (`cmd.exe`)
```cmd
# Activate
.rvenv\Scripts\activate.bat

# Deactivate
deactivate
```

### Windows PowerShell
```powershell
# Activate
.rvenv\Scripts\activate.ps1

# Deactivate
deactivate
```

### Linux / macOS / Git Bash
```bash
# Activate
source .rvenv/bin/activate

# Deactivate
deactivate
```

When activated:
- The virtual environment's `bin/` (and `Scripts/` on Windows) is prepended to the system `PATH`.
- The `RINGPATH` environment variable is set to the virtual environment folder.
- The command prompt is prefixed with `(<env_name>)`.

---

## Running Tests

Execute the automated test suite to verify platform detection, path resolution, directory creation, file copying, and activation script generation:

```bash
ring tests/test_ringenv.ring
```

---

## License

This project is licensed under the MIT License.
