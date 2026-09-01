.global _start

.equ NUM_AIRPORTS, 10               # Total number of airports
.equ FUEL_CAPACITY, 20000           # Maximum fuel capacity of the airplane
.equ FUEL_CONSUMPTION_RATE, 2       # Fuel consumption rate of the plane

.section .rodata
# Distance matrix [NUM_AIRPORTS x NUM_AIRPORTS]
# Each row corresponds to an airport, and each column corresponds to the distance to another airport
# Self-distance is omitted (0)

distances:

    .word  0,     2962,  5357,  7979,  8979,  9591,  8823,  10830,  8754,  6136    # 0: Tokyo
    .word  2962,  0,     2564,  5920,  8006,  9631,  9710,  12970, 11664,  8947    # 1: Hong Kong
    .word  5357,  2564,  0,     5845,   8678, 10881, 11552, 15339, 14101, 10789    # 2: Singapore
    .word  7979,  5920,  5845,  0,     3028,  5497,  6919,  11001, 13400, 13712    # 3: Dubai
    .word  8979,  8006,  8678,  3028,  0,     2488,  4114,  8027,  11002, 13021    # 4: Istanbul
    .word  9591,  9631,  10881, 5497,  2488,  0,     1895,  5540,  8760,  11628    # 5: Brussels
    .word  8823,  9710,  11552, 6919,  4114,  1895,  0,     4163,  6926,  9777     # 6: Reykjavik
    .word 10830, 12970,  15339, 11001,  8027, 5540,  4163,  0,     3974,  8007     # 7: New York
    .word  8754, 11664,  14101, 13400, 11002,  8760, 6926,  3974,  0,     4108     # 8: Los Angeles
    .word  6136,  8947,  10789, 13712, 13021, 11628, 9777,  8007,  4108,  0        # 9: Honolulu

# Direction matrix [NUM_AIRPORTS x NUM_AIRPORTS]
# SE=0, NE=1, SW=2, NW=3, self=-1

directions:

    .byte -1,  2,  2,  3,  3,  3,  3,  1,  1,  1    # 0: Tokyo
    .byte  1, -1,  2,  3,  3,  3,  3,  1,  1,  1    # 1: Hong Kong
    .byte  1,  1, -1,  3,  3,  3,  3,  3,  1,  1    # 2: Singapore
    .byte  0,  0,  0, -1,  3,  3,  3,  3,  3,  1    # 3: Dubai
    .byte  0,  0,  0,  0, -1,  3,  3,  3,  3,  1    # 4: Istanbul
    .byte  0,  0,  0,  0,  0, -1,  3,  3,  3,  3    # 5: Brussels
    .byte  0,  0,  0,  0,  0,  0, -1,  2,  3,  3    # 6: Reykjavik
    .byte  2,  2,  0,  0,  0,  0,  1, -1,  3,  3    # 7: New York
    .byte  2,  2,  2,  0,  0,  0,  0,  0, -1,  2    # 8: Los Angeles
    .byte  2,  2,  2,  2,  2,  0,  0,  0,  1, -1    # 9: Honolulu

.section .data

current_fuel: .word 20000
airport_supply: .word 17000, 18000, 16000, 17000, 27500, 36500, 15500, 26000, 27000, 40000
current_airport: .word 5            # Starting at Brussels
flight_state: .word 1               # 1 = journey ongoing, -1 = journey ended


.section .bss

distance_traveled: .space 4         # Total distance traveled
flight_history: .space 64           # Keep history of flight with airport indices (store as bytes)



.section .text
   
flight_navigation:
    # Finds next airport to fly to based on distance and fuel towards west
    # ... Your code here ...
    # Arguments:
    #   a0 = current airport index
    #   a1 = address of distances array
    #   a2 = address of directions array
    #   a3 = current fuel
    # Returns:
    #   a0 = closest westward airport index (-1 if none reachable)
    
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    
    mv s0, a0           # s0 = current airport index
    mv s1, a1           # s1 = distances array address
    mv s2, a2           # s2 = directions array address
    mv s3, a3           # s3 = current fuel
    
    li s4, -1           # s4 = best airport index (initialize to -1)
    li s5, 0x7FFFFFFF   # s5 = minimum distance (initialize to max int)
    li s6, 0            # s6 = loop counter (destination airport)
    
