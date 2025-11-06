
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

Loop:
    add  t1, a1, t0    
    add  t2, a2, t0 
    add  t3, a3, t0  
    add  t4, a4, t0   
    add  t5, a5, t0      
    add  t6, a6, t0                
    flw  fs0, 0(t1)                
    flw  fs1, 0(t2)                 
    flw  fs2, 0(t3)             
    srli s0, t0, 2

    fcvt.s.w fs3, s1             
    li   t1, 3
    remu t2, s0, t1 # data dependency- stall, branch instruction is waiting for the write-back of the rtemainder instruction. ()x7
    beqz t2, Div

Mul: # this one itself is control hazard. depending on 
    then by v1[i]
    fcvt.s.w ft0, s0               
    fmul.s ft0, ft0, fs3            # data dependency on ft0 waiting for multiplication to finish EX. -> stalls 
    fmul.s ft0, ft0, fs0          
    j    UpdateM

Div:
    sll  t3, s1, s0                
    fcvt.s.w ft1, t3               
    fdiv.s ft0, fs0, ft1           
UpdateM:
    fcvt.w.s s1, ft0                
    fmul.s ft2, ft0, fs0           
    fsub.s ft2, ft2, fs1            
    fsw   ft2, 0(t4)
    fdiv.s ft3, ft2, fs2           
    fsub.s ft3, ft3, fs10          
    fsw   ft3, 0(t5)
    fsub.s ft4, ft2, fs0            
    fmul.s ft4, ft4, ft3           
    fsw   ft4, 0(t6)
    addi t0, t0, -4
    bgez t0, Loop

# exit 
    li   a0, 0
    li   a7, 93
    ecall