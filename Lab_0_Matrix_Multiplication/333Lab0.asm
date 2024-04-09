###########################################################################
#################### CPE 333 LAB 0 ########################################
###########################################################################
#Isaac Lake, Ethan Vosburg, Samuel Solano, and Victoria Asencio-Clemens


.data
A:
	.word 0, 3, 2, 0, 3, 1, 0, 3, 2
	# .word 1, 1, 1, 1, 1, 
	      # 2, 2, 2, 2, 2, 
	      # 3, 3, 3, 3, 3, 
	      # 4, 4, 4, 4, 4, 
	      # 5, 5, 5, 5, 5

B:
	.word 1, 1, 0, 3, 1, 2, 0, 0, 0
	# .word 1, 1, 1, 1, 1, 
	      # 2, 2, 2, 2, 2, 
	      # 3, 3, 3, 3, 3, 
	      # 4, 4, 4, 4, 4, 
	      # 5, 5, 5, 5, 5

C:
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0
	# .word 0, 0, 0, 0, 0, 
	      # 0, 0, 0, 0, 0, 
	      # 0, 0, 0, 0, 0, 
	      # 0, 0, 0, 0, 0, 
	      # 0, 0, 0, 0, 0



.text
###########################################################################
##################### Initialization ######################################
###########################################################################

	li    sp, 0x10000               # Initialize the stack pointer
	la    s0, A                     # Load the base address of A into s0
	la    s1, B                     # Load the base address of B into s1
	la    s2, C                     # Load the base address of C into s2
	li    s3, 3                     # Load the dim_size into s3 (this will be one of the side lengths 
									# for addition and both for mult)
	li	  s4, 4                     # Load the second dim_size into s4 (this will be the other side length for addition)
	mv    a6, s3                    # Load one side length into a6 for multiplication
	mv    a7, s4                    # Load the other side length into a7 for multiplication
	call  MULT					  	# Call the multiplication function
	mv    s4, a7                    # Load the result of the multiplication into s4
	# li    s3, 5                   # Load the dim_size into s3
	call MATRIXMULT                 # Call the matrix multiplication function
	j    DONE                       # Done with the program


###########################################################################
##################### Matrix Addition Function ############################
###########################################################################

#ADD two matrices together of size s3 x s4 and store the result in C

#Inputs: s0, s1, s2, s4
#Outputs: To memory at address C
#Registers Changed: t0, t1, t2, t3, t4 (not an issue since they are pushed to the stack)

MATRIXADD:
	addi 	sp, sp, -24  			# Make space on the stack for 5 registers (5*4 bytes)
	sw 		t0, 0(sp)      			# Store t0 at the top of the stack
	sw 		t1, 4(sp)      			# Store t1 4 bytes below the top of the stack
	sw 		t2, 8(sp)      			# Store t2 8 bytes below the top of the stack
	sw 		t3, 12(sp)     			# Store t3 12 bytes below the top of the stack
	sw 		t4, 16(sp)     			# Store t4 16 bytes below the top of the stack
	sw 		ra, 20(sp)				# Store ra 20 bytes below the top of the stack
	addi  	t0, x0, 0               # var for matrix traversal loop loop
	mv 	  	t1, s0					# pointer for matrix array A
	mv 	  	t2, s1					# pointer for matrix array B

LOOP:
	beq   t0, s4, ADDDONE
	lw    t3, 0(t1)                 # load first value from A
	lw    t4, 0(t2)                 # load first value from B
	add   t4, t3, t4                # add the two values
	sw    t4, 0(s2)                 # put sum into s2
	addi  s2, s2, 4                 # change s2 to next store location
	addi  t0, t0, 1					# increment loop var
	addi  t1, t1, 4                 # add to pointer for matrix array A
	addi  t2, t2, 4                 # add to pointer for matrix array B
	j     LOOP

ADDDONE:
	lw t0, 0(sp)      				# Load t0 from the top of the stack
	lw t1, 4(sp)      				# Load t1 from 4 bytes below the top of the stack
	lw t2, 8(sp)      				# Load t2 from 8 bytes below the top of the stack
	lw t3, 12(sp)     				# Load t3 from 12 bytes below the top of the stack
	lw t4, 16(sp)     				# Load t4 from 16 bytes below the top of the stack
	lw ra, 20(sp)     				# Load ra from 20 bytes below the top of the stack
	addi sp, sp, 24   				# Restore the stack pointer
	ret                             # return



###########################################################################
################ Matrix Multiplication Function ###########################
###########################################################################

#Inputs: s0, s1, s2, s3
#Outputs: To memory at address C
#Registers Changed: a0, a1, a2, t0, t1, s2 (not an issue since they are pushed to the stack)

#Reference for calling row column multiplication function
#a0 row number
#a1 column number
#a2 return value

MATRIXMULT:
	addi sp, sp, -24  				# Make space on the stack for 6 registers (6*4 bytes)
	sw a0, 0(sp)      				# Store a0 at the top of the stack
	sw a1, 4(sp)      				# Store a1 4 bytes below the top of the stack
	sw a2, 8(sp)      				# Store a2 8 bytes below the top of the stack
	sw t0, 12(sp)    				# Store t0 12 bytes below the top of the stack
	sw t1, 16(sp)     				# Store t1 16 bytes below the top of the stack
	sw s2, 20(sp)     				# Store s2 20 bytes below the top of the stack
	addi  a0, x0, -1                # row number to input into RCMULT
	addi  a1, x0, 0                 # var for overall loop and - col number
	addi  t0, x0, 0                 # var for nested loop - row loop
	addi  t1, x0, 0                 # counter for the array (inc by 4)


