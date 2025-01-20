*=$1000

main_loop:
    inc $d020
    dec $d021
    jmp main_loop