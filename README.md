# Video to Text Transcription - Whisper AI

Transcriere automată video/audio la text folosind Whisper AI (OpenAI).

## Caracteristici

✨ **Whisper AI Local** - Nu necesită internet după instalare
🎯 **Optimizare automată subtitrări** - 80-120 caractere per linie
🌍 **Suport multilingv** - Română, Engleză, Franceză, Germană, Spaniolă, etc.
📹 **Multiple formate video** - MP4, MKV, AVI, MOV, FLV, WMV, WebM, M4V, MPG, MPEG
🎵 **Multiple formate audio** - MP3, WAV, M4A, AAC, OGG, FLAC
💾 **Formate de ieșire** - SRT (subtitrări), TXT (text simplu)
🚀 **Interfață text interactivă** - Windows PowerShell & Linux Bash

## Cerințe

### Windows
- Python 3.8+
- ffmpeg
- PowerShell 5.0+

### Linux (Debian/Ubuntu)
- Python 3.8+
- ffmpeg
- bash
- zenity (opțional, pentru dialog grafic)

## Instalare

### 1. Instalare Python

#### Windows
Descărcați de la [python.org](https://www.python.org/downloads/)

#### Linux
```bash
sudo apt-get update
sudo apt-get install python3 python3-pip
```

### 2. Instalare ffmpeg

#### Windows
Descărcați de la [ffmpeg.org](https://ffmpeg.org/download.html) sau:
```powershell
choco install ffmpeg
```

#### Linux
```bash
sudo apt-get install ffmpeg
```

### 3. Instalare librării Python

Librăriile vor fi instalate automat când rulați scripturile pentru prima dată, sau le puteți instala manual:

```bash
# Instalare PyTorch (CPU)
pip install torch --index-url https://download.pytorch.org/whl/cpu

# Instalare Whisper AI și dependențe
pip install openai-whisper srt pysrt
```

### 4. Instalare Zenity (Opțional pentru Linux)

Pentru dialog grafic pe Linux:
```bash
sudo apt-get install zenity
```

## Utilizare

### Windows PowerShell

```powershell
.\video-to-text-windows.ps1
```

**Notă:** Dacă primiți eroare de execution policy:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Linux

```bash
./video-to-text-linux.sh
```

### Linie de comandă directă

```bash
# Windows
python video-to-text.py video.mp4 small ro srt

# Linux
python3 video-to-text.py video.mp4 small ro srt
```

## Modele Whisper Disponibile

| Model | Viteză | Calitate | RAM Necesar | Recomandat Pentru |
|-------|--------|----------|-------------|-------------------|
| tiny | Foarte rapid | Decent | ~1GB | Testare rapidă |
| base | Rapid | Bun | ~1GB | Video-uri scurte |
| **small** | **Mediu** | **Foarte bun** | **~2GB** | **Utilizare generală** ✓ |
| medium | Lent | Excelent | ~5GB | Calitate înaltă |
| large-v3 | Foarte lent | Excepțional | ~10GB | Maxim acuratețe |
| turbo | Rapid | Excelent | ~6GB | Echilibru ideal |

**Prima rulare:** Modelul ales va fi descărcat automat (1-10GB în funcție de model).

## Limbi Suportate

Română (ro), Engleză (en), Franceză (fr), Germană (de), Spaniolă (es), Italiană (it), Portugheză (pt), Rusă (ru), Polonă (pl), Olandeză (nl), Ucraineană (uk), Turcă (tr), Japoneză (ja), Chineză (zh), Coreeană (ko) și multe altele.

## Formate Suportate

### Video
MP4, MKV, AVI, MOV, FLV, WMV, WebM, M4V, MPG, MPEG

### Audio
MP3, WAV, M4A, AAC, OGG, FLAC

## Optimizare Subtitrări

Scripturile includ optimizare automată a subtitrărilor:
- **Lungime optimă:** 80-120 caractere per subtitrare
- **Împărțire inteligentă:** Împarte textul lung pe baza punctuației
- **Combinare:** Combină subtitrările prea scurte
- **Gap-uri:** Adaugă pauze între subtitrări (100ms)

## Exemple

### Exemplu 1: Video românesc cu model small
```bash
python3 video-to-text.py interviu.mp4 small ro srt
```

### Exemplu 2: Video englezesc cu model turbo
```bash
python3 video-to-text.py presentation.mp4 turbo en srt
```

### Exemplu 3: Audio MP3 cu ambele formate
```bash
python3 video-to-text.py podcast.mp3 small en all
```

## Structură Fișiere

```
video-to-text/
├── video-to-text.py              # Script Python principal
├── video-to-text-windows.ps1     # Script PowerShell pentru Windows
├── video-to-text-linux.sh        # Script Bash pentru Linux
├── merge_short_subs.py           # Optimizare avansată subtitrări
├── config.yaml                   # Configurare (de la versiunea anterioară)
└── README.md                     # Documentație
```

## Flux de Lucru

1. **Selectare fișier** - Dialog GUI sau introducere manuală
2. **Selectare model Whisper** - tiny, base, small, medium, large-v3, turbo
3. **Selectare limbă** - ro, en, fr, de, es, it, pt, ru, etc.
4. **Selectare format** - SRT, TXT sau ambele
5. **Procesare**:
   - Extragere audio din video (dacă este nevoie)
   - Transcriere cu Whisper AI
   - Optimizare subtitrări
   - Generare fișiere de ieșire
   - Curățare fișiere temporare

## Performanță

### Timp de procesare estimat (model small, 10 minute video):
- **CPU puternic (i7/Ryzen 7):** ~5-7 minute
- **CPU mediu (i5/Ryzen 5):** ~10-15 minute
- **CPU slab (i3/Ryzen 3):** ~20-30 minute

### Cerințe hardware recomandate:
- **Minim:** 4GB RAM, CPU dual-core
- **Recomandat:** 8GB RAM, CPU quad-core
- **Optimal:** 16GB RAM, CPU octa-core

**Notă:** GPU nu este necesar - Whisper funcționează pe CPU.

## Dezvoltări Viitoare

🔮 **Traducere automată**
- Integrare modele AI pentru traducere
- Generare subtitrări în multiple limbi simultan
- UI pentru selectare limbă țintă

🎨 **Interfață grafică**
- GUI modern cross-platform
- Previzualizare video cu subtitrări
- Editor de subtitrări integrat

⚡ **Optimizări**
- Suport GPU (CUDA/ROCm)
- Procesare în batch
- Cache inteligent

## Depanare

### Eroare: "ffmpeg not found"
Instalați ffmpeg și adăugați-l în PATH.

### Eroare: "whisper module not found"
```bash
pip install openai-whisper
```

### Eroare: "torch not found"
```bash
pip install torch --index-url https://download.pytorch.org/whl/cpu
```

### Transcriere lentă
- Folosiți un model mai mic (tiny sau base)
- Asigurați-vă că nu rulează alte procese intensive
- Verificați că aveți suficient RAM liber

### Calitate slabă a transcrierii
- Folosiți un model mai mare (medium sau large-v3)
- Verificați calitatea audio a video-ului
- Asigurați-vă că ați selectat limba corectă

## Licență

MIT License - Vezi fișierul LICENSE pentru detalii.

## Contact / Support

Pentru probleme sau întrebări, deschideți un issue pe GitHub.

---

**Powered by OpenAI Whisper** - https://github.com/openai/whisper
