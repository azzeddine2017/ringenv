aPackageInfo = [
	:name = "ringenv",
	:description = "Isolated Virtual Environment and Version Manager for Ring Programming Language",
	:folder = "ringenv",
	:developer = "Azzeddine Remmal",
	:email = "azzeddine.remmal@gmail.com",
	:license = "MIT License",
	:version = "1.0.0",
	:ringversion = "1.26",
	:versions = [
		[
			:version = "1.0.0",
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
		"bin/ringenv.bat",
		"bin/ringenv",
		"src/core/os_helper.ring",
		"src/core/zipengine.ring",
		"src/core/downloader.ring",
		"src/core/extractor.ring",
		"src/commands/cmd_install.ring",
		"src/commands/cmd_remove.ring",
		"src/commands/cmd_list.ring",
		"src/commands/cmd_list_remote.ring",
		"src/commands/cmd_venv.ring",
		"tests/test_ringenv.ring",
		"setup.bat",
		"setup.sh"
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
