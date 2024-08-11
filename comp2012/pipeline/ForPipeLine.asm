.text
MAIN:
	lu12i.w $s0, 0xfffff # base address
	addi.w $t0, $zero, 0 # NONE
	addi.w $t1, $zero, 1 # ADD
	addi.w $t2, $zero, 2 # SUB
	addi.w $t3, $zero, 3 # MUL
	addi.w $t4, $zero, 4 # DIV
	addi.w $t5, $zero, 5 # RAN
	addi.w $t6, $zero, 0x300
READ:
	ld.w $s1, $s0, 0x070 # load intructions
	srli.w $s2, $s1, 21  # separate [23:21] as operation
	beq $s2, $t0, NONE

	srli.w $s3, $s1, 8
	andi $s3, $s3, 0xff  # Extract operand A
	andi $s4, $s1, 0xff  # Extract operand B

	beq $s2, $t1, ADD
	beq $s2, $t2, SUB
	beq $s2, $t3, MUL
	beq $s2, $t4, DIV
	beq $s2, $t5, RAN
NONE:
	st.w $zero, $s0, 0x000
	st.w $zero, $s0, 0x060
	b READ
ADD:
	srli.w $a1, $s3, 4   # Integer part of A
	andi $a2, $s3, 0xF   # Fractional part of A
	srli.w $a3, $s4, 4   # Integer part of B
	andi $a4, $s4, 0xF   # Fractional part of B
	add.w $a5, $a1, $a3   # Integer part of result
	add.w $a6, $a2, $a4   # Fractional part of result

	addi.w $a7, $zero, 10	
	blt $a6, $a7, ADDFIXED
	addi.w $a5, $a5, 1
	addi.w $a6, $a6, -10
ADDFIXED:
	b POSTPRO
SUB:
	bge $s4, $s3, SWAP   # ensure Aint > Bint
	srli.w $a1, $s3, 4   # Integer part of A
	andi $a2, $s3, 0xF   # Fractional part of A
	srli.w $a3, $s4, 4   # Integer part of B
	andi $a4, $s4, 0xF   # Fractional part of B
	sub.w $a5, $a1, $a3
	sub.w $a6, $a2, $a4
	bge $a6, $zero, POSTPRO	
	addi.w $a5, $a5, -1
	addi.w $a6, $a6, 10
	b POSTPRO
MUL:
	srli.w $a1, $s3, 4   # Integer part of A
	andi $a2, $s3, 0xF   # Fractional part of A
	sll.w $a5, $a1, $s4
	sll.w $a6, $a2, $s4
	addi.w $a3, $zero, 10 # Judger
MULLOOP:
	blt $a6, $a3, MULEND
	sub.w $a6, $a6, $a3
	addi.w $a5, $a5, 1   # Process to normalize fractional part of the result
	b MULLOOP
MULEND:
	b POSTPRO

DIV:
	andi $a1, $s3, 0xFF 
	andi $a2, $s4, 0xFF 
	addi.w $s5, $zero, 0 # counter
	addi.w $a3, $zero, 8 # Judger
	b DIVLOOP
DIVLOOP:
	beq $s5, $a2, DIVEND
	srli.w $a1, $a1, 1
	andi $a4, $a1, 0xF
	blt $a4, $a3, DIVFIXED
	addi.w $a1, $a1, -3  # fix fractional part
DIVFIXED:
	addi.w $s5, $s5, 1  # count
	b DIVLOOP
DIVEND:
	srli.w $a5, $a1, 4   # Integer part of A
	andi $a6, $a1, 0xF   # Fractional part of A
	b POSTPRO
RAN:
	addi.w $a5, $zero, 0   # counter
    	slli.w $s6, $s3, 24
    	slli.w $s7, $s4, 16   
    	add.w  $s6, $s6, $s7
    	slli.w $s7, $s3, 8
    	add.w  $s6, $s6, $s7
    	add.w  $s6, $s6, $s4   # Generate {A,B,A,B} as seed s6
RANLOOP:
	andi $s7, $s6, 0x1 	#s7: bit 0
	srli.w $a7, $s6, 1
    	andi $a7, $a7, 0x1	         #a7: bit 1
    	xor  $s7, $s7, $a7
    	srli.w $a7, $s6, 21  	
    	andi $a7, $a7, 0x1  	#a7: bit 21
    	xor $s7, $s7, $a7
    	srli.w $a7, $s6, 31	
	andi $a7, $a7, 0x1         #a7: bit 31
	xor $s7, $s7, $a7

	slli.w $s7, $s7, 31
	srli.w $s6, $s6, 1
	add.w $s6, $s6, $s7 # shift

	addi.w $a5, $a5, 1
	bne $a5, $t6, RANLOOP # iterate
	
	addi.w $a5, $zero, 0
	st.w $s6, $s0, 0x000

	ld.w $s1, $s0, 0x070 # load intructions
	srli.w $s2, $s1, 21  # separate [23:21] as operation
	beq $s2, $t5, RANLOOP

	b READ
SWAP:
	add.w $s5, $zero, $s4
	add.w $s4, $zero, $s3
	add.w $s3, $zero, $s5
	b SUB
POSTPRO:
	addi.w $a4, $zero, 0     # the final result for integer
	addi.w $a2, $zero, 0x1   # unit 1 for count
CHECK10000:
	lu12i.w $a3, 0x2
	addi.w $a3, $a3, 0x710   # load 10000
	blt $a5, $a3, CHECK1000  # kill all 10000s
	sub.w $a5, $a5, $a3
	b CHECK10000
CHECK1000:
	addi.w $a3, $zero, 1000
	blt $a5, $a3, CHECK100   # kill all 1000s
	slli.w $a1, $a2, 28
	add.w $a4, $a4, $a1
	sub.w $a5, $a5, $a3
	b CHECK1000
CHECK100:
	addi.w $a3, $zero, 100
	blt $a5, $a3, CHECK10    # kill all 100s
	slli.w $a1, $a2, 24
	add.w $a4, $a4, $a1
	sub.w $a5, $a5, $a3
	b CHECK100
CHECK10:
	addi.w $a3, $zero, 10
	blt $a5, $a3, CHECK1     # kill all 10s
	slli.w $a1, $a2, 20
	add.w $a4, $a4, $a1
	sub.w $a5, $a5, $a3
	b CHECK10
CHECK1:
	addi.w $a3, $zero, 1
	blt $a5, $a3, VIEW       # final bit
	slli.w $a1, $a2, 16
	add.w $a4, $a4, $a1
	sub.w $a5, $a5, $a3
	b CHECK1
VIEW:
	add.w $a4, $a4, $a6
	st.w $a4, $s0, 0x000
	b READ