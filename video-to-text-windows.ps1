# Video to Text Converter - Windows PowerShell Script
# Interactive text-based interface for converting videos to subtitles

# Set encoding for proper Romanian character display
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Color definitions
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"
$PromptColor = "White"

# Function to display banner
function Show-Banner {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor $InfoColor
    Write-Host "║     VIDEO TO TEXT CONVERTER - WINDOWS VERSION         ║" -ForegroundColor $InfoColor
    Write-Host "║     Conversie Video la Subtitrare cu Optimizare      ║" -ForegroundColor $InfoColor
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor $InfoColor
    Write-Host ""
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Host "Verificare dependențe..." -ForegroundColor $InfoColor
    
    # Check Python
    try {
        $pythonVersion = python --version 2>&1
        Write-Host "✓ Python: $pythonVersion" -ForegroundColor $SuccessColor
    } catch {
        Write-Host "✗ Python nu este instalat sau nu este în PATH" -ForegroundColor $ErrorColor
        Write-Host "Descărcați Python de la: https://www.python.org/downloads/" -ForegroundColor $WarningColor
        return $false
    }
    
    # Check ffmpeg
    try {
        $ffmpegVersion = ffmpeg -version 2>&1 | Select-Object -First 1
        Write-Host "✓ ffmpeg: Instalat" -ForegroundColor $SuccessColor
    } catch {
        Write-Host "✗ ffmpeg nu este instalat sau nu este în PATH" -ForegroundColor $ErrorColor
        Write-Host "Descărcați ffmpeg de la: https://ffmpeg.org/download.html" -ForegroundColor $WarningColor
        return $false
    }
    
    # Check Python libraries
    Write-Host "Verificare librării Python..." -ForegroundColor $InfoColor
    
    $libraries = @("speech_recognition", "pydub")
    $allInstalled = $true
    
    foreach ($lib in $libraries) {
        $result = python -c "import $lib" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ $lib: Instalat" -ForegroundColor $SuccessColor
        } else {
            Write-Host "✗ $lib: Lipsește" -ForegroundColor $ErrorColor
            $allInstalled = $false
        }
    }
    
    if (-not $allInstalled) {
        Write-Host ""
        Write-Host "Instalare librării lipsă..." -ForegroundColor $WarningColor
        Write-Host "Rulăm: pip install SpeechRecognition pydub" -ForegroundColor $InfoColor
        
        $response = Read-Host "Doriți să instalez automat aceste librării? (D/N)"
        if ($response -match "^[Dd]") {
            pip install SpeechRecognition pydub
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Librării instalate cu succes!" -ForegroundColor $SuccessColor
            } else {
                Write-Host "✗ Eroare la instalarea librăriilor" -ForegroundColor $ErrorColor
                return $false
            }
        } else {
            Write-Host "Vă rugăm instalați manual: pip install SpeechRecognition pydub" -ForegroundColor $WarningColor
            return $false
        }
    }
    
    Write-Host ""
    return $true
}

# Function to select video file
function Select-VideoFile {
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host "  SELECTARE FIȘIER VIDEO" -ForegroundColor $InfoColor
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host ""
    
    # Option 1: Use file dialog
    Write-Host "Opțiuni de selectare:" -ForegroundColor $PromptColor
    Write-Host "  1. Dialog de selectare fișier (Windows GUI)" -ForegroundColor $PromptColor
    Write-Host "  2. Introduceți calea manual" -ForegroundColor $PromptColor
    Write-Host ""
    
    $choice = Read-Host "Alegeți opțiunea (1/2)"
    
    if ($choice -eq "1") {
        # Use Windows Forms file dialog
        Add-Type -AssemblyName System.Windows.Forms
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.Filter = "Fișiere Video|*.mp4;*.avi;*.mkv;*.mov;*.flv;*.wmv;*.webm;*.m4v;*.mpg;*.mpeg|Toate fișierele|*.*"
        $fileDialog.Title = "Selectați fișierul video"
        
        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $videoPath = $fileDialog.FileName
            Write-Host "✓ Fișier selectat: $videoPath" -ForegroundColor $SuccessColor
            return $videoPath
        } else {
            Write-Host "Selectare anulată" -ForegroundColor $WarningColor
            return $null
        }
    } else {
        # Manual path entry
        Write-Host ""
        Write-Host "Introduceți calea completă către fișierul video:" -ForegroundColor $PromptColor
        Write-Host "(Exemplu: C:\Videos\film.mp4)" -ForegroundColor $InfoColor
        $videoPath = Read-Host "Cale fișier"
        
        if (Test-Path $videoPath) {
            Write-Host "✓ Fișier găsit: $videoPath" -ForegroundColor $SuccessColor
            return $videoPath
        } else {
            Write-Host "✗ Fișierul nu există: $videoPath" -ForegroundColor $ErrorColor
            return $null
        }
    }
}

