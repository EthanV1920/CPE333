####################################
############ Quiz 1 ################
####################################

# Problem 1
# Translate this code to RISC-V assembly
# [5] Write a[10]=b[10]+10
# assume base address for a is in x10 and for b is in x11
# x10 = a0, x11 = a1
# RISC-V Assembly code

addi a0, a0, 40 # a[10] = a[0] + 10 * 4
addi a1, a1, 40 # b[10] = b[0] + 10 * 4
lw t0, 0(a1)    # t0 = b[10]
addi t0, t0, 10 # t0 = t0 + 10
sw t0, 0(a0)    # a[10] = t0

# Problem 2
# Translate this code to RISC-V assembly

# int x=0, sum=0;
# int a[20]={1,6,6,7,7,8,8,9,10,...} //initialize this array to some random numbers
# while (x<10){
#       sum=sum+a[x]
#       x++
# }

# RISC-V Assembly code
.data

a: .word 1, 6, 6, 7, 7, 8, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21


.text
mv t0, zero         # x = 0
mv t1, zero         # sum = 0
la t2, a            # t2 = &a[0]
li t3, 10           # x < 10

loop:
    bge t0, t3, end
    lw t4, 0(t2)    # t4 = a[x]
    add t1, t1, t4  # sum = sum + a[x]
    addi t0, t0, 1  # x++
    addi t2, t2, 4  # t2 = t2 + 4
    j loop
end:


# Problem 3
# Translate this code to RISC-V assembly

# int a[20]={1,6,6,7,7,8,8,9,10,...} //initialize this array to some random numbers
# int func (int n, int &a){ //we pass as an input parameter the address of the first element on the array 
#    int x=0, sum=0;
#     while (x<n){
#       sum=sum+a[x];
#       x++;
#    }
#    return sum;
# }

.data

a: .word 1, 6, 6, 7, 7, 8, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21

.text 
##### init #####

    li a0, 10           # n = 10 (n is arbitrary, can be any number<=20 in our case 10)
    la a1, a            # a0 = &a[0]
    call func


##### func #####

# Inputs a0, a1
# Outputs a0
func:
    # Push ra to stack
    addi sp, sp, -4
    sw ra, 0(sp)

    # run function
    mv t0, zero         # x = 0
    mv t1, zero         # sum = 0

loop:
    bge t0, a0, funcEnd
    lw t2, 0(a1)        # t2 = a[x]
    add t1, t1, t2      # sum = sum + a[x]
    addi t0, t0, 1      # x++
    addi a1, a1, 4      # a1 = a1 + 4
    j loop

funcEnd:

    mv a0, t1           # return sum

    # Pop ra from stack
    lw ra, 0(sp)
    addi sp, sp, 4
    
    ret
