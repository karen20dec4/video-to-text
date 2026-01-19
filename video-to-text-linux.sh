#!/bin/bash
# Video to Text Converter - Linux Debian Script
# Interactive text-based interface for converting videos to subtitles

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Video file extensions pattern
VIDEO_EXTENSIONS="*.mp4 *.avi *.mkv *.mov *.flv *.wmv *.webm *.m4v *.mpg *.mpeg"
VIDEO_FIND_PATTERN="\( -iname \"*.mp4\" -o -iname \"*.avi\" -o -iname \"*.mkv\" -o -iname \"*.mov\" -o -iname \"*.flv\" -o -iname \"*.wmv\" -o -iname \"*.webm\" -o -iname \"*.m4v\" -o -iname \"*.mpg\" -o -iname \"*.mpeg\" \)"

# Function to display banner
show_banner() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     VIDEO TO TEXT CONVERTER - LINUX VERSION           ║${NC}"
    echo -e "${CYAN}║     Conversie Video la Subtitrare cu Optimizare      ║${NC}"
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
    
    local libs=("speech_recognition" "pydub")
    local missing_libs=()
    
    for lib in "${libs[@]}"; do
        if python3 -c "import $lib" &> /dev/null; then
            echo -e "${GREEN}✓ $lib: Instalat${NC}"
        else
            echo -e "${RED}✗ $lib: Lipsește${NC}"
            missing_libs+=("$lib")
            all_ok=false
        fi
    done
    
    if [ ${#missing_libs[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Librării lipsă detectate${NC}"
        echo -e "${CYAN}Instalare librării: pip3 install SpeechRecognition pydub${NC}"
        echo ""
        read -p "Doriți să instalez automat aceste librării? (d/n): " response
        
        if [[ "$response" =~ ^[Dd]$ ]]; then
            pip3 install SpeechRecognition pydub
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Librării instalate cu succes!${NC}"
                all_ok=true
            else
                echo -e "${RED}✗ Eroare la instalarea librăriilor${NC}"
                all_ok=false
            fi
        else
            echo -e "${YELLOW}Vă rugăm instalați manual: pip3 install SpeechRecognition pydub${NC}"
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

# Function to select video file
select_video_file() {
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SELECTARE FIȘIER VIDEO${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    
    # Check if zenity is available for GUI dialog
    if command -v zenity &> /dev/null; then
        echo -e "${WHITE}Opțiuni de selectare:${NC}"
        echo -e "${WHITE}  1. Dialog grafic de selectare (Zenity)${NC}"
        echo -e "${WHITE}  2. Introduceți calea manual${NC}"
        echo -e "${WHITE}  3. Căutare în directorul curent${NC}"
        echo ""
        
        read -p "Alegeți opțiunea (1-3): " choice
        
        case $choice in
            1)
                video_path=$(zenity --file-selection --title="Selectați fișierul video" \
                    --file-filter="Video files (mp4,avi,mkv,mov,flv,wmv,webm) | $VIDEO_EXTENSIONS" \
                    --file-filter='All files | *' 2>/dev/null)
                
                if [ -n "$video_path" ] && [ -f "$video_path" ]; then
                    echo -e "${GREEN}✓ Fișier selectat: $video_path${NC}"
                    echo "$video_path"
                    return 0
                else
                    echo -e "${YELLOW}Selectare anulată${NC}"
                    return 1
                fi
                ;;
            2)
                echo ""
                echo -e "${WHITE}Introduceți calea completă către fișierul video:${NC}"
                echo -e "${CYAN}(Exemplu: /home/user/Videos/film.mp4)${NC}"
                read -p "Cale fișier: " video_path
                
                if [ -f "$video_path" ]; then
                    echo -e "${GREEN}✓ Fișier găsit: $video_path${NC}"
                    echo "$video_path"
                    return 0
                else
                    echo -e "${RED}✗ Fișierul nu există: $video_path${NC}"
                    return 1
                fi
                ;;
            3)
                echo ""
                echo -e "${CYAN}Căutare fișiere video în directorul curent...${NC}"
                echo ""
                
                # Find video files in current directory
                local video_files=()
                while IFS= read -r -d '' file; do
                    video_files+=("$file")
                done < <(find . -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.webm" -o -iname "*.m4v" -o -iname "*.mpg" -o -iname "*.mpeg" \) -print0 2>/dev/null)
                
                if [ ${#video_files[@]} -eq 0 ]; then
                    echo -e "${RED}✗ Nu s-au găsit fișiere video în directorul curent${NC}"
                    return 1
                fi
                
                echo -e "${WHITE}Fișiere video găsite:${NC}"
                for i in "${!video_files[@]}"; do
                    echo -e "${WHITE}  $((i+1)). $(basename "${video_files[$i]}")${NC}"
                done
                echo ""
                
                read -p "Alegeți fișierul (1-${#video_files[@]}): " file_choice
                
                if [[ "$file_choice" =~ ^[0-9]+$ ]] && [ "$file_choice" -ge 1 ] && [ "$file_choice" -le ${#video_files[@]} ]; then
                    video_path="${video_files[$((file_choice-1))]}"
                    echo -e "${GREEN}✓ Fișier selectat: $video_path${NC}"
                    echo "$video_path"
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
        # No zenity, use manual entry or current directory search
        echo -e "${WHITE}Opțiuni de selectare:${NC}"
        echo -e "${WHITE}  1. Introduceți calea manual${NC}"
        echo -e "${WHITE}  2. Căutare în directorul curent${NC}"
        echo ""
        
        read -p "Alegeți opțiunea (1-2): " choice
        
        case $choice in
            1)
                echo ""
                echo -e "${WHITE}Introduceți calea completă către fișierul video:${NC}"
                echo -e "${CYAN}(Exemplu: /home/user/Videos/film.mp4)${NC}"
                read -p "Cale fișier: " video_path
                
                if [ -f "$video_path" ]; then
                    echo -e "${GREEN}✓ Fișier găsit: $video_path${NC}"
                    echo "$video_path"
                    return 0
                else
                    echo -e "${RED}✗ Fișierul nu există: $video_path${NC}"
                    return 1
                fi
                ;;
            2)
                echo ""
                echo -e "${CYAN}Căutare fișiere video în directorul curent...${NC}"
                echo ""
                
                local video_files=()
                while IFS= read -r -d '' file; do
                    video_files+=("$file")
                done < <(find . -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.flv" -o -iname "*.wmv" -o -iname "*.webm" -o -iname "*.m4v" -o -iname "*.mpg" -o -iname "*.mpeg" \) -print0 2>/dev/null)
                
                if [ ${#video_files[@]} -eq 0 ]; then
                    echo -e "${RED}✗ Nu s-au găsit fișiere video în directorul curent${NC}"
                    return 1
                fi
                
                echo -e "${WHITE}Fișiere video găsite:${NC}"
                for i in "${!video_files[@]}"; do
                    echo -e "${WHITE}  $((i+1)). $(basename "${video_files[$i]}")${NC}"
                done
                echo ""
                
                read -p "Alegeți fișierul (1-${#video_files[@]}): " file_choice
                
                if [[ "$file_choice" =~ ^[0-9]+$ ]] && [ "$file_choice" -ge 1 ] && [ "$file_choice" -le ${#video_files[@]} ]; then
                    video_path="${video_files[$((file_choice-1))]}"
                    echo -e "${GREEN}✓ Fișier selectat: $video_path${NC}"
                    echo "$video_path"
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

# Function to select language
select_language() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SELECTARE LIMBĂ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${WHITE}Limbi disponibile:${NC}"
    echo -e "${WHITE}  1. Română (ro-RO)${NC}"
    echo -e "${WHITE}  2. Engleză - US (en-US)${NC}"
    echo -e "${WHITE}  3. Engleză - UK (en-GB)${NC}"
    echo -e "${WHITE}  4. Franceză (fr-FR)${NC}"
    echo -e "${WHITE}  5. Germană (de-DE)${NC}"
    echo -e "${WHITE}  6. Spaniolă (es-ES)${NC}"
    echo -e "${WHITE}  7. Italiană (it-IT)${NC}"
    echo -e "${WHITE}  8. Portugheză (pt-PT)${NC}"
    echo -e "${WHITE}  9. Altă limbă (cod personalizat)${NC}"
    echo ""
    
    read -p "Alegeți limba (1-9): " choice
    
    case $choice in
        1) echo "ro-RO" ;;
        2) echo "en-US" ;;
        3) echo "en-GB" ;;
        4) echo "fr-FR" ;;
        5) echo "de-DE" ;;
        6) echo "es-ES" ;;
        7) echo "it-IT" ;;
        8) echo "pt-PT" ;;
        9)
            read -p "Introduceți codul limbii (ex: ru-RU): " custom_lang
            echo "$custom_lang"
            ;;
        *)
            echo -e "${YELLOW}Opțiune invalidă. Se folosește limba implicită: ro-RO${NC}" >&2
            echo "ro-RO"
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
    echo -e "${WHITE}  3. JSON - Date structurate cu timestamp-uri${NC}"
    echo -e "${WHITE}  4. TOATE - Generează toate formatele${NC}"
    echo ""
    
    read -p "Alegeți formatul (1-4): " choice
    
    case $choice in
        1) echo "srt" ;;
        2) echo "txt" ;;
        3) echo "json" ;;
        4) echo "all" ;;
        *)
            echo -e "${YELLOW}Opțiune invalidă. Se folosește formatul implicit: SRT${NC}" >&2
            echo "srt"
            ;;
    esac
}

