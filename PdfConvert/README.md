# Project PDF Documentation Generator
  This Python script generates a PDF document with comprehensive information about all text files in a project directory. It's designed to assist with code documentation by including module names, file paths, line counts, and file content.

## Features
  - Counts lines of code for each file (excluding comments and blank lines).
  - Generates a well-structured PDF with headers, footers, and file content.
  - Summarizes the project with total files and lines of code.
  - Dynamically finds and uses DejaVuSans fonts for consistent formatting.
  - Allows exclusion of specified directories or files from processing.

## Requirements
  - Python 3.x

  Dependencies
  - `fpdf2` library (Install via `pip install fpdf2`)
      pip install fpdf2

  - DejaVuSans font files (Place in a `fonts` directory within the script's folder):
    - `DejaVuSans.ttf`
    - `DejaVuSans-Bold.ttf`
    - `DejaVuSans-Oblique.ttf`
    - `DejaVuSans-BoldOblique.ttf`

  Installing DejaVu Fonts
    sudo apt-get install fonts-dejavu-core

  On Windows: Download from DejaVu Fonts and place them in C:\Windows\Fonts.
  On Mac: Download and place them in /Library/Fonts.


## Usage
  1. Clone or download the repository.
  2. Run the script from the command line with the following syntax:

Run the script from the command line:
 bash
  python script_name.py <project_path> --exclude <file_or_dir_to_exclude>

  Example:
    python script_name.py /path/to/project --exclude .git venv


## Output
The script generates a PDF named <project_name>_project.pdf in the root of the specified project directory. This PDF includes:

Module and file names.
File paths and line counts.
Full content of text files.
A project summary with total file and line counts.


## Notes
  The script dynamically detects the environment (Linux, Windows, Mac) and adjusts paths accordingly.
  Ensure the required fonts are installed or placed in an accessible directory.
  For additional customization, edit the script to modify the PDF format or content layout.