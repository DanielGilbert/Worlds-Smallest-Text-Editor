io_load_file:
    pop ebp
    pop edx
    push ebp
    push OF_READ
    push re_open_buff
    push edx
    call [OpenFile]
    ret
