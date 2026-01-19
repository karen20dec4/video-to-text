# Video to Text Converter / Conversie Video la Text

Un set complet de scripturi pentru conversia video-urilor în subtitrări cu optimizare automată. Disponibil atât pentru Windows cât și pentru Linux.

## Caracteristici / Features

✨ **Interfață text interactivă** - Interfață ușor de utilizat în linia de comandă
🎯 **Optimizare subtitrări** - Formatare automată și optimizare a textului subtitrărilor
🌍 **Suport multilingv** - Română, Engleză, Franceză, Germană, Spaniolă, Italiană, Portugheză și altele
📹 **Multiple formate video** - MP4, AVI, MKV, MOV, FLV, WMV, WebM și altele
💾 **Multiple formate de ieșire** - SRT (subtitrări), TXT (text simplu), JSON (date structurate)
🚀 **Pregătit pentru viitor** - Infrastructură pregătită pentru traducere automată cu AI local

## Cerințe / Requirements

### Windows 10/11
- Python 3.7+
- ffmpeg
- PowerShell 5.0+

### Linux (Debian/Ubuntu)
- Python 3.7+
- ffmpeg
- bash
- zenity (opțional, pentru dialog grafic de selectare fișiere)

## Instalare / Installation

### 1. Instalare Python

#### Windows
Descărcați și instalați Python de la [python.org](https://www.python.org/downloads/)

Asigurați-vă că bifați "Add Python to PATH" în timpul instalării.

#### Linux
```bash
sudo apt-get update
sudo apt-get install python3 python3-pip
```

### 2. Instalare ffmpeg

#### Windows
1. Descărcați ffmpeg de la [ffmpeg.org](https://ffmpeg.org/download.html)
2. Extrageți arhiva
3. Adăugați calea către `ffmpeg.exe` în PATH-ul sistem

Sau folosiți Chocolatey:
```powershell
choco install ffmpeg
```

#### Linux
```bash
sudo apt-get install ffmpeg
```

### 3. Instalare librării Python

Librăriile necesare vor fi instalate automat când rulați scripturile pentru prima dată.

Sau le puteți instala manual:
```bash
# Windows
pip install SpeechRecognition pydub

# Linux
pip3 install SpeechRecognition pydub
```

### 4. Instalare Zenity (Opțional pentru Linux)

Pentru dialog grafic de selectare fișiere pe Linux:
```bash
sudo apt-get install zenity
```

## Utilizare / Usage

### Windows

1. Deschideți PowerShell
2. Navigați către directorul cu scripturile
3. Rulați scriptul:
```powershell
.\video-to-text-windows.ps1
```

**Notă:** Dacă primiți eroare de execution policy, rulați:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Linux

1. Deschideți terminalul
2. Navigați către directorul cu scripturile
3. Rulați scriptul:
```bash
./video-to-text-linux.sh
```

## Mod de funcționare / How it works

1. **Selectare video** - Alegeți fișierul video prin:
   - Dialog grafic (Windows Forms / Zenity)
   - Introducere manuală a căii
   - Căutare în directorul curent

2. **Selectare limbă** - Alegeți limba vorbirii din video:
   - Română (ro-RO)
   - Engleză - US (en-US)
   - Engleză - UK (en-GB)
   - Franceză (fr-FR)
   - Germană (de-DE)
   - Spaniolă (es-ES)
   - Italiană (it-IT)
   - Portugheză (pt-PT)
   - Sau introduceți un cod de limbă personalizat

3. **Selectare format** - Alegeți formatul de ieșire:
   - **SRT** - Fișier standard de subtitrări (recomandat)
   - **TXT** - Text simplu fără timestamp-uri
   - **JSON** - Date structurate cu timestamp-uri complete
   - **TOATE** - Generează toate formatele

4. **Procesare** - Scriptul va:
   - Extrage audio-ul din video
   - Împărți audio-ul în segmente pe baza pauzelor
   - Transcrie fiecare segment folosind Google Speech Recognition
   - Optimiza textul subtitrărilor (lungime, formatare)
   - Genera fișierele de ieșire
   - Șterge fișierele temporare

## Optimizarea Subtitrărilor / Subtitle Optimization

Scriptul include optimizare automată a subtitrărilor:

- **Lungime optimă** - Maximum 42 caractere per linie
- **Durată optimă** - Între 1 și 7 secunde per subtitrare
- **Împărțire inteligentă** - Text împărțit pe linii multiple când este necesar
- **Sincronizare precisă** - Timestamp-uri bazate pe pauzele naturale în vorbire

## Exemple de Utilizare / Usage Examples

### Conversie simplă (interfață interactivă)
```bash
# Windows
.\video-to-text-windows.ps1

# Linux
./video-to-text-linux.sh
```

### Conversie directă din linie de comandă
```bash
# Windows
python video_to_text.py "C:\Videos\film.mp4" ro-RO srt

# Linux
python3 video_to_text.py "/home/user/Videos/film.mp4" en-US srt
```

### Parametri linie de comandă
```bash
python3 video_to_text.py <video_file> [language] [output_format]

# Exemple:
python3 video_to_text.py video.mp4                    # Limba: en-US, Format: srt
python3 video_to_text.py video.mp4 ro-RO              # Română, Format: srt
python3 video_to_text.py video.mp4 ro-RO txt          # Română, Format: txt
python3 video_to_text.py video.mp4 en-US all          # Engleză, Toate formatele
```

## Structura Proiectului / Project Structure

```
video-to-text/
├── video_to_text.py              # Script Python principal / Main Python script
├── video-to-text-windows.ps1     # Script Windows PowerShell / Windows PowerShell script
├── video-to-text-linux.sh        # Script Linux Bash / Linux Bash script
├── README.md                      # Documentație / Documentation
└── requirements.txt               # Dependențe Python / Python dependencies
```

## Formate Video Suportate / Supported Video Formats

- MP4 (.mp4)
- AVI (.avi)
- MKV (.mkv)
- MOV (.mov)
- FLV (.flv)
- WMV (.wmv)
- WebM (.webm)
- M4V (.m4v)
- MPEG (.mpg, .mpeg)

## Limbi Suportate / Supported Languages

Scriptul suportă toate limbile disponibile în Google Speech Recognition API:

- Română (ro-RO)
- Engleză - US (en-US)
- Engleză - UK (en-GB)
- Franceză (fr-FR)
- Germană (de-DE)
- Spaniolă (es-ES)
- Italiană (it-IT)
- Portugheză (pt-PT)
- Rusă (ru-RU)
- Chineză (zh-CN)
- Japoneză (ja-JP)
- Coreeană (ko-KR)
- Și multe altele...

Pentru o listă completă a codurilor de limbă, consultați [documentația Google Cloud Speech-to-Text](https://cloud.google.com/speech-to-text/docs/languages).

## Dezvoltări Viitoare / Future Development

🔮 **Traducere automată** - În dezvoltare
- Integrare AI local pentru traducerea subtitrărilor
- Suport pentru modele Whisper AI
- Traducere în timp real

🎨 **Interfață grafică** - Planificat
- GUI modern cu PyQt sau Tkinter
- Previzualizare video cu subtitrări
- Editor de subtitrări integrat

⚡ **Performanță** - În lucru
- Procesare paralelă
- Suport pentru GPU
- Cache pentru procesări repetate

## Depanare / Troubleshooting

### Eroare: "ffmpeg not found"
Asigurați-vă că ffmpeg este instalat și adăugat în PATH.

**Windows:**
```powershell
# Testați ffmpeg
ffmpeg -version
```

**Linux:**
```bash
# Instalați ffmpeg
sudo apt-get install ffmpeg

# Testați ffmpeg
ffmpeg -version
```

### Eroare: "speech_recognition module not found"
Instalați librăriile Python:
```bash
pip install SpeechRecognition pydub
```

### Recunoaștere slabă a vocii
- Verificați calitatea audio a video-ului
- Asigurați-vă că ați selectat limba corectă
- Testați cu un video cu vorbire clară și fără zgomot de fundal

### Script PowerShell nu rulează
```powershell
# Setați execution policy pentru sesiunea curentă
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Sau pentru utilizatorul curent (necesită admin)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Contribuții / Contributing

Contribuțiile sunt binevenite! Vă rugăm să:
1. Fork-uiți repository-ul
2. Creați un branch pentru feature-ul vostru
3. Commit-uiți schimbările
4. Push-uiți la branch
5. Deschideți un Pull Request

## Licență / License

MIT License - Vezi fișierul LICENSE pentru detalii.

## Contact / Support

Pentru probleme sau întrebări, deschideți un issue pe GitHub.

---

**Nota:** Acest instrument folosește Google Speech Recognition API care necesită conexiune la internet pentru transcrierea audio. Pentru utilizare offline, consultați dezvoltările viitoare cu Whisper AI.
