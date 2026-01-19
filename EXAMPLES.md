# Exemple de Utilizare / Usage Examples

## Exemple Pas cu Pas / Step-by-Step Examples

### Exemplu 1: Conversie video Romanian → Subtitrare SRT

**Windows PowerShell:**
```powershell
# Rulați scriptul interactiv
.\video-to-text-windows.ps1

# Urmați pașii:
# 1. Alegeți opțiunea 1 pentru dialog grafic
# 2. Selectați fisierul: C:\Videos\interviu.mp4
# 3. Alegeți limba: 1 (Română - ro-RO)
# 4. Alegeți formatul: 1 (SRT)
# 5. Confirmați: D (Da)

# Rezultat: C:\Videos\interviu.srt
```

**Linux:**
```bash
# Rulați scriptul interactiv
./video-to-text-linux.sh

# Urmați pașii:
# 1. Alegeți opțiunea 1 (Zenity dialog) sau 2 (manual)
# 2. Selectați fisierul: /home/user/Videos/interviu.mp4
# 3. Alegeți limba: 1 (Română - ro-RO)
# 4. Alegeți formatul: 1 (SRT)
# 5. Confirmați: d (da)

# Rezultat: /home/user/Videos/interviu.srt
```

### Exemplu 2: Conversie linie de comandă (direct)

**Conversie simplă:**
```bash
# Windows
python video_to_text.py "C:\Videos\tutorial.mp4" en-US srt

# Linux
python3 video_to_text.py "/home/user/Videos/tutorial.mp4" en-US srt
```

**Conversie în toate formatele:**
```bash
# Windows
python video_to_text.py "C:\Videos\prezentare.mp4" ro-RO all

# Linux
python3 video_to_text.py "/home/user/Videos/prezentare.mp4" ro-RO all

# Rezultate:
# - prezentare.srt (subtitrare standard)
# - prezentare.txt (text simplu)
# - prezentare.json (date structurate cu timestamp-uri)
```

### Exemplu 3: Procesare multiplă video-uri

**Folosind scriptul interactiv:**
```bash
# Rulați scriptul
./video-to-text-linux.sh

# La sfârșit, când întrebat "Doriți să procesați alt video?":
# Răspundeți: d (da)
# Repetați procesul pentru fiecare video
```

**Folosind script batch (Windows):**
```powershell
# Creați un fișier process_all.ps1:
$videos = Get-ChildItem -Path "C:\Videos" -Filter "*.mp4"

foreach ($video in $videos) {
    Write-Host "Procesare: $($video.Name)"
    python video_to_text.py $video.FullName "ro-RO" "srt"
}
```

**Folosind script bash (Linux):**
```bash
#!/bin/bash
# Creați un fișier process_all.sh:

for video in /home/user/Videos/*.mp4; do
    echo "Procesare: $video"
    python3 video_to_text.py "$video" "ro-RO" "srt"
done
```

### Exemplu 4: Conversie cu limbi diferite

**Video multilingv - Engleză și Franceză:**
```bash
# Prima dată pentru Engleză
python3 video_to_text.py "conference.mp4" "en-US" "srt"
# Rezultat: conference.srt

# Mutați fișierul
mv conference.srt conference_en.srt

# A doua oară pentru Franceză
python3 video_to_text.py "conference.mp4" "fr-FR" "srt"
# Rezultat: conference.srt

# Redenumire
mv conference.srt conference_fr.srt
```

## Exemple Format Ieșire / Output Format Examples

### Format SRT (SubRip)
```srt
1
00:00:00,000 --> 00:00:05,430
Bună ziua și bun venit la această prezentare
despre conversia video la text.

2
00:00:05,730 --> 00:00:11,280
Astăzi vom discuta despre cum funcționează
recunoașterea vocală automatizată.

3
00:00:11,580 --> 00:00:15,920
Această tehnologie poate salva ore întregi
de muncă manuală.
```

### Format TXT (Text Simplu)
```text
Bună ziua și bun venit la această prezentare despre conversia video la text.
Astăzi vom discuta despre cum funcționează recunoașterea vocală automatizată.
Această tehnologie poate salva ore întregi de muncă manuală.
```

### Format JSON (Date Structurate)
```json
[
  {
    "index": 1,
    "start": 0,
    "end": 5430,
    "text": "Bună ziua și bun venit la această prezentare\ndespre conversia video la text."
  },
  {
    "index": 2,
    "start": 5730,
    "end": 11280,
    "text": "Astăzi vom discuta despre cum funcționează\nrecunoașterea vocală automatizată."
  },
  {
    "index": 3,
    "start": 11580,
    "end": 15920,
    "text": "Această tehnologie poate salva ore întregi\nde muncă manuală."
  }
]
```

## Cazuri de Utilizare Specifice / Specific Use Cases

### 1. Subtitling pentru YouTube
```bash
# Generați subtitrare SRT
python3 video_to_text.py "youtube_video.mp4" "ro-RO" "srt"

# Încărcați fișierul .srt pe YouTube în secțiunea de subtitrări
```

### 2. Transcripție pentru Podcast
```bash
# Generați text simplu pentru blog
python3 video_to_text.py "podcast_episode.mp4" "en-US" "txt"

# Rezultatul poate fi folosit direct în articole de blog
```

### 3. Analiză și Indexare Conținut
```bash
# Generați JSON pentru procesare ulterioară
python3 video_to_text.py "training_video.mp4" "en-US" "json"

# JSON-ul poate fi importat în baze de date sau folosit pentru căutare full-text
```

