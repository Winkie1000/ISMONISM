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

> This script uses:
	Class_SQLiteDB - https://github.com/AHK-just-me/Class_SQLiteDB
	This is free and unencumbered software released into the public domain.
	
	Anyone is free to copy, modify, publish, use, compile, sell, or
	distribute this software, either in source code form or as a compiled
	binary, for any purpose, commercial or non-commercial, and by any
	means.

	In jurisdictions that recognize copyright laws, the author or authors
	of this software dedicate any and all copyright interest in the
	software to the public domain. We make this dedication for the benefit
	of the public at large and to the detriment of our heirs and
	successors. We intend this dedication to be an overt act of
	relinquishment in perpetuity of all present and future rights to this
	software under copyright law.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.

	For more information, please refer to <http://unlicense.org>
*/

#LTrim
#NoEnv
#NoTrayIcon
#SingleInstance, Force
SetBatchLines, -1
SetControlDelay, -1
SetWorkingDir, % A_ScriptDir

#Include <Class_SQLiteDB>

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
Menu, FileMenu, Add, Start a new search`tF5, Dosearch
Menu, FileMenu, Add, Reload last saved search`tF6, ReloadLastSaved
Menu, FileMenu, Add,
Menu, FileMenu, Add, Open personal folder in Windows Explorer`tCtrl+E, OpenPersonalFolder
Menu, FileMenu, Add,
Menu, FileMenu, Add, Restart without modifying data files`tCtrl+R, MainGuiReload
Menu, FileMenu, Add, Exit`tAlt+F4, MainGuiClose
Menu, HelpMenu, Add, About`tF1, GoAbout
Menu, MenuBar, Add, File, :FileMenu
Menu, SettingsMenu, Add, Change settings`tF9, GoUserSettings
Menu, SettingsMenu, Add, Save settings to file`tF12, SaveSettings
Menu, MenuBar, Add, Settings, :SettingsMenu
Menu, MenuBar, Add, Help, :HelpMenu
Gui, MainGui: New, +Resize +MinSize650x400 +LabelMainGui
Gui, MainGui: Margin, 10, 10
Gui, MainGui: Menu, MenuBar
Gui, MainGui: Add, ListView, w780 h600 AltSubmit Checked Disabled Grid gMainListEvent hwndhMainList1 vcMainList1, |Cnum|Program name|Program path ; Column 1 = Checkmark + Icon
Gui, MainGui: Font, Bold
Gui, MainGui: Add, Button, ym w170 r2 gDoSearch hwndhButtonSearch, Start search
Gui, MainGui: Font, Normal
Gui, MainGui: Add, Picture, xp+30 y+20 w64 h-1 hwndhFileIcon vcFileIcon
Gui, MainGui: Add, Text, xp-30 y+100 w170 h1 Border hwndhBorder
Gui, MainGui: Add, Text, xp y+20 wp hwndhTextFolderCaption, Personal shortcut folder:
Gui, MainGui: Font, s8, Verdana
Gui, MainGui: Font, s10, Tahoma
Gui, MainGui: Font, s10, Consolas
Gui, MainGui: Add, Text, xp y+m wp r6 hwndhTextPersonalFolder, % StrReplace( oSettings.PersonalFolder, "\", " \ " )
Gui, MainGui: Font,
Gui, MainGui: Add, Button, xp y+20 wp Disabled gCreateShortcuts hwndhButtonShortcut, Create shortcut(s)`n for checked item(s)
Gui, MainGui: Add, Button, xp y+m wp Disabled gCheckedToClipboard hwndhButtonClipboard, Copy checked path(s)`n to clipboard
Gui, MainGui: Add, StatusBar, h22
Gui, MainGui: Show, Center, ISMONISM
WinGet, hMainGui, ID, A
LV_ModifyCol( 1, "NoSort" )
LV_ModifyCol( 2, 0)

GroupAdd, ISMONISM_Main, % "ahk_id " . hMainGui
If oSettings.MaximizeAtLaunch
	WinMaximize, % "ahk_id " . hMainGui

If oSettings.SearchAtLaunch
	Gosub, DoSearch
Else If oSettings.LastSavedAtLaunch
	Gosub, ReloadLastSaved
Else
	Gosub, MainGuiIdle
Return

DoSearch:
	Gosub, DeleteDatabase
	If not bSearchCancel
	{
		Gosub, SearchBegin
		Gosub, SearchFileLoop
	}
	If bSearchCancel
		Gosub, SearchComplete
	Else 
		Gosub, SearchListLoad
Return

ReloadLastSaved:
	If FileExist( "Data\search0.db" )
	{
		Gosub, SearchBegin
		Gosub, SearchListLoad
	}
	Else
	{
		ErrorMsg( "No database file found." )
		If not LV_GetCount()
			Gosub, MainGuiIdle
	}
Return

SearchBegin:
	Menu, MenuBar, Disable, 2&
	WinSet, Disable, , % "ahk_id " . hButtonSearch
	WinSet, Disable, , % "ahk_id " . hMainList1
	bIsSearching := True
	LV_Delete( )
	GuiControl, -Redraw, hMainList1
	GuiControl, , cFileIcon
Return

SearchFileLoop:
	SB_SetText( "Creating database." )
	Gosub, OpenDatabase
	sSQL := "CREATE TABLE Shortcuts( Path );"
	If not oDb.Exec( sSQL )
		DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
		sSQL := "CREATE TABLE Programs( Path );"
	If not oDb.Exec( sSQL )
		DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
	
	If not oDB.Exec( "BEGIN TRANSACTION;" )
		DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
	For index, sDir in oSettings.ShortcutDirs
	{
		SB_SetText( "Scanning shortcut folder.   (Press ESC to abort scanning)   -   " . sDir)
		Loop, Files, % sDir . "\*.lnk", R
		{
			If bSearchCancel
			{
				Gosub, SearchAborted
				Return
			}
			sFile := FileGetShotcutPath( A_LoopFileLongPath )
			sFileExt := FileGetExt( sFile )
			If HasVal( oSettings.FileTypes, sFileExt )
			{
				sSQL := "INSERT INTO Shortcuts( Path ) VALUES (" SQLiteEscapeString( sFile ) . ");"
				If not oDB.Exec( sSQL )
					DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
			}
		}
	}
	
	For index, sDir in oSettings.SearchDirs
	{
		SB_SetText( "Scanning program folder.   (Press ESC to abort scanning)   -   " . sDir )
		Loop, Files, % sDir . "\*.*", R
		{
			If bSearchCancel
			{
				Gosub, SearchAborted
				Return
			}
			If A_LoopFileExt and HasVal( oSettings.FileTypes, A_LoopFileExt )
			{
				sSQL := "INSERT INTO Programs( Path ) VALUES (" SQLiteEscapeString( A_LoopFileLongPath ) . ");"
				If not oDB.Exec( sSQL )
					DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
			}
		}
	}
	SB_SetText( "Writing to database." )
	If not oDb.Exec( "COMMIT TRANSACTION;" )
		DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
	Gosub, CloseDatabase
Return

SearchListLoad:
	Gosub, OpenDatabase
	sSQL := "SELECT DISTINCT Path FROM Programs WHERE Path COLLATE NOCASE NOT IN ( SELECT DISTINCT path FROM Shortcuts )"
	If not oDb.GetTable( sSQL, oTable )
		DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
	SB_SetText( "Reporting.   (Press ESC to abort reporting)" )
	If oTable.HasRows
	{
		If oSettings.ListViewIcons
		{
			Il_Destroy( hImageList )
			hImageList := IL_Create( 0, 1 )
			LV_SetImageList( hImageList )
		}
		Loop, % oTable.RowCount
		{
			If bSearchCancel
			{
				Gosub, SearchComplete
				Return
			}
			oTable.Next( oRow )
			If oSettings.ListViewIcons
				i := Il_Add( hImageList, oRow[1] )
			LV_Add( "Icon" . i, "", "", FileGetName( oRow[1] ), oRow[1] )
		}
		oRow.Free()
	}
	Gosub, CloseDatabase
	Gosub, SearchComplete
Return

SearchComplete:
	GuiControl, +Redraw, hMainList1
	If LV_GetCount()
	{
		If oSettings.ListViewIcons
			LV_ModifyCol( 1, 40)
		LV_ModifyCol( 2, 0)
		LV_ModifyCol( 3, "Sort" )
		LV_ModifyCol( 3 )
		LV_ModifyCol( 4 )
	}
	WinSet, Enable, , % "ahk_id " . hMainList1
	Menu, MenuBar, Enable, 2&
	bIsSearching := False
	ControlSetText, , New search, % "ahk_id " hButtonSearch
	WinSet, Enable, , % "ahk_id " . hButtonSearch
	Gosub, MainGuiUpdateStatus
	FileDelete, Data\search0.db.tmp
	bSearchCancel := False
	sDir := ""
	index := ""
	ControlFocus, , % "ahk_id " . hMainList1
Return

SearchAborted:
	Gosub, CloseDatabase
	FileMove, Data\search0.db.tmp, Data\search0.db, 1
Return

OpenDatabase:
	odb := new SQLiteDB
	If not oDb.OpenDb( A_ScriptDir . "\Data\search0.db" )
		DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
Return

CloseDatabase:
	If not oDb.CloseDB()
		DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
Return

DeleteDatabase:
	If FileExist( A_ScriptDir . "\Data\search0.db" )
	{
		Try
				FileMove, Data\search0.db, Data\search0.db.tmp, 1
		Catch e
		{
			ErrorMsg( "File operations on the database file failed." )
			bSearchCancel := True
		}
	}
Return

MainGuiUpdateStatus:
	SB_SetText( LV_GetCount() = 1 ? "1 item in the list." : FormatInteger( LV_GetCount( ) ) . " items in the list." )
	Gosub, MainListEvent
Return

CreateShortcuts:
	oShortcuts := MainListToShortcuts( oSettings.PersonalFolder )
	If IsObject( oShortcuts )
	{
		Gui, MainGui: +Disabled
		
		bShortcutCreateRemoveListRow := oSettings.ShortcutCreateRemoveListRow
		bShortcutCreateUpdateDatabase := oSettings.ShortcutCreateUpdateDatabase
		Gui, ShortcutGui: New, -Resize +Toolwindow +LabelShortcutGui +OwnerMainGui
		Gui, ShortcutGui: Default
		Gui, ShortcutGui: Margin, 20, 15
		Gui, ShortcutGui: Add, Picture, xm ym w32 h32 Icon278 Section, % A_WinDir . "\System32\shell32.dll"
		Gui, ShortcutGui: Font, Bold
		Gui, ShortcutGui: Add, Text, ys+8, Done!
		Gui, ShortcutGui: Font,
		Gui, ShortcutGui: Add, Text, xm, % oShortcuts.Count() . " shortcut(s) created in:`n" . oSettings.PersonalFolder
		Gui, ShortCutGui: Add, Text, , Do next:
		Gui, ShortcutGui: Add, Checkbox, vbShortcutCreateRemoveListRow Checked%bShortcutCreateRemoveListRow%, Delete checkmarked row(s) from the list.
		Gui, ShortcutGui: Add, Checkbox, vbShortcutCreateUpdateDatabase Checked%bShortcutCreateUpdateDatabase%, Update the database file.
		Gui, ShortCutGui: Add, Text,
		Gui, ShortcutGui: Add, Button, gShortcutGuiSet hwndhSchortcutGuiButton Hidden w80, OK
		Gui, ShortcutGui: Show, Center, ISMONISM
		ControlMove, , % ( WinGetWidth() / 2 ) - 40, , , , % "ahk_id " . hSchortcutGuiButton
		Gui, ShortcutGui: Show, Center, ISMONISM
		GuiControl, Show, % hSchortcutGuiButton
	}
	Else
		ErrorMsg( "Could not create (shortcuts in) " . oSettings.PersonalFolder )
Return

ShortcutGuiSet:
	Gui, ShortcutGui: Submit
	Gui, MainGui: Default
	If bShortcutCreateRemoveListRow
	{
		Loop
		{
			i := 0
			i := LV_GetNext( i, "C" )
			If not i
				Break
			LV_Delete( i )
		}
		Gosub, MainGuiUpdateStatus
	}
	If bShortcutCreateUpdateDatabase
	{
		Gosub, OpenDatabase
		For index, sPath in oShortcuts
		{
			sSQL := "INSERT INTO Shortcuts( Path ) VALUES (" SQLiteEscapeString( sPath ) . ");"
			If not oDB.Exec( sSQL )
				DatabaseError( oDb.ErrorMsg , oDb.ErrorCode )
		}
		Gosub, CloseDatabase
		sDir := ""
		index := ""
	}
	If ( bShortcutCreateRemoveListRow != oSettings.ShortcutCreateRemoveListRow ) or ( bShortcutCreateUpdateDatabase != oSettings.ShortcutCreateUpdateDatabase )
	{
		oSettings.ShortcutCreateRemoveListRow := bShortcutCreateRemoveListRow
		oSettings.ShortcutCreateUpdateDatabase := bShortcutCreateUpdateDatabase
		bSettingNeedsSave := True
	}
	Gosub, ShortcutGuiClose
	i := ""
Return

ShortcutGuiEscape:
ShortcutGuiClose:
	Gui, MainGui: -Disabled
	Gui, MainGui: Default
	Gui, ShortcutGui: Destroy
	WinActivate, % "ahk_id " . hMainGui
	oShortcuts := ""
	bShortcutCreateRemoveListRow := ""
	bShortcutCreateUpdateDatabase := ""
	hSchortcutGuiButton := ""
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
	Else
		GuiControl, , cFileIcon, % "*w64 *h-1 *Icon1 " GetListViewFocused( 4 )
Return

MainGuiContextMenu:
	If ( A_GuiControl = "cMainList1" and not bIsSearching and LV_GetCount() )
	{
		sFocusedName := GetListViewFocused( 3 )
		sFocusedPath := GetListViewFocused( 4 )
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

MainGuiIdle:
	LV_ModifyCol( 3, 200)
	LV_ModifyCol( 4, 200)
	SB_SetText( "Ready.")
Return

OpenPersonalFolder:
	Run, % "explore " . oSettings.PersonalFolder
Return

GoUserSettings:
	If bIsSearching
		Return
	bUserProgramFiles := False
	bUserProfileData := False
	bUserStartMenu := False
	
	bMaximizeAtLaunch := oSettings.MaximizeAtLaunch
	bSearchAtLaunch := oSettings.SearchAtLaunch
	bLastSavedAtLaunch := oSettings.LastSavedAtLaunch
	bListViewIcons := oSettings.ListViewIcons
	
	If not bSearchAtLaunch and not bLastSavedAtLaunch
		bNothingAtLaunch := 1
		
	Gui, MainGui: +Disabled
	Gui, SettingsGui: New, -Resize +Toolwindow +LabelSettingsGui +OwnerMainGui
	Gui, SettingsGui: Default
	Gui, SettingsGui: Margin, 15, 15
	Gui, SettingsGui: Add, Tab3, AltSubmit viSettingsTab, Main|Search folder(s)|Shorcut folder(s)|File extension(s)|Other
	Gui, SettingsGui: Tab, 1
	Gui, SettingsGui: Add, Text, x+15 Section, When ISMONISM is launched:
	Gui, SettingsGui: Add, Checkbox, x+m ys vbMaximizeAtLaunch Checked%bMaximizeAtLaunch%, Start with a maximized window
	Gui, SettingsGui: Add, Radio, xp y+m Section vbNothingAtLaunch Checked%bNothingAtLaunch%, Do not load a search
	Gui, SettingsGui: Add, Radio, xp y+m vbSearchAtLaunch Checked%bSearchAtLaunch%, Start a new search
	Gui, SettingsGui: Add, Radio, xp y+m vbLastSavedAtLaunch Checked%bLastSavedAtLaunch%, Load the last saved search results
	Gui, SettingsGui: Add, Text, xp y+m
	Gui, SettingsGui: Add, Text, xm+15 y+m Section, Number of database files with searches to be kept:
	Gui, SettingsGui: Add, Edit, x+m yp-3 w50
	Gui, SettingsGui: Add, UpDown, Range0-1 viDatabaseSaves, % oSettings.DatabaseSaves
	Gui, SettingsGui: Add, Text, xp y+m
	Gui, SettingsGui: Add, Text, xm+15 y+m w500, Set a folder where shortcuts should be placed:
	Gui, SettingsGui: Add, Edit, xp y+m w500 r1 vsPersonalFolder hwndhPersonalFolder, % oSettings.PersonalFolder 
	Gui, SettingsGui: Add, Button, x+m yp-1 w120 gSettingsGetPersonalFolder, Select folder
	Gui, SettingsGui: Add, Button, xm+15 yp+38 w120 gSettingsDefaultPersonalFolder, Set default folder
	Gui, SettingsGui: Tab, 2
	Gui, SettingsGui: Add, Text, x+m w500, Set folder(s) where should be searched for 'missing' items:
	Gui, SettingsGui: Add, Checkbox, xp y+m vbUserProgramFiles hwndhUserProgramFiles, % A_Is64bitOS ? "   " . sSysProgramFiles . "`n   " . sSysProgramFiles64 : "   " . sSysProgramFiles
	Gui, SettingsGui: Add, Checkbox, xp y+m vbUserProfileData hwndhUserProfileData, % "   " . A_AppData . "`n   " . A_AppDataCommon
	Gui, SettingsGui: Add, ListView, xp yp+50 w500 h200 AltSubmit Grid -ReadOnly gSettingsListEvent hwndhSettingsListTab2, Folder
	For index, sPath in oSettings.SearchDirs
	{
		If ( sPath = sSysProgramFiles Or sPath = sSysProgramFiles64 ) 
		{
			bUserProgramFiles := True
			Continue
		}
		Else If ( sPath = A_AppData Or sPath = A_AppDataCommon ) 
		{
			bUserProfileData := True
			Continue
		}
		Else
			LV_Add( "", sPath )
	}
	Gui, SettingsGui: Add, Button, x+m yp w120 Section gSettingsListAdd, Add
	Gui, SettingsGui: Add, Button, xs wp Disabled gSettingsListEdit hwndhSettingsEditListTab2, Edit selected
	Gui, SettingsGui: Add, Button, xs wp Disabled gSettingsListDelete hwndhSettingsDelListTab2, Remove selected
	Gui, SettingsGui: Tab, 3
	Gui, SettingsGui: Add, Text, x+m w500, Set folder(s) with shortcuts to compare against:
	Gui, SettingsGui: Add, Checkbox, xp y+m vbUserStartMenu hwndhUserStartMenu, % "   " . A_StartMenu . "`n   " . A_StartMenuCommon
	Gui, SettingsGui: Add, ListView, xp yp+50 w500 h200 AltSubmit Grid -ReadOnly gSettingsListEvent hwndhSettingsListTab3, Folder
	For index, sPath in oSettings.ShortcutDirs
	{
		If ( sPath = A_StartMenu Or sPath = A_StartMenuCommon ) 
		{
			bUserStartMenu := True
			Continue
		}
		Else
			LV_Add( "", sPath )
	}
	Gui, SettingsGui: Add, Button, x+m yp w120 Section gSettingsListAdd, Add
	Gui, SettingsGui: Add, Button, xs wp Disabled gSettingsListEdit hwndhSettingsEditListTab3, Edit selected
	Gui, SettingsGui: Add, Button, xs wp Disabled gSettingsListDelete hwndhSettingsDelListTab3, Remove selected
	Gui, SettingsGui: Tab, 4
	Gui, SettingsGui: Add, Text, x+15 w500, Set file extension(s) which should be searched for:
	Gui, SettingsGui: Add, ListView, xp y+m w500 h200 AltSubmit Grid -ReadOnly gSettingsListEvent hwndhSettingsListTab4, File extension
	For index, sExt in oSettings.FileTypes
	{
		LV_Add( "", sExt )
	}
	Gui, SettingsGui: Add, Button, x+m yp w120 Section gSettingsListAdd, Add
	Gui, SettingsGui: Add, Button, xs wp Disabled gSettingsListEdit hwndhSettingsEditListTab4, Edit selected
	Gui, SettingsGui: Add, Button, xs wp Disabled gSettingsListDelete hwndhSettingsDelListTab4, Remove selected
	Gui, SettingsGui: Tab, 5
	Gui, SettingsGui: Add, Checkbox, x+m vbListViewIcons Checked%bListViewIcons%, Show icons inside the list for items that have one
	Gui, SettingsGui: Add, Text, xp y+m
	Gui, SettingsGui: Add, Text, xp y+m w500, Set a search engine (the program name will be appended):
	Gui, SettingsGui: Add, Edit, xp y+m wp r1 vsSearchEngine hwndhSearchEngine, % oSettings.SearchURL
	Gui, SettingsGui: Add, Button, xp y+m w120 gSettingsDefaultSearchEngine, Set default`nsearch engine
	Gui, SettingsGui: Tab
	Gui, SettingsGui: Add, Button, xm w120 Hidden hwndhSettingsGuiApplyButton gSettingsGuiSet, &Apply settings
	Gui, SettingsGui: Show, Center, ISMONISM settings
	ControlMove, , % WinGetWidth() - 139, , , , % "ahk_id " . hSettingsGuiApplyButton
	Gui, SettingsGui: Show, Center, ISMONISM settings
	GuiControl, , % hUserProgramFiles, % bUserProgramFiles
	GuiControl, , % hUserProfileData, % bUserProfileData
	GuiControl, , % hUserStartMenu, % bUserStartMenu
	GuiControl, Show, % hSettingsGuiApplyButton
Return

SettingsGetPersonalFolder:
	ControlGetText, sPersonalFolder, , % "ahk_id " hPersonalFolder
	sPersonalFolder := FileSelectFolder( )
	If sPersonalFolder
		ControlSetText, , % sPersonalFolder, % "ahk_id " hPersonalFolder
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
		sPath := FileSelectFolder( )
		If sPath
			LV_Add( "", sPath )
	}
Return

SettingsListEdit:
	Gui, SettingsGui: Submit, NoHide
	Gui, SettingsGui: ListView, % hSettingsListTab%iSettingsTab%
	If iSettingsTab = 4
		SettingsEditListField( )
	Else
		SettingsEditListFolder( iSettingsTab )
Return

SettingsListDelete:
	Gui, SettingsGui: Submit, NoHide
	Gui, SettingsGui: ListView, % hSettingsListTab%iSettingsTab%
	SettingsListDelItem( )
Return

SettingsListEvent:
	Gui, SettingsGui: Submit, NoHide
	Gui, SettingsGui: ListView, % hSettingsListTab%iSettingsTab%
	i := 0
	Loop
	{
		i := LV_GetNext( i )
		If not i
		{
			If A_Index = 1
			{
				WinSet, Disable, , % "ahk_id " . hSettingsEditListTab%iSettingsTab%
				WinSet, Disable, , % "ahk_id " . hSettingsDelListTab%iSettingsTab%
			}
			Break
		}
		Else
		{
			WinSet, Enable, , % "ahk_id " . hSettingsEditListTab%iSettingsTab%
			WinSet, Enable, , % "ahk_id " . hSettingsDelListTab%iSettingsTab%
			If A_Index >= 2
				WinSet, Disable, , % "ahk_id " . hSettingsEditListTab%iSettingsTab%
		}
	}
	i := ""
Return

SettingsGuiSet:
	Gui, SettingsGui: Submit
	sPersonalFolder := RegExReplace( sPersonalFolder, "\\$" )
	oSettings.MaximizeAtLaunch := bMaximizeAtLaunch
	oSettings.SearchAtLaunch := bSearchAtLaunch
	oSettings.LastSavedAtLaunch := bLastSavedAtLaunch
	oSettings.DatabaseSaves := iDatabaseSaves
	oSettings.PersonalFolder := sPersonalFolder
	oSettings.ListViewIcons := bListViewIcons
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
	If bUserProfileData
	{
		a.Push( A_AppData )
		a.Push( A_AppDataCommon )
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
	oSettings.ShortcutDirs := a
	a := Array()
	Gui, SettingsGui: ListView, % hSettingsListTab4
	Loop, % LV_GetCount()
	{
		LV_GetText( sStr, A_Index )
		a.Push( sStr )
	}	
	oSettings.FileTypes := a
	a := ""
	bSettingNeedsSave := True
	Gui, MainGui: Default
	ControlSetText, , % StrReplace( oSettings.PersonalFolder, "\", " \ " ), % "ahk_id " . hTextPersonalFolder
	Gosub, SettingsGuiClose
Return

SettingsGuiEscape:
SettingsGuiClose:
	Gui, MainGui: -Disabled
	Gui, MainGui: Default
	Gui, SettingsGui: Destroy
	WinActivate, % "ahk_id " . hMainGui
	bMaximizeAtLaunch := ""
	bNothingAtLaunch := ""
	bSearchAtLaunch := ""
	bLastSavedAtLaunch := ""
	iDatabaseSaves := ""
	sPersonalFolder := ""
	bUserProgramFiles := ""
	bUserProfileData := ""
	bUserProgramFiles := ""
	bListViewIcons := ""
	sSearchEngine := ""
	iSettingsTab := ""
	index := ""
	sPath := ""
	sExt := ""
	sStr := ""
	hPersonalFolder := ""
	hSearchEngine := ""
	hSettingsListTab2 := ""
	hSettingsListTab3 := ""
	hSettingsListTab4 := ""
	hUserProgramFiles := ""
	hUserProfileData := ""
	hUserStartMenu := ""
	hSettingsGuiApplyButton := ""
Return

GoAbout:
	Gui, MainGui: +Disabled
	Gui, AboutGui: New, +LabelAboutGui +OwnerMainGui -SysMenu
	Gui, AboutGui: Margin, 30, 13
	Gui, AboutGui: Font, Bold
	If A_IsCompiled
		Gui, AboutGui: Add, Picture, xm ym w40 h40 Section, % A_ScriptFullPath
	Else
		Gui, AboutGui: Add, Picture, xm ym w40 h40 Icon3 Section, % A_WinDir . "\System32\shell32.dll" ; Something needed because of the 'ys'-option of the Text control below 
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
	Gui, AboutGui: Add, Text, ys Section, 0.5.0   (2021-11-30)
	Gui, AboutGui: Add, Text, xs, Winkie
	Gui, AboutGui: Add, Text, xs, see below for the license of ISMONISM and used components
	Gui, AboutGui: Add, Tab3, xm AltSubmit viAboutTab, ISMONISM|JSON_ToObj()|JSON_Beautify()|Class_SQLiteDB|sqlite3.dll|Icon
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
		This is free and unencumbered software released into the public domain.
		
		Anyone is free to copy, modify, publish, use, compile, sell, or
		distribute this software, either in source code form or as a compiled
		binary, for any purpose, commercial or non-commercial, and by any
		means.

		In jurisdictions that recognize copyright laws, the author or authors
		of this software dedicate any and all copyright interest in the
		software to the public domain. We make this dedication for the benefit
		of the public at large and to the detriment of our heirs and
		successors. We intend this dedication to be an overt act of
		relinquishment in perpetuity of all present and future rights to this
		software under copyright law.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
		OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
		ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
		OTHER DEALINGS IN THE SOFTWARE.

		For more information, please refer to <http://unlicense.org>
	)
	Gui, AboutGui: Tab, 5
	Gui, AboutGui: Add, Button, x+15 w80 Default gAboutLaunchWebsite, Visit website
	Gui, AboutGui: Add, Text, xp yp+35,
	(
		All of the code and documentation in SQLite has been dedicated to the public domain by the authors. 
		All code authors, and representatives of the companies they work for, 
		have signed affidavits dedicating their contributions to the public domain 
		and originals of those signed affidavits are stored in a firesafe at the main offices of Hwaci. 
		Anyone is free to copy, modify, publish, use, compile, sell, or distribute the original SQLite code, 
		either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.
	)
	Gui, AboutGui: Tab, 6
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
	Else If iAboutTab = 4
		Run, https://github.com/AHK-just-me/Class_SQLiteDB
	Else If iAboutTab = 5
		Run, https://www.sqlite.org/
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
	AutoXYWH( "wh", hMainList1 )
	AutoXYWH( "x", hButtonSearch, hFileIcon, hBorder, hTextFolderCaption, hTextPersonalFolder, hButtonShortcut, hButtonClipboard )
Return

SaveSettings:
	oFile := FileOpen( "Data\ISMONISM.json", "w" )
	oFile.Write( JSON_Beautify( oSettings ) )
	oFile.Close( )
	bSettingNeedsSave := False
Return

MainGuiReload:
	Reload
Return

MainGuiClose:
	If bSettingNeedsSave
		Gosub, SaveSettings
	If not oSettings.DatabaseSaves
	{
		If FileExist( "Data\search0.db" )
		{
			Try
				FileDelete, Data\search0.db
			Catch e
				ErrorMsg( "Could not delete the database file." )
		}
	}
	ExitApp
Return

#IfWinActive ahk_group ISMONISM_Main
ESC::
	If bIsSearching
		bSearchCancel := True
Return
#IfWinActive

MainListToShortcuts( sPersonalFolder )
{
	Try
	{
		a := Array()
		i := 0
		Loop
		{
			i := LV_GetNext( i, "C" )
			If not i
				Break
			LV_GetText( sName, i, 3 )
			sName := FileGetBaseName( sName )
			LV_GetText( sPath, i, 4 )
			FileCreateDir, % sPersonalFolder
			Loop,
			{
				If Not FileExist( sPersonalFolder . "\" . sName . ".lnk" )
				{
					FileCreateShortCut, % sPath, % sPersonalFolder . "\" . sName . ".lnk"
					a.Push( sPath )
					Break
				}
				Else
				{
					If A_Index > 1
						sName := RegExReplace( sName, " \(\d+\)$" )
					sName := sName . " (" . A_Index . ")"
				}
			}
		}
		Return a
	}
	Catch e
	{
		Return ""
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
		LV_GetText( Txt, i, 4 )
		If ( A_Index != 1 )
			v .= "`n"
		v .= Txt
	}
	If v
		Return v
}

