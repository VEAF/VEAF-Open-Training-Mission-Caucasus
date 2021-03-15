Ce document est également disponible [en français](readme.fr.md)

## How to build a mission?

### Prerequisites

#### Manual installation

You need a few things set up on your PC for these scripts to function.

- LUA : you need a working LUA interpreter, in your PATH, ready to be called with the `lua` command
- 7zip : you need 7zip, or another zip tool, in your PATH, ready to be called with the `7zip` command
- Powershell : you need Powershell, and you need it to be configured to allow script execution (read [this article](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.1)) ; basically you need to run this command in an elevated (admin) Powershell prompt : `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine`
- npm : you need the NPM package manager from NodeJS to get the VEAF mission creation tools ; see [here](https://www.npmjs.com/get-npm)

#### Using Chocolatey

The required tools can easily be installed using *Chocolatey* (see [here](https://chocolatey.org/)).

**WARNING** : do not do both *manual installation* and *Chocolatey installation*

To install Chocolatey, use this command  in an elevated (admin) Powershell prompt : `Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))`

After *Chocolatey* is installed, use these simple commands in a elevated (admin) command prompt to install the required tools :

- LUA : `choco install -y lua`
- 7zip : `choco install -y 7zip.commandline`
- npm : `choco install -y nodejs`

### Build the mission

Building the mission from source is easy ; you simply have to run the `build.cmd` script. You don't even need to run it in a `cmd` window, double-clicking it will be ok.

The process will take all the files in the `src` folder, fetch the latest version of the *VEAF Mission Creation Tools* (from GitHub), and compile all of this in a ready-to-use mission for DCS (in a `.miz` file).

This file will be named after the mission (this is configured in the first line of the `build.cmd` script), and placed in the `build` folder.

### Editing a compiled mission

After a mission has been compiled, copy it from the `build` folder to the main mission folder (the folder where `extract.cmd` and `build.cmd` are stored). Then, you can open it in the DCS Mission Editor and edit it (add/remove units, add triggers, change zones, etc.).

Also, you can edit the mission source files in parallel (using a text editor, I recommend Notepad++ or Visual Studio Code); specifically, you can edit :

- the mission configuration file `src/scripts/missionConfig.lua`, to setup the mission parameters ; this is the main file you'll edit.
- the radio presets file `src/radio/radioSettings.lua`, to setup the radio presets pushed to the aircrafts.
- the weather presets in `src/weatherAndTime`

If you edit one of these files, and because they're compiled *into* the mission `.miz` file, you'll have to *rebuild* your mission before you can test your editions in the game.

There's a way to easily test these changes : the first trigger has a LUA predicate, that conditions the scripts loading method. If set to `false`, the scripts are loading statically (i.e. they're loading *from the mission*) ; if set to `true`, the scripts will be loaded dynamically, so each time you restart the mission in DCS (Left-SHIFT + R) you can test whatever change you saved to the files.

![triggers](https://user-images.githubusercontent.com/172286/109670752-bac72180-7b73-11eb-9d20-cadd84bff1a5.jpg)


### Extract an edited version of the mission

Once a mission has been edited and saved in the DCS mission editor, you need to *extract* its content to the `src` folder, in order to reinject it later with the `build` script.

To do this, simply run the `extract.cmd` script. You don't even need to run it in a `cmd` window, double-clicking it will be ok.

This script will take any mission file starting with the mission name (configured in the beginning of the script), in the mission folder (the folder where `extract.cmd` and `build.cmd` are stored, not the `build` folder), extract its content, process them and store them in `src`.

### Advanced settings

#### Setting the location of the 7zip executable

If your 7zip tool is not in your PATH, you can set its location in the `SEVENZIP` environment variable. It's a string which should point to the `7za` executable (e.g. `c:\tools\7zip\bin\7zip.exe`)

#### Setting the location of the LUA executable

In the same way, you can set its location of the LUA executable in the `LUA` environment variable. It's a string which should point to the `lua` executable (e.g. `c:\tools\lua\bin\lua.exe`)

#### Skip the pauses

If you set the `NOPAUSE` environment variable to "true", then the pauses in the script will not be marked.

## How to use this - graphic version

![schema](https://user-images.githubusercontent.com/172286/109007616-9ddeaa00-76ac-11eb-89ba-370e16810240.jpg)

