#Jason Cho CSCI 260 Project 2
.data
a: .byte 0 #a can be from 0 to 99
b: .byte 12 #b can be from 0 to 99

.text
#MAIN FUNCTION
#load a and b
#if (a > b) or (a < 0) or (b > 99) EXIT
#increment b to b+1
#divide a = a/10, s3 = quotient (a/10), s4 = remainder (a%10)
#WHILE (a < b+1)
#	if(remainder == 10)
#		quotient++
#		remainder = 0
#	if(a < 10) 
#		display(1,a)
#		delay()
#		a++
#		remainder++
#
#	else
#		display(0,quotient)
#		display(1,remainder)
#		delay()
#		a++
#		remainder++
main:
lb $s0, a #load A
lb $s1, b #load B


#if a or b < 0 ->EXIT
slt $t0, $s0, $zero #t0 = 1 if a < 0, t0 = 0 if a > 0
bne $t0, $zero, EXIT #if t0 != 0 (a <= 0) EXIT
slt $t1, $s1, $zero #t1 = 1 if b < 0, t0 = 0 if b > 0
bne $t1, $zero, EXIT #if t1 !=0 (b <= 0) EXIT

#if a or b > 99 ->EXIT
addi $t0, $zero, 99 #t0 = 99
slt $t1, $t0, $s0 #if(99 < a) t1 = 1, else t1 = 0
bne $t1, $zero, EXIT #if t1 != 0 (a > 99) EXIT
slt $t1, $t0, $s1 #if(99 < b) t1 = 1, else t1 = 0
bne $t1, $zero, EXIT #if t1 !=0 (b > 99) EXIT

addi $s1, $s1, 1 #b = b+1, so a would also increment to the original b value

#if a > b -> EXIT
slt $t0, $s0, $s1 #t1 = 1 if a < b, t0 = 0 if a > b
beq $t0, $zero, EXIT #if a > b, EXIT

addi $s2, $zero, 10 #s2 = 10
div $s0, $s2 #a = a/10
mfhi $s3 #s3 = REMAINDER
mflo $s4 #s4 = QUOTIENT
#if starting a = 31, $s3 = 31/10 = 1, $s4 = 31/10 = 3

loop:
#FORCES a to increment till it reaches b
#WHILE(a <= b)
beq $s0, $s1, EXIT #if a == b ->EXIT, program is done

#if a < 10, branch to display_right
slti $t1, $s0, 10 #if s0 (a) < 10, t1 = 1
bne $t1, $zero, display_right #if t1 == t2, branch to display_right

#if s3 == 10, set quotient s4++ and remainder s3 = 0
addi $t4, $zero, 10 #t4 = 10
bne $t4, $s3, next #if s3 != 10, move on
addi $s4, $s4, 1 #s4++
add $s3, $zero, $zero #s3 = 0
		
next:
		
display_left:
#display(0,quotient)
add $a0, $zero, $zero #pass LED VALUE a0 = 0 for LEFT
add $a1, $s4, $zero #pass QUOTIENT value, quotient value increments after remainder 9++
jal display
	
display_right:
#display(1,remainder)
addi $a0, $zero, 1 #pass LED VALUE a0 = 1 for RIGHT
add $a1, $s3, $zero #pass display value a1 = a
jal display
jal delay
				
addi $s0, $s0, 1 #a++
addi $s3, $s3, 1 #remainder value++
bne $s0, $s1, loop #if a < b go back to main

EXIT:
li $v0, 10
syscall

#DISPLAY FUNCTION(led,digit)
#convert DIGIT INPUT to proper HEX value
#if LED == 0, store HEX value onto LEFT light addr.
#if LED == 1, store HEX value onto RIGHT light addr.
display:
#STORE STACK POINTER
addi $sp, $sp, -12 #PUSH three registers on stack
sw $ra, 8($sp) #save return address
sw $a0, 4($sp) #save LED input
sw $a1, 0($sp) #save DIGIT input

#SET DIGIT TO APPROPRIATE HEX VALUE
#IF DIGIT INPUT == t0, branch to corresponding HEX value
add $t0, $zero, $zero
beq $a1, $t0, zero

addi $t0, $zero, 1
beq $a1, $t0, one

addi $t0, $zero, 2
beq $a1, $t0, two

addi $t0, $zero, 3
beq $a1, $t0, three

addi $t0, $zero, 4
beq $a1, $t0, four

addi $t0, $zero, 5
beq $a1, $t0, five

addi $t0, $zero, 6
beq $a1, $t0, six

addi $t0, $zero, 7
beq $a1, $t0, seven

addi $t0, $zero, 8
beq $a1, $t0, eight

addi $t0, $zero, 9
beq $a1, $t0, nine

#SET t8 to HEX VALUE and Jump to LIGHT
zero:
li $t8, 0x3F
j LIGHT

one:
li $t8, 0x06
j LIGHT

two:
li $t8, 0x5B
j LIGHT

three:
li $t8, 0x4F
j LIGHT

four:
li $t8, 0x66
j LIGHT

five:
li $t8, 0x6D
j LIGHT

six:
li $t8, 0x7D
j LIGHT

seven:
li $t8, 0x07
j LIGHT

eight:
li $t8, 0x7F
j LIGHT

nine:
li $t8, 0x6F
j LIGHT

#check LED input value
LIGHT:
beq $a0, $zero, LEFT_LED #goto left_led if a0 = 0
addi $t7, $zero, 1 #t7 =1
beq $a0, $t7, RIGHT_LED #goto right_led if a0 = 1

#if led = 0, store byte in LEFT LED addr. 0xFFFF0011
LEFT_LED:
la $t9, 0xFFFF0011
sb $t8, 0($t9)

lw $a1, 0($sp) #restore DIGIT
lw $a0, 4($sp) #restore LED
lw $ra, 8($sp) #restore return address
addi $sp, $sp, 12 #adjust stack ptr

jr $ra #return to main

#if led = 1,store byte in RIGHT LED addr. 0xFFFF0010
RIGHT_LED:
la $t9, 0xFFFF0010
sb $t8, 0($t9)

lw $a1, 0($sp) #restore DIGIT
lw $a0, 4($sp) #restore LED
lw $ra, 8($sp) #restore return address
addi $sp, $sp, 12 #adjust stack ptr

jr $ra #return to main

#delay loop
delay:
addi $s5, $zero, 400000 #s5 = 400,000 loop
add $s6, $zero, $zero #s6 = 0
delay_loop:
addi $s6, $s6, 1 # s6++
bne $s5, $s6, delay_loop #return to loop if s5 != s6
exit_delay:
jr $ra #return to main
