ui_browse_for_file:
    mov eax, [hwnd_main]
    mov [ofn.hwndOwner], eax
    push ofn
    call [GetOpenFileName]
    push MB_OK
    push filename
    push filename
    push HWND_DESKTOP
    call [MessageBox]
    ret

ui_create_textbox:
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
    push textbox_font_name
    push DEFAULT_PITCH
    push DEFAULT_QUALITY
    push CLIP_DEFAULT_PRECIS
    push OUT_DEFAULT_PRECIS
    push ANSI_CHARSET
    push FALSE
    push FALSE
    push FALSE
    push FW_DONTCARE
    push 0
    push 0
    push 0
    push 16
    call [CreateFont]
    push TRUE
    push eax
    push WM_SETFONT
    push [hwnd_textbox]
    call [SendMessage]
    call ui_resize_textbox
    ret

ui_init:
    push NULL
    call [GetModuleHandle]
    mov [wcx.hInstance], eax
    push wcx
    call [RegisterClassEx]
    push NULL
    push [wcx.hInstance]
    push NULL
    push HWND_DESKTOP
    push 480
    push 640
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push WS_OVERLAPPEDWINDOW + WS_VISIBLE
    push window_title
    push wste_class
    push WS_EX_LEFT
    call [CreateWindowEx]
    mov [hwnd_main], eax
    call ui_create_textbox
    ret

ui_main:
    push 0
    push 0
    push NULL
    push msg
    call [GetMessage]
    test eax, eax
    jz .end
    push msg
    call [TranslateMessage]
    push msg
    call [DispatchMessage]
    jmp ui_main
.end:
    ret

ui_resize_textbox:
    push rect
    push [hwnd_main]
    call [GetClientRect]
    push TRUE
    push [rect.bottom]
    push [rect.right]
    push [rect.top]
    push [rect.left]
    push [hwnd_textbox]
    call [MoveWindow]
    ret

ui_window_proc:
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
    call ui_resize_textbox
.neq_wm_size:
    push edx
    push ecx
    push ebx
    push eax
    call [DefWindowProc]  ; result in eax so we can just ret here
.end:
    ret
