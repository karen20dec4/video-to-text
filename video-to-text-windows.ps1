# Video to Text Transcription - Windows PowerShell Script
# Whisper AI Integration - Interactive Text Interface
# Version 2.0

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
    Write-Host "║     VIDEO TO TEXT TRANSCRIPTION - WHISPER AI         ║" -ForegroundColor $InfoColor
    Write-Host "║     Transcriere Video/Audio cu AI Local              ║" -ForegroundColor $InfoColor
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor $InfoColor
    Write-Host ""
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Host "Verificare dependențe..." -ForegroundColor $InfoColor
    $allOk = $true
    
    # Check Python
    try {
        $pythonVersion = python --version 2>&1
        Write-Host "✓ Python: $pythonVersion" -ForegroundColor $SuccessColor
    } catch {
        Write-Host "✗ Python nu este instalat sau nu este în PATH" -ForegroundColor $ErrorColor
        Write-Host "Descărcați Python de la: https://www.python.org/downloads/" -ForegroundColor $WarningColor
        $allOk = $false
    }
    
    # Check ffmpeg
    try {
        $ffmpegVersion = ffmpeg -version 2>&1 | Select-Object -First 1
        Write-Host "✓ ffmpeg: Instalat" -ForegroundColor $SuccessColor
    } catch {
        Write-Host "✗ ffmpeg nu este instalat sau nu este în PATH" -ForegroundColor $ErrorColor
        Write-Host "Descărcați ffmpeg de la: https://ffmpeg.org/download.html" -ForegroundColor $WarningColor
        $allOk = $false
    }
    
    # Check Python libraries
    Write-Host "Verificare librării Python..." -ForegroundColor $InfoColor
    
    $libraries = @{
        "whisper" = "openai-whisper"
        "srt" = "srt"
        "pysrt" = "pysrt"
    }
    
    $missingLibs = @()
    
    foreach ($lib in $libraries.Keys) {
        $result = python -c "import $lib" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ $lib: Instalat" -ForegroundColor $SuccessColor
        } else {
            Write-Host "✗ $lib: Lipsește" -ForegroundColor $ErrorColor
            $missingLibs += $libraries[$lib]
        }
    }
    
    if ($missingLibs.Count -gt 0) {
        Write-Host ""
        Write-Host "Librării lipsă detectate!" -ForegroundColor $WarningColor
        Write-Host "Instalare: pip install $($missingLibs -join ' ')" -ForegroundColor $InfoColor
        Write-Host ""
        
        $response = Read-Host "Doriți să instalez automat aceste librării? (D/N)"
        if ($response -match "^[Dd]") {
            Write-Host "Instalare librării..." -ForegroundColor $InfoColor
            
            # Install torch first (CPU version)
            Write-Host "Instalare PyTorch (CPU)..." -ForegroundColor $InfoColor
            pip install torch --index-url https://download.pytorch.org/whl/cpu
            
            # Install other libraries
            foreach ($pkg in $missingLibs) {
                pip install $pkg
            }
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Librării instalate cu succes!" -ForegroundColor $SuccessColor
            } else {
                Write-Host "✗ Eroare la instalarea librăriilor" -ForegroundColor $ErrorColor
                $allOk = $false
            }
        } else {
            Write-Host "Vă rugăm instalați manual librăriile necesare" -ForegroundColor $WarningColor
            $allOk = $false
        }
    }
    
    Write-Host ""
    return $allOk
}

# Function to select video/audio file
function Select-MediaFile {
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host "  SELECTARE FIȘIER VIDEO/AUDIO" -ForegroundColor $InfoColor
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host ""
    
    Write-Host "Opțiuni de selectare:" -ForegroundColor $PromptColor
    Write-Host "  1. Dialog de selectare fișier (Windows GUI)" -ForegroundColor $PromptColor
    Write-Host "  2. Introduceți calea manual" -ForegroundColor $PromptColor
    Write-Host ""
    
    $choice = Read-Host "Alegeți opțiunea (1/2)"
    
    if ($choice -eq "1") {
        # Use Windows Forms file dialog
        Add-Type -AssemblyName System.Windows.Forms
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.Filter = "Fișiere Video|*.mp4;*.mkv;*.avi;*.mov;*.flv;*.wmv;*.webm;*.m4v;*.mpg;*.mpeg|Fișiere Audio|*.mp3;*.wav;*.m4a;*.aac;*.ogg;*.flac|Toate fișierele|*.*"
        $fileDialog.Title = "Selectați fișierul video sau audio"
        
        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $filePath = $fileDialog.FileName
            Write-Host "✓ Fișier selectat: $filePath" -ForegroundColor $SuccessColor
            return $filePath
        } else {
            Write-Host "Selectare anulată" -ForegroundColor $WarningColor
            return $null
        }
    } else {
        # Manual path entry
        Write-Host ""
        Write-Host "Introduceți calea completă către fișier:" -ForegroundColor $PromptColor
        Write-Host "(Exemplu: C:\Videos\film.mp4)" -ForegroundColor $InfoColor
        $filePath = Read-Host "Cale fișier"
        
        if (Test-Path $filePath) {
            Write-Host "✓ Fișier găsit: $filePath" -ForegroundColor $SuccessColor
            return $filePath
        } else {
            Write-Host "✗ Fișierul nu există: $filePath" -ForegroundColor $ErrorColor
            return $null
        }
    }
}

