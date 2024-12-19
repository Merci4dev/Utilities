# Requirements
    Bash (ensure you run the script with bash, not sh).

## Dependencies
    ffmpeg, inotify-tools, and pv installed.
    On Ubuntu/Debian:

        sudo apt update
        sudo apt install ffmpeg inotify-tools pv -y

## Usage
    Give execution permission to executable:
        chmod +x auto_convert_mp4_to_mov.sh

## Usage Mode 
    Mode 1 (Monitor a fixed folder) Monitor the dir where this file is located
        ./auto_convert_mp4_to_mov.sh

    Mode 2 (Batch conversion of a specific folder). Immediately converts all .mp4 in /path/to/your/folder. Outputs the .mov files to /path/to/your/folder/convertedVideos.
        ./auto_convert_mp4_to_mov.sh "/path/to/your/folder"

    Mode 3 (Monitor the script directory for new folders). Watches the script’s directory for new directories being added. If a new folder is pasted, it waits a bit (sleep 5) and then processes .mp4 files inside that folder in batch mode.

        ./auto_convert_mp4_to_mov.sh --monitor-script-dir



