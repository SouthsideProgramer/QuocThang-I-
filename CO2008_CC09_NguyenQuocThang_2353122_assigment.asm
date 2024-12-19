.data 
.align 2
input: .asciiz "input_matrix.txt"
output: .asciiz "output_matrix.txt"
buffer: .space 100000      

.align 2
error: .asciiz "Error: size not match"

.align 4                  
image: .space 40000      
kernel: .space 40000       
outputmatrix: .space 400000
save: .space 400000
out: .space 40000

.align 2
number: .float 48.0
n: .word 10
m: .word 10
p: .word 10
s: .word 10
half: .float 0.5
ten: .float 10.0
one: .float 1.0
zero: .float 0.0
minus1: .float -1.0
image_padding: .space 50000 
space: .asciiz " "
dot: .asciiz "."
minus: .asciiz "-"
four: .float 10.0
.text
main:
#open file 
li $v0, 13 
la $a0, input 
la $a1, 0 
la $a2, 0
syscall 
move $t0, $v0

 #readfile 
li $v0, 14
move $a0, $t0
la $a1, buffer
li $a2, 1000000
syscall 

li $t5, 0 #index 
li $t9, 0 #counter to select register 
li $t7, 0 #temporary variable to build each number

checkstring: #check if it number 
lb $t6, buffer($t5)
beq $t6, 0, endloop 
beq $t9, 4, endloop # n m p s 
beq $t6, 46, skipchar



checkifspace:
li $t8, 32 
beq $t6, $t8, store_value #if it's space store value 
#if it's a digit 
sub $t6, $t6, 48 
mul $t7, $t7, 10 #multiply pervious digit to 10
add $t7, $t7, $t6
j nextchar

store_value:
    # Store accumulated number in the appropriate register
    beq $t9, 0, store_in_t1
    beq $t9, 1, store_in_t2
    beq $t9, 2, store_in_t3
    beq $t9, 3, store_in_t4
    
    store_in_t1: #store n
    move $t1, $t7
    addi $t9, $t9, 1              # Increment register counter
    li $t7, 0                     # Reset accumulator
    j nextchar
    
    store_in_t2:
    move $t2, $t7
    addi $t9, $t9, 1
    li $t7, 0                     # Reset accumulator
    j nextchar

store_in_t3:
    move $t3, $t7
    addi $t9, $t9, 1
    li $t7, 0                     # Reset accumulator
    j nextchar

store_in_t4:
    move $t4, $t7
    addi $t9, $t9, 1
    li $t7, 0                     # Reset accumulator
    j nextchar
    
nextchar: 
addi $t5, $t5, 1
j checkstring

skipchar: 
add $t5, $t5, 2 #skip when pointer meet . 
j checkstring
 
endloop:
     sw $t1, n
     sw $t2, m
     sw $t3, p
     sw $t4, s
     bgt $t1, 7, checksize
     blt $t1, 3, checksize
     bgt $t2, 4, checksize
     blt $t2, 2, checksize
     bgt $t3, 4 checksize
     blt $t3, 0, checksize 
     bgt $t4, 3, checksize 
     blt $t4, 1, checksize
    bne $t7, 0, store_value 
    lw $t4, s
    lw $t1,n
    lw $t2, m
    lw $t3, p
    mul $k1, $t4, 2 
    add $k0, $t1, $k1    
    blt $k0, $t2, checksize
    addi $t5, $t5, 2
     li $t0, 0 #number of input added 
     l.s $f20, ten
     l.s $f8, one 
    bge $k0, $t2, matrix 

matrix:
 lb $t6, buffer($t5)      # Load next character
 mul $t8, $t1, $t1  #matrix
beq $t6, 32, store_matrix_value #if $t6 = space -> store the value
beq $t8, $t0, start_padding
beq $t6 , 46, float_calculate
beq $t6, 45, negative_cal #cal neg
beq $t6, 0, store_matrix_value #if $t6 = null end loop
#integer calculate 
sub $t6, $t6, 48 #convert to ascii
mul $t7, $t7, 10 #for multiple digit
add $t7, $t7, $t6 
j next_matrix_char