# Function to select language
function Select-Language {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host "  SELECTARE LIMBĂ" -ForegroundColor $InfoColor
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host ""
    
    Write-Host "Limbi disponibile:" -ForegroundColor $PromptColor
    Write-Host "  1. Română (ro-RO)" -ForegroundColor $PromptColor
    Write-Host "  2. Engleză - US (en-US)" -ForegroundColor $PromptColor
    Write-Host "  3. Engleză - UK (en-GB)" -ForegroundColor $PromptColor
    Write-Host "  4. Franceză (fr-FR)" -ForegroundColor $PromptColor
    Write-Host "  5. Germană (de-DE)" -ForegroundColor $PromptColor
    Write-Host "  6. Spaniolă (es-ES)" -ForegroundColor $PromptColor
    Write-Host "  7. Italiană (it-IT)" -ForegroundColor $PromptColor
    Write-Host "  8. Portugheză (pt-PT)" -ForegroundColor $PromptColor
    Write-Host "  9. Altă limbă (cod personalizat)" -ForegroundColor $PromptColor
    Write-Host ""
    
    $choice = Read-Host "Alegeți limba (1-9)"
    
    switch ($choice) {
        "1" { return "ro-RO" }
        "2" { return "en-US" }
        "3" { return "en-GB" }
        "4" { return "fr-FR" }
        "5" { return "de-DE" }
        "6" { return "es-ES" }
        "7" { return "it-IT" }
        "8" { return "pt-PT" }
        "9" {
            $customLang = Read-Host "Introduceți codul limbii (ex: ru-RU)"
            return $customLang
        }
        default {
            Write-Host "Opțiune invalidă. Se folosește limba implicită: ro-RO" -ForegroundColor $WarningColor
            return "ro-RO"
        }
    }
}

# Function to select output format
function Select-OutputFormat {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host "  FORMAT IEȘIRE" -ForegroundColor $InfoColor
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host ""
    
    Write-Host "Formate disponibile:" -ForegroundColor $PromptColor
    Write-Host "  1. SRT - Fișier subtitrare (recomandat)" -ForegroundColor $PromptColor
    Write-Host "  2. TXT - Text simplu" -ForegroundColor $PromptColor
    Write-Host "  3. JSON - Date structurate cu timestamp-uri" -ForegroundColor $PromptColor
    Write-Host "  4. TOATE - Generează toate formatele" -ForegroundColor $PromptColor
    Write-Host ""
    
    $choice = Read-Host "Alegeți formatul (1-4)"
    
    switch ($choice) {
        "1" { return "srt" }
        "2" { return "txt" }
        "3" { return "json" }
        "4" { return "all" }
        default {
            Write-Host "Opțiune invalidă. Se folosește formatul implicit: SRT" -ForegroundColor $WarningColor
            return "srt"
        }
    }
}

