.section .data
	.balign 4
	K: .word 16
	y: .space 4
	b_float: .float 171.0
	vector_i: .float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
	vector_w: .float 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0, 32.0

.section .text
.globl _start
_start:
	la t0, K
	lw t0, (t0)
	la t0, b_float
	flw ft0, (t0)
	la t0, vector_i
	flw ft0, (t0)
	la t0, vector_w
	flw ft0, (t0)
Main:
	la a7, y
	la t0, K
	lw t0, (t0)
	la t1, b_float
	flw ft0, (t1) # b_float
	la a0, vector_i
	la a1, vector_w
	li t1, 0 	# byte offset
	slli s0, t1, 2
	add t2, s0, a0
	add t3, s0, a1

	flw ft1, (t2)
	flw ft2, (t3)

	fcvt.s.w ft3, t1 # reusing t1 because it already contains 0
loop:
	
		# iteration finished
	# else:

	fmul.s ft4, ft1, ft2
	fadd.s ft3, ft3, ft4 # update ft3 (x)
	
	addi t1, t1, 1
	slli s0, t1, 2		# go to the next float offset
	add t2, s0, a0
	add t3, s0, a1
	
	flw ft1, (t2)
	flw ft2, (t3)
    
	blt t1,t0, loop


end_loop:
	# add b to the result
	fadd.s ft3, ft3, ft0
# checking the exponent of X with Mask-and-compare: 
# if word & 0x7F800000 = 0x7F800000 => exponent is 0xFF
	fmv.x.w a5, ft3 # move 32-bit float bit pattern to a0
	li t0, 0x7F800000
	and t1, a5, t0
	beq t1, t0, exp_all_ones
	
	# else, load the real value 
	fsw ft3, (a7)
	J end

# Or now that we're using rv32imf, we can mark it via F extension
exp_all_ones:
	# f(x) = 0 = y
	li t0, 0
	fcvt.s.w ft4, t0
	fsw ft4, (a7) # load zero to y
	
	# fclass.s a1, fa0 	# a1 bits: 0=-inf, 7=+inf, 8=sNaN, 9=qNaN
	# li t0, (1<<0)|(1<<7)|(1<<8)|(1<<9)
	# and a1, a1, t0
	# bneq a1, exp_all_ones

end:

	li a0, 0
	li a7, 93
	ecall
