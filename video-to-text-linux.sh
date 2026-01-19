#!/bin/bash
# Video to Text Transcription - Linux Script
# Whisper AI Integration - Interactive Text Interface
# Version 2.0

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to display banner
show_banner() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     VIDEO TO TEXT TRANSCRIPTION - WHISPER AI         ║${NC}"
    echo -e "${CYAN}║     Transcriere Video/Audio cu AI Local              ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${CYAN}Verificare dependențe...${NC}"
    
    local all_ok=true
    
    # Check Python
    if command -v python3 &> /dev/null; then
        local python_version=$(python3 --version 2>&1)
        echo -e "${GREEN}✓ Python: $python_version${NC}"
    else
        echo -e "${RED}✗ Python3 nu este instalat${NC}"
        echo -e "${YELLOW}Instalați cu: sudo apt-get install python3 python3-pip${NC}"
        all_ok=false
    fi
    
    # Check ffmpeg
    if command -v ffmpeg &> /dev/null; then
        echo -e "${GREEN}✓ ffmpeg: Instalat${NC}"
    else
        echo -e "${RED}✗ ffmpeg nu este instalat${NC}"
        echo -e "${YELLOW}Instalați cu: sudo apt-get install ffmpeg${NC}"
        all_ok=false
    fi
    
    # Check Python libraries
    echo -e "${CYAN}Verificare librării Python...${NC}"
    
    declare -A libs=(
        ["whisper"]="openai-whisper"
        ["srt"]="srt"
        ["pysrt"]="pysrt"
    )
    
    local missing_libs=()
    
    for lib in "${!libs[@]}"; do
        if python3 -c "import $lib" &> /dev/null; then
            echo -e "${GREEN}✓ $lib: Instalat${NC}"
        else
            echo -e "${RED}✗ $lib: Lipsește${NC}"
            missing_libs+=("${libs[$lib]}")
        fi
    done
    
    if [ ${#missing_libs[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Librării lipsă detectate!${NC}"
        echo -e "${CYAN}Instalare: pip3 install ${missing_libs[*]}${NC}"
        echo ""
        read -p "Doriți să instalez automat aceste librării? (d/n): " response
        
        if [[ "$response" =~ ^[Dd]$ ]]; then
            echo -e "${CYAN}Instalare librării...${NC}"
            
            # Install torch first (CPU version)
            echo -e "${CYAN}Instalare PyTorch (CPU)...${NC}"
            pip3 install torch --index-url https://download.pytorch.org/whl/cpu
            
            # Install other libraries
            for pkg in "${missing_libs[@]}"; do
                pip3 install "$pkg"
            done
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Librării instalate cu succes!${NC}"
            else
                echo -e "${RED}✗ Eroare la instalarea librăriilor${NC}"
                all_ok=false
            fi
        else
            echo -e "${YELLOW}Vă rugăm instalați manual librăriile necesare${NC}"
            all_ok=false
        fi
    fi
    
    echo ""
    
    if [ "$all_ok" = true ]; then
        return 0
    else
        return 1
    fi
}

# Function to select media file
select_media_file() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SELECTARE FIȘIER VIDEO/AUDIO${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    
    # Check if zenity is available for GUI dialog
    if command -v zenity &> /dev/null; then
        echo -e "${WHITE}Opțiuni de selectare:${NC}"
        echo -e "${WHITE}  1. Dialog grafic (Zenity)${NC}"
        echo -e "${WHITE}  2. Introduceți calea manual${NC}"
        echo -e "${WHITE}  3. Căutare în directorul curent${NC}"
        echo ""
        
        read -p "Alegeți opțiunea (1-3): " choice
        
        case $choice in
            1)
                file_path=$(zenity --file-selection --title="Selectați fișierul video sau audio" \
                    --file-filter='Video/Audio | *.mp4 *.mkv *.avi *.mov *.flv *.wmv *.webm *.m4v *.mpg *.mpeg *.mp3 *.wav *.m4a *.aac *.ogg *.flac' \
                    --file-filter='All files | *' 2>/dev/null)
                
                if [ -n "$file_path" ] && [ -f "$file_path" ]; then
                    echo -e "${GREEN}✓ Fișier selectat: $file_path${NC}"
                    echo "$file_path"
                    return 0
                else
                    echo -e "${YELLOW}Selectare anulată${NC}"
                    return 1
                fi
                ;;
            2)
                echo ""
                echo -e "${WHITE}Introduceți calea completă către fișier:${NC}"
                echo -e "${CYAN}(Exemplu: /home/user/Videos/film.mp4)${NC}"
                read -p "Cale fișier: " file_path
                
                if [ -f "$file_path" ]; then
                    echo -e "${GREEN}✓ Fișier găsit: $file_path${NC}"
                    echo "$file_path"
                    return 0
                else
                    echo -e "${RED}✗ Fișierul nu există: $file_path${NC}"
                    return 1
                fi
                ;;
            3)
                echo ""
                echo -e "${CYAN}Căutare fișiere în directorul curent...${NC}"
                echo ""
                
                local media_files=()
                while IFS= read -r -d '' file; do
                    media_files+=("$file")
                done < <(find . -maxdepth 1 -type f \( \
                    -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o \
                    -iname "*.flv" -o -iname "*.wmv" -o -iname "*.webm" -o -iname "*.m4v" -o \
                    -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.mp3" -o -iname "*.wav" -o \
                    -iname "*.m4a" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.flac" \
                    \) -print0 2>/dev/null)
                
                if [ ${#media_files[@]} -eq 0 ]; then
                    echo -e "${RED}✗ Nu s-au găsit fișiere în directorul curent${NC}"
                    return 1
                fi
                
                echo -e "${WHITE}Fișiere găsite:${NC}"
                for i in "${!media_files[@]}"; do
                    echo -e "${WHITE}  $((i+1)). $(basename "${media_files[$i]}")${NC}"
                done
                echo ""
                
                read -p "Alegeți fișierul (1-${#media_files[@]}): " file_choice
                
                if [[ "$file_choice" =~ ^[0-9]+$ ]] && [ "$file_choice" -ge 1 ] && [ "$file_choice" -le ${#media_files[@]} ]; then
                    file_path="${media_files[$((file_choice-1))]}"
                    echo -e "${GREEN}✓ Fișier selectat: $file_path${NC}"
                    echo "$file_path"
                    return 0
                else
                    echo -e "${RED}✗ Selecție invalidă${NC}"
                    return 1
                fi
                ;;
            *)
                echo -e "${RED}Opțiune invalidă${NC}"
                return 1
                ;;
        esac
    else
        # No zenity, use manual entry or directory search
        echo -e "${WHITE}Opțiuni de selectare:${NC}"
        echo -e "${WHITE}  1. Introduceți calea manual${NC}"
        echo -e "${WHITE}  2. Căutare în directorul curent${NC}"
        echo ""
        
        read -p "Alegeți opțiunea (1-2): " choice
        
        case $choice in
            1)
                echo ""
                echo -e "${WHITE}Introduceți calea completă către fișier:${NC}"
                echo -e "${CYAN}(Exemplu: /home/user/Videos/film.mp4)${NC}"
                read -p "Cale fișier: " file_path
                
                if [ -f "$file_path" ]; then
                    echo -e "${GREEN}✓ Fișier găsit: $file_path${NC}"
                    echo "$file_path"
                    return 0
                else
                    echo -e "${RED}✗ Fișierul nu există: $file_path${NC}"
                    return 1
                fi
                ;;
            2)
                echo ""
                echo -e "${CYAN}Căutare fișiere în directorul curent...${NC}"
                echo ""
                
                local media_files=()
                while IFS= read -r -d '' file; do
                    media_files+=("$file")
                done < <(find . -maxdepth 1 -type f \( \
                    -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o \
                    -iname "*.flv" -o -iname "*.wmv" -o -iname "*.webm" -o -iname "*.m4v" -o \
                    -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.mp3" -o -iname "*.wav" -o \
                    -iname "*.m4a" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.flac" \
                    \) -print0 2>/dev/null)
                
                if [ ${#media_files[@]} -eq 0 ]; then
                    echo -e "${RED}✗ Nu s-au găsit fișiere în directorul curent${NC}"
                    return 1
                fi
                
                echo -e "${WHITE}Fișiere găsite:${NC}"
                for i in "${!media_files[@]}"; do
                    echo -e "${WHITE}  $((i+1)). $(basename "${media_files[$i]}")${NC}"
                done
                echo ""
                
                read -p "Alegeți fișierul (1-${#media_files[@]}): " file_choice
                
                if [[ "$file_choice" =~ ^[0-9]+$ ]] && [ "$file_choice" -ge 1 ] && [ "$file_choice" -le ${#media_files[@]} ]; then
                    file_path="${media_files[$((file_choice-1))]}"
                    echo -e "${GREEN}✓ Fișier selectat: $file_path${NC}"
                    echo "$file_path"
                    return 0
                else
                    echo -e "${RED}✗ Selecție invalidă${NC}"
                    return 1
                fi
                ;;
            *)
                echo -e "${RED}Opțiune invalidă${NC}"
                return 1
                ;;
        esac
    fi
}

# Function to select Whisper model
select_whisper_model() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SELECTARE MODEL WHISPER AI${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${WHITE}Modele disponibile (calitate vs. viteză):${NC}"
    echo -e "${WHITE}  1. tiny   - Cel mai rapid, calitate mai scăzută (~1GB RAM)${NC}"
    echo -e "${WHITE}  2. base   - Rapid, calitate decentă (~1GB RAM)${NC}"
    echo -e "${GREEN}  3. small  - Echilibrat, calitate bună (~2GB RAM) [RECOMANDAT]${NC}"
    echo -e "${WHITE}  4. medium - Mai lent, calitate foarte bună (~5GB RAM)${NC}"
    echo -e "${WHITE}  5. large-v3 - Cel mai lent, calitate excelentă (~10GB RAM)${NC}"
    echo -e "${WHITE}  6. turbo  - Rapid și precis, calitate excelentă (~6GB RAM)${NC}"
    echo ""
    
    read -p "Alegeți modelul (1-6, default: 3): " choice
    
    if [ -z "$choice" ]; then
        choice="3"
    fi
    
    case $choice in
        1) echo "tiny" ;;
        2) echo "base" ;;
        3) echo "small" ;;
        4) echo "medium" ;;
        5) echo "large-v3" ;;
        6) echo "turbo" ;;
        *)
            echo -e "${YELLOW}Opțiune invalidă. Se folosește modelul implicit: small${NC}" >&2
            echo "small"
            ;;
    esac
}

