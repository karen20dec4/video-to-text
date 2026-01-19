#!/usr/bin/env python3
"""
Video/Audio to Text Transcription with Whisper AI
Enhanced version with video support - based on mp3-to-text-v57.py
Supports MP4, MKV, AVI, MOV, FLV, WMV, WebM and audio formats
"""

import os
import sys
import subprocess
import warnings
import logging
from pathlib import Path
from typing import Optional, Dict, Any

# Suppress whisper warnings
warnings.filterwarnings(
    "ignore",
    message="FP16 is not supported on CPU",
    category=UserWarning,
    module="whisper.transcribe"
)

# Core dependencies
try:
    import whisper
    import srt
    from datetime import timedelta
except ImportError as e:
    print(f"ERROR: Missing essential library: {e}")
    print("Install with: pip install openai-whisper srt")
    sys.exit(1)

VERSION = "2.0-video"

# Supported video and audio formats
VIDEO_EXTENSIONS = [".mp4", ".mkv", ".avi", ".mov", ".flv", ".wmv", ".webm", ".m4v", ".mpg", ".mpeg"]
AUDIO_EXTENSIONS = [".mp3", ".wav", ".m4a", ".aac", ".ogg", ".flac"]

# Valid Whisper languages
VALID_LANGUAGES = ["ro", "en", "fr", "de", "ru", "es", "it", "pt", "pl", "nl", "uk", "tr", "ja", "zh", "ko"]

# Model mapping
MODEL_MAPPING = {
    "tiny": "tiny",
    "base": "base",
    "small": "small",
    "medium": "medium",
    "large-v1": "large-v1",
    "large-v2": "large-v2",
    "large-v3": "large-v3",
    "turbo": "turbo"
}

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)


def check_ffmpeg() -> bool:
    """Check if ffmpeg is available"""
    try:
        subprocess.run(["ffmpeg", "-version"], 
                      stdout=subprocess.PIPE, 
                      stderr=subprocess.PIPE,
                      check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def extract_audio_from_video(video_path: Path, output_audio: Path) -> bool:
    """Extract audio from video file using ffmpeg"""
    logger.info(f"Extracting audio from video: {video_path.name}")
    
    try:
        cmd = [
            "ffmpeg", "-i", str(video_path),
            "-vn",  # No video
            "-acodec", "pcm_s16le",  # PCM audio codec
            "-ar", "16000",  # Sample rate for Whisper
            "-ac", "1",  # Mono
            "-y",  # Overwrite output
            str(output_audio)
        ]
        
        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True
        )
        
        logger.info(f"Audio extracted successfully: {output_audio.name}")
        return True
        
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to extract audio: {e.stderr.decode()}")
        return False


def transcribe_with_whisper(
    audio_path: Path,
    model_type: str = "small",
    language: str = "ro"
) -> Optional[Dict]:
    """Transcribe audio using Whisper AI"""
    
    logger.info(f"Loading Whisper model: {model_type}")
    logger.info(f"Language: {language}")
    
    try:
        # Load Whisper model
        model = whisper.load_model(model_type)
        
        logger.info(f"Transcribing: {audio_path.name}")
        logger.info("This may take a few minutes depending on file length and model size...")
        
        # Transcribe
        result = model.transcribe(
            str(audio_path),
            language=language,
            task="transcribe",
            verbose=False
        )
        
        logger.info("Transcription completed successfully")
        return result
        
    except Exception as e:
        logger.error(f"Transcription error: {e}")
        return None


def save_as_srt(segments: list, output_path: Path) -> bool:
    """Save transcription segments as SRT file"""
    try:
        srt_entries = []
        
        for i, segment in enumerate(segments, start=1):
            start_time = timedelta(seconds=segment['start'])
            end_time = timedelta(seconds=segment['end'])
            text = segment['text'].strip()
            
            srt_entry = srt.Subtitle(
                index=i,
                start=start_time,
                end=end_time,
                content=text
            )
            srt_entries.append(srt_entry)
        
        # Write SRT file
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(srt.compose(srt_entries))
        
        logger.info(f"SRT file saved: {output_path}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to save SRT: {e}")
        return False


def save_as_txt(segments: list, output_path: Path) -> bool:
    """Save transcription as plain text"""
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            for segment in segments:
                f.write(segment['text'].strip() + "\n")
        
        logger.info(f"TXT file saved: {output_path}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to save TXT: {e}")
        return False


