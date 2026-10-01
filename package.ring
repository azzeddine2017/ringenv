

aPackageInfo = [
	:name = "ringenv",
	:description = "Isolated Virtual Environment and Version Manager for Ring Programming Language",
	:folder = "ringenv",
	:developer = "Azzeddine Remmal",
	:email = "azzeddine.remmal@gmail.com",
	:license = "MIT License",
	:version = "1.1.0",
	:ringversion = "1.27",
	:versions = [
		[
			:version = "1.1.0",
			:branch = "master"
		],
		[
			:version = "1.0.3",
			:branch = "master"
		]
	],
	:libs = [
		[
			:name = "stdlib",
			:version = "1.0",
			:providerusername = ""
		]
	],
	:files = [
		"main.ring",
		"README.md",
		"package.ring",
		"setup.bat",
		"setup.sh",
		"bin/ringenv.bat",
		"bin/ringenv",
		"src/core/ui_style.ring",
		"src/core/os_helper.ring",
		"src/core/categories.ring",
		"src/core/zipengine.ring",
		"src/core/downloader.ring",
		"src/core/extractor.ring",
		"src/commands/cmd_install.ring",
		"src/commands/cmd_remove.ring",
		"src/commands/cmd_list.ring",
		"src/commands/cmd_list_remote.ring",
		"src/commands/cmd_hub.ring",
		"src/commands/cmd_venv.ring",
		"src/commands/cmd_build.ring",
		"src/commands/cmd_harvest.ring",
		"tests/test_ringenv.ring",
		"docs/README.md",
		"docs/getting_started.md",
		"docs/version_management.md",
		"docs/virtual_environments.md",
		"docs/community_hub.md",
		"docs/packaging_and_distribution.md"
	],
	:ringfolderfiles = [

	],
	:windowsfiles = [

	],
	:linuxfiles = [

	],
	:macosfiles = [

	],
	:windowsringfolderfiles = [
		"bin/ringenv.bat"
	],
	:linuxringfolderfiles = [
		"bin/ringenv"
	],
	:macosringfolderfiles = [
		"bin/ringenv"
	],
	:run = "ring main.ring",
	:setup = "",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = "",
	:remotefolder = "ringenv",
	:branch = "master",
	:providerusername = "",
	:providerwebsite = "github.com"
]
