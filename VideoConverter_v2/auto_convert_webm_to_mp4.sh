#!/usr/bin/env bash

# ============================================================
# Script: auto_convert_webm_to_mp4_and_wav.sh
# Description:
#   Monitors a directory for `.webm` files and:
#   1. Converts `.webm` to `.mp4` with proper scaling.
#   2. Extracts audio from the resulting `.mp4` to `.wav`
#      and creates a final `.mp4` with PCM audio.
# ============================================================

if [ -z "$BASH_VERSION" ]; then
  echo "This script requires Bash. Example: bash $0"
  exit 1
fi

# ------------------ CONFIGURATIONS -------------------
DEFAULT_MONITOR_DIR="${HOME}/Desktop/DavinciResolve/AutomaticConvertWebm"
PROCESSED_FOLDER="processedFiles"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------ FUNCTIONS ------------------------

# Step 1: Convert .webm to .mp4 with scaling
# convert_webm_to_mp4() {
#   local input_file="$1"
#   local output_file="$2"

#   echo "   Converting .webm to .mp4: $input_file -> $output_file"

#   ffmpeg -i "$input_file" \
#     -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
#     -c:v libx264 -c:a aac -movflags +faststart \
#     -y -hide_banner -loglevel warning -stats \
#     "$output_file"

#   if [ $? -eq 0 ]; then
#     echo "   ✅ Conversion to MP4 complete: $output_file"
#   else
#     echo "   ❌ Error converting $input_file to MP4"
#     return 1
#   fi
# }

convert_webm_to_mp4() {
  local input_file="$1"
  local output_file="$2"

  # Verifica que el archivo de entrada exista
  if [ ! -f "$input_file" ]; then
    echo "   ❌ Error: Input file does not exist: $input_file"
    return 1
  fi

  echo "   Converting .webm to .mp4: $input_file -> $output_file"

  ffmpeg -i "$input_file" \
    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
    -c:v libx264 -c:a aac -movflags +faststart \
    -y -hide_banner -loglevel warning -stats \
    "$output_file"

  if [ $? -eq 0 ]; then
    echo "   ✅ Conversion to MP4 complete: $output_file"
  else
    echo "   ❌ Error converting $input_file to MP4"
    return 1
  fi
}


# Step 2: Convert .mp4 to final .mp4 with PCM audio
convert_mp4_to_final() {
  local input_file="$1"
  local final_file="$2"

  echo "   Processing audio and finalizing: $input_file -> $final_file"

  local temp_audio="temp_audio.wav"

  # Extract audio, process, and create final file
  ffmpeg -i "$input_file" -q:a 0 -map a "$temp_audio" && \
  ffmpeg -i "$input_file" -i "$temp_audio" \
    -c:v copy -c:a pcm_s16le -map 0:v:0 -map 1:a:0 \
    -y -hide_banner -loglevel warning -stats \
    "$final_file" && rm "$temp_audio"

  if [ $? -eq 0 ]; then
    echo "   ✅ Final MP4 created: $final_file"
  else
    echo "   ❌ Error finalizing $input_file"
    return 1
  fi
}

# Process a single .webm file
# process_webm_file() {
#   local input_file="$1"
#   local output_dir="$2"

#   local base_name="$(basename "${input_file%.*}")"
#   local mp4_file="${output_dir}/${base_name}.mp4"
#   local final_file="${output_dir}/${base_name}_final.mp4"

#   # Step 1: Convert .webm to .mp4
#   convert_webm_to_mp4 "$input_file" "$mp4_file" || return

#   # Step 2: Convert .mp4 to final .mp4 with PCM audio
#   convert_mp4_to_final "$mp4_file" "$final_file" || return

#   echo "------ Finished processing: $input_file ------"
# }

process_webm_file() {
  local input_file="$1"
  local output_dir="$2"

  # Verificar si el archivo de entrada existe
  if [ ! -f "$input_file" ]; then
    echo "   ❌ Error: File not found: $input_file"
    return 1
  fi

  local base_name="$(basename "${input_file%.*}")"
  local mp4_file="${output_dir}/${base_name}.mp4"
  local final_file="${output_dir}/${base_name}_final.mp4"

  # Step 1: Convert .webm to .mp4
  convert_webm_to_mp4 "$input_file" "$mp4_file" || return

  # Step 2: Convert .mp4 to final .mp4 with PCM audio
  convert_mp4_to_final "$mp4_file" "$final_file" || return

  # Step 3: Delete the temporary .mp4 file
  echo "   🔄 Cleaning up: Removing temporary file $mp4_file"
  rm -f "$mp4_file"

  echo "------ Finished processing: $input_file ------"
}



# Process all .webm files in a directory
process_all_webm_in_dir() {
  local dir_source="$1"
  local dir_target="$2"

  mkdir -p "$dir_target"
  echo "Searching for .webm files in: $dir_source"

  for file in "$dir_source"/*.webm; do
    [ -f "$file" ] || continue
    process_webm_file "$file" "$dir_target"
  done

  echo "------ Finished batch processing for: $dir_source ------"
}

# Monitor a directory for new .webm files
# monitor_mode() {
#   local WATCH_DIR="$1"
#   local PROCESSED_DIR="${WATCH_DIR}/${PROCESSED_FOLDER}"

#   mkdir -p "$PROCESSED_DIR"

#   process_all_webm_in_dir "$WATCH_DIR" "$PROCESSED_DIR"
#   echo "=== Monitoring folder for new .webm files: $WATCH_DIR ==="

#   inotifywait -m -e create -e close_write -e moved_to --format "%w%f" "$WATCH_DIR" | while read -r new_file; do
#     if [[ "$new_file" == *.webm ]]; then
#       echo ">>> New .webm file detected: $new_file"
#       process_webm_file "$new_file" "$PROCESSED_DIR"
#     fi
#   done
# }

monitor_mode() {
  local WATCH_DIR="$1"
  local PROCESSED_DIR="${WATCH_DIR}/${PROCESSED_FOLDER}"

  mkdir -p "$PROCESSED_DIR"

  process_all_webm_in_dir "$WATCH_DIR" "$PROCESSED_DIR"
  echo "=== Monitoring folder for new .webm files: $WATCH_DIR ==="

  inotifywait -m -e create -e close_write -e moved_to --format "%w%f" "$WATCH_DIR" | while read -r new_file; do
    if [[ "$new_file" == *.webm ]]; then
      echo ">>> New .webm file detected: $new_file"

      # Verificar que el archivo esté completamente copiado
      while lsof | grep -q "$new_file"; do
        echo ">>> Waiting for file to finish copying: $new_file"
        sleep 1
      done

      # Procesar el archivo
      process_webm_file "$new_file" "$PROCESSED_DIR"
    fi
  done
}



# ------------------- MAIN ---------------------------

main() {
  local mode_dir="$1"

  if [ -n "$mode_dir" ]; then
    if [ "$mode_dir" = "--monitor-script-dir" ]; then
      echo "=== Monitoring script folder for new directories ==="
      monitor_mode "$SCRIPT_DIR"
    else
      if [ ! -d "$mode_dir" ]; then
        echo "Error: '$mode_dir' is not a valid directory."
        exit 1
      fi
      process_all_webm_in_dir "$mode_dir" "${mode_dir}/${PROCESSED_FOLDER}"
    fi
  else
    monitor_mode "$DEFAULT_MONITOR_DIR"
  fi
}

main "$1"