### 4. Subtitrări pentru Cursuri Online
```bash
# Procesați toate lecțiile dintr-un curs
for i in {1..20}; do
    python3 video_to_text.py "lectie_${i}.mp4" "ro-RO" "srt"
done

# Rezultat: lectie_1.srt, lectie_2.srt, ..., lectie_20.srt
```

### 5. Traducere Viitoare (Pregătire)
```bash
# Generați toate formatele pentru traducere ulterioară
python3 video_to_text.py "original_video.mp4" "en-US" "all"

# Rezultate:
# - original_video.srt - pentru playere video
# - original_video.txt - pentru verificare umană
# - original_video.json - pentru traducere automată (viitor)
```

## Sfaturi pentru Rezultate Optime / Tips for Best Results

### 1. Calitate Audio
```
✅ Bine:
- Audio clar, fără zgomot de fundal
- Vorbire distinctă, ritm moderat
- Microfon de calitate

❌ Evitați:
- Muzică de fundal puternică
- Ecou sau reverberație
- Vorbire prea rapidă sau șoptită
```

### 2. Limba Corectă
```bash
# Dacă aveți dubii despre dialect:
# Încercați ambele variante pentru Engleză:

python3 video_to_text.py "video.mp4" "en-US" "srt"  # American English
python3 video_to_text.py "video.mp4" "en-GB" "srt"  # British English

# Comparați rezultatele și alegeți pe cel mai bun
```

### 3. Verificare Post-Procesare
```bash
# Generați toate formatele pentru verificare
python3 video_to_text.py "important_video.mp4" "ro-RO" "all"

# 1. Verificați .txt pentru acuratețe generală
# 2. Verificați .json pentru timestamp-uri
# 3. Folosiți .srt pentru verificare în player video
```

## Automatizare Avansată / Advanced Automation

### Script pentru Procesare în Lot (Windows)
```powershell
# process_directory.ps1
param(
    [string]$InputDir = "C:\Videos\ToProcess",
    [string]$OutputDir = "C:\Videos\Processed",
    [string]$Language = "ro-RO",
    [string]$Format = "srt"
)

# Creați directorul de ieșire dacă nu există
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir
}

# Procesați toate video-urile
Get-ChildItem -Path $InputDir -Include @("*.mp4", "*.avi", "*.mkv") -Recurse | ForEach-Object {
    Write-Host "Procesare: $($_.Name)" -ForegroundColor Cyan
    
    python video_to_text.py $_.FullName $Language $Format
    
    # Mutați rezultatele în directorul de ieșire
    $baseName = $_.BaseName
    Move-Item "$($_.DirectoryName)\$baseName.$Format" -Destination $OutputDir -Force
    
    Write-Host "Completat: $baseName.$Format" -ForegroundColor Green
}

Write-Host "`nToate video-urile au fost procesate!" -ForegroundColor Green
```

### Script pentru Procesare în Lot (Linux)
```bash
#!/bin/bash
# process_directory.sh

INPUT_DIR="${1:-./videos}"
OUTPUT_DIR="${2:-./subtitles}"
LANGUAGE="${3:-ro-RO}"
FORMAT="${4:-srt}"

# Creați directorul de ieșire
mkdir -p "$OUTPUT_DIR"

# Procesați toate video-urile
find "$INPUT_DIR" -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" \) | while read -r video; do
    echo -e "\e[36mProcesare: $(basename "$video")\e[0m"
    
    python3 video_to_text.py "$video" "$LANGUAGE" "$FORMAT"
    
    # Mutați rezultatele
    base_name=$(basename "$video" | sed 's/\.[^.]*$//')
    mv "$(dirname "$video")/$base_name.$FORMAT" "$OUTPUT_DIR/" 2>/dev/null
    
    echo -e "\e[32mCompletat: $base_name.$FORMAT\e[0m"
done

echo -e "\n\e[32mToate video-urile au fost procesate!\e[0m"
```

**Utilizare:**
```bash
chmod +x process_directory.sh

# Procesați directorul implicit
./process_directory.sh

# Sau specificați parametri
./process_directory.sh /path/to/videos /path/to/output ro-RO srt
```

## Integrare în Workflow / Workflow Integration

### 1. Cu Git/GitHub pentru Documentare
```bash
#!/bin/bash
# Generați documentație automată din video tutorials

for video in tutorials/*.mp4; do
    base=$(basename "$video" .mp4)
    
    # Generați transcript
    python3 video_to_text.py "$video" "en-US" "txt"
    
    # Mutați în directorul docs
    mv "tutorials/${base}.txt" "docs/transcripts/${base}.md"
    
    # Commit
    git add "docs/transcripts/${base}.md"
    git commit -m "Add transcript for $base tutorial"
done

git push
```

### 2. Cu API pentru Procesare Cloud
```python
# cloud_processor.py - Exemplu integrare
import subprocess
import requests

def process_and_upload(video_path, language, api_endpoint):
    # Procesați local
    subprocess.run([
        "python3", "video_to_text.py",
        video_path, language, "json"
    ])
    
    # Încărcați rezultatul
    json_path = video_path.replace(".mp4", ".json")
    with open(json_path, 'r') as f:
        data = f.read()
    
    response = requests.post(api_endpoint, data=data)
    return response.json()
```

---

Pentru mai multe exemple și cazuri de utilizare, consultați [README.md](README.md).
