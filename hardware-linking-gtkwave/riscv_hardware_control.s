.globl _start

#.section .bss

.section .data
    arr: .word 1111, 2222, 3333, 4444, 5555, 6666
.section .text

_start:
    la x5, arr
    nop
    nop
    nop
    lw x6, 0(x5)
    nop
    add x8, x6, x6

################################################################################# 
# DO NOT EDIT ABOVE THIS LINE.

    # Load-Use Hazard Implementation
    # Load x7 from memory location arr+4 (second element: 2222)
    lw x7, 4(x5)
    # Immediately use x7 in the next instruction - this creates a load-use hazard
    add x9, x7, x6
    # The processor must stall to resolve this hazard

# DO NOT EDIT BELOW THIS LINE.
################################################################################# 
    j END

END:    
    li   a7, 10       
    j .