store_matrix_value:
mtc1 $t7, $f10
cvt.s.w $f10, $f10 
add.s $f10, $f30, $f10
swc1  $f10, image($s0) 
addi $s0, $s0, 4
addi $t0, $t0, 1 
addi $t5, $t5, 1
l.s $f0, zero
l.s $f8, one
l.s $f10, zero
l.s $f30, zero
li $t7, 0 
j matrix

negative_cal:
li $k0, 0
addi $t5, $t5, 1
lb $t6, buffer($t5)
beq $t6, 32, store_matrix_value
beq $t6, 46, neg_float_calculate
sub $t6, $t6, 48
mul $t7, $t7, 10
sub $t7, $t7, $t6
j negative_cal

next_matrix_char:
addi $t5, $t5, 1 
j matrix

float_calculate: 
addi $t5, $t5, 1 
lb $t6, buffer($t5)      # Load next character
beq $t6, 32, store_matrix_value #if $t6 = space -> store the value 
beq $t6, 0, start_padding
sub $t6, $t6, 48
mtc1 $t6, $f0
cvt.s.w $f0, $f0       # Convert the integer in $f0 to a single-precision float
div.s $f8, $f8, $f20 
mul.s $f16, $f8, $f0
add.s $f30, $f16, $f30
j float_calculate

neg_float_calculate:
addi $t5, $t5, 1 
lb $t6, buffer($t5)      # Load next character
beq $t6, 32, trans_negative #if $t6 = space -> store the value 
beq $t6, 0, start_padding
sub $t6, $t6, 48
mtc1 $t6, $f0
cvt.s.w $f0, $f0       # Convert the integer in $f0 to a single-precision float
div.s $f8, $f8, $f20 
mul.s $f16, $f8, $f0
add.s $f30, $f16, $f30
j neg_float_calculate

trans_negative:
l.s $f2, zero 
sub.s $f30, $f2, $f30
j store_matrix_value

j float_calculate
start_padding: 
lw $t1, n 
lw  $t3, p
li $t0, 0 #input in 1 line 
beqz $t3, coppy_from_image
li $t9, 0 #line 
add $t8, $t3, $t1 
add $t3, $t3, $t3 #edge + 2 for each padding
add $t4, $t1, $t3 #padding edge
l.s $f0, zero
li $t6, 0 #index
lw  $t3, p
sub $t2, $t4, $t3
j padding

padding: 
beq $t9, 0, padding_first_row 
bgt $t9, $t2, padding_final_row
beq $t0, $t3, padding_matrix
swc1 $f0, image_padding($s2) 
beq $t0, $t3, padding_matrix
addi $s2, $s2, 4 
addi $t0, $t0, 1 
j padding

padding_first_row: 
beq $t9, $t3  next_line_padding
beq $t0, $t4, next_line_padding_first_row
swc1 $f0, image_padding($s2) 
addi $s2, $s2, 4
addi $t0, $t0, 1 
j padding_first_row

next_line_padding_first_row: 
li $t0, 0
addi $t9, $t9, 1
j padding_first_row

next_line_padding:
li $t0, 0
addi $t9, $t9, 1
j padding

padding_final_row: 
swc1 $f0, image_padding($s2) 
beq $t9, $t4, start_kernel
addi $s2, $s2, 4 
beq $t0, $t4, next_line_padding_final_row
addi $t0, $t0, 1 
j padding_final_row

next_line_padding_final_row:
li $t0, 0
addi $t9, $t9, 1
j padding_final_row

padding_matrix:
lwc1 $f1, image($s3)
swc1 $f1, image_padding($s2) 
beq $t0, $t8, add_zero_inback
addi $s2, $s2, 4
addi $s3, $s3, 4
addi $t0, $t0, 1 
j padding_matrix

