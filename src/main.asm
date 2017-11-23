format PE GUI 4.0
entry WinMain

include "win32w.inc"

;;;-------------------------------------
section ".data" data readable writeable
;;;-------------------------------------

wcx:
    ;; struct WNDCLASSEX {
    .cbSize        dd 48     ; sizeof(WNDCLASSEX)
    .style         dd 0
    .lpfnWndProc   dd WindowProc
    .cbClsExtra    dd 0
    .cbWndExtra    dd 0
    .hInstance     dd 0
    .hIcon         dd 0
    .hCursor       dd 0
    .hbrBackground dd COLOR_WINDOW+1
    .lpszMenuName  dd 0
    .lpszClassName dd szClass_main
    .hIconSm       dd 0
    ;; }

    hWnd_edit dd ?
    hWnd_main dd ?

    szClass_edit db "EDIT", 0
    szClass_main db "WSTE_Main", 0

msg:    rb 10000

;;;-------------------------------------
section ".code" code readable executable
;;;-------------------------------------

WinMain:
    push NULL
    call [GetModuleHandle]
    mov [wcx.hInstance], eax

    push wcx
    call [RegisterClassEx]

    push NULL
    push [wcx.hInstance]
    push NULL
    push HWND_DESKTOP
    push 600
    push 800
    push 200
    push 200
    push WS_OVERLAPPEDWINDOW + WS_VISIBLE
    push szClass_main
    push szClass_main
    push WS_EX_TOPMOST
    call [CreateWindowEx]
    mov [hWnd_main], eax

    push NULL
    push [wcx.hInstance]
    push NULL
    push [hWnd_main]
    push 400
    push 400
    push 20
    push 20
    push ES_LEFT + ES_MULTILINE + ES_WANTRETURN + WS_VISIBLE + WS_CHILD + WS_HSCROLL + WS_VSCROLL
    push NULL
    push szClass_edit
    push WS_EX_CLIENTEDGE
    call [CreateWindowEx]
    mov [hWnd_edit], eax

    .message_loop:
        push 0
        push 0
        push NULL
        push msg
        call [GetMessage]
        test eax, eax
        jz WinMain_end
        push msg
        call [TranslateMessage]
        push msg
        call [DispatchMessage]
    jmp .message_loop
WinMain_end:
    push 0
    call [ExitProcess]

WindowProc:
    pop ebp         ; ret addr
    pop eax         ; hWnd_main
    pop ebx         ; uMsg
    pop ecx         ; wParan
    pop edx         ; lParam
    push ebp        ; restore ret addr to not crash on ret

    cmp ebx, WM_DESTROY
    jne .not_wm_destroy
        push 0
        call [PostQuitMessage]
        jmp WindowProc_end
    .not_wm_destroy:
    cmp ebx, WM_SIZE
    jne .not_wm_size
        ;; resize textbox here
    .not_wm_size:
    ;; else
        push edx
        push ecx
        push ebx
        push eax
        call [DefWindowProc]  ; result in eax so we can just ret here
WindowProc_end:
    ret

;;;-------------------------------------
section ".idata" import data readable writeable
;;;-------------------------------------

    library Kernel32 , "Kernel32.dll", \
            User32   , "User32.dll"

    import Kernel32,\
        GetModuleHandle , "GetModuleHandleA", \
        ExitProcess     , "ExitProcess"

    import User32,                             \
        CreateWindowEx   , "CreateWindowExA",  \
        GetMessage       , "GetMessageA",      \
        TranslateMessage , "TranslateMessage", \
        DispatchMessage  , "DispatchMessageA", \
        RegisterClassEx  , "RegisterClassExA", \
        DefWindowProc    , "DefWindowProcA",   \
        PostQuitMessage  , "PostQuitMessage"
