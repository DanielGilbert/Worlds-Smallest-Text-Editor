<img align="right" src="img/screenshot.png" alt="" />

![](https://img.shields.io/github/license/philiparvidsson/Worlds-Smallest-Text-Editor.svg)

# What is this?

This is the world's smallest, fully functional text editor! Written in [x86 assembly language](https://en.wikipedia.org/wiki/X86_assembly_language) and compiled with [flat assembler](https://flatassembler.net/), the executable is only a few kilobytes in size!

The program can load, save and edit text files just like [Notepad](https://en.wikipedia.org/wiki/Microsoft_Notepad). More features might be added later (e.g. syntax highlighting, program preferences etc.) if it can be done without affecting the size of the executable.

## How small is it?

Using the included make-script (which uses [fasm](https://flatassembler.net/) for assembly and linking), the executable file size is **3072 bytes**.

## User instructions
The editor is intentionally kept very simple, but there are a few keyboard shortcuts that you need to know.

### Keyboard shortcuts
| Key combination  | Command      |
| ---------------- | ------------ |
| Ctrl + L         | Open...      |
| Ctrl + S         | Save         |
| Ctrl + Shift + S | Save as...   |

## Building and running

### Prerequisites
* [flat assembler](https://flatassembler.net/) — *An assembler for x86 processors. It supports Intel-style assembly language on the IA-32 and x86-64 computer architectures.*
* [Python 3](https://www.python.org/downloads/) — *A widely used high-level programming language for general-purpose programming, created by Guido van Rossum and first released in 1991.*
* [Windows 7+](https://www.microsoft.com/en-us/windows/) — *A personal computer operating system developed and released by Microsoft as part of the Windows NT family of operating systems.*

### Instructions
1. Clone this repository: `git clone https://github.com/philiparvidsson/Worlds-Smallest-Text-Editor`
2. Run the make-script: `python make.py`  
   <sup><i><b>&nbsp;&nbsp;&nbsp;&nbsp;NOTE:</b> The make script will automatically download [fasm](https://flatassembler.net/) to the repository directory.</i></sup>
3. Run the executable normally or start it with the make-script: `python make.py run`

To clone, build and run the program, enter the following into your terminal:  
`git clone https://github.com/philiparvidsson/Worlds-Smallest-Text-Editor && cd Worlds-Smallest-Text-Editor && python make.py && python make.py run`