flight_nav_loop:
    li t0, NUM_AIRPORTS
    bge s6, t0, flight_nav_done    # if counter >= NUM_AIRPORTS, done
    
    # Calculate offset in directions array: current_airport * NUM_AIRPORTS + dest_airport
    li t1, NUM_AIRPORTS
    mul t2, s0, t1      # t2 = current_airport * NUM_AIRPORTS
    add t2, t2, s6      # t2 = current_airport * NUM_AIRPORTS + dest_airport
    add t3, s2, t2      # t3 = address of direction[current][dest]
    lbu t4, 0(t3)       # t4 = direction value
    
    # Check if direction is SW (2) or NW (3)
    li t5, 2
    beq t4, t5, flight_nav_check_fuel
    li t5, 3
    beq t4, t5, flight_nav_check_fuel
    j flight_nav_next   # Not westward, skip
    
flight_nav_check_fuel:
    # Calculate offset in distances array (word-aligned)
    slli t2, t2, 2      # t2 = offset * 4 (convert to bytes)
    add t3, s1, t2      # t3 = address of distance[current][dest]
    lw t4, 0(t3)        # t4 = distance
    
    # Calculate fuel required: distance * FUEL_CONSUMPTION_RATE
    li t5, FUEL_CONSUMPTION_RATE
    mul t6, t4, t5      # t6 = fuel required
    
    # Check if we have enough fuel
    bgt t6, s3, flight_nav_next     # if fuel_required > current_fuel, skip
    
    # Check if this is closer than current best
    bge t4, s5, flight_nav_next     # if distance >= min_distance, skip
    
    # Update best airport
    mv s4, s6           # best_airport = dest_airport
    mv s5, t4           # min_distance = distance
    
flight_nav_next:
    addi s6, s6, 1      # counter++
    j flight_nav_loop
    
flight_nav_done:
    mv a0, s4           # return best airport index
    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    addi sp, sp, 32

    # a0 = closest westward airport index
    ret


refuel:
    # Refuel the airplane at the current airport
    # ... Your code here ...
    # Arguments:
    #   a0 = airport index
    #   a1 = address of airport_supply array
    #   a2 = current fuel level
    # Returns:
    #   a0 = updated fuel level
    
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    
    mv s0, a0           # s0 = airport index
    mv s1, a1           # s1 = airport_supply array address
    mv s2, a2           # s2 = current fuel
    
    # Get airport supply: airport_supply[airport_index]
    slli t0, s0, 2      # t0 = airport_index * 4 (word offset)
    add t1, s1, t0      # t1 = address of airport_supply[airport_index]
    lw t2, 0(t1)        # t2 = available fuel at airport
    
    # Calculate how much fuel we can take
    li t3, FUEL_CAPACITY
    sub t4, t3, s2      # t4 = FUEL_CAPACITY - current_fuel (space available in tank)
    
    # Take minimum of (space_in_tank, airport_supply)
    blt t4, t2, refuel_take_tank_space
    mv t5, t2           # t5 = fuel_to_take = airport_supply
    j refuel_update
    
refuel_take_tank_space:
    mv t5, t4           # t5 = fuel_to_take = space_in_tank
    
refuel_update:
    # Update current fuel
    add s2, s2, t5      # current_fuel += fuel_to_take
    
    # Update airport supply
    sub t2, t2, t5      # airport_supply -= fuel_to_take
    sw t2, 0(t1)        # store updated supply back
    
    mv a0, s2           # return updated fuel level
    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16

    ret

