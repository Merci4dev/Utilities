import os
import argparse
from fpdf import FPDF

# Define a custom PDF class inheriting from FPDF to allow customization of PDF generation
class PDF(FPDF):
    def __init__(self, font_dir, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Attempt to load the DejaVuSans font in various styles for PDF text rendering
        try:
            self.add_font('DejaVu', '', os.path.join(font_dir, 'DejaVuSans.ttf'), uni=True)
            self.add_font('DejaVu', 'B', os.path.join(font_dir, 'DejaVuSans-Bold.ttf'), uni=True)
            self.add_font('DejaVu', 'I', os.path.join(font_dir, 'DejaVuSans-Oblique.ttf'), uni=True)
            self.add_font('DejaVu', 'BI', os.path.join(font_dir, 'DejaVuSans-BoldOblique.ttf'), uni=True)
            print("Fonts loaded successfully.")
        except Exception as e:
            print(f"Error loading fonts: {str(e)}")
        
        # Set the default font and enable auto page break
        self.set_font('DejaVu', '', 12)
        self.set_auto_page_break(auto=True, margin=15)

    # Define the header for each page in the PDF
    def header(self):
        self.set_font('DejaVu', 'B', 14)
        self.cell(0, 10, 'Project Documentation', ln=True, align='C')
        self.ln(10)

    # Define the footer for each page in the PDF
    def footer(self):
        self.set_y(-15)
        self.set_font('DejaVu', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', align='C')

# Function to determine the module name based on the file's relative path within the project
def get_module_name(file_path, project_path):
    relative_path = os.path.relpath(file_path, project_path)
    return os.path.dirname(relative_path)

# Function to determine if a path should be excluded based on a list of exclusions
def should_exclude(path, project_path, excludes):
    relative_path = os.path.relpath(path, project_path)
    parts = relative_path.split(os.sep)
    return any(part in excludes for part in parts)

# Function to check if a file is a readable text file
def is_text_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            f.read(1024)
        return True
    except:
        return False

# Function to count lines of code in a given file, excluding comments and blank lines
def count_lines_of_code(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            code_lines = 0
            in_block_comment = False
            for line in lines:
                stripped_line = line.strip()
                if stripped_line.startswith('/*') or stripped_line.startswith('/**'):
                    in_block_comment = True
                if in_block_comment:
                    if '*/' in stripped_line:
                        in_block_comment = False
                    continue
                if stripped_line and not stripped_line.startswith('//'):
                    code_lines += 1
            return code_lines
    except:
        return 0

# Function to sanitize text content, replacing unsupported characters with '?'
def sanitize_content(content):
    return ''.join([c if ord(c) < 65535 else '?' for c in content])

# Main function to generate the PDF with project documentation
def generate_pdf(project_path, excludes, font_dir):
    pdf = PDF(font_dir=font_dir)
    parent_dir_name = os.path.basename(os.path.normpath(project_path))
    pdf_file_name = f"{parent_dir_name}_project.pdf"
    pdf_file_path = os.path.join(project_path, pdf_file_name)

    excludes.append(pdf_file_name)  # Exclude the output PDF from further processing

    total_lines_of_code = 0
    file_count = 0

    # Walk through all files in the project directory
    for root, dirs, files in os.walk(project_path):
        # Filter directories based on the exclusion list
        dirs[:] = [d for d in dirs if not should_exclude(os.path.join(root, d), project_path, excludes)]
        for file in files:
            file_path = os.path.join(root, file)
            if should_exclude(file_path, project_path, excludes):
                continue
            if not is_text_file(file_path):
                continue

            # Process the file and count lines of code
            file_count += 1
            lines_of_code = count_lines_of_code(file_path)
            total_lines_of_code += lines_of_code

            module_name = get_module_name(file_path, project_path)
            pdf.add_page()
            pdf.set_font('DejaVu', 'B', 14)
            pdf.cell(0, 10, f"Module: {module_name}", ln=True)
            pdf.set_font('DejaVu', 'B', 12)
            pdf.cell(0, 10, f"File: {file_path}", ln=True)
            pdf.cell(0, 10, f"Lines of code: {lines_of_code}", ln=True)
            pdf.set_font('DejaVu', '', 10)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    content = sanitize_content(content)
                    pdf.multi_cell(0, 5, content)
            except Exception as e:
                pdf.set_font('DejaVu', 'I', 10)
                pdf.multi_cell(0, 5, f"Error reading file: {str(e)}")

    # Add a summary page at the end of the PDF
    pdf.add_page()
    pdf.set_font('DejaVu', 'B', 16)
    pdf.cell(0, 10, "Project Summary", ln=True)
    pdf.set_font('DejaVu', '', 12)
    pdf.cell(0, 10, f"Total files: {file_count}", ln=True)
    pdf.cell(0, 10, f"Total lines of code: {total_lines_of_code}", ln=True)

    # Output the final PDF file
    try:
        pdf.output(pdf_file_path)
        print(f"PDF generated: {pdf_file_path}")
        print(f"Total files: {file_count}")
        print(f"Total lines of code: {total_lines_of_code}")
    except Exception as e:
        print(f"Error generating PDF: {str(e)}")

# Main function to parse command-line arguments and execute the PDF generation
def main():
    parser = argparse.ArgumentParser(description="Generate a PDF documentation of the project")
    parser.add_argument("project_path", help="Path to the project")
    parser.add_argument("--exclude", nargs='*', default=[], help="Directories or files to exclude (can specify multiple values)")
    args = parser.parse_args()
    excludes = args.exclude

    # Define the font directory path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    font_dir = os.path.join(script_dir, 'fonts')

    # Check if all required font files are present
    required_fonts = [
        'DejaVuSans.ttf',
        'DejaVuSans-Bold.ttf',
        'DejaVuSans-Oblique.ttf',
        'DejaVuSans-BoldOblique.ttf'
    ]
    missing_fonts = [font for font in required_fonts if not os.path.isfile(os.path.join(font_dir, font))]
    if missing_fonts:
        print(f"Error: The following fonts were not found in {font_dir}: {', '.join(missing_fonts)}")
        print("Make sure to download all DejaVuSans font variants and place them in the correct directory.")
        return

    generate_pdf(args.project_path, excludes, font_dir)

# Execute the main function
if __name__ == "__main__":
    main()
