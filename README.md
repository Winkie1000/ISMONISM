# ISMONISM
<img align="left" src="https://raw.githubusercontent.com/Winkie1000/ISMONISM/master/Resources/Icon.png" alt="ISMONISM logo" height="40px" style="margin-top: 5px">

ISMONISM (*In Start Menu Or Not In Start Menu*) is an utility for scanning folders recursively, to find files for which there is no matching shortcut in (a subfolder of) any user-defined folder.

This utility was originally created with the Windows Start Menu in mind. By default it searches for executables (*.exe) in the `Program Files` folders. However, both the extension(s) to search for and the search folder(s) are user configurable.

It has the ability to create shortcuts of found items in a user configurable 'personal shortcut folder' (By default a subfolder of the Start Menu).

## Screenshot
![ISMONISM screenshot](https://raw.githubusercontent.com/Winkie1000/ISMONISM/master/Resources/Screenshot-01.png)

### Settings
![ISMONISM settings screenshot](https://raw.githubusercontent.com/Winkie1000/ISMONISM/master/Resources/Screenshot-02.png)

## Using the source code

The script is created with [AutoHotkey](https://www.autohotkey.com/download/) 1.1.32.00 - 1.1.33.02 Unicode.

In order to launch  `ISMONISM.ahk` [from the root of this repository](ISMONISM.ahk) the following is needed:
- These scripts are needed in a [Library](https://www.autohotkey.com/docs/Functions.htm#lib):
	- `JSON_ToObj.ahk` by Vxe from [here](https://github.com/Jim-VxE/AHK-Lib-JSON_ToObj).
	- `JSON_Beautify.ahk` by Joe DF from [here](https://github.com/joedf/JSON_BnU).
	- `AutoXYWH.ahk` by tmplinshi & toralf from [here](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1079).
	- `Class_SQLiteDB.ahk` by just me form [here](https://github.com/AHK-just-me/Class_SQLiteDB).
- `sqlite3.dll` from [here](https://www.sqlite.org/download.html#win32) is needed alongside `ISMONISM.ahk`. Be sure to download the right bit-version.

## License and credits

ISMONISM is licensed under the [MIT License](https://opensource.org/licenses/MIT).

For more information, see the [license](LICENSE).

This script/application uses the following components:

- `JSON_ToObj.ahk` by [Vxe](https://github.com/Jim-VxE): AutoHotkey Object conversion from JSON-like text. Copyright © 2011-2012 [VxE]. All rights reserved. For information about the license see the top of the [source](ISMOMISM.ahk).
- `JSON_Beautify.ahk` by [Joe DF](https://joedf.ahkscript.org/about.html), licenced under the [MIT License](https://opensource.org/licenses/MIT). For more information see the top of the [source](ISMOMISM.ahk).
- The icon/logo is copyrighted: (C) Iconic Hub, licensed free for commercial use. See the
[Iconfinder.com file page](https://www.iconfinder.com/icons/1886938/files_folder_search_storage_icon).
- `HasVal()` by [jNizM](https://github.com/jNizM) & [Lexicos](https://github.com/Lexikos), unlicensed open source code from [here](https://github.com/jNizM/AHK_Scripts/blob/master/src/arrays/HasVal.ahk). For more information see the corresponding [AutoHotkey.com forum post](https://www.autohotkey.com/boards/viewtopic.php?p=110388#p110388).
- `AutoXYWH()` by [tmplinshi](https://github.com/tmplinshi) & [toralf](https://github.com/Toralf-AHK), unlicensed open source code from from [here](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1079).
- `BetterBox()` by wolf_II, unlicensed open source code from [here](https://www.autohotkey.com/boards/viewtopic.php?p=253712).
- `Class_SQLiteDB` by [just me](https://github.com/AHK-just-me), open source code [released in the public domain](http://unlicense.org/). For more information see the top of the [source](ISMOMISM.ahk).
- `sqlite3.dll`  by the [SQLite Developers](https://www.sqlite.org/crew.html), open source software [released in the public domain](https://www.sqlite.org/copyright.html).

## See also

This project was created as part of NANY 2020 (*New Apps for the New Year*), hosted by [DonationCoder.com](https://www.donationcoder.com/). For more information see the corresponding [DonationCoder.com forum topic](https://www.donationcoder.com/forum/index.php?topic=49299).