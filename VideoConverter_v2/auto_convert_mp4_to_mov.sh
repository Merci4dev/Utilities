#!/usr/bin/env bash

# ============================================================
# Script: auto_convert_mp4_to_mov.sh
# Description:
#   - MODE 1 (default, no arguments):
#       Monitors a fixed folder: ~/Desktop/DAVINCI RESOLVE/AutomaticConvertMp4ToMov
#   - MODE 2 (a directory as an argument):
#       Immediately processes all .mp4 files in that directory and then exits (batch).
#   - MODE 3 (--monitor-script-dir):
#       Monitors the script's folder for new directories
#       (e.g. "GrobVideos" pasted), and converts all .mp4 files inside.
#
#   Uses pcm_s16le for DaVinci Resolve compatibility,
#   and scales to half resolution by default (SCALE_FACTOR=2).
# ============================================================

if [ -z "$BASH_VERSION" ]; then
  echo "This script requires Bash. Example: bash $0"
  exit 1
fi

# -------------- CONFIGURATIONS -----------------
SCALE_FACTOR="2"         # 1 = original, 2 = half resolution
CRF_VALUE="18"
PRESET="slow"
AUDIO_CODEC="pcm_s16le"  # uncompressed audio, DaVinci-friendly
AUDIO_SAMPLE_RATE="48000"
AUDIO_CHANNELS="2"
CONVERTED_FOLDER="convertedVideos"

DEFAULT_MONITOR_DIR="${HOME}/Desktop/DAVINCI RESOLVE/AutomaticConvertMp4ToMov"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# ------------------ FUNCTIONS -------------------

convert_file() {
  local input_file="$1"
  local dir_target="$2"

  local filename="$(basename "$input_file")"
  local base_name="${filename%.*}"
  local output_file="${dir_target}/${base_name}.mov"

  if [ -f "$output_file" ]; then
    echo "   [Skipping] File already exists: $output_file"
    return
  fi

  echo "   Converting: $filename -> ${base_name}.mov"

  local input_size
  input_size=$(du -b "$input_file" 2>/dev/null | cut -f1)
  [ -z "$input_size" ] && input_size=100000

  ffmpeg -i "$input_file" \
    -vf "scale=iw/${SCALE_FACTOR}:ih/${SCALE_FACTOR}" \
    -vcodec libx264 -preset "$PRESET" -crf "$CRF_VALUE" \
    -acodec "$AUDIO_CODEC" -ar "$AUDIO_SAMPLE_RATE" -ac "$AUDIO_CHANNELS" \
    -movflags +faststart \
    -y -hide_banner -loglevel warning -stats 2>&1 "$output_file" \
  | pv -s "$input_size" > /dev/null

  if [ $? -eq 0 ]; then
    echo "   ✅ Conversion complete: $output_file"
  else
    echo "   ❌ Error converting: $filename"
  fi
}

convert_all_mp4_in_dir() {
  local dir_source="$1"
  local dir_target="$2"
  mkdir -p "$dir_target"

  echo "Searching for .mp4 files in: $dir_source"

  for file in "$dir_source"/*.mp4; do
    [ -f "$file" ] || continue
    convert_file "$file" "$dir_target"
  done

  echo "------ Finished batch conversion for: $dir_source ------"
}


# ------ MODE 1: Monitor a fixed folder ------
monitor_mode() {
  local WATCH_DIR="$1"
  local CONVERTED_DIR="${WATCH_DIR}/${CONVERTED_FOLDER}"

  mkdir -p "$CONVERTED_DIR"

  convert_all_mp4_in_dir "$WATCH_DIR" "$CONVERTED_DIR"
  echo "=== (Mode 1) Monitoring folder: $WATCH_DIR ==="

  inotifywait -m -e create -e close_write -e moved_to --format "%w%f" "$WATCH_DIR" | while read -r new_file; do
    echo ">>> Event detected: $new_file"
    convert_all_mp4_in_dir "$WATCH_DIR" "$CONVERTED_DIR"
  done
}


# ------ MODE 2: Process a directory in batch ------
batch_mode() {
  local SRC_DIR="$1"
  if [ ! -d "$SRC_DIR" ]; then
    echo "Error: '$SRC_DIR' is not a valid directory."
    exit 1
  fi

  local CONVERTED_DIR="${SRC_DIR}/${CONVERTED_FOLDER}"
  convert_all_mp4_in_dir "$SRC_DIR" "$CONVERTED_DIR"
}


# ------ MODE 3: Monitor the script folder for NEW DIRECTORIES ------
monitor_script_dir_for_folders() {
  echo "=== (Mode 3) Monitoring the script folder: $SCRIPT_DIR ==="
  echo "    If you paste a folder with .mp4 files here, they will be converted automatically."

  inotifywait -m -e create -e moved_to --format "%w%f" "$SCRIPT_DIR" | while read -r new_path; do
    # Check if the detected item is a directory
    if [ -d "$new_path" ]; then
      echo ">>> New directory detected: $new_path"
      # Wait for the copy to finish. Adjust sleep based on folder size
      sleep 5
      batch_mode "$new_path"
    fi
  done
}


# ------ MAIN ------
main() {
  if [ -n "$1" ]; then
    if [ "$1" = "--monitor-script-dir" ]; then
      # MODE 3
      monitor_script_dir_for_folders
    else
      # MODE 2
      batch_mode "$1"
    fi
  else
    # MODE 1
    monitor_mode "$DEFAULT_MONITOR_DIR"
  fi
}

main "$1"
