@echo off
chcp 65001 >nul
title Installation yt-dlp et spotdl

echo ============================================
echo   INSTALLATION - yt-dlp et spotdl
echo ============================================
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python non trouve. Telecharge-le sur https://www.python.org/downloads/
    echo Coche bien "Add Python to PATH" pendant l'installation !
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo [OK] %%v

:: Recuperer le dossier Scripts de pip via Python lui-meme
for /f "delims=" %%p in ('python -c "import sysconfig; print(sysconfig.get_path(\"scripts\"))"') do set "PIP_SCRIPTS=%%p"
echo [OK] Dossier Scripts : %PIP_SCRIPTS%
echo.

echo Installation de yt-dlp...
python -m pip install -U yt-dlp
echo.

echo Installation de spotdl...
python -m pip install -U spotdl
echo.

echo Telechargement de FFmpeg via spotdl...
python -m spotdl --download-ffmpeg
echo.

echo Verification :
if exist "%PIP_SCRIPTS%\yt-dlp.exe" (echo [OK] yt-dlp.exe trouve dans %PIP_SCRIPTS%) else (echo [!!] yt-dlp.exe introuvable dans %PIP_SCRIPTS%)
if exist "%PIP_SCRIPTS%\spotdl.exe"  (echo [OK] spotdl.exe  trouve dans %PIP_SCRIPTS%) else (echo [!!] spotdl.exe  introuvable dans %PIP_SCRIPTS%)
echo.
echo Installation terminee ! Lance downloader.bat
pause