GetListViewFocused( iColumn )
{
	i := LV_GetNext( i, "F" )
	LV_GetText( v, i, iColumn )
	Return v
}

MainListSortChecked()
{
	Loop, % LV_GetCount()
		LV_Modify( A_Index, "", "", "" )
	
	i := 0
	If Not  LV_GetNext( i, "C" )
	{
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
	Global bSettingNeedsSave
	FileCreateDir, Data
	If FileExist( A_ScriptDir . "\ISMONISM.json" ) ; v0.4.0 -> 0.5.0
	{
		FileMove, % A_ScriptDir . "\ISMONISM.json", % A_ScriptDir . "\Data\ISMONISM.json", 1
	}
	If FileExist( "Data\ISMONISM.json" )
	{
	
		s := FileRead( "Data\ISMONISM.json" )
		o := JSON_ToObj( s )
		v := o.FileTypes
		If Not IsObject( v ) ; v0.3.1 -> v0.4.0
		{
			a := StrSplit( v, "," )
			o.FileTypes := a
			bSettingNeedsSave := True
		}
		If o.MaximizeAtLaunch = "" ; v0.3.1 -> v0.4.0
		{
			o.MaximizeAtLaunch := False
			bSettingNeedsSave := True
		}
		If o.SearchAtLaunch = "" ; v0.4.0 -> v0.5.0
		{
			o.SearchAtLaunch :=  False
			o.LastSavedAtLaunch := False
			o.ListViewIcons := False
			o.ShortcutCreateRemoveListRow := 1
			o.ShortcutCreateUpdateDatabase := 1
			bSettingNeedsSave := True
		}
	}
	Else
	{
		o := SetDefaultSettings()
		bSettingNeedsSave := True
	}
	Return o
}

SetDefaultSettings()
{
	o := Object()
	o.DatabaseSaves := 0
	o.FileTypes := [ "exe" ]
	o.LastSavedAtLaunch := False
	o.ListViewIcons := False
	o.MaximizeAtLaunch := False
	o.PersonalFolder := A_StartMenu . "\My shortcuts"
	o.SearchDirs := [ "C:\Program Files", "C:\Program Files (x86)" ]
	o.SearchAtLaunch := False
	o.SearchURL := "https://www.duckduckgo.com/?q="
	o.ShortcutCreateRemoveListRow := 1
	o.ShortcutCreateUpdateDatabase := 1
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

SettingsEditListField(  )
{
	If LV_GetCount( )
	{
		i := LV_GetNext( 0, "F" )
		If i = 1
		{
			LV_GetText( Txt, i)
			If Txt
				Txt := BetterBox( "Edit value", , Txt )
			If Txt
			{
				Gui, SettingsGui: Default
				LV_Modify( i, "Col", Txt )
			}
		}
	}
}

SettingsEditListFolder( iSettingsTab )
{
	Gui, SettingsGui: ListView, % hSettingsListTab%iSettingsTab%
	If LV_GetCount( )
	{
		i := LV_GetNext( 0, "F" )
		If i = 1
		{
			sPath := FileSelectFolder( )
			If sPath
				LV_Modify( i, "Col", sPath )
		}
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

FileGetExt( sPath )
{
	SplitPath, sPath, , , v
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

WinGetWidth( )
{
	WinGetPos, , , v, , A
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

SQLiteEscapeString( Str )
{
	Return "'" . StrReplace( Str, "'", "''") . "'"
}

ErrorMsg( sMsg )
{
	MsgBox, 262160, ISMONISM error, % sMsg
}

DatabaseError( sMsg, iCode )
{
	ErrorMsg( "SQLite database error:`n`nMsg:`t" . sMsg . "`nCode:`t" . iCode )
}
