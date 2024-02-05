.set gpt_base, 0xFFFF0100
.set car_base, 0xFFFF0300
.set serial_base, 0xFFFF0500
.set user_stack_end, 0x07FFFFFC
stack_base: .skip 0x100
stack_end:

Syscall_get_systime:
    li s0, gpt_base
    li t0, 1

    sb t0, 0(s0)
    1:
        lb t0, 0(s0)
        bnez t0, 1b    

    lw a0, 4(s0)
    ret

Syscall_set_engine_and_steering:
    li t0, 128
    bge a1, t0, 1f

    li t0, -128
    ble a1, t0, 1f

    li t0, 2
    bge a0, t0, 1f

    li t0, -2
    ble a0, t0, 1f
    
    li s0, car_base
    addi s0, s0, 32
    sb a0, 1(s0)
    sb a1, 0(s0)
    
    li a0, 0
    ret

    1:
        li a0, -1
        ret

Syscall_get_position:
    li s0, car_base
    li t0, 1
    sb t0, 0(s0)

    1:
        lb t0, 0(s0)
        bnez t0, 1b

    lw t0, 16(s0)
    sw t0, 0(a0)

    lw t0, 20(s0)
    sw t0, 0(a1)

    lw t0, 24(s0)
    sw t0, 0(a2)

    ret

Syscall_get_rotation:
    li s0, car_base
    li t0, 1
    sb t0, 0(s0)

    1:
        lb t0, 0(s0)
        bnez t0, 1b

    lw t0, 4(s0)
    sw t0, 0(a0)

    lw t0, 8(s0)
    sw t0, 0(a1)

    lw t0, 12(s0)
    sw t0, 0(a2)

    ret

Syscall_read_serial:
    li s0, serial_base
    mv t1, a1
    li t2, 0

    1:
        beqz a1, 2f

        li t0, 1
        sb t0, 2(s0)

        busy_waiting:
            lb t0, 2(s0)
            bnez t0, busy_waiting

        lb t0, 3(s0)
        beqz t0, 2f
        sb t0, 0(a0)
        addi t2, t2, 1
        addi a0, a0, 1
        addi a1, a1, -1
        j 1b

    2:
        mv a0, t2
        mv a1, t1
        ret

Syscall_write_serial:
    li s0, serial_base
    li t0, 1
    mv t1, a0

    1:
        beqz a1, 3f
        lb t0, 0(a0)
        sb t0, 1(s0)

        li t0, 1
        sb t0, 0(s0)
        2:
            lb t0, 0(s0)
            bnez t0, 2b
        
        addi a0, a0, 1
        addi a1, a1, -1
        bnez a1, 1b
    
    3:
        mv a0, t1
        ret

Syscall_set_handbrake:
    li s0, car_base
    sb a0, 34(s0)
    ret

Syscall_read_sensors:
    li s0, car_base
    addi s0, s0, 36

    li t0, 0
    li t1, 256
    1:
        beq t0, t1, 1f
        lb t2, 0(s0)
        sb t2, 0(a0)
        addi a0, a0, 1
        addi s0, s0, 1
        addi t0, t0, 1
        j 1b

    1:
        addi a0, a0, -256
        ret

Syscall_read_sensor_distance:
    li s0, car_base
    li t0, 1
    sb t0, 2(s0)

    1:
        lb t0, 2(s0)
        bnez t0, 1b
    
    lb a0, 28(s0)
    ret

int_handler:
    
    csrrw sp, mscratch, sp
    addi sp, sp, -32
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw s0, 12(sp)
    sw s1, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)
    sw ra, 28(sp)

    li t0, 10
    bne a7, t0, 1f
    jal Syscall_set_engine_and_steering
    j end

    1:
        li t0, 11
        bne a7, t0, 1f
        jal Syscall_set_handbrake
        j end
    
    1:
        li t0, 12
        bne a7, t0, 1f
        jal Syscall_read_sensors
        j end
    
    1:
        li t0, 13
        bne a7, t0, 1f
        jal Syscall_read_sensor_distance
        j end

    1:
        li t0, 15
        bne a7, t0, 1f
        jal Syscall_get_position
        j end

    1:
        li t0, 16
        bne a7, t0, 1f
        jal Syscall_get_rotation
        j end

    1:
        li t0, 17
        bne a7, t0, 1f
        jal Syscall_read_serial
        j end

    1:
        li t0, 18
        bne a7, t0, 1f
        jal Syscall_write_serial
        j end
    
    1:
        li t0, 20
        bne a7, t0, end
        jal Syscall_get_systime
        j end

    end:
    csrr t0, mepc  # load return address (address of 
                   # the instruction that invoked the syscall)
    addi t0, t0, 4 # adds 4 to the return address (to return after ecall) 
    csrw mepc, t0  # stores the return address back on mepc

    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw s0, 12(sp)
    lw s1, 16(sp)
    lw a1, 20(sp)
    lw a2, 24(sp)
    lw ra, 28(sp) 
    addi sp, sp, 32
    csrrw sp, mscratch, sp

    mret           # Recover remaining context (pc <- mepc)
  

.globl _start
_start:
    li sp, user_stack_end

    la t0, int_handler
    csrw mtvec, t0

    la t0, stack_end
    csrw mscratch, t0

    csrr t1, mstatus
    li t2, ~0x1800
    and t1, t1, t2
    csrw mstatus, t1

    la t0, main
    csrw mepc, t0

    mret
