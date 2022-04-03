# Allow these procedures to be called from other code units
.global delay
.global in_word
.global out_word

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