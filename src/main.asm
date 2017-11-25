format PE GUI 4.0
entry main

include 'win32w.inc'

macro print description,number
{
   display description
   value=number
   pos=1000
   repeat 4
      digit=value/pos
      value=value-(digit*pos)
      pos=pos/10
      display ('0'+digit)
   end repeat
   display $d,$a
}

section '.text' code readable writeable executable

main:
    push NULL
    call [GetModuleHandle]
    mov [wcx.hInstance], eax
    push wcx
    call [RegisterClassEx]
    xor edx, edx
    ;push NULL
    push edx
    push [wcx.hInstance]
    ;push NULL
    push edx
    ;push HWND_DESKTOP
    push edx
    push 480
    push 640
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push WS_OVERLAPPEDWINDOW + WS_VISIBLE
    push window_title
    push wste_class
    ;push WS_EX_LEFT
    push edx
    call [CreateWindowEx]
    mov [hwnd_main], eax
    call create_textbox
message_loop:
    push 0
    push 0
    push NULL
    push msg
    call [GetMessage]
    test eax, eax
    jz .end
    cmp [msg.message], WM_KEYDOWN
    jne .neq_wm_keydown
    push VK_CONTROL
    call [GetKeyState]
    and ah, 1000b
    test ah, ah
    jz .ctrl_not_pressed
    mov edx, msg.wParam
    cmp byte [edx], 0x4f   ; O
    jne .not_o_key
    call open_file
    jmp message_loop
.not_o_key:
    cmp byte [edx], 0x53   ; S
    jne .not_s_key
    push VK_SHIFT
    call [GetKeyState]
    and ah, 1000b
    test ah, ah
    jnz .shift_pressed
    cmp byte [filename], 0
    jz .must_save_as
    call write_file
    jmp message_loop
.must_save_as:
.shift_pressed:
    call save_file
    jmp message_loop
.not_s_key:
.ctrl_not_pressed:
.neq_wm_keydown:
    push msg
    call [TranslateMessage]
    push msg
    call [DispatchMessage]
    jmp message_loop
.end:
    push 0
    call [ExitProcess]

read_file:
    push NULL
    push FILE_ATTRIBUTE_NORMAL
    push OPEN_EXISTING
    push NULL
    push FILE_SHARE_READ
    push GENERIC_READ
    push filename
    call [CreateFile]
    cmp eax, INVALID_HANDLE_VALUE
    jne .open_ok
    call error_msgbox
    ret
.open_ok:
    mov [file_handle], eax
    push NULL
    push eax
    call [GetFileSize]
    inc eax
    mov [file_size], eax
    call [GetProcessHeap]
    mov [heap_handle], eax
    push [file_size]
    push HEAP_ZERO_MEMORY
    push eax
    call [HeapAlloc]
    mov [file_data_ptr], eax
    push NULL
    push num_bytes_read
    push [file_size]
    push [file_data_ptr]
    push [file_handle]
    call [ReadFile]
    push [file_data_ptr]
    push [hwnd_textbox]
    call [SetWindowText]
    push [file_handle]
    call [CloseHandle]
    push [file_data_ptr]
    push 0
    push [heap_handle]
    call [HeapFree]
    ret

write_file:
    call [GetProcessHeap]
    mov [heap_handle], eax
    push [hwnd_textbox]
    call [GetWindowTextLength]
    inc eax                     ; make room for nullchar
    mov [file_size], eax
    push [file_size]
    push HEAP_ZERO_MEMORY
    push [heap_handle]
    call [HeapAlloc]
    mov [file_data_ptr], eax
    push [file_size]
    push [file_data_ptr]
    push [hwnd_textbox]
    call [GetWindowText]
    push NULL
    push FILE_ATTRIBUTE_NORMAL
    push CREATE_ALWAYS
    push NULL
    push 0
    push GENERIC_WRITE
    push filename
    call [CreateFile]
    cmp eax, INVALID_HANDLE_VALUE
    jne .open_ok
    call error_msgbox
    ret
.open_ok:
    mov [file_handle], eax
    push NULL
    push num_bytes_read
    mov eax, [file_size]
    dec eax                     ; dont write nullchar
    push eax
    push [file_data_ptr]
    push [file_handle]
    call [WriteFile]
    push [file_handle]
    call [CloseHandle]
    push [file_data_ptr]
    push 0
    push [heap_handle]
    call [HeapFree]
    ret

open_file:
    mov eax, [hwnd_main]
    mov [ofn.hwndOwner], eax
    push ofn
    call [GetOpenFileName]
    test eax, eax
    jz .user_cancelled
    call read_file
    push filename
    push [hwnd_main]
    call [SetWindowText]
.user_cancelled:
    ret

save_file:
    mov eax, [hwnd_main]
    mov [ofn.hwndOwner], eax
    push ofn
    call [GetSaveFileName]
    test eax, eax
    jz .user_cancelled
    call write_file
    push filename
    push [hwnd_main]
    call [SetWindowText]
.user_cancelled:
    ret

create_textbox:
    push NULL
    push [wcx.hInstance]
    push NULL
    push [hwnd_main]
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push ES_LEFT + ES_MULTILINE + ES_WANTRETURN + WS_VISIBLE + WS_CHILD + WS_HSCROLL + WS_VSCROLL
    push NULL
    push edit_class
    push WS_EX_LEFT
    call [CreateWindowEx]
    mov [hwnd_textbox], eax
    push eax
    call [SetFocus]
    push textbox_font
    push DEFAULT_PITCH
    push PROOF_QUALITY
    push CLIP_DEFAULT_PRECIS
    push OUT_DEFAULT_PRECIS
    push ANSI_CHARSET

    xor ecx, ecx
    mov cl, 7
