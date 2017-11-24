format PE GUI 4.0
entry WinMain

include "win32w.inc"

;;;-------------------------------------
section ".data" data readable writeable
;;;-------------------------------------

include "io.data.asm"
include "ui.data.asm"

;;;-------------------------------------
section ".code" code readable executable
;;;-------------------------------------

include "io.code.asm"
include "ui.code.asm"

WinMain:
    call ui.init
    call ui.main

    push 0
    call [ExitProcess]

;;;-------------------------------------
section ".imports" import data readable writeable
;;;-------------------------------------

    library Comdlg32 , "Comdlg32.dll", \
            Gdi32    , "Gdi32.dll",    \
            Kernel32 , "Kernel32.dll", \
            User32   , "User32.dll"

    import Comdlg32, \
        GetOpenFileName, "GetOpenFileNameA", \
        GetSaveFileName, "GetSaveFileNameA"

    import Gdi32, \
        CreateFont, "CreateFontA"

    import Kernel32,\
        CloseHandle     , "CloseHandle",      \
        CreateFile      , "CreateFileA",      \
        ExitProcess     , "ExitProcess",      \
        GetFileSize     , "GetFileSize",      \
        GetModuleHandle , "GetModuleHandleA", \
        GetProcessHeap  , "GetProcessHeap",   \
        HeapAlloc       , "HeapAlloc",        \
        HeapFree        , "HeapFree",         \
        ReadFile        , "ReadFile"

    import User32,                             \
        CreateWindowEx   , "CreateWindowExA",  \
        DefWindowProc    , "DefWindowProcA",   \
        DispatchMessage  , "DispatchMessageA", \
        GetClientRect    , "GetClientRect",    \
        GetKeyState      , "GetKeyState",      \
        GetMessage       , "GetMessageA",      \
        MessageBox       , "MessageBoxA",      \
        MoveWindow       , "MoveWindow",       \
        PostQuitMessage  , "PostQuitMessage",  \
        RegisterClassEx  , "RegisterClassExA", \
        SendMessage      , "SendMessageA",     \
        SetWindowText    , "SetWindowTextA",   \
        SetFocus         , "SetFocus",         \
        TranslateMessage , "TranslateMessage"
