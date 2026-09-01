.data
    secret_code: .word 517, 1863, 4174, 1705, 456, 2025, 0
    key:         .word 17

.text

.globl _start

_start:
    # Load addresses and values to registers
    la t0, secret_code         
    la t1, key
    lw t1, 0(t1)               # t1 = 17
    
# DO NOT EDIT ABOVE THIS LINE.         
    
    li t6, 0                   # t6 = final sum (decoded message)
    li t2, 0                   # t2 = index counter
    
loop:
    lw t3, 0(t0)               # Load current number from array
    beqz t3, end               # If number is 0, go to end
    
    # Check if t3 contains key (17) as consecutive digits
    mv t4, t3                  # t4 = copy of current number for checking
    li t5, 0                   # t5 = flag (0 = not found, 1 = found)
    
check_digits:
    li a0, 10                  # a0 = 10 (for division)
    
    # Get last two digits: (t4 % 100)
    li a1, 100
    remu a2, t4, a1            # a2 = t4 % 100 (last two digits)
    
    # Check if last two digits equal key
    beq a2, t1, found_key      # If a2 == 17, found
    
    # Divide by 10 to check next pair
    divu t4, t4, a0            # t4 = t4 / 10
    beqz t4, check_done        # If t4 == 0, no more digits
    j check_digits             # Continue checking
    
found_key:
    li t5, 1                   # Set flag = 1 (found)
    
check_done:
    # If key was found, transform: new_value = number * index
    beqz t5, no_transform      # If flag == 0, skip transformation
    
    mul t3, t3, t2             # t3 = number * index
    sw t3, 0(t0)               # Store transformed value back to array
    
no_transform:
    # Add current value to sum
    add t6, t6, t3             # t6 += current value
    
    # Move to next element
    addi t0, t0, 4             # Move pointer to next word
    addi t2, t2, 1             # Increment index
    j loop                     # Continue loop

# DO NOT EDIT BELOW THIS LINE.      

end: 
    # t6 should have the final decoded value
    li a7, 10
    ecall
