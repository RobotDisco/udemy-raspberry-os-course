# Allow these procedures to be called from other code units
.global delay
.global in_word
.global out_word

.global memset
.global memcpy
.global memmove
.global memcpy

.global get_el

delay:
    # x0 is, by convention, where our only input variable is set
    # subtract one from x0 
    # subs sets conditional flags, sub does not.
    subs x0, x0, #1
    # If x0 is not 0, jump to start o delay function (basically loop)
    bne delay
    # x0 is 0 (we have delayed our desired amount) so return
    ret

in_word:
    # x0 is the address we're loading a 32-bit value from
    # We load it into w0, the 32-bit version of x0 (clearing higher bits)
    # x0/w0 is the register storing the return value, by convention
    ldr w0, [x0]
    ret

out_word:
    # x0 contains our memory address
    # x1 contains our 32-bit value.
    # x1 assumes register value is 64-bit
    # w1 assumes same register value is 32-bit
    # So store register 1's value as 32-bit into address x0
    str w1, [x0]
    ret

memset:
    # If size param is 0 words, don't do anything
    cmp x2, #0
    beq memset_end

set:
    # Store value of src x1 into dst address [x0] as a 32-bit byte
    # Move x0's value up by 1
    strb w1, [x0], #1
    # Subtract 1 from size param x2. If not zero,
    # do memset again 
    subs x2, x2, #1
    bne set

memset_end:
    ret

memcmp:
    # Move value of x0 into x3 as temporary holding
    mov x3, x0
    # Clear out x0, assume values are the same by default
    mov x0, #0

compare:
    # Is size param zero? Then we're done
    cmp x2, #0
    beq memcmp_end

    # Load byte values from our pointer params into temp registers,
    # increment address param values by 1 word
    ldrb w4, [x3], #1
    ldrb w5, [x1], #1
    # Subtract size param by one
    sub x2, x2, #1
    # Are loaded values the same?
    cmp w4, w5
    # If so, look at the next word
    beq compare

    # If not, we're not equal, adjust the return value
    mov x0, #1

memcmp_end:
    # We previously zeroed out x0, so just return
    ret

# We don't clear out the value at the source address,
# so memmove and memcpy are currently the same operation
memmove:
memcpy:
    # If our size arg is 0, then we're done
    cmp x2, #0
    beq memcpy_end
    # This is a direction value, start with +1
    # as we assume we are copying in a forwards
    # direction
    mov x4, #1


    # If address of src is >=  dst
    # we can do a straightforward byte copy
    cmp x1, x0
    bhs copy
    # If address of dst is < than src address
    # and end address of src is <= start of dst
    # we can do a straightforward copy
    add x3, x1, x2
    cmp x3, x0
    bls copy

    # otherwise, our dst buffer overlaps with our src buffer
    # so we will have to copy our data backwards as to not
    # overwrite the values in our src buffer.
overlap:
    # Subtract one from size since we are zero-indexed
    sub x3, x2, #1
    # Replace src/dst params with end values
    add x0, x0, x3
    add x1, x1, x3
    # x4 should indicate that we are copying in a backwards direction
    neg x4, x4


copy:
    # Load values from memory
    ldrb w3, [x1]
    strb w3, [x0]
    # Increment or decrement src/dst pointers based on direction/overlap
    add x0, x0, x4
    add x1, x1, x4

    # Decrement size and restart procedure
    subs x2, x2, #1
    bne copy

memcpy_end:
    ret

get_el:
    mrs x0, currentel
    # Bits 0-1 aren't used, bits 2-3 represent current exception level
    # so shift right by 2 and return.
    lsr x0, x0, #2
    ret