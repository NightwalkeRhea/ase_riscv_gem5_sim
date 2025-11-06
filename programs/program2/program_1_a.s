.section .data
.balign 4

V1:     .fill 32, 4, 0x3f800000     
V2:     .fill 32, 4, 0x40000000     
V3:     .fill 32, 4, 0x40000000     
V4:     .space 128
V5:     .space 128
V6:     .space 128

bfloat:  .float 0.0                 


.section .text
.globl _start
_start:
    li   t0, 124                    
    li   s1, 1                    

    la   a1, V1
    la   a2, V2
    la   a3, V3
    la   a4, V4
    la   a5, V5
    la   a6, V6
    add  t1, a1, t0                
    add  t2, a2, t0                 
    add  t3, a3, t0                 
    add  t4, a4, t0                 
    add  t5, a5, t0                 
    add  t6, a6, t0                 

    flw  fs0, 0(t1)                
    flw  fs1, 0(t2)              
    flw  fs2, 0(t3) 
    lui   s2, %hi(bfloat)
    addi  s2, s2, %lo(bfloat)
    flw   fs10, 0(s2)             

loop:
    add   t1, a1, t0                
    add   t2, a2, t0                
    add   t3, a3, t0               


    flw   fs0, 0(t1)               
    add   t4, a4, t0                
    flw   fs1, 0(t2)                
    add   t5, a5, t0                
    flw   fs2, 0(t3)             
    add   t6, a6, t0               

    
    srli  s0, t0, 2                 
    fcvt.s.w fs3, s1                
    li    t1, 3
    remu  t2, s0, t1                
    addi  s2, t0, -4                

   
    beqz  t2, Div


Mul:
    fcvt.s.w ft0, s0               
    fmul.s   ft0, ft0, fs3          
    fmul.s   ft0, ft0, fs0          # a

    j       AfterA
Div:
    sll     t3, s1, s0              
    fcvt.s.w ft1, t3               
    fdiv.s   ft0, fs0, ft1          # a   
AfterA:
    fmul.s   ft2, ft0, fs0         
    fsub.s   ft2, ft2, fs1         
    fdiv.s   ft3, ft2, fs2          
    fsub.s   ft4, ft2, fs0          
    fsw      ft2, 0(t4)             
    fsub.s   ft3, ft3, fs10         
    fsw      ft3, 0(t5)             
    fmul.s   ft4, ft4, ft3          
    fsw      ft4, 0(t6)             
    fcvt.w.s s1, ft0                
    mv      t0, s2
    bgez    t0, Loop


# exit 
    li   a0, 0
    li   a7, 93
    ecall