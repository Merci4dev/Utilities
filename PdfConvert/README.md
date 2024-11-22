# Project PDF Documentation Generator

This Python script generates a PDF document containing information about all text files in a project directory. The PDF includes the name of each module, file path, line count, and file content, making it a valuable tool for code documentation.

## Features

- Counts lines of code for each file.
- Generates a well-structured PDF with a header, footer, and content from each text file.
- Summarizes the project with total files and lines of code.
- Excludes specified directories and files from processing.
- Customizable fonts for the PDF output.

## Requirements

- Python 3.x
- `fpdf2` library (Install via `pip install fpdf2`)
- DejaVuSans font files (Place in a `fonts` directory within the script's folder):
  - `DejaVuSans.ttf`
  - `DejaVuSans-Bold.ttf`
  - `DejaVuSans-Oblique.ttf`
  - `DejaVuSans-BoldOblique.ttf`

## Usage

Run the script from the command line:

```bash
python script_name.py <project_path> --exclude <file_or_dir_to_exclude>

Example:

python script_name.py /path/to/project --exclude .git venv
