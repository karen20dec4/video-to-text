# Traducere Automată cu AI Local / Automatic Translation with Local AI

## Viziune / Vision

Următoarea fază de dezvoltare va include traducerea automată a subtitrărilor folosind modele AI locale, permițând utilizatorilor să genereze subtitrări în multiple limbi fără a depinde de servicii cloud externe.

## Arhitectură Propusă / Proposed Architecture

### 1. Modele AI Locale

#### Opțiunea A: Whisper AI (OpenAI)
```python
# Exemplu implementare viitoare
import whisper

class WhisperTranslator:
    def __init__(self, model_size="base"):
        self.model = whisper.load_model(model_size)
    
    def transcribe_and_translate(self, audio_path, target_language):
        result = self.model.transcribe(
            audio_path,
            task="translate",
            language=target_language
        )
        return result["text"]
```

**Avantaje:**
- Suport pentru 99+ limbi
- Performanță excelentă
- Funcționează complet offline
- Modele de diferite dimensiuni (tiny, base, small, medium, large)

**Dezavantaje:**
- Necesită resurse computaționale semnificative
- Modele mari (>1GB pentru versiunile performante)

#### Opțiunea B: MarianMT (Hugging Face)
```python
# Exemplu implementare viitoare
from transformers import MarianMTModel, MarianTokenizer

class MarianTranslator:
    def __init__(self, source_lang, target_lang):
        model_name = f'Helsinki-NLP/opus-mt-{source_lang}-{target_lang}'
        self.tokenizer = MarianTokenizer.from_pretrained(model_name)
        self.model = MarianMTModel.from_pretrained(model_name)
    
    def translate(self, text):
        tokens = self.tokenizer([text], return_tensors="pt", padding=True)
        translated = self.model.generate(**tokens)
        return self.tokenizer.decode(translated[0], skip_special_tokens=True)
```

**Avantaje:**
- Modele specializate pentru perechi de limbi
- Dimensiuni mici ale modelelor (~300MB)
- Traducere rapidă
- Calitate bună pentru limbi europene

**Dezavantaje:**
- Necesită model separat pentru fiecare pereche de limbi
- Mai puține limbi disponibile decât Whisper

#### Opțiunea C: NLLB (No Language Left Behind - Meta)
```python
# Exemplu implementare viitoare
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

class NLLBTranslator:
    def __init__(self):
        model_name = "facebook/nllb-200-distilled-600M"
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
    
    def translate(self, text, src_lang, tgt_lang):
        self.tokenizer.src_lang = src_lang
        inputs = self.tokenizer(text, return_tensors="pt")
        
        translated = self.model.generate(
            **inputs,
            forced_bos_token_id=self.tokenizer.lang_code_to_id[tgt_lang]
        )
        
        return self.tokenizer.batch_decode(translated, skip_special_tokens=True)[0]
```

**Avantaje:**
- Suport pentru 200+ limbi
- Un singur model pentru toate perechile de limbi
- Calitate foarte bună

**Dezavantaje:**
- Model mare (~2.5GB)
- Mai lent decât modelele specializate

### 2. Interfață Utilizator Propusă

#### Windows PowerShell
```powershell
# Opțiuni noi în meniu:
Write-Host "  5. Traducere subtitrare existentă" -ForegroundColor $PromptColor
Write-Host "  6. Conversie + Traducere automată" -ForegroundColor $PromptColor

# Workflow traducere:
# 1. Selectare fișier SRT/TXT/JSON
# 2. Selectare limbă sursă
# 3. Selectare limbă țintă (sau multiple limbi)
# 4. Selectare model AI (Whisper/Marian/NLLB)
# 5. Procesare și generare fișiere traduse
```

#### Linux Bash
```bash
# Opțiuni noi în meniu:
echo -e "${WHITE}  5. Traducere subtitrare existentă${NC}"
echo -e "${WHITE}  6. Conversie + Traducere automată${NC}"

# Workflow similar cu Windows
```

