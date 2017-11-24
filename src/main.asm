format PE GUI 4.0
entry WinMain

include "win32w.inc"

;;;-------------------------------------
section ".data" data readable writeable
;;;-------------------------------------

io.file_data_ptr dd 0
io.heap_handle   dd 0
ui.edit_class    db "EDIT", 0
ui.wste_class    db "WSTE_Main", 0
ui.textbox_font  db "Consolas", 0
ui.window_title  db "The World's Smallest Text Editor!", 0
ui.file_filters  db "Any file (*.*)", 0, "*.*", 0, 0

ui.wcx:
    .cbSize        dd 48
    .style         dd 0
    .lpfnWndProc   dd ui.window_proc
    .cbClsExtra    dd 0
    .cbWndExtra    dd 0
    .hInstance     dd 0
    .hIcon         dd 0
    .hCursor       dd 0
    .hbrBackground dd COLOR_WINDOW+1
    .lpszMenuName  dd 0
    .lpszClassName dd ui.wste_class
    .hIconSm       dd 0

ui.ofn:
    .lStructSize       dd 88
    .hwndOwner         dd NULL
    .hInstance         dd NULL
    .lpstrFilter       dd ui.file_filters
    .lpstrCustomFilter dd NULL
    .nMaxCustFilter    dd 0
    .nFilterIndex      dd 1
    .lpstrFile         dd ui.filename
    .nMaxFile          dd MAX_PATH
    .lpstrFileTitle    dd NULL
    .nMaxFileTitle     dd 0
    .lpstrInitialDir   dd NULL
    .lpstrTitle        dd NULL
    .Flags             dd OFN_HIDEREADONLY
    .nFileOffset       dw 0
    .nFileExtension    dw 0
    .lpstrDefExt       dd NULL
    .lCustData         dd NULL
    .lpfnHook          dd NULL
    .lpTemplateName    dd NULL
    .lpReserved        dd NULL
    .dwReserved        dd 0
    .FlagsEx           dd 0

ui.msg:
    .hwnd    dd ?
    .message dd ?
    .wParam  dd ?
    .lParam  dd ?
    .time    dd ?
    .pt      dq ?

ui.rect:
    .left   dd ?
    .top    dd ?
    .right  dd ?
    .bottom dd ?

io.file_handle     dd ?
io.file_size       dd ?
io.num_bytes_read  dd ?
ui.hwnd_textbox    dd ?
ui.hwnd_main       dd ?
ui.filename        rb MAX_PATH

;;;-------------------------------------
section ".code" code readable executable
;;;-------------------------------------

io.load_file:
    pop ebp
    pop edx
    push ebp
    push NULL
    push FILE_ATTRIBUTE_NORMAL
    push OPEN_EXISTING
    push NULL
    push FILE_SHARE_READ
    push GENERIC_READ
    push edx
    call [CreateFile]
    cmp eax, INVALID_HANDLE_VALUE
    jne .open_ok
    push .open_fail_msg
    call ui.message_box
    ret
.open_ok:
    mov [io.file_handle], eax
    push NULL
    push [io.file_handle]
    call [GetFileSize]
    inc eax
    mov [io.file_size], eax
    call [GetProcessHeap]
    mov [io.heap_handle], eax
    push [io.file_size]
    push HEAP_ZERO_MEMORY
    push eax
    call [HeapAlloc]
    mov [io.file_data_ptr], eax
    push NULL
    push io.num_bytes_read
    push [io.file_size]
    push [io.file_data_ptr]
    push [io.file_handle]
    call [ReadFile]
    push [io.file_data_ptr]
    push [ui.hwnd_textbox]
    call [SetWindowText]
    push [io.file_handle]
    call [CloseHandle]
    push [io.file_data_ptr]
    push 0
    push [io.heap_handle]
    call [HeapFree]
    ret
.open_fail_msg db "Could not open file.", 0

io.save_file:
    call [GetProcessHeap]
    mov [io.heap_handle], eax
    push [ui.hwnd_textbox]
    call [GetWindowTextLength]
    inc eax                     ; make room for nullchar
    mov [io.file_size], eax
    push [io.file_size]
    push HEAP_ZERO_MEMORY
    push [io.heap_handle]
    call [HeapAlloc]
    mov [io.file_data_ptr], eax
    push [io.file_size]
    push [io.file_data_ptr]
    push [ui.hwnd_textbox]
    call [GetWindowText]
    push NULL
    push FILE_ATTRIBUTE_NORMAL
    push CREATE_ALWAYS
    push NULL
    push 0
    push GENERIC_WRITE
    push ui.filename
    call [CreateFile]
    mov [io.file_handle], eax
    push NULL
    push io.num_bytes_read
    mov eax, [io.file_size]
    dec eax                     ; dont write nullchar
    push eax
    push [io.file_data_ptr]
    push [io.file_handle]
    call [WriteFile]
    push [io.file_handle]
    call [CloseHandle]
    push [io.file_data_ptr]
    push 0
    push [io.heap_handle]
    call [HeapFree]
    ret

ui.open_file:
    mov eax, [ui.hwnd_main]
    mov [ui.ofn.hwndOwner], eax
    push ui.ofn
    call [GetOpenFileName]
    test eax, eax
    jz .user_cancelled
    push ui.filename
    call io.load_file
    push ui.filename
    push [ui.hwnd_main]
    call [SetWindowText]
