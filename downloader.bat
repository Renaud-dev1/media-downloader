@echo off
chcp 65001 >nul
title Downloader - YouTube et Spotify
color 0A

echo ============================================
echo      DOWNLOADER - YouTube et Spotify
echo ============================================
echo.

:: Trouver le dossier Scripts Python dynamiquement
set "PIP_SCRIPTS="
python --version >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%p in ('python -c "import sysconfig; print(sysconfig.get_path(\"scripts\"))"') do set "PIP_SCRIPTS=%%p"
)

:: Chercher yt-dlp
set "YTDLP="
where yt-dlp >nul 2>&1 && set "YTDLP=yt-dlp"
if "%YTDLP%"=="" if defined PIP_SCRIPTS if exist "%PIP_SCRIPTS%\yt-dlp.exe" set "YTDLP=%PIP_SCRIPTS%\yt-dlp.exe"
if "%YTDLP%"=="" if exist "%~dp0yt-dlp.exe" set "YTDLP=%~dp0yt-dlp.exe"

:: Chercher spotdl
set "SPOTDL="
where spotdl >nul 2>&1 && set "SPOTDL=spotdl"
if "%SPOTDL%"=="" if defined PIP_SCRIPTS if exist "%PIP_SCRIPTS%\spotdl.exe" set "SPOTDL=%PIP_SCRIPTS%\spotdl.exe"
if "%SPOTDL%"=="" if exist "%~dp0spotdl.exe" set "SPOTDL=%~dp0spotdl.exe"

echo Verification des outils :
if not "%YTDLP%"=="" (echo [OK] yt-dlp trouve) else (echo [--] yt-dlp introuvable)
if not "%SPOTDL%"=="" (echo [OK] spotdl  trouve) else (echo [--] spotdl  introuvable)
echo.

if "%YTDLP%"=="" if "%SPOTDL%"=="" (
    echo Aucun outil installe. Lance install.bat d'abord.
    pause
    exit /b 1
)

:ask_link
set "link="
set /p "link=Colle le lien YouTube ou Spotify : "
if "%link%"=="" (
    echo Lien vide, reessaie.
    goto ask_link
)

set "PLATFORM="
echo %link% | findstr /i "youtube.com youtu.be" >nul 2>&1
if not errorlevel 1 set "PLATFORM=youtube"
echo %link% | findstr /i "open.spotify.com" >nul 2>&1
if not errorlevel 1 set "PLATFORM=spotify"

if "%PLATFORM%"=="" (
    echo Lien non reconnu. Doit etre un lien YouTube ou Spotify.
    echo.
    goto ask_link
)

echo Plateforme : %PLATFORM%
echo.

if "%PLATFORM%"=="youtube" if "%YTDLP%"=="" (
    echo yt-dlp introuvable, impossible de telecharger YouTube.
    goto ask_link
)
if "%PLATFORM%"=="spotify" if "%SPOTDL%"=="" (
    echo spotdl introuvable, impossible de telecharger Spotify.
    goto ask_link
)

set "FORMAT_CHOICE=audio"
if "%PLATFORM%"=="youtube" (
    echo Que veux-tu telecharger ?
    echo   [1] Audio MP3
    echo   [2] Video MP4
    echo.
    set /p "FC=Ton choix (1 ou 2) : "
    if "%FC%"=="2" set "FORMAT_CHOICE=video"
    echo.
)

echo Ou sauvegarder ?
echo   [1] Bureau
echo   [2] Telechargements
echo   [3] Chemin personnalise
echo.
set /p "DC=Ton choix (1, 2 ou 3) : "

if "%DC%"=="1" set "DEST=%USERPROFILE%\Desktop"
if "%DC%"=="2" set "DEST=%USERPROFILE%\Downloads"
if "%DC%"=="3" (
    echo.
    set /p "DEST=Chemin complet : "
)
if "%DC%"=="" set "DEST=%USERPROFILE%\Downloads"

if not exist "%DEST%" mkdir "%DEST%"
echo.
echo Destination : %DEST%
echo Telechargement en cours...
echo.

if "%PLATFORM%"=="youtube" (
    if "%FORMAT_CHOICE%"=="audio" (
        "%YTDLP%" -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o "%DEST%\%%(title)s.%%(ext)s" "%link%"
    ) else (
        "%YTDLP%" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4" -o "%DEST%\%%(title)s.%%(ext)s" "%link%"
    )
)
if "%PLATFORM%"=="spotify" (
    "%SPOTDL%" download "%link%" --output "%DEST%"
)

echo.
if errorlevel 1 (
    echo Telechargement echoue.
) else (
    echo Succes ! Sauvegarde dans : %DEST%
)
echo.
set /p "AGAIN=Telecharger autre chose ? (o/n) : "
if /i "%AGAIN%"=="o" (
    echo.
    goto ask_link
)
echo.
echo A plus !
timeout /t 2 >nul