# Function to select Whisper model
function Select-WhisperModel {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host "  SELECTARE MODEL WHISPER AI" -ForegroundColor $InfoColor
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host ""
    
    Write-Host "Modele disponibile (calitate vs. viteză):" -ForegroundColor $PromptColor
    Write-Host "  1. tiny   - Cel mai rapid, calitate mai scăzută (~1GB RAM)" -ForegroundColor $PromptColor
    Write-Host "  2. base   - Rapid, calitate decentă (~1GB RAM)" -ForegroundColor $PromptColor
    Write-Host "  3. small  - Echilibrat, calitate bună (~2GB RAM) [RECOMANDAT]" -ForegroundColor $SuccessColor
    Write-Host "  4. medium - Mai lent, calitate foarte bună (~5GB RAM)" -ForegroundColor $PromptColor
    Write-Host "  5. large-v3 - Cel mai lent, calitate excelentă (~10GB RAM)" -ForegroundColor $PromptColor
    Write-Host "  6. turbo  - Rapid și precis, calitate excelentă (~6GB RAM)" -ForegroundColor $PromptColor
    Write-Host ""
    
    $choice = Read-Host "Alegeți modelul (1-6, default: 3)"
    
    if ([string]::IsNullOrWhiteSpace($choice)) {
        $choice = "3"
    }
    
    switch ($choice) {
        "1" { return "tiny" }
        "2" { return "base" }
        "3" { return "small" }
        "4" { return "medium" }
        "5" { return "large-v3" }
        "6" { return "turbo" }
        default {
            Write-Host "Opțiune invalidă. Se folosește modelul implicit: small" -ForegroundColor $WarningColor
            return "small"
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
    Write-Host "  1. Română (ro)" -ForegroundColor $PromptColor
    Write-Host "  2. Engleză (en)" -ForegroundColor $PromptColor
    Write-Host "  3. Franceză (fr)" -ForegroundColor $PromptColor
    Write-Host "  4. Germană (de)" -ForegroundColor $PromptColor
    Write-Host "  5. Spaniolă (es)" -ForegroundColor $PromptColor
    Write-Host "  6. Italiană (it)" -ForegroundColor $PromptColor
    Write-Host "  7. Portugheză (pt)" -ForegroundColor $PromptColor
    Write-Host "  8. Rusă (ru)" -ForegroundColor $PromptColor
    Write-Host "  9. Altă limbă (cod personalizat)" -ForegroundColor $PromptColor
    Write-Host ""
    
    $choice = Read-Host "Alegeți limba (1-9, default: 1)"
    
    if ([string]::IsNullOrWhiteSpace($choice)) {
        $choice = "1"
    }
    
    switch ($choice) {
        "1" { return "ro" }
        "2" { return "en" }
        "3" { return "fr" }
        "4" { return "de" }
        "5" { return "es" }
        "6" { return "it" }
        "7" { return "pt" }
        "8" { return "ru" }
        "9" {
            $customLang = Read-Host "Introduceți codul limbii (ex: pl, nl, uk)"
            return $customLang
        }
        default {
            Write-Host "Opțiune invalidă. Se folosește limba implicită: ro" -ForegroundColor $WarningColor
            return "ro"
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
    Write-Host "  3. TOATE - Generează ambele formate" -ForegroundColor $PromptColor
    Write-Host ""
    
    $choice = Read-Host "Alegeți formatul (1-3, default: 1)"
    
    if ([string]::IsNullOrWhiteSpace($choice)) {
        $choice = "1"
    }
    
    switch ($choice) {
        "1" { return "srt" }
        "2" { return "txt" }
        "3" { return "all" }
        default {
            Write-Host "Opțiune invalidă. Se folosește formatul implicit: SRT" -ForegroundColor $WarningColor
            return "srt"
        }
    }
}

# Function to process video/audio
function Start-Transcription {
    param(
        [string]$FilePath,
        [string]$Model,
        [string]$Language,
        [string]$OutputFormat
    )
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host "  PROCESARE FIȘIER" -ForegroundColor $InfoColor
    Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
    Write-Host ""
    
    Write-Host "Fișier: $FilePath" -ForegroundColor $InfoColor
    Write-Host "Model Whisper: $Model" -ForegroundColor $InfoColor
    Write-Host "Limbă: $Language" -ForegroundColor $InfoColor
    Write-Host "Format ieșire: $OutputFormat" -ForegroundColor $InfoColor
    Write-Host "Optimizare subtitrare: Activată (80-120 caractere)" -ForegroundColor $InfoColor
    Write-Host ""
    
    # Get script directory
    $scriptDir = $PSScriptRoot
    if ([string]::IsNullOrEmpty($scriptDir)) {
        $scriptDir = Get-Location
    }
    $pythonScript = Join-Path $scriptDir "video-to-text.py"
    
    # Check if Python script exists
    if (-not (Test-Path $pythonScript)) {
        Write-Host "✗ Eroare: Scriptul Python nu a fost găsit: $pythonScript" -ForegroundColor $ErrorColor
        Write-Host "Vă rugăm asigurați-vă că video-to-text.py este în același director." -ForegroundColor $WarningColor
        return $false
    }
    
    Write-Host "Începe transcrierea cu Whisper AI..." -ForegroundColor $SuccessColor
    Write-Host "ATENȚIE: Prima rulare va descărca modelul AI (~1-10GB, în funcție de model)" -ForegroundColor $WarningColor
    Write-Host "Acest proces poate dura 5-30 minute în funcție de:" -ForegroundColor $WarningColor
    Write-Host "  - Lungimea fișierului" -ForegroundColor $InfoColor
    Write-Host "  - Modelul ales" -ForegroundColor $InfoColor
    Write-Host "  - Performanța calculatorului" -ForegroundColor $InfoColor
    Write-Host ""
    
    # Run Python script
    try {
        python $pythonScript $FilePath $Model $Language $OutputFormat
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓ TRANSCRIERE COMPLETĂ CU SUCCES!" -ForegroundColor $SuccessColor
            Write-Host ""
            return $true
        } else {
            Write-Host ""
            Write-Host "✗ Eroare la transcriere" -ForegroundColor $ErrorColor
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
        Write-Host "  CONFIGURARE TRANSCRIERE" -ForegroundColor $InfoColor
        Write-Host "═══════════════════════════════════════════" -ForegroundColor $InfoColor
        Write-Host ""
        
        # Select file
        $filePath = Select-MediaFile
        if ([string]::IsNullOrEmpty($filePath)) {
            Write-Host ""
            $retry = Read-Host "Doriți să încercați din nou? (D/N)"
            if ($retry -notmatch "^[Dd]") {
                break
            }
            continue
        }
        
        # Select model
        $model = Select-WhisperModel
        
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
        Write-Host "  Fișier: $(Split-Path -Leaf $filePath)" -ForegroundColor $PromptColor
        Write-Host "  Model: $model" -ForegroundColor $PromptColor
        Write-Host "  Limbă: $language" -ForegroundColor $PromptColor
        Write-Host "  Format: $outputFormat" -ForegroundColor $PromptColor
        Write-Host ""
        
        $confirm = Read-Host "Continuați cu transcrierea? (D/N)"
        if ($confirm -match "^[Dd]") {
            $success = Start-Transcription -FilePath $filePath -Model $model -Language $language -OutputFormat $outputFormat
            
            if ($success) {
                Write-Host ""
                Write-Host "Fișierele de ieșire au fost salvate în același director cu fișierul sursă." -ForegroundColor $SuccessColor
            }
        } else {
            Write-Host "Transcriere anulată" -ForegroundColor $WarningColor
        }
        
        Write-Host ""
        $another = Read-Host "Doriți să procesați alt fișier? (D/N)"
        
    } while ($another -match "^[Dd]")
    
    Write-Host ""
    Write-Host "Mulțumim că ați folosit Video to Text Transcription!" -ForegroundColor $SuccessColor
    Write-Host "La revedere!" -ForegroundColor $InfoColor
    Write-Host ""
    Read-Host "Apăsați Enter pentru a ieși"
}

# Run main program
Main