def optimize_subtitles(input_srt: Path, output_srt: Path, min_chars: int = 80, max_chars: int = 120) -> bool:
    """Optimize subtitles by merging short ones and splitting long ones"""
    logger.info("Optimizing subtitles...")
    
    try:
        # Try to use the existing merge_short_subs.py if available
        merge_script = Path(__file__).parent / "merge_short_subs.py"
        
        if merge_script.exists():
            logger.info("Using advanced subtitle optimizer (merge_short_subs.py)")
            result = subprocess.run(
                [sys.executable, str(merge_script), str(input_srt), str(output_srt)],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            if result.returncode == 0:
                logger.info("Subtitles optimized successfully")
                return True
            else:
                logger.warning("Advanced optimizer failed, using basic optimization")
        
        # Basic optimization fallback
        import pysrt
        subs = pysrt.open(str(input_srt), encoding='utf-8')
        
        optimized = []
        temp_text = ""
        start_time = None
        
        for sub in subs:
            if not temp_text:
                start_time = sub.start
            
            temp_text += " " + sub.text.strip() if temp_text else sub.text.strip()
            
            if len(temp_text) >= min_chars or sub == subs[-1]:
                # Save this subtitle
                optimized.append(pysrt.SubRipItem(
                    index=len(optimized) + 1,
                    start=start_time,
                    end=sub.end,
                    text=temp_text[:max_chars] if len(temp_text) > max_chars else temp_text
                ))
                temp_text = ""
                start_time = None
        
        result_file = pysrt.SubRipFile(optimized)
        result_file.save(str(output_srt), encoding='utf-8')
        
        logger.info(f"Basic optimization complete: {len(subs)} -> {len(optimized)} subtitles")
        return True
        
    except Exception as e:
        logger.error(f"Subtitle optimization failed: {e}")
        # If optimization fails, just copy the original
        import shutil
        shutil.copy(input_srt, output_srt)
        return False


def process_file(
    input_file: Path,
    model_type: str = "small",
    language: str = "ro",
    output_format: str = "srt",
    optimize: bool = True
) -> bool:
    """Main processing function for video or audio file"""
    
    if not input_file.exists():
        logger.error(f"Input file not found: {input_file}")
        return False
    
    # Check file extension
    file_ext = input_file.suffix.lower()
    is_video = file_ext in VIDEO_EXTENSIONS
    is_audio = file_ext in AUDIO_EXTENSIONS
    
    if not (is_video or is_audio):
        logger.error(f"Unsupported file format: {file_ext}")
        logger.error(f"Supported video: {', '.join(VIDEO_EXTENSIONS)}")
        logger.error(f"Supported audio: {', '.join(AUDIO_EXTENSIONS)}")
        return False
    
    # Prepare output paths
    output_dir = input_file.parent
    base_name = input_file.stem
    
    # Extract audio if video file
    if is_video:
        if not check_ffmpeg():
            logger.error("ffmpeg not found. Please install ffmpeg to process video files.")
            return False
        
        audio_file = output_dir / f"{base_name}_audio.wav"
        if not extract_audio_from_video(input_file, audio_file):
            return False
    else:
        audio_file = input_file
    
    # Transcribe with Whisper
    result = transcribe_with_whisper(audio_file, model_type, language)
    
    if not result:
        # Clean up temporary audio
        if is_video and audio_file.exists():
            audio_file.unlink()
        return False
    
    # Save output
    success = False
    
    if output_format == "srt" or output_format == "all":
        raw_srt = output_dir / f"{base_name}_raw.srt"
        if save_as_srt(result['segments'], raw_srt):
            if optimize:
                final_srt = output_dir / f"{base_name}.srt"
                optimize_subtitles(raw_srt, final_srt)
                # Remove raw file if optimization succeeded
                if final_srt.exists():
                    raw_srt.unlink()
            success = True
    
    if output_format == "txt" or output_format == "all":
        txt_file = output_dir / f"{base_name}.txt"
        if save_as_txt(result['segments'], txt_file):
            success = True
    
    # Clean up temporary audio file
    if is_video and audio_file.exists():
        audio_file.unlink()
        logger.info("Temporary audio file removed")
    
    return success


def main():
    """Command line interface"""
    if len(sys.argv) < 2:
        print(f"Video/Audio to Text Transcription {VERSION}")
        print("Powered by Whisper AI")
        print()
        print("Usage: python video-to-text.py <input_file> [model] [language] [format]")
        print()
        print("Arguments:")
        print("  input_file : Video or audio file path")
        print("  model      : tiny, base, small, medium, large-v3, turbo (default: small)")
        print("  language   : ro, en, fr, de, es, it, pt, etc. (default: ro)")
        print("  format     : srt, txt, all (default: srt)")
        print()
        print("Examples:")
        print("  python video-to-text.py video.mp4")
        print("  python video-to-text.py video.mp4 small ro srt")
        print("  python video-to-text.py audio.mp3 base en txt")
        print()
        print("Supported video formats:")
        print(" ", ", ".join(VIDEO_EXTENSIONS))
        print()
        print("Supported audio formats:")
        print(" ", ", ".join(AUDIO_EXTENSIONS))
        sys.exit(1)
    
    input_file = Path(sys.argv[1])
    model_type = sys.argv[2] if len(sys.argv) > 2 else "small"
    language = sys.argv[3] if len(sys.argv) > 3 else "ro"
    output_format = sys.argv[4] if len(sys.argv) > 4 else "srt"
    
    # Validate inputs
    if model_type not in MODEL_MAPPING:
        logger.error(f"Invalid model: {model_type}")
        logger.error(f"Valid models: {', '.join(MODEL_MAPPING.keys())}")
        sys.exit(1)
    
    if language not in VALID_LANGUAGES:
        logger.warning(f"Language '{language}' not in validated list, but will try anyway")
    
    logger.info("=" * 60)
    logger.info(f"Video/Audio to Text Transcription {VERSION}")
    logger.info("=" * 60)
    logger.info(f"Input file: {input_file}")
    logger.info(f"Model: {model_type}")
    logger.info(f"Language: {language}")
    logger.info(f"Output format: {output_format}")
    logger.info("=" * 60)
    
    success = process_file(input_file, model_type, language, output_format, optimize=True)
    
    if success:
        logger.info("=" * 60)
        logger.info("✓ PROCESSING COMPLETE!")
        logger.info("=" * 60)
        sys.exit(0)
    else:
        logger.error("=" * 60)
        logger.error("✗ PROCESSING FAILED")
        logger.error("=" * 60)
        sys.exit(1)


if __name__ == "__main__":
    main()
