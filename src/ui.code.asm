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

    ;; save here


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
    push ui.textbox_font_name
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

ui.init:
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
    ret

ui.main:
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
    jmp ui.main
.not_o_key:
    cmp [ui.msg.wParam], 0x53   ; S
    jne .not_s_key
    call ui.save_file
    jmp ui.main
.not_s_key:
.ctrl_not_pressed:
.neq_wm_keydown:
    push ui.msg
    call [TranslateMessage]
    push ui.msg
    call [DispatchMessage]
    jmp ui.main
.end:
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

ui.set_textbox_text:
    pop ebp
    pop edx
    push ebp
    push edx
    push [ui.hwnd_textbox]
    call [SetWindowText]
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
