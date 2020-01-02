; ISMONISM (In Start Menu Or Not In Start Menu)
; https://github.com/Winkie1000/ISMONISM

/*
ISMONISM license: MIT License

Copyright (c) 2019-2020 Winkie

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

> This script uses:
	AutoHotkey Object conversion from JSON-like text. Copyright © 2011-2012 [VxE]. All rights reserved.
	https://github.com/Jim-VxE/AHK-Lib-JSON_ToObj
	
	Redistribution and use in source and binary forms, with or without modification, are permitted provided that
	the following conditions are met:
	
	1. Redistributions of source code must retain the above copyright notice, this list of conditions and the
	following disclaimer.
	
	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
	following disclaimer in the documentation and/or other materials provided with the distribution.
	
	3. The name "VxE" may not be used to endorse or promote products derived from this software without specific
	prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY VxE "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
	TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
	SHALL VxE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
	BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
	TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
	THE POSSIBILITY OF SUCH DAMAGE.

> This script uses:
	JSON_Beautify() - https://github.com/joedf/JSON_BnU
	MIT License
	
	Copyright (c) Joe DF
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

#LTrim
#NoEnv
#NoTrayIcon
#SingleInstance, Force
SetControlDelay, -1

If ( A_IsCompiled and A_Is64bitOS ) ; Compiled is 32-bit
	EnvGet, sSysProgramFiles, ProgramW6432
Else
	EnvGet, sSysProgramFiles, ProgramFiles
EnvGet, sSysProgramFiles64, ProgramFiles(x86)

oSettings := GetSettingsFromFile()

Menu, ListViewMenu, Add, Copy selected path(s) to clipboard, SelectedToClipboard
Menu, ListViewMenu, Add,
Menu, ListViewMenu, Add, Show focused path in Windows Explorer, FocusedToExplorer
Menu, ListViewMenu, Add, Search online for focused name, FocusedToInternet
Menu, FileMenu, Add, Save settings and restart, MainGuiSaveReload
Menu, FileMenu, Add, Restart without saving settings, MainGuiReload
Menu, FileMenu, Add, Exit, MainGuiClose
Menu, HelpMenu, Add, About, GoAbout
Menu, MenuBar, Add, File, :FileMenu
Menu, MenuBar, Add, Settings, GoUserSettings
Menu, MenuBar, Disable, 2&
Menu, MenuBar, Add, Help, :HelpMenu
Gui, MainGui: New, +Resize +MinSize600x250 +LabelMainGui
Gui, MainGui: Margin, 10, 10
Gui, MainGui: Menu, MenuBar
Gui, MainGui: Add, ListView, w800 h600 AltSubmit Checked Disabled Grid gMainListEvent hwndhMainList1 vcMainList1, |Cnum|Program name|Program path
Gui, MainGui: Add, Button, ym w150 Disabled gCreateShortcuts hwndhButtonShortcut, Create shortcut(s)`n for checked items
Gui, MainGui: Add, Button, xp y+m wp Disabled gCheckedToClipboard hwndhButtonClipboard, Copy checked path(s)`n to clipboard
Gui, MainGui: Add, StatusBar, h22
Gui, MainGui: Show, Center, ISMONISM
WinGet, hMainGui, ID, A
LV_ModifyCol( 2, 0)
LV_ModifyCol( 1, "NoSort" )

aMenuItems := Array()
SB_SetText( "Scanning shortcut folder(s).    (Press ESC to abort scanning)")
For index, sDir in oSettings.ShortcutDirs
{
	Loop, Files, % sDir . "\*.lnk", R
	{
		If bUserCancel
		{
			Gosub, SearchComplete
			Return
		}
		aMenuItems.Push( FileGetShotcutPath( A_LoopFileLongPath ) )
	}
}

For index, sDir in oSettings.SearchDirs
{
	SB_SetText( "Scanning program folder: " . sDir . "    (Press ESC to abort scanning)" )
	Loop, Files, % sDir . "\*.*", R
	{
		If bUserCancel
		{
			Gosub, SearchComplete
			Return
		}
		If A_LoopFileExt and InStr( oSettings.FileTypes, A_LoopFileExt, , 1 )
		{
			If Not HasVal( aMenuItems, A_LoopFileLongPath )
			{
				LV_Add( "", "", "", FileGetName( A_LoopFileLongPath ), A_LoopFileLongPath )
			}
		}
	}
}

Gosub, SearchComplete

Return

SearchComplete:
	LV_ModifyCol( )
	LV_ModifyCol( 2, 0)
	LV_ModifyCol( 3, "200 Sort" )
	WinSet, Enable, , % "ahk_id " . hMainList1
	Menu, MenuBar, Enable, 2&
	bSearchComplete := True
	SB_SetText( bUserCancel ? FormatInteger( LV_GetCount( ) ) . " item(s) found which are not in any shortcut folder (search aborted).          Personal shortcut folder: " . oSettings.PersonalFolder
		: FormatInteger( LV_GetCount( ) ) . " item(s) found which are not in any shortcut folder.          Personal shortcut folder: " . oSettings.PersonalFolder )
	aMenuItems := ""
	sDir := ""
	index := ""
Return

CreateShortcuts:
	bCreateShortcuts := MainListToShortcuts( oSettings.PersonalFolder )
	If bCreateShortcuts
		MsgBox, 64, ISMONISM, % "Done!`n" . bCreateShortcuts . " shortcuts created in " . oSettings.PersonalFolder
	Else
		MsgBox, 16, ISMONISM, % "Error!`nCould not create (shortcuts in) " . oSettings.PersonalFolder
	bCreateShortcuts := ""
Return

CheckedToClipboard:
	Clipboard:= GetMainListPaths( "C" )
Return

MainListEvent:
	If LV_GetNext( 0, "C")
	{
		WinSet, Enable, , % "ahk_id " . hButtonShortcut
		WinSet, Enable, , % "ahk_id " . hButtonClipboard
	}
	Else
	{
		WinSet, Disable, , % "ahk_id " . hButtonShortcut
		WinSet, Disable, , % "ahk_id " . hButtonClipboard
	}
	If ( A_GuiEvent = "ColClick" and A_EventInfo = 1)
		MainListSortChecked()
Return

MainGuiContextMenu:
	If ( A_GuiControl = "cMainList1" and bSearchComplete )
	{
		sFocusedName := GetListViewFocused( 1 )
		sFocusedPath := GetListViewFocused( 2 )
		sSelectedPaths := GetMainListPaths( )
		Menu, ListViewMenu, Delete, 4&
		Menu, ListViewMenu, Add, % "Search online for " . sFocusedName, FocusedToInternet
		Menu, ListViewMenu, Show, % A_GuiX+10, % A_GuiY+10
	}
Return

SelectedToClipboard:
	Clipboard := sSelectedPaths
	sFocusedName := ""
	sFocusedPath := ""
	sSelectedPaths := ""
Return

FocusedToExplorer:
	Run, % "explorer.exe /e`, /n`, /select`," . sFocusedPath, , UseErrorLevel
	sFocusedName := ""
	sFocusedPath := ""
	sSelectedPaths := ""
Return

FocusedToInternet:
	Run, % oSettings.SearchURL . sFocusedName
	sFocusedName := ""
	sFocusedPath := ""
	sSelectedPaths := ""
Return

GoUserSettings:
	bUserProgramFiles := False
	bUserStartMenu := False
	
	Gui, MainGui: +Disabled
	Gui, SettingsGui: New, -Resize +Toolwindow +LabelSettingsGui +OwnerMainGui
	Gui, SettingsGui: Default
	Gui, SettingsGui: Margin, 15, 15
	Gui, SettingsGui: Add, Tab3, AltSubmit viSettingsTab, Main|Search folder(s)|Shorcut folder(s)|File extension(s)
	Gui, SettingsGui: Tab, 1
	Gui, SettingsGui: Add, Text, x+15 w500, Set a folder where shortcuts should be placed:
	Gui, SettingsGui: Add, Edit, xp yp+35 w500 r1 vsPersonalFolder hwndhPersonalFolder, % oSettings.PersonalFolder 
	Gui, SettingsGui: Add, Button, xp+530 yp-1 w120 gSettingsGetPersonalFolder, Select folder
	Gui, SettingsGui: Add, Button, xs+15 yp+38 w120 gSettingsDefaultPersonalFolder, Set default folder
	Gui, SettingsGui: Add, Text, xs+15 yp+68 w500, Set a search engine (the program name will be appended):
	Gui, SettingsGui: Add, Edit, xp yp+35 w500 r1 vsSearchEngine hwndhSearchEngine, % oSettings.SearchURL
	Gui, SettingsGui: Add, Button, xs+15 yp+38 w120 gSettingsDefaultSearchEngine, Set default`nsearch engine
	Gui, SettingsGui: Tab, 2
	Gui, SettingsGui: Add, Text, x+15 w500, Set folder(s) where should be searched for 'missing' items:
	Gui, SettingsGui: Add, Checkbox, xp yp+35 vbUserProgramFiles hwndhUserProgramFiles, % A_Is64bitOS ? "   " . sSysProgramFiles . "`n   " . sSysProgramFiles64 : "   " . sSysProgramFiles
	Gui, SettingsGui: Add, ListView, xp yp+50 w500 h200 AltSubmit Grid -ReadOnly hwndhSettingsListTab2, Folder
	For index, sDir in oSettings.SearchDirs
	{
		If (sDir = sSysProgramFiles Or sDir = sSysProgramFiles64 ) 
		{
			bUserProgramFiles := True
			Continue
		}
		Else
			LV_Add( "", sDir )
	}
	Gui, SettingsGui: Add, Button, xp+530 yp w120 Section gSettingsListAdd, Add
	Gui, SettingsGui: Add, Button, xs wp gSettingsListEdit, Edit focused
	Gui, SettingsGui: Add, Button, xs wp gSettingsListDelete, Remove selected
	Gui, SettingsGui: Tab, 3
	Gui, SettingsGui: Add, Text, x+15 w500, Set folder(s) with shortcuts:
	Gui, SettingsGui: Add, Checkbox, xp yp+35 vbUserStartMenu hwndhUserStartMenu, % "   " . A_StartMenu . "`n   " . A_StartMenuCommon
	Gui, SettingsGui: Add, ListView, xp yp+50 w500 h200 AltSubmit Grid -ReadOnly hwndhSettingsListTab3, Folder
	For index, sDir in oSettings.ShortcutDirs
	{
		If (sDir = A_StartMenu Or sDir = A_StartMenuCommon ) 
		{
			bUserStartMenu := True
			Continue
		}
		Else
			LV_Add( "", sDir )
	}
	Gui, SettingsGui: Add, Button, xp+530 yp w120 Section gSettingsListAdd, Add
	Gui, SettingsGui: Add, Button, xs wp gSettingsListEdit, Edit focused
	Gui, SettingsGui: Add, Button, xs wp gSettingsListDelete, Remove selected
	Gui, SettingsGui: Tab, 4
	Gui, SettingsGui: Add, Text, x+15 w500, Set file extension(s) which should be searched for:
	Gui, SettingsGui: Add, ListView, xp yp+35 w500 h200 AltSubmit Grid -ReadOnly hwndhSettingsListTab4, File extension
	Loop, Parse, % oSettings.FileTypes, `,
		LV_Add( "", A_LoopField )
	Gui, SettingsGui: Add, Button, xp+530 yp w120 Section gSettingsListAdd, Add
	Gui, SettingsGui: Add, Button, xs wp gSettingsListEdit, Edit focused
	Gui, SettingsGui: Add, Button, xs wp gSettingsListDelete, Remove selected
	Gui, SettingsGui: Tab
	Gui, SettingsGui: Add, Button, xm+560 w120 gSettingsGuiSet, &OK
	Gui, SettingsGui: Show, Center, ISMONISM settings
	GuiControl, , % hUserProgramFiles, % bUserProgramFiles
	GuiControl, , % hUserStartMenu, % bUserStartMenu
Return

SettingsGetPersonalFolder:
	ControlGetText, sPersonalFolder, , % "ahk_id " hPersonalFolder
	sPersonalFolder := FileSelectFolder( )
	If sPersonalFolder
		ControlSetText, , % sPersonalFolder , % "ahk_id " hPersonalFolder
Return

SettingsDefaultPersonalFolder:
	ControlSetText, , % A_StartMenu . "\My shortcuts", % "ahk_id " hPersonalFolder
Return

SettingsDefaultSearchEngine:
	ControlSetText, , https://www.duckduckgo.com/?q=, % "ahk_id " hSearchEngine
Return

SettingsListAdd:
	Gui, SettingsGui: Submit, NoHide
	Gui, SettingsGui: ListView, % hSettingsListTab%iSettingsTab%
	If iSettingsTab = 4
	{
		sStr := BetterBox( "Enter a value", "Tip: with a comma between them, you can add multiple`n extensions at once: e.g. 'ahk,bat,msi'."  )
		Gui, SettingsGui: Default
		Loop, Parse, sStr, `,
			LV_Add( "", A_LoopField )
	}
	Else
	{
		sDir := FileSelectFolder( )
		If sDir
			LV_Add( "", sDir )
	}
Return

SettingsListEdit:
	Gui, SettingsGui: Submit, NoHide
	Gui, SettingsGui: ListView, % hSettingsListTab%iSettingsTab%
	If iSettingsTab = 4
		SettingsEditListExt( )
	Else
	{
		sDir := FileSelectFolder( )
		If sDir
			LV_Add( "", sDir )
	}
Return

SettingsListDelete:
	Gui, SettingsGui: Submit, NoHide
	Gui, SettingsGui: ListView, % hSettingsListTab%iSettingsTab%
	SettingsListDelItem( )
Return

SettingsGuiSet:
	Gui, SettingsGui: Submit
	sPersonalFolder := RegExReplace( sPersonalFolder, "\\$" )
	oSettings.PersonalFolder := sPersonalFolder
	oSettings.SearchURL := sSearchEngine
	a := Array()
	Gui, SettingsGui: ListView, % hSettingsListTab2
	Loop, % LV_GetCount()
	{
		LV_GetText( sStr, A_Index )
		a.Push( sStr )
	}
	If bUserProgramFiles
	{
		a.Push( sSysProgramFiles )
		If A_Is64bitOS
			a.Push( sSysProgramFiles64 )
	}
	oSettings.SearchDirs := a
	a := Array()
	Gui, SettingsGui: ListView, % hSettingsListTab3
	Loop, % LV_GetCount()
	{
		LV_GetText( sStr, A_Index )
		a.Push( sStr )
	}
	If bUserStartMenu
	{
		a.Push( A_StartMenu )
		a.Push( A_StartMenuCommon )
	}
	oSettings.ShortCutDirs := a
	Gui, SettingsGui: ListView, % hSettingsListTab4
	Loop, % LV_GetCount()
	{
		LV_GetText( sStr, A_Index )
		If A_Index != 1
			v .= ","
		v .= sStr
	}	
	oSettings.FileTypes := v
	a := ""
	v := ""
	bUserSettings := True
	GoSub, SettingsGuiClose
Return

SettingsGuiEscape:
SettingsGuiClose:
	Gui, MainGui: -Disabled
	Gui, MainGui: Default
	Gui, SettingsGui: Destroy
	WinActivate, % "ahk_id " . hMainGui
	sPersonalFolder := ""
	sSearchEngine := ""
	iSettingsTab := ""
	index := ""
	sDir := ""
	sStr := ""
	hPersonalFolder := ""
	hSearchEngine := ""
	hSettingsListTab2 := ""
	hSettingsListTab3 := ""
	hSettingsListTab4 := ""
	hUserProgramFiles := ""
	hUserStartMenu := ""
Return

GoAbout:
	Gui, MainGui: +Disabled
	Gui, AboutGui: New, +LabelAboutGui +OwnerMainGui -SysMenu
	Gui, AboutGui: Margin, 30, 13
	Gui, AboutGui: Font, Bold
	If A_IsCompiled
		Gui, AboutGui: Add, Picture, xm ym w40 h40 Section, % A_ScriptFullPath
	Else
		Gui, AboutGui: Add, Text, xm-30 ym w0 h0, ; Because of the 'ys'-option of the Text below
	Gui, AboutGui: Add, Text, ys w375,
		(
			ISMONISM is an utility for scanning folders recursively, to find files for which there is no matching shortcut in (a subfolder of) of any user-defined folder.
		)
	Gui, AboutGui: Add, Text, ym+17 w80 h0
	Gui, AboutGui: Add, Button, ym+17 w80 Default gAboutGuiClose, &OK
	Gui, AboutGui: Font
	Gui, AboutGui: Add, Text, xm  Section, Version:
	Gui, AboutGui: Add, Text, xs, Creator:
	Gui, AboutGui: Add, Text, xs, License:
	Gui, AboutGui: Add, Text, ys Section, 0.3.0   (2020-01-02)
	Gui, AboutGui: Add, Text, xs, Winkie
	Gui, AboutGui: Add, Text, xs, see below for the license of ISMONISM and used components
	Gui, AboutGui: Add, Tab3, xm AltSubmit viAboutTab, ISMONISM|JSON_ToObj()|JSON_Beautify()|Icon
	Gui, AboutGui: Tab, 1
	Gui, AboutGui: Add, Button, x+15 w80 Default gAboutLaunchWebsite, Visit website
	Gui, AboutGui: Add, Text, xp yp+35,
	(
		MIT License
		
		Copyright (c) 2019-2020 Winkie

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	)
	Gui, AboutGui: Tab, 2
	Gui, AboutGui: Add, Button, x+15 w80 Default gAboutLaunchWebsite, Visit website
	Gui, AboutGui: Add, Text, xp yp+35,
	(
		AutoHotkey Object conversion from JSON-like text. Copyright © 2011-2012 [VxE]. All rights reserved.
		
		Redistribution and use in source and binary forms, with or without modification, are permitted provided that
		the following conditions are met:
		
		1. Redistributions of source code must retain the above copyright notice, this list of conditions and the
		following disclaimer.
		
		2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
		following disclaimer in the documentation and/or other materials provided with the distribution.
		
		3. The name "VxE" may not be used to endorse or promote products derived from this software without specific
		prior written permission.

		THIS SOFTWARE IS PROVIDED BY VxE "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
		TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
		SHALL VxE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
		(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
		BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
		TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
		THE POSSIBILITY OF SUCH DAMAGE.
	)
	Gui, AboutGui: Tab, 3
	Gui, AboutGui: Add, Button, x+15 w80 Default gAboutLaunchWebsite, Visit website
	Gui, AboutGui: Add, Text, xp yp+35,
	(
		MIT License
		
		Copyright (c) Joe DF

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	)
		Gui, AboutGui: Tab, 4
	Gui, AboutGui: Add, Button, x+15 w80 Default gAboutLaunchWebsite, Visit website
	Gui, AboutGui: Add, Text, xp yp+35,
	(
		Copyright (c) Iconic Hub

		Free for commercial use.
	)
	Gui, AboutGui: Show, Center, About ISMONISM
Return

AboutLaunchWebsite:
	Gui, AboutGui: Submit, NoHide
	If iAboutTab = 1
		Run, https://github.com/Winkie1000/ISMONISM
	Else If iAboutTab = 2
		Run, https://github.com/Jim-VxE/AHK-Lib-JSON_ToObj
	Else If iAboutTab = 3
		Run, https://github.com/joedf/JSON_BnU
	Else
		Run, https://www.iconfinder.com/icons/1886938/files_folder_search_storage_icon
	iAboutTab := ""
Return

AboutGuiClose:
AboutGuiEscape:
	Gui, MainGui: -Disabled
	Gui, AboutGui: Destroy
	WinActivate, % "ahk_id " . hMainGui
Return

MainGuiSize:
	Critical, Off
	Sleep, -1
	AutoXYWH( "wh", hMainList1 )
	AutoXYWH( "x", hButtonShortcut, hButtonClipboard )
Return

MainGuiEscape:
	bUserCancel := True
Return

MainGuiReload:
	Reload
Return

MainGuiSaveReload:
	Gosub, SaveSettings
	Reload
Return

MainGuiClose:
	If bUserSettings
		Gosub, SaveSettings
	ExitApp
Return

SaveSettings:
	oFile := FileOpen( "ISMONISM.json", "w" )
	oFile.Write( JSON_Beautify( oSettings ) )
	oFile.Close( )
Return

MainListToShortcuts( sPersonalFolder )
{
	Try
	{
		i := 0
		Loop
		{
			i := LV_GetNext( i, "C" )
			If not i
				Break
			LV_GetText( sName, i, 1 )
			sName := FileGetBaseName( sName )
			LV_GetText( sPath, i, 2 )
			If Not InStr( FileExist( sPersonalFolder ), "D" )
				FileCreateDir, % sPersonalFolder
			FileCreateShortCut, % sPath, % sPersonalFolder . "\" . sName . ".lnk"
			iOut++
		}
		Return iOut
	}
	Catch e
	{
		Return 0
	}
}

GetMainListPaths( sRowType := "" )
{
	i := 0
	Loop
	{
		i := LV_GetNext( i, sRowType )
		If not i
			Break
		LV_GetText( Txt, i, 2 )
		If ( A_Index != 1 )
			v .= "`n"
		v .= Txt
	}
	If v
		Return v
}

GetListViewFocused( iColumn)
{
	i := LV_GetNext( i, "F" )
	LV_GetText( v, i, iColumn )
	Return v
}

MainListSortChecked()
{
	i := 0
	If Not  LV_GetNext( i, "C" )
	{
		Loop, % LV_GetCount()
			LV_Modify( A_Index, "", "", "" )
		LV_ModifyCol(3, "Sort")
	}
	Else
	{
		Loop
		{
			i := LV_GetNext( i, "C" )
			If not i
				Break
			LV_Modify( i, "", "", "1" )
		}
		LV_ModifyCol(3, "Sort")
		LV_ModifyCol(2, "SortDesc")
	}
}

GetSettingsFromFile()
{
	Global bUserSettings
	If FileExist( "ISMONISM.json" )
	{
	
		s := FileRead( "ISMONISM.json" )
		o := JSON_ToObj( s )
	}
	Else
	{
		o := SetDefaultSettings()
		bUserSettings := True
	}
	Return o
}

SetDefaultSettings()
{
	o := Object()
	o.FileTypes := "exe"
	o.PersonalFolder := A_StartMenu . "\My shortcuts"
	o.SearchDirs := [ "C:\Program Files", "C:\Program Files (x86)" ]
	o.SearchURL := "https://www.duckduckgo.com/?q="
	o.ShortcutDirs := [ A_StartMenu, A_StartMenuCommon ]
	Return o
}
SettingsListDelItem()
{
	Loop
	{
		i := LV_GetNext( 0 )
		If not i
			Break
		LV_Delete( i )
	}
}

SettingsEditListExt(  )
{
	i := LV_GetNext( 0, "F" )
	If i < 1
		i := 1
	LV_GetText( Txt, i)
	If Txt
		Txt := BetterBox( "Edit value", , Txt )
	If Txt
	{
		Gui, SettingsGui: Default
		LV_Modify( i, "Col", Txt )
	}
}

; By wolf_II (modified by Winkie) - https://www.autohotkey.com/boards/viewtopic.php?p=253784#p253784
BetterBox(Title := "", Prompt := "", Default := "", Pos := -1) {
; Title: the title for the GUI
; Prompt: is the text to display
; Pos: the position of the text insertion point
;	Pos =  0  => at the start of the string
;	Pos =  1  => after the first character of the string
;	Pos = -1  => at the end of the string

	Static Result
	
	Gui, SettingsGui: +Disabled
	Gui, BetterBox: New,, %Title%
	Gui, BetterBox: +Toolwindow +OwnerSettingsGui
	Gui, BetterBox: Margin, 30, 18
	If Prompt
		Gui, BetterBox: Add, Text,, %Prompt%
	Gui, BetterBox: Add, Edit, w290 vResult, %Default%
	Gui, BetterBox: Add, Button, x80 w80 Default, &OK
	Gui, BetterBox: Add, Button, x+m wp, &Cancel
	Gui, BetterBox: Show
	
	Gui, BetterBox: +LastFound
	SendMessage, 0xB1, %Pos%, %Pos%, Edit1 ; EM_SETSEL
	WinWaitClose
	Return Result

	BetterBoxButtonOK:
		Gui, SettingsGui: -Disabled
		Gui, BetterBox: Submit
		Gui, BetterBox: Destroy
	Return

	BetterBoxButtonCancel:
	BetterBoxGuiClose:
	BetterBoxGuiEscape:
		Gui, SettingsGui: -Disabled
		Gui, BetterBox: Destroy
		Result := ""
	Return
}

FileRead( sPath )
{
	FileRead, v, % sPath
	Return v
}

FileGetBaseName( sPath )
{
	v := sPath, DllCall( "shlwapi.dll\PathRemoveExtension", Str, v )
	Return v
}

FileGetName( sPath )
{
	SplitPath, sPath, v
	Return v
}

FileGetShotcutPath( sPath )
{
	FileGetShortcut, % sPath, v
	If v
		Return v
}

FileSelectFolder()
{
	FileSelectFolder, v, , , Select a folder.
	Return v
}

FormatInteger( Int )
{
	vVar := Int
	Loop
	{
		If vVar > 999
		{
			StringLen, vLen, vVar
			StringTrimLeft, vPart, vVar, % vLen - 3
			vOut := "." vPart vOut
			StringTrimRight, vVar, vVar, 3
		}
		Else
			Break
	}
	Return vVar vOut
}

; HasVal() -- by jNizM & Lexicos -- https://github.com/jNizM/AHK_Scripts/blob/master/src/arrays/HasVal.ahk
HasVal(haystack, needle) 
{
	For index, value in haystack
		If (value = needle)
			Return index
	If !(IsObject(haystack))
		Throw Exception("Bad haystack!", -1, haystack)
	Return 0
}