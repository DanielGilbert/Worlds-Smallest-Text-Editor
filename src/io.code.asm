io_load_file:
    pop ebp
    pop edx
    push ebp
    push OF_READ
    push NULL                   ; data struct
    push edx
    call [OpenFile]
    ret
