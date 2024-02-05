.globl set_engine
.globl set_handbrake
.globl read_sensor_distance
.globl get_distance
.globl get_position
.globl get_rotation
.globl get_time
.globl get_distance
.globl atoi
.globl itoa
.globl print_char2
.globl approx_sqrt
.globl gets
.globl puts
.globl strlen_custom
.globl fill_and_pop
.globl print_char

set_engine:
    li a7, 10
    ecall
    ret

set_handbrake:
    li a7, 11
    ecall
    ret

read_sensor_distance:
    li a7, 13
    ecall
    ret

get_position:
    li a7, 15
    ecall
    ret

get_rotation:
    li a7, 16
    ecall
    ret

get_time:
    li a7, 20
    ecall
    ret

get_distance:
    sub a0, a0, a3
    sub a1, a1, a4
    sub a2, a2, a5
    mul a0, a0, a0
    mul a1, a1, a1
    mul a2, a2, a2
    add a0, a0, a1
    add a0, a0, a2
    li a1, 10

    mv t6, ra
    jal approx_sqrt
    mv ra, t6
    ret

atoi:
    lb t1, 0(a0)
    li t5, 45
    beqz t1, 2f

    mv s5, a0
    1:
        lb t1, 0(s5)
        beqz t1, 1f
        addi s5, s5, 1
        j 1b

    1: 
        li t1, 0
        li t2, 1
        li t4, 10

    2:
        addi s5, s5, -1
        lb t3, 0(s5)
        beq t3, t5, 3f
        add t3, t3, -48
        mul t3, t3, t2
        add t1, t1, t3
        beq s5, a0, 2f
        mul t2, t2, t4
        j 2b
    
    3:
        li t5, -1
        mul t1, t1, t5
    
    2:
        mv a0, t1
        ret

reverse:

    mv s1, a0
    mv s2, a0

    1:
        lb t1, 0(s2)
        beqz t1, 1f
        addi s2, s2, 1
        j 1b

    1:
        addi s2, s2, -1
        blt s2, s1, 2f
       
        lb t1, 0(s1)
        lb t2, 0(s2)

        sb t2, 0(s1)
        sb t1, 0(s2)

        addi s1, s1, 1
        j 1b

    2:
        ret

itoa:
    beqz a0, 6f
    li t3, 16
    li t4, 10
    mv s1, a1

    slt t5, a0, x0
    beqz t5, 1f
    li t6, -1
    mul a0, a0, t6

    1:
    beq a2, t3, 2f
    1:
        beqz a0, 3f
        rem t1, a0, a2
        div a0, a0, a2
        addi t1, t1, 48
        sb t1, 0(s1)
        addi s1, s1, 1
        j 1b
    
    2:
        beqz a0, 3f 
        rem t1, a0, a2
        div a0, a0, a2

        bge t1, t4, 4f
        addi t1, t1, 48
        sb t1, 0(s1)
        addi s1, s1, 1
        j 2b

        4:
            addi t1, t1, 55 
            sb t1, 0(s1)
            addi s1, s1, 1
            j 2b

    3:
        beqz t5, 5f
        li t5, 45
        sb t5, 0(s1)
        addi s1, s1, 1

        5:  
            sb x0, 0(s1)
            mv t0, ra
            mv a0, a1
            jal reverse     
            mv ra, t0
            ret

        ret
    
    6:
        li t1, 48
        sb t1, 0(a1)
        addi a1, a1, 1
        sb x0, 0(a1)

        addi a1, a1, -1
        mv a0, a1
        ret

approx_sqrt:
    li t0, 1
    li t2, 0
 
    srl t1, a0, t0 # t1 = initial guess
    beqz t1, skip_loop

    1:
        div a1, a0, t1
        add t1, t1, a1
        srl t1, t1, t0

        addi t2, t2, 1
        bne t2, a1, 1b
    
    skip_loop:
        mv a0, t1
    
    ret

print_char:
    li t0, 10
    sb t0, 1(a0)
    li a1, 2
    li a7, 18
    ecall
    ret


print_char2:
    li t0, 66
    sb t0, 0(a0)
    li t0, 10
    sb t0, 1(a0)
    li a1, 2
    li a7, 18
    ecall
    ret


strlen_custom:
    li t0, 0
    
    1:
        lb t1, 0(a0)
        beqz t1, 1f
        addi a0, a0, 1
        addi t0, t0, 1
        j 1b

    1:
        mv a0, t0
        ret

puts:
    mv t1, a0
    1:
        lb t0, 0(t1)
        beqz t0, 2f

        mv a0, t1
        li a1, 1
        li a7, 18
        ecall
        addi t1, t1, 1
        j 1b

    2:
        li t0, 10
        sb t0, 0(t1)

        mv a0, t1
        li a1, 1
        li a7, 18
        ecall

        sb x0, 0(t1)
        
        ret

gets:
    mv s5, a0
    li t0, 0
    1:
        mv a0, s5
        li a1, 1
        li a7, 17
        ecall

        lb t1, 0(s5)
        li t2, 10
        beq t1, t2, 2f

        addi s5, s5, 1
        addi t0, t0, -1
    
        j 1b
    2:
        sb x0, 0(s5)
        add s5, s5, t0
        mv a0, s5
    ret

fill_and_pop:
    lw t0, 0(a0)
    sw t0, 0(a1)
    lw t0, 4(a0)
    sw t0, 4(a1)
    lw t0, 8(a0)
    sw t0, 8(a1)
    lw t0, 12(a0)
    sw t0, 12(a1)
    lw t0, 16(a0)
    sw t0, 16(a1)
    lw t0, 20(a0)
    sw t0, 20(a1)
    lw t0, 24(a0)
    sw t0, 24(a1)
    lw t0, 28(a0)
    sw t0, 28(a1)
    
    lw a0, 28(a0)
    ret
