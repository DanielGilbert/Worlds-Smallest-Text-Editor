#---------------------------------------
# IMPORTS
#---------------------------------------

import ctypes
import ntpath
import os
import shutil
import subprocess
import sys
import urllib.request
import zipfile

#---------------------------------------
# CONSTANTS
#---------------------------------------

DL_PATH  = ".fasm"
FASM_URL = "https://flatassembler.net/fasmw172.zip"

#---------------------------------------
# FUNCTIONS
#---------------------------------------

def download_fasm():
    """Downloads fasm if isn't downloaded already."""
    if os.path.isdir(DL_PATH):
        # Already downloaded (probably).
        return

    os.mkdir(DL_PATH)

    # https://msdn.microsoft.com/en-us/library/windows/desktop/aa365535
    FILE_ATTRIBUTE_HIDDEN = 2
    ctypes.windll.kernel32.SetFileAttributesW(DL_PATH, FILE_ATTRIBUTE_HIDDEN)

    fasm_zip_path = os.path.join(DL_PATH, "fasm.zip")
    urllib.request.urlretrieve(FASM_URL, fasm_zip_path)

    with zipfile.ZipFile(fasm_zip_path) as fasm_zip:
        fasm_zip.extractall(DL_PATH)

    os.remove(fasm_zip_path)

def fasm_assemble(filename):
    """Assembles the specified file using fasm."""
    cwd = os.getcwd()
    filename = os.path.join(cwd, filename)
    os.chdir(DL_PATH)
    fasm_exe = os.path.join(os.getcwd(), "fasm.exe")
    os.chdir("INCLUDE")
    subprocess.call([fasm_exe, filename])
    os.chdir(cwd)

def main():
    script_dir, _ = ntpath.split(sys.argv[0])

    if script_dir:
        os.chdir(script_dir)

    if len(sys.argv) == 2:
        if sys.argv[1] == "clean":
            if os.path.isdir(".fasm") : shutil.rmtree(".fasm")
            if os.path.isdir("bin")   : shutil.rmtree("bin")
        elif sys.argv[1] == "run":
            subprocess.call([r"bin\wste.exe"])
        return

    if os.path.isfile(r"bin\wste.exe"):
        os.remove(r"bin\wste.exe")

    download_fasm()
    fasm_assemble(r"src\main.asm")

    if os.path.isfile(r"src\main.exe"):
        if not os.path.isdir("bin"):
            os.mkdir("bin")

        shutil.move(r"src\main.exe", r"bin\wste.exe")

#---------------------------------------
# ENTRY POINT
#---------------------------------------

if __name__ == "__main__":
    main()
