# Ghid Rapid de Utilizare / Quick Start Guide

## Instalare Rapidă / Quick Install

### Windows

1. **Instalare Python 3.8+** de la [python.org](https://www.python.org/downloads/)
2. **Instalare ffmpeg** de la [ffmpeg.org](https://ffmpeg.org/download.html)
3. **Rulare script:**
   ```powershell
   .\video-to-text-windows.ps1
   ```
4. Scriptul va instala automat librăriile necesare (PyTorch, Whisper, etc.)

### Linux (Debian/Ubuntu)

1. **Instalare dependențe sistem:**
   ```bash
   sudo apt-get update
   sudo apt-get install python3 python3-pip ffmpeg zenity
   ```

2. **Rulare script:**
   ```bash
   chmod +x video-to-text-linux.sh
   ./video-to-text-linux.sh
   ```

3. Scriptul va instala automat librăriile Python necesare

## Primul Video / First Video

### Pas cu Pas / Step by Step

1. **Rulați scriptul** (vezi comezile de mai sus)

2. **Așteptați verificarea dependențelor** - Prima dată va instala:
   - PyTorch (~100MB)
   - Whisper AI (~50MB)
   - Alte librării (~20MB)

3. **Selectați fișierul video**:
   - Windows: Dialog grafic
   - Linux: Zenity dialog SAU introducere manuală SAU căutare în director

4. **Alegeți modelul Whisper** (Recomandat: **small** pentru început):
   - `tiny` - Foarte rapid, calitate OK (testare)
   - `small` - Echilibrat, calitate bună ✓ **RECOMANDAT**
   - `medium` - Lent, calitate foarte bună
   - `large-v3` - Foarte lent, calitate maximă
   - `turbo` - Rapid și precis

5. **Alegeți limba**:
   - Română (ro)
   - Engleză (en)
   - Franceză (fr)
   - Etc.

6. **Alegeți formatul**:
   - SRT - Pentru subtitrări (recomandat)
   - TXT - Pentru text simplu
   - TOATE - Ambele formate

7. **Confirmați și așteptați**:
   - Prima rulare va descărca modelul Whisper ales (1-10GB)
   - Procesarea durează 5-30 minute în funcție de:
     * Lungimea video-ului
     * Modelul ales
     * Performanța PC-ului

8. **Rezultate**:
   - Fișierele sunt salvate în același director cu video-ul
   - Exemplu: `video.mp4` → `video.srt` și/sau `video.txt`

## Exemple Rapide / Quick Examples

### Exemplu 1: Video românesc, model small
```bash
# Linie de comandă directă
python3 video-to-text.py video.mp4 small ro srt

# Sau folosiți scriptul interactiv
./video-to-text-linux.sh  # Linux
.\video-to-text-windows.ps1  # Windows
```

### Exemplu 2: Video englezesc, model rapid
```bash
python3 video-to-text.py presentation.mp4 tiny en srt
```

### Exemplu 3: Audio MP3, model de calitate
```bash
python3 video-to-text.py podcast.mp3 medium en txt
```

### Exemplu 4: Video în franceză, toate formatele
```bash
python3 video-to-text.py conference.mp4 small fr all
```

## Probleme Frecvente / Common Issues

### 1. "ffmpeg not found"
**Soluție:**
- Windows: Descărcați ffmpeg și adăugați în PATH
- Linux: `sudo apt-get install ffmpeg`

### 2. "whisper module not found"
**Soluție:**
```bash
pip install openai-whisper
# SAU
pip3 install openai-whisper
```

### 3. "torch not found"
**Soluție:**
```bash
pip install torch --index-url https://download.pytorch.org/whl/cpu
```

### 4. Procesare foarte lentă
**Soluție:**
- Folosiți un model mai mic (`tiny` sau `base`)
- Închideți alte aplicații
- Verificați că aveți RAM liber (minim 4GB)

### 5. Calitate slabă a transcrierii
**Soluție:**
- Folosiți un model mai mare (`medium` sau `large-v3`)
- Verificați că ați ales limba corectă
- Verificați calitatea audio a video-ului

### 6. PowerShell Execution Policy Error
**Soluție:**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Recomandări Model / Model Recommendations

| Scenariu | Model Recomandat | RAM | Timp (10min video) |
|----------|------------------|-----|---------------------|
| **Testare rapidă** | tiny | 1GB | ~3-5 min |
| **Utilizare generală** | **small** ✓ | 2GB | ~5-10 min |
| **Calitate înaltă** | medium | 5GB | ~15-25 min |
| **Maxim acuratețe** | large-v3 | 10GB | ~30-45 min |
| **Echilibru ideal** | turbo | 6GB | ~8-15 min |

## Tips & Tricks

1. **Prima rulare:** Modelul se descarcă o singură dată, apoi e salvat local în cache

2. **Video-uri lungi:** Pentru video-uri >1 oră, folosiți `tiny` sau `base` pentru viteză

3. **Calitate audio:** Pentru audio foarte clar (podcast, prezentare), `small` e suficient

4. **Audio zgomotos:** Pentru audio cu zgomot, folosiți `medium` sau `large-v3`

5. **Multiple fișiere:** Procesați-le unul câte unul - scriptul întreabă dacă vreți alt fișier

6. **Traducere viitor:** Subtitrările generate pot fi traduse ulterior cu AI translation

## Suport

Dacă întâmpinați probleme:
1. Verificați că aveți Python 3.8+ și ffmpeg instalat
2. Verificați că aveți internet pentru prima descărcare a modelului
3. Verificați că aveți suficient spațiu pe disc (10-15GB pentru modele mari)
4. Deschideți un issue pe GitHub cu detalii despre eroare

## Următorii Pași

După ce aveți subtitrări generate, puteți:
- Le folosiți direct în playere video (VLC, Media Player Classic, etc.)
- Le editați manual dacă e nevoie
- Le traduceți în alte limbi (viitoare funcționalitate)
- Le folosiți pentru indexare/căutare în video-uri

---

**Succes cu transcrierea!** 🎉