# Function to select language
select_language() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SELECTARE LIMBĂ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${WHITE}Limbi disponibile:${NC}"
    echo -e "${WHITE}  1. Română (ro)${NC}"
    echo -e "${WHITE}  2. Engleză (en)${NC}"
    echo -e "${WHITE}  3. Franceză (fr)${NC}"
    echo -e "${WHITE}  4. Germană (de)${NC}"
    echo -e "${WHITE}  5. Spaniolă (es)${NC}"
    echo -e "${WHITE}  6. Italiană (it)${NC}"
    echo -e "${WHITE}  7. Portugheză (pt)${NC}"
    echo -e "${WHITE}  8. Rusă (ru)${NC}"
    echo -e "${WHITE}  9. Altă limbă (cod personalizat)${NC}"
    echo ""
    
    read -p "Alegeți limba (1-9, default: 1): " choice
    
    if [ -z "$choice" ]; then
        choice="1"
    fi
    
    case $choice in
        1) echo "ro" ;;
        2) echo "en" ;;
        3) echo "fr" ;;
        4) echo "de" ;;
        5) echo "es" ;;
        6) echo "it" ;;
        7) echo "pt" ;;
        8) echo "ru" ;;
        9)
            read -p "Introduceți codul limbii (ex: pl, nl, uk): " custom_lang
            echo "$custom_lang"
            ;;
        *)
            echo -e "${YELLOW}Opțiune invalidă. Se folosește limba implicită: ro${NC}" >&2
            echo "ro"
            ;;
    esac
}