.user_cancelled:
    ret

ui.save_file:
    mov eax, [ui.hwnd_main]
    mov [ui.ofn.hwndOwner], eax
    push ui.ofn
    call [GetSaveFileName]
    test eax, eax
    jz .user_cancelled
    call io.save_file
    push ui.filename
    push [ui.hwnd_main]
    call [SetWindowText]
.user_cancelled:
    ret

ui.create_textbox:
    push NULL
    push [ui.wcx.hInstance]
    push NULL
    push [ui.hwnd_main]
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push ES_LEFT + ES_MULTILINE + ES_WANTRETURN + WS_VISIBLE + WS_CHILD + WS_HSCROLL + WS_VSCROLL
    push NULL
    push ui.edit_class
    push WS_EX_LEFT
    call [CreateWindowEx]
    mov [ui.hwnd_textbox], eax
    push eax
    call [SetFocus]
    push ui.textbox_font
    push DEFAULT_PITCH
    push PROOF_QUALITY
    push CLIP_DEFAULT_PRECIS
    push OUT_DEFAULT_PRECIS
    push ANSI_CHARSET
    push FALSE
    push FALSE
    push FALSE
    push FW_NORMAL
    push 0
    push 0
    push 0
    push 14
    call [CreateFont]
    push TRUE
    push eax
    push WM_SETFONT
    push [ui.hwnd_textbox]
    call [SendMessage]
    call ui.resize_textbox
    ret

ui.message_box:
    pop ebp
    pop edx
    push ebp
    push MB_OK
    push edx
    push edx
    push HWND_DESKTOP
    call [MessageBox]
    ret

ui.resize_textbox:
    push ui.rect
    push [ui.hwnd_main]
    call [GetClientRect]
    push TRUE
    push [ui.rect.bottom]
    push [ui.rect.right]
    push [ui.rect.top]
    push [ui.rect.left]
    push [ui.hwnd_textbox]
    call [MoveWindow]
    ret

ui.window_proc:
    pop ebp         ; ret addr
    pop eax         ; hWnd_main
    pop ebx         ; uMsg
    pop ecx         ; wParan
    pop edx         ; lParam
    push ebp        ; restore ret addr to not crash on ret
    cmp ebx, WM_DESTROY
    jne .neq_wm_destroy
    push 0
    call [PostQuitMessage]
    jmp .end
.neq_wm_destroy:
    cmp ebx, WM_SIZE
    jne .neq_wm_size
    call ui.resize_textbox
.neq_wm_size:
    push edx
    push ecx
    push ebx
    push eax
    call [DefWindowProc]  ; result in eax so we can just ret here
.end:
    ret

WinMain:
    push NULL
    call [GetModuleHandle]
    mov [ui.wcx.hInstance], eax
    push ui.wcx
    call [RegisterClassEx]
    push NULL
    push [ui.wcx.hInstance]
    push NULL
    push HWND_DESKTOP
    push 480
    push 640
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push WS_OVERLAPPEDWINDOW + WS_VISIBLE
    push ui.window_title
    push ui.wste_class
    push WS_EX_LEFT
    call [CreateWindowEx]
    mov [ui.hwnd_main], eax
    call ui.create_textbox
message_loop:
    push 0
    push 0
    push NULL
    push ui.msg
    call [GetMessage]
    test eax, eax
    jz .end
    cmp [ui.msg.message], WM_KEYDOWN
    jne .neq_wm_keydown
    push VK_CONTROL
    call [GetKeyState]
    and ax, 10000000b
    test ax, ax
    jz .ctrl_not_pressed
    cmp [ui.msg.wParam], 0x4f   ; O
    jne .not_o_key
    call ui.open_file
    jmp message_loop
.not_o_key:
    cmp [ui.msg.wParam], 0x53   ; S
    jne .not_s_key
    push VK_SHIFT
    call [GetKeyState]
    and ax, 10000000b
    test ax, ax
    jnz .shift_pressed
    cmp byte [ui.filename], 0
    jz .must_save_as
    call io.save_file
    jmp message_loop
.must_save_as:
.shift_pressed:
    call ui.save_file
    jmp message_loop
.not_s_key:
.ctrl_not_pressed:
.neq_wm_keydown:
    push ui.msg
    call [TranslateMessage]
    push ui.msg
    call [DispatchMessage]
    jmp message_loop
.end:
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
        ReadFile        , "ReadFile",         \
        WriteFile       , "WriteFile"

    import User32,                                    \
        CreateWindowEx      , "CreateWindowExA",      \
        DefWindowProc       , "DefWindowProcA",       \
        DispatchMessage     , "DispatchMessageA",     \
        GetClientRect       , "GetClientRect",        \
        GetKeyState         , "GetKeyState",          \
        GetMessage          , "GetMessageA",          \
        GetWindowText       , "GetWindowTextA",       \
        GetWindowTextLength , "GetWindowTextLengthA", \
        MessageBox          , "MessageBoxA",          \
        MoveWindow          , "MoveWindow",           \
        PostQuitMessage     , "PostQuitMessage",      \
        RegisterClassEx     , "RegisterClassExA",     \
        SendMessage         , "SendMessageA",         \
        SetFocus            , "SetFocus",             \
        SetWindowText       , "SetWindowTextA",       \
        TranslateMessage    , "TranslateMessage"