# Function to process video
process_video() {
    local video_path="$1"
    local language="$2"
    local output_format="$3"
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  PROCESARE VIDEO${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${CYAN}Fișier video: $video_path${NC}"
    echo -e "${CYAN}Limbă: $language${NC}"
    echo -e "${CYAN}Format ieșire: $output_format${NC}"
    echo -e "${CYAN}Optimizare subtitrare: Activată${NC}"
    echo ""
    
    # Get script directory
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local python_script="$script_dir/video_to_text.py"
    
    # Check if Python script exists
    if [ ! -f "$python_script" ]; then
        echo -e "${RED}✗ Eroare: Scriptul Python nu a fost găsit: $python_script${NC}"
        echo -e "${YELLOW}Vă rugăm asigurați-vă că video_to_text.py este în același director cu acest script.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Începe procesarea...${NC}"
    echo -e "${YELLOW}Acest proces poate dura câteva minute în funcție de lungimea video-ului.${NC}"
    echo ""
    
    # Run Python script
    python3 "$python_script" "$video_path" "$language" "$output_format"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ PROCESARE COMPLETĂ CU SUCCES!${NC}"
        echo ""
        return 0
    else
        echo ""
        echo -e "${RED}✗ Eroare la procesare${NC}"
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
        echo -e "${CYAN}  CONFIGURARE CONVERSIE${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo ""
        
        # Select video file
        video_path=$(select_video_file)
        if [ $? -ne 0 ] || [ -z "$video_path" ]; then
            echo ""
            read -p "Doriți să încercați din nou? (d/n): " retry
            if [[ ! "$retry" =~ ^[Dd]$ ]]; then
                break
            fi
            continue
        fi
        
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
        echo -e "${WHITE}  Video: $(basename "$video_path")${NC}"
        echo -e "${WHITE}  Limbă: $language${NC}"
        echo -e "${WHITE}  Format: $output_format${NC}"
        echo ""
        
        read -p "Continuați cu procesarea? (d/n): " confirm
        if [[ "$confirm" =~ ^[Dd]$ ]]; then
            if process_video "$video_path" "$language" "$output_format"; then
                echo ""
                echo -e "${GREEN}Fișierele de ieșire au fost salvate în același director cu video-ul.${NC}"
            fi
        else
            echo -e "${YELLOW}Procesare anulată${NC}"
        fi
        
        echo ""
        read -p "Doriți să procesați alt video? (d/n): " another
        
        if [[ ! "$another" =~ ^[Dd]$ ]]; then
            break
        fi
    done
    
    echo ""
    echo -e "${GREEN}Mulțumim că ați folosit Video to Text Converter!${NC}"
    echo -e "${CYAN}La revedere!${NC}"
    echo ""
}

# Run main program
main
