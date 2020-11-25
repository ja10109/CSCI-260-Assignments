#Jason Cho
#CS 260 Project 1
.data
frameBuffer:	.space	0x80000 #512 wide x 256 high pixels
m: 		.word 	40
n: 		.word 	80
c1r: 		.word 	0xFF
c1g: 		.word	0xFF
c1b:		.word	0x0
c2r:		.word 	0x0
c2g:		.word 	0x0
c2b:		.word 	0xFF
c3r:		.word 	0xFF
c3g:		.word 	0x0
c3b:		.word 	0x0

.text 
lw $s0,m                # load m
lw $s1,n                # load n

#if M or N is out of range go to exit
beq $s0, $zero, Exit
beq $s1, $zero, Exit

add $s2, $s0, $s1	#s2 = m+n
addi $s3, $zero, 256	#s3 = 256
slt $t1, $s2, $s3	#t1 = 1 if (m+n) < 256
beq $t1, $zero, Exit	#if t1 = 0 (m+n) > 256 go to Exit

# check whether n is odd
checkN:
andi $t2,$s1, 1		#mask shift t2 = n to test if its odd
bne $t2,$zero,oddN	#if n % 2 == 1 go to oddN
j start			#else jump to start


oddN:                   # if n is odd, increment n by 1
add $s1,$s1,1 #t1= n++
sw $s1,n #store n

start:
la $t0, frameBuffer	#512x256
addi $t4, $t0, 524288	#set t4 as final pixel of the grid


#LOAD C1
C1:
la $t1, c1r		#t1 = load address of c1r
lw $t1, c1r		#t1 = c1r
la $t2, c1g		#t2 = load address of c1g
lw $t2, c1g		#t2 = c1g
la $t3, c1b		#t3 = load address of c1b
lw $t3, c1b		#t3 = c1r
sll $t1, $t1, 16	#shift red component
sll $t2, $t2, 8		#shift green component
or $t1, $t1,$t2		#t1 = t1 + t2
or $t1, $t1, $t3	#t1 = t1 + t2 + t3

#li $t1, 0x0000FFFF

loopC1:
beq $t0, $t4, exitLoop	#if reaches the final pixel go to ExitLoop
sw $t1,0($t0)		#fill in C1
addi $t0,$t0,4		#move to next pixel
j loopC1
exitLoop:

#sets up the horizontal rectangle starting from x = (512-(2m+n))/2 to 2m+n as the rows
#y = (256-n)/2 to n as the columns 
Horizontal_Rectangle:
li $t1,256		    #t1 = 256        
sub $t1,$t1,$s1 	    #t1 = 256-n       
srl $t2,$t1,1               #t2 = (256-n)/2 = y value
li $t1,512		    #t1 = 512        
sll $t3,$s0,1		    #t3 = 2m
add $t3,$t3,$s1             #t3 = 2m+n
sub $t1,$t1,$t3		    #t3 = 512 - 2m+n
srl $t4,$t1,1               #t4 = (512-(2m+n))/2 = x

add $a0,$t4,$zero          # pass starting x value
add $a1,$t3,$zero          # pass width(2m+n)
add $a2,$t2,$zero          # pass starting y value
add $a3,$s1,$zero          # pass height(n)

#LOAD C2
C2:
la $t1, c2r		#t1 load address of c2r
lw $t1, c2r		#t1 = c2r
la $t2, c2g		#t2 load address of c2g
lw $t2, c2g		#t2 = c2g
la $t3, c2b		#t3 load address of c2b
lw $t3, c2b		#t3 = c2b
sll $t1, $t1, 16	#shift red component
sll $t2, $t2, 8		#shift green component
or $t1, $t1,$t2		#t1 = t2+t3
or $t1, $t1, $t3	#t1 = t1 + t2 + t3

jal DRAW_SHAPE          #call function DRAW_SHAPE to draw horizontal rectangle