add_zero_inback:
beq $t0, $t4, next_line_padding
swc1 $f0, image_padding($s2) 
addi $s2, $s2, 4
addi $t0, $t0, 1 
j add_zero_inback

coppy_from_image:
beq $t0, $t1, start_kernel
lw $t1, n  
mul $t1, $t1, $t1 
lwc1 $f1, image($s3)
swc1 $f1, image_padding($s2) 
addi $s2, $s2, 4
addi $s3, $s3, 4
addi $t0, $t0, 1 
j coppy_from_image

start_kernel:
     li $t0, 0 #number of input added 
     l.s $f20, ten
     l.s $f8, one 
     lw $t1, m 
     mul $t1, $t1, $t1
     addi $t5, $t5, 2
     la $s3, kernel
kernel_matrix:
lb $t6, buffer($t5) 
beq $t1, $t0, conv
beq $t6, 32, store_matrix_value_kernel
beq $t6 , 46, float_calculate_kernel
beq $t6, 45, negative_cal_kernel #cal neg
beq $t6, 0, store_matrix_value_kernel #if $t6 = null end loop
#integer calculate 
sub $t6, $t6, 48 #convert to ascii
mul $t7, $t7, 10 #for multiple digit
add $t7, $t7, $t6 
j next_kernel_matrix

next_kernel_matrix:
addi $t5, $t5, 1
j kernel_matrix

store_matrix_value_kernel:
mtc1 $t7, $f10
cvt.s.w $f10, $f10 
add.s $f10, $f30, $f10
swc1  $f10, 0($s3) 
addi $s3, $s3, 4
addi $t0, $t0, 1 
addi $t5, $t5, 1
l.s $f0, zero
l.s $f8, one
l.s $f30, zero
l.s $f10, zero
li $t7, 0 
j kernel_matrix

float_calculate_kernel: 
addi $t5, $t5, 1 
lb $t6, buffer($t5)      # Load next character
beq $t6, 32, store_matrix_value_kernel #if $t6 = space -> store the value 
beq $t6, 0, conv
sub $t6, $t6, 48
mtc1 $t6, $f0
cvt.s.w $f0, $f0       # Convert the integer in $f0 to a single-precision float
div.s $f8, $f8, $f20 
mul.s $f16, $f8, $f0
add.s $f30, $f16, $f30
j float_calculate_kernel

negative_cal_kernel:
li $k0, 0
addi $t5, $t5, 1
lb $t6, buffer($t5)
beq $t6, 32, trans_negative_kernel
beq $t6, 46, float_calculate_kernel_neg
sub $t6, $t6, 48
mul $t7 ,$t7, 10
sub $t7, $t7, $t6
j negative_cal_kernel

float_calculate_kernel_neg: 
addi $t5, $t5, 1 
lb $t6, buffer($t5)      # Load next character
beq $t6, 32, trans_negative_kernel #if $t6 = space -> store the value 
beq $t6, 0, conv
sub $t6, $t6, 48
mtc1 $t6, $f0
cvt.s.w $f0, $f0       # Convert the integer in $f0 to a single-precision float
div.s $f8, $f8, $f20 
mul.s $f16, $f8, $f0
add.s $f30, $f16, $f30
j float_calculate_kernel_neg

trans_negative_kernel:
l.s $f2, zero 
sub.s $f30, $f2, $f30
j store_matrix_value_kernel