@@:
    push 0
    loop @r

    ;push FALSE
    ;push FALSE
    ;push FALSE
    ;push FW_DONTCARE
    ;push 0
    ;push 0
    ;push 0

    push 14
    call [CreateFont]
    push TRUE
    push eax
    push WM_SETFONT
    push [hwnd_textbox]
    call [SendMessage]
    call resize_textbox
    ret

error_msgbox:
    push MB_OK
    push error_msg
    push error_msg
    push HWND_DESKTOP
    call [MessageBox]
    ret

resize_textbox:
    push rect
    push [hwnd_main]
    call [GetClientRect]
    push TRUE
    mov ebx, rect
    push dword [ebx+12]
    push dword [ebx+8]
    push dword [ebx+4]
    push dword [ebx]
    push [hwnd_textbox]
    call [MoveWindow]
    ret

window_proc:
    pop ebp         ; ret addr
    pop eax         ; hWnd_main
    pop ebx         ; uMsg
    pop ecx         ; wParan
    pop edx         ; lParam
    push ebp        ; restore ret addr to not crash on ret
    cmp bl, WM_DESTROY
    jne .neq_wm_destroy
    push 0
    call [PostQuitMessage]
    jmp .end
.neq_wm_destroy:
    cmp bl, WM_SIZE
    jne .neq_wm_size
    call resize_textbox
    jmp .end
.neq_wm_size:
    push edx
    push ecx
    push ebx
    push eax
    call [DefWindowProc]  ; result in eax so we can just ret here
.end:
    ret

print 'code (bytes): ', $-main

edit_class    db 'EDIT', 0
wste_class    db 'WSTE_Main', 0
textbox_font  db 'Consolas', 0
window_title  db 'The World''s Smallest Text Editor!', 0
file_filters  db 'Any file (*.*)', 0, '*.*', 0, 0
error_msg     db 'Error.', 0

wcx:
    .cbSize        dd 48
    .style         dd 0
    .lpfnWndProc   dd window_proc
    .cbClsExtra    dd 0
    .cbWndExtra    dd 0
    .hInstance     dd 0
    .hIcon         dd 0
    .hCursor       dd 0
    .hbrBackground dd COLOR_WINDOW+1
    .lpszMenuName  dd 0
    .lpszClassName dd wste_class
    .hIconSm       dd 0

ofn:
    .lStructSize       dd 88
    .hwndOwner         dd NULL
    .hInstance         dd NULL
    .lpstrFilter       dd file_filters
    .lpstrCustomFilter dd NULL
    .nMaxCustFilter    dd 0
    .nFilterIndex      dd 1
    .lpstrFile         dd filename
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

print 'data (bytes): ', $-edit_class
print 'total (bytes): ', $-main

msg:
    .hwnd    dd ?
    .message dd ?
    .wParam  dd ?
    .lParam  dd ?
    .time    dd ?
    .pt      dq ?

rect:
    .left   dd ?
    .top    dd ?
    .right  dd ?
    .bottom dd ?

file_data_ptr   dd ?
heap_handle     dd ?
file_handle     dd ?
file_size       dd ?
num_bytes_read  dd ?
hwnd_textbox    dd ?
hwnd_main       dd ?
filename        rb MAX_PATH

section '.idata' import data readable

    library Comdlg32 , 'Comdlg32.dll', \
            Gdi32    , 'Gdi32.dll',    \
            Kernel32 , 'Kernel32.dll', \
            User32   , 'User32.dll'

    import Comdlg32, \
        GetOpenFileName, 'GetOpenFileNameA', \
        GetSaveFileName, 'GetSaveFileNameA'

    import Gdi32, \
        CreateFont, 'CreateFontA'

    import Kernel32,\
        CloseHandle     , 'CloseHandle',      \
        CreateFile      , 'CreateFileA',      \
        ExitProcess     , 'ExitProcess',      \
        GetFileSize     , 'GetFileSize',      \
        GetModuleHandle , 'GetModuleHandleA', \
        GetProcessHeap  , 'GetProcessHeap',   \
        HeapAlloc       , 'HeapAlloc',        \
        HeapFree        , 'HeapFree',         \
        ReadFile        , 'ReadFile',         \
        WriteFile       , 'WriteFile'

    import User32,                                    \
        CreateWindowEx      , 'CreateWindowExA',      \
        DefWindowProc       , 'DefWindowProcA',       \
        DispatchMessage     , 'DispatchMessageA',     \
        GetClientRect       , 'GetClientRect',        \
        GetKeyState         , 'GetKeyState',          \
        GetMessage          , 'GetMessageA',          \
        GetWindowText       , 'GetWindowTextA',       \
        GetWindowTextLength , 'GetWindowTextLengthA', \
        MessageBox          , 'MessageBoxA',          \
        MoveWindow          , 'MoveWindow',           \
        PostQuitMessage     , 'PostQuitMessage',      \
        RegisterClassEx     , 'RegisterClassExA',     \
        SendMessage         , 'SendMessageA',         \
        SetFocus            , 'SetFocus',             \
        SetWindowText       , 'SetWindowTextA',       \
        TranslateMessage    , 'TranslateMessage'
