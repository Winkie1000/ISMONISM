# ISMONISM
<img align="left" src="https://raw.githubusercontent.com/Winkie1000/ISMONISM/master/Resources/Icon.png" alt="ISMONISM logo" height="40px" style="margin-top: 5px">

ISMONISM (*In Start Menu Or Not In Start Menu*) is an utility for scanning folders recursively, to find files for which there is no matching shortcut in (a subfolder of) any user-defined folder.

This utility was originally created with the Windows Start Menu in mind. By default it searches for executables (.exe) in the `Program Files` folders. However, both the extension(s) to search for and the search folder(s) are user configurable.

It has the ability to create shortcuts of found items in a user configurable 'personal shortcut folder' (By default a subfolder of the Start Menu).

## Screenshot
![ISMONISM screenshot](https://raw.githubusercontent.com/Winkie1000/ISMONISM/master/Resources/Screenshot-01.png)

### Settings
![ISMONISM settings screenshot](https://raw.githubusercontent.com/Winkie1000/ISMONISM/master/Resources/Screenshot-02.png)

## Using the source code

The script is created with [AutoHotkey](https://www.autohotkey.com/download/) 1.1.32.00 Unicode.

In order to launch  `ISMONISM.ahk` from the root of this repository the following scripts are needed in a [Library](https://www.autohotkey.com/docs/Functions.htm#lib):
- `JSON_ToObj.ahk` by Vxe from [here](https://github.com/Jim-VxE/AHK-Lib-JSON_ToObj).
- `JSON_Beautify.ahk` by Joe DF from [here](https://github.com/joedf/JSON_BnU).

## License and credits

ISMONISM is licensed under the [MIT License](https://opensource.org/licenses/MIT).

For more information, see the [license](LICENSE).

This script/application uses the following components:

- `JSON_ToObj.ahk` by [Vxe](https://github.com/Jim-VxE): AutoHotkey Object conversion from JSON-like text. Copyright © 2011-2012 [VxE]. All rights reserved. For information about the license see the top of the [source](ISMOMISM.ahk).
- `JSON_Beautify.ahk` by [Joe DF](https://joedf.ahkscript.org/about.html), licenced under the [MIT License](https://opensource.org/licenses/MIT). For more information see the top of the [source](ISMOMISM.ahk).
- The icon/logo is copyrighted: (C) Iconic Hub, licensed free for commercial use. See the
[Iconfinder.com file page](https://www.iconfinder.com/icons/1886938/files_folder_search_storage_icon).
- `HasVal()` by [jNizM](https://github.com/jNizM) & [Lexicos](https://github.com/Lexikos), unlicensed open source code from [here](https://github.com/jNizM/AHK_Scripts/blob/master/src/arrays/HasVal.ahk). For more information see the corresponding [AutoHotkey.com Forum post](https://www.autohotkey.com/boards/viewtopic.php?p=110388#p110388).
- `BetterBox()` by wolf_II, unlicensed open source code from [here](https://www.autohotkey.com/boards/viewtopic.php?p=253712).

## See also

This project was created as part of NANY 2020 (*New Apps for the New Year*), hosted by [DonationCoder.com](https://www.donationcoder.com/). For more information see [this forum topic](https://www.donationcoder.com/forum/index.php?topic=49299).