# Function to select output format
select_output_format() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  FORMAT IEȘIRE${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${WHITE}Formate disponibile:${NC}"
    echo -e "${WHITE}  1. SRT - Fișier subtitrare (recomandat)${NC}"
    echo -e "${WHITE}  2. TXT - Text simplu${NC}"
    echo -e "${WHITE}  3. TOATE - Generează ambele formate${NC}"
    echo ""
    
    read -p "Alegeți formatul (1-3, default: 1): " choice
    
    if [ -z "$choice" ]; then
        choice="1"
    fi
    
    case $choice in
        1) echo "srt" ;;
        2) echo "txt" ;;
        3) echo "all" ;;
        *)
            echo -e "${YELLOW}Opțiune invalidă. Se folosește formatul implicit: SRT${NC}" >&2
            echo "srt"
            ;;
    esac
}

# Function to process video/audio
process_transcription() {
    local file_path="$1"
    local model="$2"
    local language="$3"
    local output_format="$4"
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  PROCESARE FIȘIER${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${CYAN}Fișier: $file_path${NC}"
    echo -e "${CYAN}Model Whisper: $model${NC}"
    echo -e "${CYAN}Limbă: $language${NC}"
    echo -e "${CYAN}Format ieșire: $output_format${NC}"
    echo -e "${CYAN}Optimizare subtitrare: Activată (80-120 caractere)${NC}"
    echo ""
    
    # Get script directory
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local python_script="$script_dir/video-to-text.py"
    
    # Check if Python script exists
    if [ ! -f "$python_script" ]; then
        echo -e "${RED}✗ Eroare: Scriptul Python nu a fost găsit: $python_script${NC}"
        echo -e "${YELLOW}Vă rugăm asigurați-vă că video-to-text.py este în același director.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Începe transcrierea cu Whisper AI...${NC}"
    echo -e "${YELLOW}ATENȚIE: Prima rulare va descărca modelul AI (~1-10GB, în funcție de model)${NC}"
    echo -e "${YELLOW}Acest proces poate dura 5-30 minute în funcție de:${NC}"
    echo -e "${CYAN}  - Lungimea fișierului${NC}"
    echo -e "${CYAN}  - Modelul ales${NC}"
    echo -e "${CYAN}  - Performanța calculatorului${NC}"
    echo ""
    
    # Run Python script
    python3 "$python_script" "$file_path" "$model" "$language" "$output_format"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ TRANSCRIERE COMPLETĂ CU SUCCES!${NC}"
        echo ""
        return 0
    else
        echo ""
        echo -e "${RED}✗ Eroare la transcriere${NC}"
        return 1
    fi
}

# Main program
main() {
    show_banner
    
    # Check prerequisites
    if ! check_prerequisites; then
        echo ""
        echo -e "${YELLOW}Vă rugăm instalați dependențele lipsă și rulați din nou scriptul.${NC}"
        read -p "Apăsați Enter pentru a ieși"
        exit 1
    fi
    
    while true; do
        echo ""
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${CYAN}  CONFIGURARE TRANSCRIERE${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo ""
        
        # Select file
        file_path=$(select_media_file)
        if [ $? -ne 0 ] || [ -z "$file_path" ]; then
            echo ""
            read -p "Doriți să încercați din nou? (d/n): " retry
            if [[ ! "$retry" =~ ^[Dd]$ ]]; then
                break
            fi
            continue
        fi
        
        # Select model
        model=$(select_whisper_model)
        
        # Select language
        language=$(select_language)
        
        # Select output format
        output_format=$(select_output_format)
        
        # Confirm and process
        echo ""
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${CYAN}  CONFIRMARE${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo ""
        echo -e "${WHITE}Setări alese:${NC}"
        echo -e "${WHITE}  Fișier: $(basename "$file_path")${NC}"
        echo -e "${WHITE}  Model: $model${NC}"
        echo -e "${WHITE}  Limbă: $language${NC}"
        echo -e "${WHITE}  Format: $output_format${NC}"
        echo ""
        
        read -p "Continuați cu transcrierea? (d/n): " confirm
        if [[ "$confirm" =~ ^[Dd]$ ]]; then
            if process_transcription "$file_path" "$model" "$language" "$output_format"; then
                echo ""
                echo -e "${GREEN}Fișierele de ieșire au fost salvate în același director cu fișierul sursă.${NC}"
            fi
        else
            echo -e "${YELLOW}Transcriere anulată${NC}"
        fi
        
        echo ""
        read -p "Doriți să procesați alt fișier? (d/n): " another
        
        if [[ ! "$another" =~ ^[Dd]$ ]]; then
            break
        fi
    done
    
    echo ""
    echo -e "${GREEN}Mulțumim că ați folosit Video to Text Transcription!${NC}"
    echo -e "${CYAN}La revedere!${NC}"
    echo ""
}

# Run main program
main
