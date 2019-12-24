; ISMONISM - (In Start Menu Or Not In Start Menu) -- by Winkie
; 2019-12-20

#NoEnv
#NoTrayIcon
#SingleInstance, Force
SetControlDelay, -1

; *** CONFIGURATION STARTS HERE ***

; USAGE: add folders below between the brackets where this script has to look for shortcuts
; Enclose the paths in quation marks and separate them with a comma.
; The default is the Start Menu, through built-in variables: aShortcutDirs := [ A_StartMenu, A_StartMenuCommon ]
aShortcutDirs := [ A_StartMenu, A_StartMenuCommon ]

; USAGE: add folders below between the brackets where this script has to look for items to match against the shortcut folder(s)
; Enclose the paths in quation marks and separate them with a comma.
aSearchDirs := [ "C:\Program Files", "C:\Program Files (x86)" ]

; USAGE: add file extensions for which this script has to look, separated with a comma
; Important: omit spaces, e.g.: sFileTypes := "exe,bat,ahk"
sFileTypes := "exe"

; *** END OF CONFIGURATION ***

Gui, 1:-Resize +LabelMainGui +HwndhMainGui
Gui, 1:Margin, 10, 10
Gui, 1:Add, ListView, w800 h500 Disabled Grid Sort hwndhListView1, Program name|Program path
Gui, 1:Add, StatusBar, h22
Gui, 1:Show, Center, ISMONISM
SB_SetParts( 300 )

aMenuItems := Array()
SB_SetText( "Scanning shortcut folder(s).", 1 )
For each, sDir in aShortcutDirs
{
	Loop, Files, % sDir . "\*.lnk", R
	{
		aMenuItems.Push( FileGetShotcutPath( A_LoopFileLongPath ) )
	}
}

SB_SetText( "Scanning program folder:", 1 )
For each, sDir in aSearchDirs
{
	SB_SetText( sDir, 2 )
	Loop, Files, % sDir . "\*.*", R
	{
		If A_LoopFileExt and InStr( sFileTypes, A_LoopFileExt, , 1 )
		{
			If Not HasVal( aMenuItems, A_LoopFileLongPath )
			{
				LV_Add( "", FileGetName( A_LoopFileLongPath ), A_LoopFileLongPath )
			}
		}
	}
}

LV_ModifyCol( )
LV_ModifyCol( 1, 200 )
WinSet, Enable, , % "ahk_id " . hListView1
SB_SetText( LV_GetCount( ) . " item(s) found which are not in any shortcut folder.", 1 )
SB_SetText( "", 2 )

Return

MainGuiEscape:
MainGuiClose:
	ExitApp
Return

FileGetName( sPath )
{
	SplitPath, sPath, v
	Return v
}

FileGetShotcutPath( sPath )
{
	FileGetShortcut, % sPath, v
	Return v
}

; HasVal -- by jNizM & Lexicos -- https://www.autohotkey.com/boards/viewtopic.php?p=110388#p110388
HasVal( haystack, needle ) 
{
	For index, value in haystack
		If (value = needle)
			Return index
	If !IsObject(haystack)
		Throw Exception("Bad haystack!", -1, haystack)
	Return 0
}