; Biome-exclusive single-instance autoresetting AHK script
; Author: Specnr
; New Version Author: Aconnox
; Depends on Atum Mod AND Chunk Mod
#NoEnv
#SingleInstance Force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

; default global variables
global saves := "C:\*\MultiMC\instances\*\.minecraft\saves\" ; keep the last slash
global oldWorldsFolder := "C:\MultiInstanceMC\oldWorlds\"
global disableTTS := True ; (Disable for TTS [Default: True])
global prefs := {"beach": True, "forest": False, "plains": True, "savannah": False, "ocean": True, "jungle": False, "desert": True} ; (Set to True to toggle spawning in that biome, otherwise set to False)

IsInGame()
{
  rawLogFile := StrReplace(saves, "saves", "logs\latest.log")
  StringTrimRight, logFile, rawLogFile, 1
  numLines := 0
  Loop, Read, %logFile%
  {
    numLines += 1
  }
  saved := False
  startTime := A_TickCount
  Loop, Read, %logFile%
  {
    if ((numLines - A_Index) < 5)
    {
      if (InStr(A_LoopReadLine, "Loaded 0 advancements")) {
        saved := True
        break
      }
    }
  }
  return saved
}

MoveWorlds()
{
  Loop, Files, %saves%*, D
  {
    If (InStr(A_LoopFileName, "Speedrun #"))
      FileMoveDir, %saves%%A_LoopFileName%, %oldWorldsFolder%%A_LoopFileName%%A_NowUTC%Instance %idx%, R
  }
}

GetCurrAdvDir() {
  Loop, Files, %saves%*, D
  {
    CheckFile_Start := A_LoopFileTimeCreated
    If (CheckFile_Start > CheckFile_End)
    {
      CheckFile_End := A_LoopFileTimeCreated
      Out := A_LoopFileFullPath
    }
  }
  return Out "\advancements\"
}

SpawnBiome(biome, advDir)
{
  while (True) {
    if (FileExist(advDir "*.json"))
      break
  }
  Loop, Files, %advDir%*.json
    FileReadLine, data, %advDir%%A_LoopFileName%, 4
  return InStr(data, biome)
}

CheckBiomes(advDir) 
{
  for biome, toCheck in prefs {
    if (toCheck && SpawnBiome(biome, advDir))
      return biome
  }
  return -1
}

AutoReset()
{
  while (True) {
    Send, +{Tab}{Enter}
    sleep, 0
    MoveWorlds()
    while (True) {
      if (IsInGame())
        break
    }
    Send, {Esc}
    advDir := GetCurrAdvDir()
    if (CheckBiomes(advDir) != -1) {
      Send, {Esc}
      if (!disableTTS)
        ComObjCreate("SAPI.SpVoice").Speak("Seed")
      return
    }
  }
}

Settings()
{
	SetKeyDelay, 0
	send {Esc}{Tab}{Tab}{Tab}{Tab}{Tab}{Tab}{Enter}{Tab}
	SetKeyDelay, 0
	loop, 200
	{
	send {Right}
	}
	loop, 58 ; decrease this number if you want a higher fov
	{
	send {Left}
	}
	SetKeyDelay, 0
	send {Tab}{Tab}{Tab}{Tab}{Tab}{Enter}{Shift}+{P}{Tab}{Tab}{Tab}{Tab}
	SetKeyDelay, 0
	loop, 400
	{
	send {Left}
	}
	loop, 68 ; decrease this number if you want a lower render distance
	{
	send {Right}
	}
	SetKeyDelay, 0
	send {Esc}{Tab}{Tab}{Tab}{Tab}{Tab}{Tab}{Tab}{Enter}{Tab}{Enter}{Tab}
	SetKeyDelay, 0
	loop, 200
	{
	send {Left}
	}
	loop, 123 ; increase this number if you want a higher sensitivity
	{
	send {Right}
	}
	SetKeyDelay, 0
	send {Esc}{Esc}{Esc}{Esc}
	Sleep, 100
	send +{Tab}+{Tab}+{Tab}{Enter}+{Tab}{Enter}{Tab}{Enter}
      return
}

#IfWinActive, Minecraft
  {
    RAlt::ExitApp ; Exits Script
    *+b:: ; Starts autoresetting	
      Send, {Esc}
      AutoReset()
   return
}
{
    *+n:: ; Reset Settings
      Settings()
   return
  }