### 3. Structură Fișiere Ieșire

```
video.mp4
├── video_ro-RO.srt          # Subtitrare originală (română)
├── video_en-US.srt          # Traducere engleză
├── video_fr-FR.srt          # Traducere franceză
├── video_de-DE.srt          # Traducere germană
└── translations/
    ├── video_metadata.json  # Metadate traduceri
    └── translation_log.txt  # Log procesare
```

## Implementare Etapizată / Phased Implementation

### Faza 1: Infrastructură de Bază (Curent) ✅
- [x] Extragere audio din video
- [x] Transcripție vocală
- [x] Generare subtitrări optimizate
- [x] Interfață text interactivă
- [x] Suport multiple formate

### Faza 2: Pregătire pentru AI (În curs)
- [ ] Refactorizare cod pentru modularitate
- [ ] Adăugare sistem de plugin-uri
- [ ] Creare interfață abstractă pentru traducători
- [ ] Implementare cache pentru modele AI
- [ ] Optimizare memorie și performanță

### Faza 3: Integrare Model AI Simplu
- [ ] Implementare MarianMT pentru perechi comune:
  - ro-RO ↔ en-US
  - en-US ↔ fr-FR
  - en-US ↔ de-DE
  - en-US ↔ es-ES
- [ ] Interfață pentru selectare limbă țintă
- [ ] Procesare batch pentru multiple limbi
- [ ] Validare și testare traduceri

### Faza 4: Modele Avansate
- [ ] Integrare Whisper AI (opțional)
- [ ] Integrare NLLB pentru limbi rare
- [ ] Sistem de selecție automată model optim
- [ ] Suport GPU pentru accelerare
- [ ] Fine-tuning pentru domenii specifice

### Faza 5: Funcționalități Avansate
- [ ] Editor de subtitrări integrat
- [ ] Corectare automată traduceri
- [ ] Sincronizare timp subtitrări
- [ ] Export pentru platforme video (YouTube, Vimeo)
- [ ] Interfață grafică (GUI)

## Cerințe Tehnice Viitoare / Future Technical Requirements

### Hardware Minim pentru Traducere AI
```
CPU: Intel i5/AMD Ryzen 5 sau superior
RAM: 8GB (16GB recomandat pentru modele mari)
Spațiu Disc: 5GB pentru modele
GPU: Opțional, dar recomandat pentru performanță (CUDA/ROCm)
```

### Dependențe Python Noi
```txt
# Pentru Whisper
openai-whisper>=20230124
torch>=2.0.0
torchaudio>=2.0.0

# Pentru MarianMT/NLLB
transformers>=4.30.0
sentencepiece>=0.1.99
sacremoses>=0.0.53

# Pentru accelerare GPU
torch-cuda>=2.0.0  # Pentru NVIDIA
torch-rocm>=2.0.0  # Pentru AMD

# Utilități
langdetect>=1.0.9
pycountry>=22.3.5
```

## Exemple de Utilizare Viitor / Future Usage Examples

### Exemplu 1: Conversie + Traducere Automată
```bash
# Linux
./video-to-text-linux.sh

# Opțiuni noi:
# 6. Conversie + Traducere automată
#    - Selectare video
#    - Limbă sursă: ro-RO (autodetectare)
#    - Limbi țintă: en-US, fr-FR, de-DE
#    - Model: MarianMT (rapid) sau NLLB (complet)
#
# Rezultate:
# - video_ro-RO.srt (original)
# - video_en-US.srt (tradus)
# - video_fr-FR.srt (tradus)
# - video_de-DE.srt (tradus)
```

### Exemplu 2: Traducere Subtitrare Existentă
```bash
# Linie de comandă
python3 video_to_text.py translate \
    --input video_ro.srt \
    --source ro-RO \
    --targets en-US fr-FR de-DE \
    --model marian \
    --output-dir ./translations/
```

