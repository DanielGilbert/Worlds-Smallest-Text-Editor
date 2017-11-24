<img align="right" src="img/screenshot.png" alt="" />

![](https://img.shields.io/github/license/philiparvidsson/Worlds-Smallest-Text-Editor.svg)

# What is this?

This is the world's smallest, fully functional text editor! Written in [x86 assembly language](https://en.wikipedia.org/wiki/X86_assembly_language) and compiled with [flat assembler](https://flatassembler.net/), the executable is only a few kilobytes in size!

The program can load, save and edit textfiles just like [Notepad](https://en.wikipedia.org/wiki/Microsoft_Notepad) on Windows. More features might be added later (e.g. syntax highlighting, program preferences etc.) if it can be done without affecting the size of the executable.

## How small is it?

Using the included make-script (which uses [fasm](https://flatassembler.net/) for assembly and linking), the executable file size is **3072 bytes**.

## Building and running

### Prerequisites
* [Python 3](https://www.python.org/downloads/)

### Instructions
1. Clone this repository: `git clone https://github.com/philiparvidsson/Worlds-Smallest-Text-Editor`
2. Run the make-script: `python make.py`  
   <sup><i><b>&nbsp;&nbsp;&nbsp;&nbsp;NOTE:</b> The make script will automatically download [fasm](https://flatassembler.net/) to the repository directory.</i></sup>
3. Run the executable normally or start it with the make-script: `python make.py run`

To clone, build and run the program, enter the following into your terminal:  
`git clone https://github.com/philiparvidsson/Worlds-Smallest-Text-Editor && cd Worlds-Smallest-Text-Editor && python make.py && python make.py run`
