###########################################################################
#################### Multiplication Function  #############################
###########################################################################
#Note only works for possitive integers

#Inputs: a6, a7
#Outputs: a7
#Registers Changed: t0, t1, t2, t3
MULT:	
	addi sp, sp, -4		#Pushes ra to stack
	sw ra, 0(sp)
	li t0, 0		#Running Total
	li t1, 1		#Loop "Counter"
	li t2, -1		#Starts at -1 Due to how we increment it
	
MULTI:
	beqz t1, MULTEND	#Checks if we are finished with the mult
	and t3, t1, a7		#Checks if we should add this loop
	addi t2, t2, 1
	slli t1, t1, 1
	beqz t3, MULTI
	sll t3, a6, t2		
	add t0, t0, t3
	j MULTI
	
MULTEND:
	mv a7, t0

	lw ra, 0(sp)		#Pop return address from the stack
	addi sp, sp, 4
	ret