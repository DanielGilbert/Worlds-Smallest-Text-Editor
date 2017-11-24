format PE GUI 4.0
entry WinMain

include "win32w.inc"

;;;-------------------------------------
section ".data" data readable writeable
;;;-------------------------------------

include "ui.data.asm"

;;;-------------------------------------
section ".code" code readable executable
;;;-------------------------------------

include "ui.code.asm"

WinMain:
    call ui_init
    call ui_main

    push 0
    call [ExitProcess]

;;;-------------------------------------
section ".imports" import data readable writeable
;;;-------------------------------------

    library Comdlg32 , "Comdlg32.dll", \
            Gdi32    , "Gdi32.dll"   , \
            Kernel32 , "Kernel32.dll", \
            User32   , "User32.dll"

    import Comdlg32, \
        GetOpenFileName, "GetOpenFileNameA"

    import Gdi32, \
        CreateFont, "CreateFontA"

    import Kernel32,\
        GetModuleHandle , "GetModuleHandleA", \
        ExitProcess     , "ExitProcess"

    import User32,                             \
        CreateWindowEx   , "CreateWindowExA",  \
        DefWindowProc    , "DefWindowProcA",   \
        DispatchMessage  , "DispatchMessageA", \
        GetClientRect    , "GetClientRect",    \
        GetMessage       , "GetMessageA",      \
        MessageBox       , "MessageBoxA",      \
        MoveWindow       , "MoveWindow",       \
        PostQuitMessage  , "PostQuitMessage",  \
        RegisterClassEx  , "RegisterClassExA", \
        SendMessage      , "SendMessageA",     \
        TranslateMessage , "TranslateMessage"
