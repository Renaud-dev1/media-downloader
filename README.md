# Media Downloader — YouTube & Spotify

Script Windows en batch permettant de télécharger de l'audio ou de la vidéo
depuis YouTube (MP3/MP4) et Spotify (MP3 avec métadonnées et pochette).

## Prérequis

- [Python 3.10+](https://www.python.org/downloads/) — cocher "Add Python to PATH"
- `yt-dlp` et `spotdl` (installés automatiquement via `install.bat`)

## Installation

1: Cloner le repo ou télécharger les fichiers
2: Lancer `install.bat`
3: Lancer `downloader.bat`

## Fonctionnalités

- Détection automatique de la plateforme (YouTube ou Spotify)
- Choix du format : Audio MP3 ou Vidéo MP4 (YouTube)
- Choix du dossier de destination (Bureau, Téléchargements, personnalisé)
- Téléchargement Spotify avec métadonnées et pochette d'album
- Détection automatique du chemin Python même hors PATH

## Technologies utilisées

- Windows Batch Script
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [spotDL](https://github.com/spotDL/spotify-downloader)
- FFmpeg

## Avertissement

Ce projet est réalisé à des fins éducatives.
Respecte les droits d'auteur et les conditions d'utilisation des plateformes.