execute_flight:
    # Execute flight to next airport
    # Change current_airport, update current_fuel, distance_traveled
    # ... Your code here ...
    # Arguments:
    #   a0 = destination airport index
    #   a1 = distance to destination
    #   a2 = current fuel
    # Returns:
    #   a0 = updated fuel level
    
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw ra, 12(sp)
    
    mv s0, a0           # s0 = destination airport
    mv s1, a1           # s1 = distance
    mv s2, a2           # s2 = current fuel
    
    # Calculate fuel consumed: distance * FUEL_CONSUMPTION_RATE
    li t0, FUEL_CONSUMPTION_RATE
    mul t1, s1, t0      # t1 = fuel_consumed
    
    # Update current fuel
    sub s2, s2, t1      # current_fuel -= fuel_consumed
    
    # Update distance_traveled
    la t2, distance_traveled
    lw t3, 0(t2)        # t3 = current distance_traveled
    add t3, t3, s1      # t3 += distance
    sw t3, 0(t2)        # store updated distance_traveled
    
    # Update current_airport
    la t4, current_airport
    sw s0, 0(t4)        # current_airport = destination
    
    # Update current_fuel in memory
    la t5, current_fuel
    sw s2, 0(t5)        # store updated fuel
    
    mv a0, s2           # return updated fuel level
    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16

    ret


check_flight_state:
    # Check if flight can continue or end
    # ... Your code here ...
    # Arguments:
    #   a0 = next airport index (-1 if no reachable westward airport)
    # Returns:
    #   a0 = flight state (1 = continue, -1 = end)
    
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    
    mv s0, a0           # s0 = next airport index
    
    # If next airport is -1, journey ends
    li t0, -1
    beq s0, t0, check_flight_end
    
    # Otherwise, journey continues
    li s1, 1
    j check_flight_done
    
check_flight_end:
    li s1, -1
    
check_flight_done:
    # Update flight_state in memory
    la t1, flight_state
    sw s1, 0(t1)
    
    mv a0, s1           # return flight state
    
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8

    ret


_start:
    # Initialize and implement flight logic
    # ... Your code here ...
    
    # Initialize flight history counter
    li s10, 0           # s10 = flight history counter (bonus)
    
    # Record starting airport in flight history
    la t0, current_airport
    lw t1, 0(t0)        # t1 = current airport
    la t2, flight_history
    sb t1, 0(t2)        # flight_history[0] = starting airport
    addi s10, s10, 1    # increment history counter
    
main_loop:
    # Load current state
    la t0, current_airport
    lw s0, 0(t0)        # s0 = current airport
    la t1, current_fuel
    lw s1, 0(t1)        # s1 = current fuel
    
    # Call flight_navigation to find next westward airport
    mv a0, s0           # a0 = current airport
    la a1, distances    # a1 = distances array
    la a2, directions   # a2 = directions array
    mv a3, s1           # a3 = current fuel
    jal ra, flight_navigation
    mv s2, a0           # s2 = next airport index
    
    # Check flight state
    mv a0, s2           # a0 = next airport
    jal ra, check_flight_state
    mv s3, a0           # s3 = flight state
    
    # If flight state is -1, end journey
    li t0, -1
    beq s3, t0, end_journey
    
    # Calculate distance to next airport
    # offset = current_airport * NUM_AIRPORTS + next_airport
    li t0, NUM_AIRPORTS
    mul t1, s0, t0      # t1 = current * NUM_AIRPORTS
    add t1, t1, s2      # t1 = current * NUM_AIRPORTS + next
    slli t1, t1, 2      # t1 *= 4 (word size)
    la t2, distances
    add t2, t2, t1      # t2 = address of distance[current][next]
    lw s4, 0(t2)        # s4 = distance to next airport
    
    # Execute flight to next airport
    mv a0, s2           # a0 = destination airport
    mv a1, s4           # a1 = distance
    mv a2, s1           # a2 = current fuel
    jal ra, execute_flight
    mv s1, a0           # s1 = updated fuel
    
    # Record destination in flight history (bonus)
    la t0, flight_history
    add t0, t0, s10     # t0 = address of flight_history[counter]
    sb s2, 0(t0)        # flight_history[counter] = destination airport
    addi s10, s10, 1    # increment history counter
    
    # Refuel at new airport
    mv a0, s2           # a0 = current airport (just landed)
    la a1, airport_supply
    mv a2, s1           # a2 = current fuel
    jal ra, refuel
    mv s1, a0           # s1 = updated fuel after refueling
    
    # Store updated fuel
    la t0, current_fuel
    sw s1, 0(t0)
    
    # Continue to next iteration
    j main_loop
    
end_journey:

    # Exit
    li a7, 10
    ecall
