# Packaging and Distribution Guide

This guide explains how to structure an application built inside a `ringenv` virtual environment and how to package and distribute it.

---

## 1. Project Directory Structure

Always keep your project source code outside the `.rvenv` directory. The virtual environment is an expendable runtime container that can be recreated at any time.

```text
MyProject/
├── .rvenv/                     # Virtual environment (ignored by Git)
├── src/                        # Application source code
│   ├── main.ring               # Entry point
│   ├── app_logic.ring
│   └── database.ring
├── assets/                     # Images, fonts, configuration files
├── tests/                      # Automated unit tests
│   └── test_app.ring
├── .gitignore                  # Ignore .rvenv/ and temporary files
├── package.ring                # Ring package definition (for ringpm)
└── README.md                   # Project documentation
```

### Recommended `.gitignore`:
```gitignore
.rvenv/
myenv/
target/
*.exe
*.dll
*.so
*.dylib
```

---

## 2. Writing Application Code with Dependencies

Inside an activated virtual environment, install the required packages:

```bash
ringenv hub install xlsxlib
ringenv hub install ringqr
```

In your `src/main.ring`, import the libraries normally:

```ring
# src/main.ring
load "stdlibcore.ring"
load "xlsxlib.ring"
load "ringqr.ring"

func main
    ? "Application running inside isolated environment!"
    # Your application logic here
```

Run your application:
```bash
ring src/main.ring
```
The active environment's `ring.exe` will resolve and load the packages directly from `.rvenv/tools/ringpm/packages/`.

---

## 3. Compiling Standalone Executables (`ring2exe`)

To distribute your application to end users who do not have Ring installed:

```bash
# From within the active virtual environment:
ring2exe src/main.ring -dist
```

### What `ring2exe` Does:
1. Compiles your Ring source code and imported libraries into bytecode or embedded C.
2. If a C compiler is not found, `ring2exe` uses the native Ring standalone packaging method without needing any C compiler.
3. Generates the executable binary and required runtime DLLs in `target/windows/` (or `target/linux/` / `target/macos/`).
4. The output folder can be zipped and distributed directly to users.

---

## 4. Publishing as a Ring Package (`package.ring`)

To publish your library or application so other Ring developers can install it via `ringpm`:

Create `package.ring` in the project root:

```ring
aPackageInfo = [
    :name = "myproject",
    :description = "Description of my project",
    :developer = "Your Name",
    :email = "your.email@example.com",
    :license = "MIT License",
    :version = "1.0.0",
    :ringversion = "1.27",
    :files = [
        "src/main.ring",
        "src/app_logic.ring",
        "README.md"
    ],
    :libs = [
        [
            :name = "xlsxlib",
            :version = "1.0",
            :providerusername = "Azzeddine2017"
        ]
    ]
]
```

Push your project to GitHub. Users can then install it with:
```bash
ringpm install myproject from YourGitHubUsername
```
All dependencies specified in `:libs` will be resolved and installed automatically.