conv:
    lw $t1, n              # size of image
    lw $t2, m              # size of kernel
    lw $t3, p              # Load padding
    lw $t4, s              # Load stride

    mtc1 $t4, $f20 
    cvt.s.w $f20, $f20 
    mtc1 $t2, $f22
    cvt.s.w $f22, $f22
    add $t1, $t1, $t3 #size = n + p 
    add $t1, $t1, $t3 #size = n + 2p
      mtc1 $t1, $f27
    cvt.s.w $f27, $f27
    lw $t1, n              # size of image
    lw $t2, m              # size of kernel
    lw $t3, p              # Load padding
    lw $t4, s              # Load stride
  #output size 
  li $t5,0 #size=0 
  add $t5, $t5, $t1 #size=N
  add $t3, $t3, $t3 #2p 
  add $t5, $t5, $t3 #size= N + 2p 
  sub $t5, $t5, $t2 #size= N + 2p - M 
  div $t5, $t5, $t4 #size = (N +2p -M)/s 
  mflo $t5
  addi $t5, $t5, 1 #size = (N +2p -M)/s + 1
  l.s $f1, zero #  rowOutput
  mtc1 $t5, $f9 # size Output
  cvt.s.w $f9, $f9 
  mtc1 $t2, $f11 #size Kernel 
  cvt.s.w $f11, $f11 
    l.s $f4, zero 		   #kpaddedImagecol
    l.s $f6, zero 		   # paddedImageRow
    la $s1, kernel 
    la $s2, outputmatrix
    la $s6, kernel
    la $s7, outputmatrix 
  #forRow
loop_rowOutput:
c.lt.s $f1, $f9  #if i >= sizeOutput -> endprogram
bc1f end_program 
l.s $f3, zero # colOutput = 0

loop_colOutput:
c.lt.s $f3, $f9
bc1f end_rowOutput 
l.s $f0, zero #conv_sum=0 
l.s $f5, zero # rowKernel=0

loop_rowKernel:
c.lt.s $f5, $f11 
bc1f end_rowKernel
l.s $f7, zero  #colKernel

loop_colKernel:
c.lt.s  $f7, $f11 
bc1f end_colKernel
# calculate paddedImageRow
mul.s $f4, $f1, $f20 #paddedImageRow= RowOutput*stride
add.s $f4, $f4, $f5 #paddedImageRow= RowOuput*stride + RowKernel 
#calculate paddImageCol
mul.s $f6, $f3, $f20 #paddedImageCol= ColOutput*stride + ColKernel
add.s $f6, $f6, $f7 
#calculate Image Index
mul.s $f10, $f4, $f27 #Index_image = paddedimageRow*padded_imagesize
add.s $f10, $f10, $f6 #Index_image = paddedimageRow*padded_imagesize + paddedimageCol
cvt.w.s $f10, $f10 
mfc1 $t7, $f10
mul $t8, $t7, 4 
add $s0, $s4, $t8
lwc1 $f12, image_padding($s0)

#calculate KernelIndex=rowKernel * kernelSize + colKernel
mul.s $f14, $f5, $f11 
add.s $f14, $f14, $f7 

#load kernel 
cvt.w.s $f14, $f14 
mfc1 $t7, $f14
mul $t7, $t7, 4  
add $s1, $s6, $t7
lwc1 $f16, 0($s1)
#cal convolution 
mul.s $f18, $f16, $f12
add.s $f0, $f0, $f18
l.s $f29, one 
add.s $f7, $f7, $f29 
j loop_colKernel 

end_colKernel:
#increase rowKernel
l.s $f29, one 
add.s $f5, $f5, $f29 
j loop_rowKernel

end_rowKernel:
#calculate Output Index 
mul.s $f24, $f1, $f9 #index=output_Row*outputsize
add.s $f24, $f24, $f3 #index=output_row*output_size + index 

#store_output
cvt.w.s $f24, $f24 
mfc1 $t7, $f24 
mul $t7, $t7, 4 
add $s2, $s7, $t7 
l.s $f13, ten           
mul.s $f15, $f0, $f13    
l.s $f14, half             
add.s $f16, $f15, $f14       
trunc.w.s $f17, $f16        
cvt.s.w $f18, $f17          
    div.s $f0, $f18, $f13       
swc1 $f0, 0($s2)
l.s $f29, one
add.s $f3, $f3, $f29 
j loop_colOutput

end_rowOutput:
    # increase rowOutput
    l.s $f29, one
    add.s $f1, $f1, $f29
    j loop_rowOutput  
end_program:

