#!/usr/bin/env python3

"""
auto_convert_mp4_to_mov.py

Description:
    - MODE 1 (default, no arguments):
        Monitors a fixed folder: ~/Desktop/DAVINCI RESOLVE/AutomaticConvertMp4ToMov
        Any .mp4 file found or newly added is converted to .mov with PCM audio.
    - MODE 2 (directory argument):
        Immediately processes all .mp4 files in the given directory (batch),
        outputs to a 'convertedVideos' subfolder, then exits.
    - MODE 3 (--monitor-script-dir):
        Monitors the script's folder for new directories (e.g. "GrobVideos" dropped),
        then converts all .mp4 files inside those directories.

Uses pcm_s16le for DaVinci Resolve compatibility, scaling to half resolution (SCALE_FACTOR=2) by default.
"""

import os
import sys
import time
import subprocess
from pathlib import Path

try:
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler, PatternMatchingEventHandler
except ImportError:
    print("Please install watchdog:\n  pip install watchdog")
    sys.exit(1)

# ---------------- CONFIGURATIONS ----------------
SCALE_FACTOR = 2         # 1 = original, 2 = half resolution
CRF_VALUE = 18           # lower CRF = better quality, bigger file
PRESET = "slow"          # ffmpeg preset: slow, medium, fast...
AUDIO_CODEC = "pcm_s16le"   # uncompressed PCM audio for DaVinci Resolve
AUDIO_SAMPLE_RATE = 48000
AUDIO_CHANNELS = 2
CONVERTED_FOLDER = "convertedVideos"

DEFAULT_MONITOR_DIR = os.path.join(Path.home(), "Desktop", "DAVINCI RESOLVE", "AutomaticConvertMp4ToMov")
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# -------------- HELPER FUNCTIONS ---------------
def convert_file(input_file: Path, output_dir: Path):
    """Convert a single .mp4 file to .mov using ffmpeg with PCM audio."""
    output_dir.mkdir(parents=True, exist_ok=True)
    
    base_name = input_file.stem
    output_file = output_dir / f"{base_name}.mov"
    
    if output_file.is_file():
        print(f"   [Skipping] {output_file} already exists.")
        return
    
    print(f"   Converting: {input_file.name} -> {output_file.name}")
    
    # Build ffmpeg command
    cmd = [
        "ffmpeg", "-y", "-hide_banner", "-loglevel", "warning", "-stats",
        "-i", str(input_file),
        "-vf", f"scale=iw/{SCALE_FACTOR}:ih/{SCALE_FACTOR}",
        "-vcodec", "libx264",
        "-preset", PRESET,
        "-crf", str(CRF_VALUE),
        "-acodec", AUDIO_CODEC,
        "-ar", str(AUDIO_SAMPLE_RATE),
        "-ac", str(AUDIO_CHANNELS),
        "-movflags", "+faststart",
        str(output_file)
    ]
    
    subprocess.run(cmd, check=False)
    if output_file.is_file():
        print(f"   ✅ Conversion complete: {output_file}")
    else:
        print(f"   ❌ Error converting: {input_file.name}")

def convert_all_mp4_in_dir(src_dir: Path):
    """Convert all .mp4 files in src_dir to .mov, placing them in src_dir/convertedVideos."""
    converted_dir = src_dir / CONVERTED_FOLDER
    converted_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"Searching for .mp4 files in: {src_dir}")
    
    for mp4_file in src_dir.glob("*.mp4"):
        convert_file(mp4_file, converted_dir)
    
    print(f"------ Finished batch conversion for: {src_dir} ------")

# ---------------- MODE 1: MONITOR FIXED DIRECTORY ----------------
class MP4EventHandler(PatternMatchingEventHandler):
    """Watches for newly created or closed .mp4 files and converts them."""
    def __init__(self, watch_dir: Path, **kwargs):
        super().__init__(patterns=["*.mp4"], ignore_directories=True, **kwargs)
        self.watch_dir = watch_dir
        self.converted_dir = self.watch_dir / CONVERTED_FOLDER
        
        # Convert existing .mp4 files at startup
        convert_all_mp4_in_dir(self.watch_dir)
        print(f"=== (Mode 1) Monitoring folder: {self.watch_dir} ===")
        
    def on_created(self, event):
        print(f">>> Event detected: {event.src_path}")
        convert_all_mp4_in_dir(self.watch_dir)
    
    def on_modified(self, event):
        # Some systems might trigger on_modified if a file is written in chunks
        print(f">>> Modification detected: {event.src_path}")
        convert_all_mp4_in_dir(self.watch_dir)

def monitor_fixed_directory():
    watch_dir = Path(DEFAULT_MONITOR_DIR)
    watch_dir.mkdir(parents=True, exist_ok=True)
    
    event_handler = MP4EventHandler(watch_dir)
    observer = Observer()
    observer.schedule(event_handler, str(watch_dir), recursive=False)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

# ---------------- MODE 2: BATCH PROCESS A DIRECTORY ----------------
def batch_mode(directory: str):
    src_dir = Path(directory)
    if not src_dir.is_dir():
        print(f"Error: '{directory}' is not a valid directory.")
        sys.exit(1)
    
    convert_all_mp4_in_dir(src_dir)

# ---------------- MODE 3: MONITOR SCRIPT DIR FOR NEW DIRECTORIES ----------------
class NewFolderHandler(FileSystemEventHandler):
    """Detects new directories created or moved into the script directory."""
    def on_created(self, event):
        if event.is_directory:
            new_path = Path(event.src_path)
            print(f">>> New directory detected: {new_path}")
            # Wait a bit to allow files to finish copying
            time.sleep(5)
            batch_mode(str(new_path))

def monitor_script_dir_for_folders():
    print(f"=== (Mode 3) Monitoring the script folder: {SCRIPT_DIR} ===")
    print("    If you paste a folder with .mp4 files here, it will be converted automatically.")
    
    script_path = Path(SCRIPT_DIR)
    observer = Observer()
    observer.schedule(NewFolderHandler(), str(script_path), recursive=False)
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

# ---------------- MAIN LOGIC ----------------
def main():
    args = sys.argv[1:]
    
    if len(args) == 0:
        # MODE 1
        monitor_fixed_directory()
    elif len(args) == 1:
        if args[0] == "--monitor-script-dir":
            # MODE 3
            monitor_script_dir_for_folders()
        else:
            # MODE 2
            batch_mode(args[0])
    else:
        print("Usage:")
        print("  python auto_convert_mp4_to_mov.py           # Mode 1 (monitor default folder)")
        print("  python auto_convert_mp4_to_mov.py <dir>     # Mode 2 (batch convert all .mp4 in <dir>)")
        print("  python auto_convert_mp4_to_mov.py --monitor-script-dir  # Mode 3 (monitor script folder)")
        sys.exit(1)

if __name__ == "__main__":
    main()