# Function to process video
function Start-VideoProcessing {
    param(
        [string]$VideoPath,
        [string]$Language,
        [string]$OutputFormat
    )
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host "  PROCESARE VIDEO" -ForegroundColor $InfoColor
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host ""
    
    Write-Host "Fișier video: $VideoPath" -ForegroundColor $InfoColor
    Write-Host "Limbă: $Language" -ForegroundColor $InfoColor
    Write-Host "Format ieșire: $OutputFormat" -ForegroundColor $InfoColor
    Write-Host "Optimizare subtitrare: Activată" -ForegroundColor $InfoColor
    Write-Host ""
    
    # Get script directory
    $scriptDir = $PSScriptRoot
    if ([string]::IsNullOrEmpty($scriptDir)) {
        $scriptDir = Get-Location
    }
    $pythonScript = Join-Path $scriptDir "video_to_text.py"
    
    # Check if Python script exists
    if (-not (Test-Path $pythonScript)) {
        Write-Host "✗ Eroare: Scriptul Python nu a fost găsit: $pythonScript" -ForegroundColor $ErrorColor
        Write-Host "Vă rugăm asigurați-vă că video_to_text.py este în același director cu acest script." -ForegroundColor $WarningColor
        return $false
    }
    
    Write-Host "Începe procesarea..." -ForegroundColor $SuccessColor
    Write-Host "Acest proces poate dura câteva minute în funcție de lungimea video-ului." -ForegroundColor $WarningColor
    Write-Host ""
    
    # Run Python script
    try {
        python $pythonScript $VideoPath $Language $OutputFormat
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓ PROCESARE COMPLETĂ CU SUCCES!" -ForegroundColor $SuccessColor
            Write-Host ""
            return $true
        } else {
            Write-Host ""
            Write-Host "✗ Eroare la procesare" -ForegroundColor $ErrorColor
            return $false
        }
    } catch {
        Write-Host ""
        Write-Host "✗ Eroare la executarea scriptului Python: $_" -ForegroundColor $ErrorColor
        return $false
    }
}

# Main program
function Main {
    Show-Banner
    
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Host ""
        Write-Host "Vă rugăm instalați dependențele lipsă și rulați din nou scriptul." -ForegroundColor $WarningColor
        Read-Host "Apăsați Enter pentru a ieși"
        exit 1
    }
    
    do {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
        Write-Host "  CONFIGURARE CONVERSIE" -ForegroundColor $InfoColor
        Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
        Write-Host ""
        
        # Select video file
        $videoPath = Select-VideoFile
        if ([string]::IsNullOrEmpty($videoPath)) {
            Write-Host ""
            $retry = Read-Host "Doriți să încercați din nou? (D/N)"
            if ($retry -notmatch "^[Dd]") {
                break
            }
            continue
        }
        
        # Select language
        $language = Select-Language
        
        # Select output format
        $outputFormat = Select-OutputFormat
        
        # Confirm and process
        Write-Host ""
        Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
        Write-Host "  CONFIRMARE" -ForegroundColor $InfoColor
        Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
        Write-Host ""
        Write-Host "Setări alese:" -ForegroundColor $PromptColor
        Write-Host "  Video: $(Split-Path -Leaf $videoPath)" -ForegroundColor $PromptColor
        Write-Host "  Limbă: $language" -ForegroundColor $PromptColor
        Write-Host "  Format: $outputFormat" -ForegroundColor $PromptColor
        Write-Host ""
        
        $confirm = Read-Host "Continuați cu procesarea? (D/N)"
        if ($confirm -match "^[Dd]") {
            $success = Start-VideoProcessing -VideoPath $videoPath -Language $language -OutputFormat $outputFormat
            
            if ($success) {
                Write-Host ""
                Write-Host "Fișierele de ieșire au fost salvate în același director cu video-ul." -ForegroundColor $SuccessColor
            }
        } else {
            Write-Host "Procesare anulată" -ForegroundColor $WarningColor
        }
        
        Write-Host ""
        $another = Read-Host "Doriți să procesați alt video? (D/N)"
        
    } while ($another -match "^[Dd]")
    
    Write-Host ""
    Write-Host "Mulțumim că ați folosit Video to Text Converter!" -ForegroundColor $SuccessColor
    Write-Host "La revedere!" -ForegroundColor $InfoColor
    Write-Host ""
    Read-Host "Apăsați Enter pentru a ieși"
}

# Run main program
Main