la $s0, outputmatrix
la $s1, save
l.s $f0, zero
l.s $f1, zero #counter 
l.s $f2, ten
l.s $f3, zero
l.s $f4, zero
l.s $f5, one 
li $t0, 0
li $t5, 0
li $t3, 0
li $t7,0
li $t9,0
mul.s $f9, $f9, $f9

print:
li $t1, 32
li $t2, 1
lwc1 $f0, 0($s0)
c.eq.s $f1, $f9
bc1t end
c.lt.s $f0, $f3
bc1f print_positive
bc1t print_negative


print_positive:
#take the float part 
mul.s $f0, $f0, $f2 
cvt.w.s $f0, $f0
mfc1 $t0, $f0 
div $t0, $t0, 10
add $t3, $t3, $t0
mfhi $t6 
addi $t6, $t6, 48
	check_amount_of_number: 
	div $t3, $t3, 10
	beqz $t3, convert 
	mul $t2, $t2, 10
	j check_amount_of_number
	convert: 
	beqz $t2, save_float
	div $t8, $t0, $t2 
	addi $t7, $t8, 48
	sb $t7, 0($s1) 
	mul $t8, $t8, $t2
	sub $t0, $t0, $t8
	addi $s1, $s1, 4
	div $t2, $t2, 10
	j convert
	save_float: 
	li $t4 ,46
	sb $t4, 0($s1) 
	addi $s1, $s1, 4 
	#float_part 
	sb $t6, 0($s1) 
	j next_num
print_negative:
#take the float part 
mul.s $f0, $f0, $f2 
cvt.w.s $f0, $f0
mfc1 $t0, $f0 
sub $t0, $t5, $t0 #change to possitive
div $t0, $t0, 10
add $t3, $t3, $t0
mfhi $t6 
addi $t6, $t6, 48
#save "-"
li $t4, 45
sb $t4, 0($s1) 
addi $s1, $s1, 4 
	check_amount_of_number_neg: 
	div $t3, $t3, 10
	beqz $t3, convert 
	mul $t2, $t2, 10
	j check_amount_of_number_neg
	convert_neg: 
	beqz $t2, save_float_neg
	div $t8, $t0, $t2 
	addi $t7, $t8, 48
	sb $t7, 0($s1) 
	mul $t8, $t8, $t2
	sub $t0, $t0, $t8
	addi $s1, $s1, 4
	div $t2, $t2, 10
	j convert_neg
	save_float_neg: 
	li $t4 ,46
	sb $t4, 0($s1) 
	addi $s1, $s1, 4 
	#float_part 
	sb $t6, 0($s1) 
	j next_num
next_num:
	li $t4, 32
	addi $s1, $s1, 4
	sb $t4, 0($s1)
	addi $s1, $s1, 4
	addi $t9, $t9, 1
	#add space 
	add.s $f1, $f1, $f5
	addi $s0, $s0, 4
	j print
end:
la $s3, save
la $t7, out
l.s $f5, one
l.s $f0, zero
l.s $f10, four
 li  $v0, 13 
la $a0, output
li $a1, 1
li $a2, 0
li $t8, 1
syscall
move $s6, $v0
#open file 
cvt.w.s $f10, $f9
mfc1 $t9, $f10

save_val:
beq $t8, $zero, pre_print
lb $t8, 0($s3)
addi $s3, $s3, 4
sb $t8, 0($t7)
addi $t7, $t7, 1
j save_val 
pre_print:
la $a0, out
move $a1, $a0
li $t0, 0
li $t9, 0

count_loop1:
lb $t1, 0($a0)
addi $a0, $a0, 1
addi $t0, $t0, 1
bnez $t1, count_loop1

reverse_end_loop:
li $v0, 15
move $a0, $s6
la $a1, out 
move $a2, $t0
syscall


done: 
li $v0, 10 
syscall

#check if size of image matrix less than kernel
checksize:
li $v0, 13
la $a0, output
li $a1, 1
la $a2, 0
syscall
move $s6, $v0

li $v0, 15  
move $a0, $s6 
la $a1, error
li $a2, 22
syscall
li $v0, 10 
syscall 