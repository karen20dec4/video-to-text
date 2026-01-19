#!/usr/bin/env python3
"""
Video to Text Converter with Subtitle Optimization
Converts video files to text/subtitles using speech recognition
"""

import os
import sys
import subprocess
from pathlib import Path
import json

try:
    import speech_recognition as sr
except ImportError:
    print("ERROR: speech_recognition library not found.")
    print("Please install it with: pip install SpeechRecognition")
    sys.exit(1)

try:
    from pydub import AudioSegment
    from pydub.silence import split_on_silence
except ImportError:
    print("ERROR: pydub library not found.")
    print("Please install it with: pip install pydub")
    sys.exit(1)


class VideoToText:
    """Main class for video to text conversion"""
    
    def __init__(self, video_path, language="en-US", optimize_subtitles=True):
        self.video_path = Path(video_path)
        self.language = language
        self.optimize_subtitles = optimize_subtitles
        self.audio_path = None
        self.recognizer = sr.Recognizer()
        
        # Subtitle optimization settings (configurable)
        self.max_subtitle_length = 42  # characters per line (standard for readability)
        self.max_subtitle_duration = 7000  # milliseconds (standard subtitle duration)
        self.min_subtitle_duration = 1000  # milliseconds (minimum readable duration)
        
    def extract_audio(self):
        """Extract audio from video file using ffmpeg"""
        if not self.video_path.exists():
            raise FileNotFoundError(f"Video file not found: {self.video_path}")
        
        # Create output path for audio
        audio_filename = self.video_path.stem + "_audio.wav"
        self.audio_path = self.video_path.parent / audio_filename
        
        print(f"Extracting audio from video: {self.video_path.name}")
        
        # Check if ffmpeg is available
        try:
            subprocess.run(["ffmpeg", "-version"], 
                         stdout=subprocess.PIPE, 
                         stderr=subprocess.PIPE,
                         check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            raise RuntimeError("ffmpeg is not installed or not in PATH. Please install ffmpeg.")
        
        # Extract audio using ffmpeg
        cmd = [
            "ffmpeg", "-i", str(self.video_path),
            "-vn",  # No video
            "-acodec", "pcm_s16le",  # PCM audio codec
            "-ar", "16000",  # Sample rate
            "-ac", "1",  # Mono
            "-y",  # Overwrite output file
            str(self.audio_path)
        ]
        
        try:
            subprocess.run(cmd, 
                         stdout=subprocess.PIPE, 
                         stderr=subprocess.PIPE,
                         check=True)
            print(f"Audio extracted successfully: {self.audio_path.name}")
            return True
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to extract audio: {e.stderr.decode()}")
    
    def split_audio_on_silence(self):
        """Split audio into chunks based on silence for better recognition"""
        print("Analyzing audio and splitting on silence...")
        
        # Load audio file
        audio = AudioSegment.from_wav(str(self.audio_path))
        
        # Split audio on silence
        chunks = split_on_silence(
            audio,
            min_silence_len=500,  # Minimum silence length in ms
            silence_thresh=audio.dBFS - 14,  # Silence threshold
            keep_silence=300  # Keep some silence at edges
        )
        
        print(f"Audio split into {len(chunks)} chunks")
        return chunks
    
    def transcribe_audio(self):
        """Transcribe audio to text with timestamps"""
        print(f"Transcribing audio (language: {self.language})...")
        
        # Load audio file
        audio = AudioSegment.from_wav(str(self.audio_path))
        
        # Split into chunks
        chunks = self.split_audio_on_silence()
        
        transcriptions = []
        current_time = 0
        
        for i, chunk in enumerate(chunks):
            # Export chunk to temporary file
            chunk_filename = self.audio_path.parent / f"chunk_{i}.wav"
            chunk.export(str(chunk_filename), format="wav")
            
            try:
                # Recognize chunk
                with sr.AudioFile(str(chunk_filename)) as source:
                    audio_data = self.recognizer.record(source)
                    try:
                        text = self.recognizer.recognize_google(audio_data, language=self.language)
                        
                        # Calculate timestamps
                        chunk_duration = len(chunk)
                        start_time = current_time
                        end_time = current_time + chunk_duration
                        
                        if self.optimize_subtitles:
                            # Optimize subtitle text
                            text = self.optimize_subtitle_text(text)
                        
                        transcriptions.append({
                            'index': i + 1,
                            'start': start_time,
                            'end': end_time,
                            'text': text
                        })
                        
                        print(f"Chunk {i+1}/{len(chunks)}: {text[:50]}...")
                        
                    except sr.UnknownValueError:
                        print(f"Chunk {i+1}/{len(chunks)}: [Inaudible]")
                    except sr.RequestError as e:
                        print(f"Error: Could not request results; {e}")
                
                current_time += len(chunk)
                
            finally:
                # Clean up chunk file
                if chunk_filename.exists():
                    chunk_filename.unlink()
        
        return transcriptions
    
    def optimize_subtitle_text(self, text):
        """Optimize subtitle text by splitting long lines"""
        if len(text) <= self.max_subtitle_length:
            return text
        
        # Split text into words
        words = text.split()
        lines = []
        current_line = []
        current_length = 0
        
        for word in words:
            word_length = len(word) + 1  # +1 for space
            if current_length + word_length > self.max_subtitle_length:
                if current_line:
                    lines.append(' '.join(current_line))
                    current_line = [word]
                    current_length = word_length
                else:
                    # Single word is too long, add it anyway
                    lines.append(word)
                    current_length = 0
            else:
                current_line.append(word)
                current_length += word_length
        
        if current_line:
            lines.append(' '.join(current_line))
        
        return '\n'.join(lines)
    
    def format_timestamp(self, milliseconds):
        """Format timestamp in SRT format (HH:MM:SS,mmm)"""
        seconds, ms = divmod(milliseconds, 1000)
        minutes, seconds = divmod(seconds, 60)
        hours, minutes = divmod(minutes, 60)
        return f"{int(hours):02d}:{int(minutes):02d}:{int(seconds):02d},{int(ms):03d}"
    
    def save_as_srt(self, transcriptions, output_path=None):
        """Save transcriptions as SRT subtitle file"""
        if output_path is None:
            output_path = self.video_path.parent / (self.video_path.stem + ".srt")
        
        with open(output_path, 'w', encoding='utf-8') as f:
            for item in transcriptions:
                f.write(f"{item['index']}\n")
                f.write(f"{self.format_timestamp(item['start'])} --> {self.format_timestamp(item['end'])}\n")
                f.write(f"{item['text']}\n\n")
        
        print(f"Subtitles saved to: {output_path}")
        return output_path
    
    def save_as_txt(self, transcriptions, output_path=None):
        """Save transcriptions as plain text file"""
        if output_path is None:
            output_path = self.video_path.parent / (self.video_path.stem + ".txt")
        
        with open(output_path, 'w', encoding='utf-8') as f:
            for item in transcriptions:
                f.write(f"{item['text']}\n")
        
        print(f"Text saved to: {output_path}")
        return output_path
    
    def save_as_json(self, transcriptions, output_path=None):
        """Save transcriptions as JSON file"""
        if output_path is None:
            output_path = self.video_path.parent / (self.video_path.stem + ".json")
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(transcriptions, f, indent=2, ensure_ascii=False)
        
        print(f"JSON saved to: {output_path}")
        return output_path
    
    def process(self, output_format='srt'):
        """Main processing method"""
        try:
            # Extract audio from video
            self.extract_audio()
            
            # Transcribe audio
            transcriptions = self.transcribe_audio()
            
            # Save in requested format
            if output_format == 'srt':
                output_path = self.save_as_srt(transcriptions)
            elif output_format == 'txt':
                output_path = self.save_as_txt(transcriptions)
            elif output_format == 'json':
                output_path = self.save_as_json(transcriptions)
            elif output_format == 'all':
                self.save_as_srt(transcriptions)
                self.save_as_txt(transcriptions)
                output_path = self.save_as_json(transcriptions)
            else:
                raise ValueError(f"Unknown output format: {output_format}")
            
            print("\nProcessing complete!")
            return output_path
            
        finally:
            # Clean up temporary audio file
            if self.audio_path and self.audio_path.exists():
                self.audio_path.unlink()
                print(f"Temporary audio file removed: {self.audio_path.name}")


def main():
    """Command line interface"""
    if len(sys.argv) < 2:
        print("Usage: python video_to_text.py <video_file> [language] [output_format]")
        print("  video_file: Path to video file")
        print("  language: Language code (default: en-US)")
        print("            Examples: en-US, ro-RO, fr-FR, de-DE, es-ES")
        print("  output_format: srt, txt, json, or all (default: srt)")
        sys.exit(1)
    
    video_file = sys.argv[1]
    language = sys.argv[2] if len(sys.argv) > 2 else "en-US"
    output_format = sys.argv[3] if len(sys.argv) > 3 else "srt"
    
    converter = VideoToText(video_file, language=language, optimize_subtitles=True)
    converter.process(output_format=output_format)


if __name__ == "__main__":
    main()