### Exemplu 3: Batch Traducere pentru Canal YouTube
```bash
#!/bin/bash
# translate_all_videos.sh

# Procesați toate video-urile unui canal
for video in youtube_videos/*.mp4; do
    base=$(basename "$video" .mp4)
    
    # Generați subtitrare originală (română)
    python3 video_to_text.py "$video" ro-RO srt
    
    # Traduceți în multiple limbi
    python3 video_to_text.py translate \
        --input "youtube_videos/${base}.srt" \
        --source ro-RO \
        --targets en-US es-ES fr-FR de-DE it-IT pt-PT \
        --model nllb \
        --optimize
    
    echo "Completat: $base (7 limbi)"
done
```

## Design Pattern pentru Extensibilitate / Design Pattern for Extensibility

```python
# video_to_text_v2.py - Arhitectură viitoare

from abc import ABC, abstractmethod

class Translator(ABC):
    """Interfață abstractă pentru traducători"""
    
    @abstractmethod
    def translate(self, text: str, source_lang: str, target_lang: str) -> str:
        pass
    
    @abstractmethod
    def get_supported_languages(self) -> list:
        pass
    
    @abstractmethod
    def is_available(self) -> bool:
        """Verifică dacă modelul este disponibil local"""
        pass

class MarianTranslator(Translator):
    """Implementare pentru MarianMT"""
    def translate(self, text, source_lang, target_lang):
        # Implementare...
        pass

class WhisperTranslator(Translator):
    """Implementare pentru Whisper"""
    def translate(self, text, source_lang, target_lang):
        # Implementare...
        pass

class NLLBTranslator(Translator):
    """Implementare pentru NLLB"""
    def translate(self, text, source_lang, target_lang):
        # Implementare...
        pass

class TranslationManager:
    """Manager pentru selectarea traducătorului optim"""
    
    def __init__(self):
        self.translators = {
            'marian': MarianTranslator(),
            'whisper': WhisperTranslator(),
            'nllb': NLLBTranslator()
        }
    
    def get_best_translator(self, source_lang, target_lang):
        """Selectează cel mai bun traducător pentru perechea de limbi"""
        # Logică de selecție...
        pass
    
    def translate_subtitle(self, subtitle_path, source_lang, target_langs):
        """Traduce un fișier de subtitrare în multiple limbi"""
        # Implementare...
        pass
```

## Cronologie Estimată / Estimated Timeline

```
Q2 2026: Faza 2 - Pregătire infrastructură
Q3 2026: Faza 3 - Implementare MarianMT
Q4 2026: Faza 4 - Modele avansate (Whisper/NLLB)
Q1 2027: Faza 5 - Funcționalități avansate și GUI
```

## Contribuții / Contributing

Dacă doriți să contribuiți la dezvoltarea funcționalității de traducere:

1. Testați modelele AI locale pe sistemul dumneavoastră
2. Raportați performanța pentru diferite configurații hardware
3. Sugereți îmbunătățiri pentru interfața de traducere
4. Contribuiți cu traduceri de test pentru validare
5. Documentați cazuri de utilizare specifice

## Resurse / Resources

### Documentație Modele AI
- [Whisper AI](https://github.com/openai/whisper)
- [MarianMT](https://huggingface.co/Helsinki-NLP)
- [NLLB](https://huggingface.co/facebook/nllb-200-distilled-600M)
- [Transformers](https://huggingface.co/docs/transformers/)

### Tutoriale și Ghiduri
- [Fine-tuning Whisper](https://huggingface.co/blog/fine-tune-whisper)
- [Translation with Transformers](https://huggingface.co/docs/transformers/tasks/translation)
- [Optimizing Inference](https://huggingface.co/docs/transformers/performance)

---

**Notă:** Această funcționalitate este în curs de planificare. Structura actuală a codului este pregătită pentru această extensie viitoare prin design modular și interfețe flexibile.

Pentru întrebări sau sugestii despre funcționalitatea de traducere, deschideți un issue pe GitHub cu label "enhancement" și "translation".
