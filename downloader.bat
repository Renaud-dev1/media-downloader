@echo off
chcp 65001 >nul
title Downloader - YouTube et Spotify
color 0A
setlocal enabledelayedexpansion

echo ============================================
echo      DOWNLOADER - YouTube et Spotify
echo ============================================
echo.

set "PIP_SCRIPTS="
python --version >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%p in ('python -c "import sysconfig; print(sysconfig.get_path(\"scripts\"))"') do set "PIP_SCRIPTS=%%p"
)

set "YTDLP="
where yt-dlp >nul 2>&1 && set "YTDLP=yt-dlp"
if "!YTDLP!"=="" if defined PIP_SCRIPTS if exist "!PIP_SCRIPTS!\yt-dlp.exe" set "YTDLP=!PIP_SCRIPTS!\yt-dlp.exe"
if "!YTDLP!"=="" if exist "%~dp0yt-dlp.exe" set "YTDLP=%~dp0yt-dlp.exe"

set "SPOTDL="
where spotdl >nul 2>&1 && set "SPOTDL=spotdl"
if "!SPOTDL!"=="" if defined PIP_SCRIPTS if exist "!PIP_SCRIPTS!\spotdl.exe" set "SPOTDL=!PIP_SCRIPTS!\spotdl.exe"
if "!SPOTDL!"=="" if exist "%~dp0spotdl.exe" set "SPOTDL=%~dp0spotdl.exe"

set "FFMPEG_DIR="
for /f "delims=" %%f in ('python -c "import spotdl; import os; print(os.path.dirname(spotdl.__file__))" 2^>nul') do set "FFMPEG_DIR=%%f"
if defined FFMPEG_DIR if not exist "!FFMPEG_DIR!\ffmpeg.exe" set "FFMPEG_DIR="
if not defined FFMPEG_DIR if exist "%APPDATA%\spotdl\ffmpeg.exe" set "FFMPEG_DIR=%APPDATA%\spotdl"
if not defined FFMPEG_DIR where ffmpeg >nul 2>&1 && set "FFMPEG_DIR=ffmpeg"

echo Verification des outils :
if not "!YTDLP!"=="" (echo [OK] yt-dlp) else (echo [--] yt-dlp introuvable)
if not "!SPOTDL!"=="" (echo [OK] spotdl) else (echo [--] spotdl introuvable)
if not "!FFMPEG_DIR!"=="" (echo [OK] ffmpeg) else (echo [!!] ffmpeg introuvable)
echo.

if "!YTDLP!"=="" if "!SPOTDL!"=="" (
    echo Aucun outil installe. Lance install.bat d'abord.
    pause
    exit /b 1
)

:ask_link
echo Colle le lien YouTube ou Spotify puis appuie sur Entree :

for /f "delims=" %%L in ('powershell -NoProfile -Command "Write-Host '' -NoNewline; [Console]::In.ReadLine()"') do set "link=%%L"

if "!link!"=="" (
    echo Lien vide, reessaie.
    goto ask_link
)

set "PLATFORM="
set "IS_PLAYLIST=0"

powershell -NoProfile -Command "if ('!link!' -match 'youtube\.com|youtu\.be') { exit 0 } else { exit 1 }" >nul 2>&1
if not errorlevel 1 set "PLATFORM=youtube"

powershell -NoProfile -Command "if ('!link!' -match 'open\.spotify\.com') { exit 0 } else { exit 1 }" >nul 2>&1
if not errorlevel 1 set "PLATFORM=spotify"

if "!PLATFORM!"=="" (
    echo Lien non reconnu. Doit etre un lien YouTube ou Spotify.
    echo.
    goto ask_link
)

if "!PLATFORM!"=="youtube" (
    powershell -NoProfile -Command "if ('!link!' -match 'list=') { exit 0 } else { exit 1 }" >nul 2>&1
    if not errorlevel 1 set "IS_PLAYLIST=1"
)

if "!IS_PLAYLIST!"=="1" (
    echo Plateforme : YouTube - PLAYLIST detectee
) else (
    echo Plateforme : !PLATFORM!
)
echo.

set "FORMAT_CHOICE=audio"
if "!PLATFORM!"=="youtube" (
    echo   [1] Audio MP3
    echo   [2] Video MP4
    echo.
    set /p "FC=Ton choix (1 ou 2) : "
    if "!FC!"=="2" set "FORMAT_CHOICE=video"
    echo.
)

echo Ou sauvegarder ?
echo   [1] Bureau
echo   [2] Telechargements
echo   [3] Chemin personnalise
echo.
set /p "DC=Ton choix (1, 2 ou 3) : "

if "!DC!"=="1" set "DEST=%USERPROFILE%\Desktop"
if "!DC!"=="2" set "DEST=%USERPROFILE%\Downloads"
if "!DC!"=="3" (
    echo.
    set /p "DEST=Chemin : "
)
if "!DEST!"=="" set "DEST=%USERPROFILE%\Downloads"

if not exist "!DEST!" mkdir "!DEST!"
echo.
echo Destination : !DEST!
echo Telechargement en cours...
echo.

set "FFARG="
if defined FFMPEG_DIR if not "!FFMPEG_DIR!"=="ffmpeg" set "FFARG=--ffmpeg-location "!FFMPEG_DIR!""

if "!PLATFORM!"=="youtube" (
    if "!IS_PLAYLIST!"=="1" (
        if "!FORMAT_CHOICE!"=="audio" (
            "!YTDLP!" !FFARG! -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --yes-playlist -o "!DEST!\%%(playlist_index)s - %%(title)s.%%(ext)s" "!link!"
        ) else (
            "!YTDLP!" !FFARG! -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4" --yes-playlist -o "!DEST!\%%(playlist_index)s - %%(title)s.%%(ext)s" "!link!"
        )
    ) else (
        if "!FORMAT_CHOICE!"=="audio" (
            "!YTDLP!" !FFARG! -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --no-playlist -o "!DEST!\%%(title)s.%%(ext)s" "!link!"
        ) else (
            "!YTDLP!" !FFARG! -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4" --no-playlist -o "!DEST!\%%(title)s.%%(ext)s" "!link!"
        )
    )
)

if "!PLATFORM!"=="spotify" (
    "!SPOTDL!" download "!link!" --output "!DEST!"
)

echo.
if errorlevel 1 (
    echo Telechargement echoue.
) else (
    echo Succes ! Sauvegarde dans : !DEST!
)
echo.
set /p "AGAIN=Telecharger autre chose ? (o/n) : "
if /i "!AGAIN!"=="o" (
    echo.
    goto ask_link
)
echo.
echo A plus !
timeout /t 2 >nul