LOOP:
	beq   t0, s3, MMDONE
	addi  a1, x0, 0                 # var for nested loop
	addi  a0, a0, 1
	addi  t0, t0, 1


NESTED:
	beq   a1, s3, LOOP
	call  RCMULT
	sw    a2, 0(s2)                 # put mult result into s4
	addi  s2, s2, 4                 # change s4 to store location
					# (s2 (array start) + t1 (offset))
	addi  t1, t1, 4                 # update t1 which is the array offset
	addi  a1, a1, 1                 # update nested var
	j     NESTED

MMDONE:

	lw a0, 0(sp)      				# Load a0 from the top of the stack
	lw a1, 4(sp)      				# Load a1 from 4 bytes below the top of the stack
	lw a2, 8(sp)      				# Load a2 from 8 bytes below the top of the stack
	lw t0, 12(sp)     				# Load t0 from 12 bytes below the top of the stack
	lw t1, 16(sp)     				# Load t1 from 16 bytes below the top of the stack
	lw s2, 20(sp)     				# Load s2 from 20 bytes below the top of the stack
	addi sp, sp, 24   				# Restore the stack pointer

###########################################################################
#################### Row / Column Multiplication ##########################
###########################################################################
#Helper function for matrix multiplication

#Inputs: a0, a1
#Outputs: a2
#Registers Changed: t4, t5, t6, a3, a6, a7 (not an issue since they are pushed to the stack)
RCMULT:
	addi sp, sp, -28  				# Make space on the stack for 8 registers (8*4 bytes)
	sw t4, 0(sp)      				# Store t4 at the top of the stack
	sw t5, 4(sp)      				# Store t5 4 bytes below the top of the stack
	sw t6, 8(sp)      				# Store t6 8 bytes below the top of the stack
	sw a3, 12(sp)     				# Store a3 12 bytes below the top of the stack
	sw a6, 16(sp)     				# Store a6 16 bytes below the top of the stack
	sw a7, 20(sp)     				# Store a7 20 bytes below the top of the stack
	sw ra, 24(sp)     				# Store ra 24 bytes below the top of the stack
	mv    a6, a0                    # move row num to a6 for multiplication
	mv    a7, s3                    # move dim_size to a7 for muliplication
	call  MULT                      # multiply row number by dim_size
	slli  t4, a7, 2                 # row product x 4 = offset for first element
	add   t4, s0, t4                # add to pointer for matrix array A
	mv    t5, a1                    # move column number to t5
	slli  t5, t5, 2                 # multiply by 4 to get offset for first element
	add   t5, s1, t5                # add to pointer for matrix array B
	mv    t6, zero                  # initialize value for looping
	mv    a2, zero                  # initialize total sum

DOTPROD:                                  
	bge   t6, s3, RCMULTEND         # branch when done with dot product
	lw    a6, 0(t4)                 # load first row value from A
	lw    a7, 0(t5)                 # load first column value from B
	call  MULT                      # multiply row and column values
	add   a2, a2, a7                # add product to total
	addi  t4, t4, 4                 # move to next row value
	slli  a3, s3, 2                 # a3 = dim_size x 4
	add   t5, t5, a3                # move to next column value
	addi  t6, t6, 1                 # increment number for looping
	j     DOTPROD                   # loop

RCMULTEND:                                
	# Pop registers from the stack
	lw t4, 0(sp)      				# Load t4 from the top of the stack
	lw t5, 4(sp)      				# Load t5 from 4 bytes below the top of the stack
	lw t6, 8(sp)      				# Load t6 from 8 bytes below the top of the stack
	lw a3, 12(sp)     				# Load a3 from 12 bytes below the top of the stack
	lw a6, 16(sp)     				# Load a6 from 16 bytes below the top of the stack
	lw a7, 20(sp)     				# Load a7 from 20 bytes below the top of the stack
	lw ra, 24(sp)     				# Load ra from 24 bytes below the top of the stack
	addi sp, sp, 28   				# Restore the stack pointer
	ret                             # return

###########################################################################
#################### Multiplication Function #############################
###########################################################################
#Note only works for positive integers

#Inputs: a6, a7
#Outputs: a7
#Registers Changed: t0, t1, t2, t3 (not an issue since they are pushed to the stack)
MULT:
	addi  sp, sp, -20               # Adjust stack pointer to make room for
					# 5 registers (ra, t0, t1, t2, t3)
	sw    ra, 16(sp)                # Push ra to stack
	sw    t0, 12(sp)                # Push t0 to stack
	sw    t1, 8(sp)                 # Push t1 to stack
	sw    t2, 4(sp)                 # Push t2 to stack
	sw    t3, 0(sp)                 # Push t3 to stack
                                          
	li    t0, 0                     # Running Total
	li    t1, 1                     # Loop "Counter"
	li    t2, -1                    # Starts at -1 Due to how we increment it
                                          
MULTI:                                    
	beqz  t1, MULTEND               # Checks if we are finished with the mult
	and   t3, t1, a7                # Checks if we should add this loop
	addi  t2, t2, 1
	slli  t1, t1, 1
	beqz  t3, MULTI
	sll   t3, a6, t2
	add   t0, t0, t3
	j     MULTI

MULTEND:
	mv    a7, t0

	lw    t3, 0(sp)                 #Pop t3 from the stack
	lw    t2, 4(sp)                 #Pop t2 from the stack
	lw    t1, 8(sp)                 #Pop t1 from the stack
	lw    t0, 12(sp)                #Pop t0 from the stack
	lw    ra, 16(sp)                #Pop return address from the stack
	addi  sp, sp, 20                #Adjust stack pointer back
	ret

DONE:
	nop
