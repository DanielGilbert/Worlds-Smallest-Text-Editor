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
    cmp eax, -1  ; INVALID_FILE_SIZE
    jne .size_ok
    push .size_fail_msg
    call ui.message_box
    ret
.size_ok:
    mov [io.file_size], eax
    call [GetProcessHeap]
    push [io.file_size]
    cmp [io.file_data_ptr], 0
    jne .no_dealloc
    push eax
    push [io.file_data_ptr]
    push 0
    push eax
    call [HeapFree]
    pop eax
.no_dealloc:
    push HEAP_ZERO_MEMORY
    push eax
    call [HeapAlloc]
    test eax, eax
    jnz .heap_ok
    push .heap_fail_msg
    call ui.message_box
.heap_ok:
    mov [io.file_data_ptr], eax
    push NULL
    push io.num_bytes_read
    push [io.file_size]
    push [io.file_data_ptr]
    push [io.file_handle]
    call [ReadFile]
    test eax, eax
    jnz .read_ok
    push .read_fail_msg
    call ui.message_box
.read_ok:
    push [io.file_data_ptr]
    call ui.set_textbox_text
    push [io.file_handle]
    call [CloseHandle]
    ret
.open_fail_msg db "Could not open file.", 0
.size_fail_msg db "Could not get file size.", 0
.heap_fail_msg db "Could not allocate memory.", 0
.read_fail_msg db "Could not read file.", 0
