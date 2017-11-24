    hwnd_textbox dd ?
    hwnd_main    dd ?

    edit_class db "EDIT", 0
    wste_class db "WSTE_Main", 0

    textbox_font_name db "Consolas", 0

    window_title db "World's Smallest Text Editor"

    file_filters db "All Files", 0, "*.*", 0, 0

wcx:
    .cbSize        dd 48
    .style         dd 0
    .lpfnWndProc   dd ui_window_proc
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
    .lStructSize       dd  88
    .hwndOwner         dd  NULL
    .hInstance         dd  NULL
    .lpstrFilter       dd  file_filters
    .lpstrCustomFilter dd  NULL
    .nMaxCustFilter    dd  0
    .nFilterIndex      dd  1
    .lpstrFile         dd  filename
    .nMaxFile          dd  256
    .lpstrFileTitle    dd  NULL
    .nMaxFileTitle     dd  0
    .lpstrInitialDir   dd  NULL
    .lpstrTitle        dd  NULL
    .Flags             dd  OFN_HIDEREADONLY
    .nFileOffset       dw  0
    .nFileExtension    dw  0
    .lpstrDefExt       dd  NULL
    .lCustData         dd  NULL
    .lpfnHook          dd  NULL
    .lpTemplateName    dd  NULL
    .lpReserved        dd  NULL
    .dwReserved        dd  0
    .FlagsEx           dd  0

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

    filename        rb 256