#sets up the vertical rectangle with (512-n)/2 as the starting x value to n
#(256-(2m+n)/2 as the starting y value to (2m+n)
VERTICAL_RECTANGLE:
li $t2,512		#t2 = 512, cant use t1 because it has C2 color
sub $t2,$t2,$s1		#t2 = 512 - n
srl $t3,$t2,1           #t3=(512-n)/2= x
li $t2,256		#t2 = 256
sll $t4,$s0,1		#t4 = 2m
add $t4,$t4,$s1         #t4 = 2m+n
sub $t2,$t2,$t4		#t2 = 256 - 2m+n
srl $t5,$t2,1           #t5 = (256-(2m+n))/2 = y

add $a0,$t3,$zero       # pass starting x value
add $a1,$s1,$zero       # pass width(n)
add $a2,$t5,$zero       # pass starting y value
add $a3,$t4,$zero       # pass height(2m+n)

jal DRAW_SHAPE          #call function DRAW_SHAPE to draw vertical rectangle

#sets up the box that fits inside the two previous rectangles
#starting x value = (512-n)/2 to n
#starting y value = (256-n)/2 to n
INNER_BOX:
li $t1,512		#t1 = 512
sub $t1,$t1,$s1		#t1 = 512-n
srl $t2,$t1,1           #t2 = (512-n)/2= x
li $t3,256		#t3 = 256
add $t4,$zero,$s1       #t4 = n
sub $t4,$t3,$t4		#256-n
srl $t5,$t4,1           #t3= (256-n)/2=y

add $a0,$t2,$zero       # pass starting x value
add $a1,$s1,$zero       # pass width(n)
add $a2,$t5,$zero       # pass starting y value
add $a3,$s1,$zero       # pass height(n)

#LOAD C3
C3:
la $t1, c3r		#t1 address of c3r
lw $t1, c3r		#t1 = c3r
la $t2, c3g		#t2 address of c3g
lw $t2, c3g		#t2 = c3g
la $t3, c3b		#t3 address of c3b
lw $t3, c3b		#t3 = c3b
sll $t1, $t1, 16	#shift red component
sll $t2, $t2, 8		#shift green componenet
or $t1, $t1,$t2		#t1 = t1+t2
or $t1, $t1, $t3	#t1 = t1+t2+t3

jal DRAW_SHAPE          # draw center box

Exit:
li $v0,10        
syscall                 # exit the program


#Function fills in C2 boxes and C3 box in middle
#Function takes in paramaters a0,a1,a2,a3(x,width,y,height)
#Then sets up two loops where that fills in the shape while x increments till it reaches width
#then x resets as y increments and fills in the color till y reaches height paramter
DRAW_SHAPE:
#if height or width is 0 exit the function
beq $a1,$zero, exit_function
beq $a3,$zero, exit_function

la $t0,frameBuffer       #reset frameBuffer
add $a1,$a1,$a0          #pass starting x value based width
add $a3,$a3,$a2          #pass starting y value based off height

#scale x values by 4 bytes in the width
sll $a0,$a0,2
sll $a1,$a1,2		 

#scale y values by 1024 bytes in the height of the function
sll $a2,$a2,11
sll $a3,$a3,11

add $t2,$a2,$t0         #t2 = row starting addresses
add $a2,$t2,$a0         #a2 = y starting point of shape

#set end location of shape
add $a3,$a3,$t0		#a3 = end y value of frameBuffer  
add $a3,$a3,$a0         #a3 = end y value of frameBuffer and end x value

li $t3,512              #load t3 = 512
sll $t3, $t3, 2		#t3 = 512x4 =2048
add $t2,$t2,$a1         #end location of rows

#first loop goes through the rows
loop1:
add $t4,$a2, $zero      #t4 = starting x value
   
#second loop fills each rows and determines whether row is filled
loop2:
sw $t1,($t4)       	#fill color in t4
addi $t4,$t4,4          #t4 to next pixel in row
bne $t4,$t2,loop2       #if t4 cuurent row pixel != t2 end row pixel stay in loop 2
add $a2,$a2,$t3         #else a2 = a2+t3 next row
add $t2,$t2,$t3         #t2 = t2+t3 end position of row
bne $a2,$a3,loop1       #if a2 != a3(end position) go back to loop1

#once both loops are executed go back  
exit_function:
jr $ra                  #return
