//Author: Mohammed Hossain
//File: Assignment 6
//-----------------------------------------------------------------------------
//varaibles
define(value_r, w19)						//value
define(argc_r, w21)						//argc
define(argv_r, x22)						//argv
define(fd_r, w20)						//fd
define(buf_base_r, x23)						//buf base address
define(nread_r, x24)						//variable read
define(base_r, x25)

define(power_r, d19)						//exponent
define(num_r, d20)						//numerator
define(fact_r, d21)						//denominator (n!)
define(equals_r, d22)						//equals = num / denominator
define(total_r, d23)						//total = 1 + equals + ...
define(increment, d24)						//increment
define(stop_r, d25)						//to hold stop value
define(temp_r, d26)						//hold temp var
//------------------------------------------------------------------------------
	.data
stop_m:			.double 0r1.0e-10			//constant value
conversion_m:		.double 0r1.57079632679489661923	//constant coversion value pi/2
change_m:		.double 0r90.0
//-----------------------------------------------------------------------------
//text
	.text
abort_str:              .string "can't open file for writing. Aborting.\n"
notopen_str:           	.string "Error: Incorrect number of arugmnets\n"

header_str:		.string "Input:\t\tsin(x):\t\tcos(x)\n"
value_str:		.string "%.2f deg\t%.10f\t%.10f\n"
//----------------------------------------------------------------------------
//equates
buf_size = 8
buf_s = 16

alloc = -(16 + buf_size) & -16
dealloc = -alloc
//----------------------------------------------------------------------------
fp	.req	x29
lr	.req	x30

	.global main
	.balign 4
main:
	stp	fp, lr, [sp, alloc]!				//allocate memory for main()
	mov	fp, sp

	mov	argc_r, w0					//copy argc: # of elements in array
	mov	argv_r, x1					//copy argv; base address of the array
	cmp	argc_r, 2					//compare # of arguments
	b.eq	continue					//if equal then continue the program

	ldr	x0, =notopen_str				//if not equal then print notopen
	bl	printf
	b	end

continue:
	mov	w0, -100					//1st arg (use cwd)
	ldr	x1, [argv_r, 8]					//2nd arg (pathname)
	mov	w2, 0						//3rd arg (read only)
	mov	w4, 0						//4th arg (not used)
	mov	x8, 56						//openat I/O request
	svc	0

	mov	fd_r, w0
	cmp	fd_r, 0						//error check

	b.ge	continue2


	ldr	x0, =abort_str
	bl	printf
	mov	w0, -1						//return -1
	b	end						//exit program

continue2:
	//print header
	ldr	x0, =header_str
	bl	printf

	add     buf_base_r, fp, buf_s                           //calc base address of buf

top:
	mov	w0, fd_r					//arg 1:read
	mov	x1, buf_base_r					//arg 2: buf
	mov	w2, buf_size					//arg 3: n
	mov	x8, 63						//read I/O request
	svc	0						//call system function

	mov	nread_r, x0					//record bytes read

	//check if read properly
	cmp	nread_r, buf_size
	b.ne	close

	//convert x degree to radians
	ldr	d0, [buf_base_r]				//load x value
	ldr	base_r, =change_m				//get address
	ldr	d16, [base_r]					//load 90


	fdiv	d1, d0, d16					// x/90

	ldr	base_r, =conversion_m				//get conversion address
	ldr	d17, [base_r]					//load conversion in d17
	fmul	d0, d1, d17					// (x/90) * (pi/2)

	//calc sin and cos
		bl	sin_calc				//bl sin calculation
	//value returened in d1

	bl	cos_calc					//bl sin calculation
	//value returned in d2

	//print values
	ldr	x0, =value_str
	ldr	d0, [buf_base_r]
	bl	printf

	b	top
close:								//close file
	mov	w0,fd_r						//fd 1st arg
	mov	x8, 57						//close I/O request
	svc	0						//call system func
	mov	w0, 0						//return 0

end:
	ldp	fp, lr, [sp], dealloc				//deallocate mem for main
	ret
//-------------------------------------------------------------------------------
//sin(x)
	.global sin_calc
	.balign 4
sin_calc:
	stp     fp, lr, [sp, -16]!                    		//allocate memory for main()
        mov     fp, sp

	ldr	base_r, =stop_m					//get address of constant (1.0e-10)
	ldr	stop_r, [base_r]				//store stop value

	fmov	power_r, 3.0					//power = 3.0
	fmov	increment, 1.0					//incremnet = 1.0
	fmov	total_r, d0					//total_r = x

	//x^3
	fmov	num_r, d0					//num = x
	fmul	num_r, num_r, d0				//num = x^2
	fmul	num_r, num_r, d0				//num = x^3

	fmov	fact_r, 6.0					//fact = 6 --> starting denom value is 3! = 6
	fdiv	equals_r, num_r, fact_r				//equals = num / fact
	fneg	equals_r, equals_r				//-(equals)
	fadd	total_r, total_r, equals_r			//total += term

loop:
	fcmp	equals_r, 0.0					//compare equals and 0
	b.gt	sub						//if it positive value than alternate to sub

	fmul	num_r, num_r, d0				//num = num * x
	fmul	num_r, num_r, d0				//increment a second time beacuse each terms exponent
								//increments by 2
	fadd	power_r, power_r, increment			//power = power + 1

	fmul	fact_r, fact_r, power_r				//do previous n! x n+1
	fadd	power_r, power_r, increment			//n! is incremented by 2 so have to multiply one more time
	fmul	fact_r, fact_r, power_r				//do previous n! x n+1

	fdiv	equals_r, num_r, fact_r				//equals = num / fact
	fadd	total_r, total_r, equals_r			//total = total + equals

	b	compare						//compare constent given with new term
sub:
        fmul    num_r, num_r, d0                                //num = num * x
        fmul    num_r, num_r, d0                                //increment a second time beacuse each terms exponent
                                                                //increments by 2
        fadd    power_r, power_r, increment                     //power = power + 1

        fmul    fact_r, fact_r, power_r                         //do previous n! x n+1
        fadd    power_r, power_r, increment                     //n! is incremented by 2 so have to multiply one more time
	fmul    fact_r, fact_r, power_r				//do previous n! x n+1

        fdiv    equals_r, num_r, fact_r                         //equals = num / fact
      	fneg	equals_r, equals_r				//negate the term to for subtraction
	fadd    total_r, total_r, equals_r                      //total = total + equals

compare:
	//compare newest terms if less than 1.0e-10
	fabs	temp_r, equals_r				//compare the abs value with const
	fcmp	temp_r, stop_r					//if equals >= contant
	b.ge	loop

	fmov	d1, total_r					//d0 = total

        ldp     fp, lr, [sp], 16                           	//deallocate mem for main
        ret
//-------------------------------------------------------------------------------
//cos(x)
        .global cos_calc
        .balign 4
cos_calc:
        stp     fp, lr, [sp, -16]!                              //allocate memory for sin()
        mov     fp, sp

        ldr     base_r, =stop_m                                 //get address of constant (1.0e-10)
        ldr     stop_r, [base_r]                                //store stop value

        fmov    power_r, 2.0                                    //power = 2.0
        fmov    increment, 1.0                                  //incremnet = 1
        fmov    total_r, 1.0                                    //total_r = x

        //x^3
        fmov    num_r, d0                                       //num = x
        fmul    num_r, num_r, d0                                //num = x^2

        fmov    fact_r, 2.0                                     //fact = power
        fdiv    equals_r, num_r, fact_r                         //equals = num / fact
        fneg    equals_r, equals_r
        fadd    total_r, total_r, equals_r                      //total += term

loop_c:
        fcmp    equals_r, 0.0					//compare terms with zero to se if its pos or neg
        b.gt    sub_c						//if terms is positive then swap to sub

        fmul    num_r, num_r, d0                                //num = num * x
        fmul    num_r, num_r, d0                                //increment a second time beacuse each terms exponent
                                                                //increments by 2
        fadd    power_r, power_r, increment                     //power = power + 1

        fmul    fact_r, fact_r, power_r                         //do previoius n! x n+1
        fadd    power_r, power_r, increment                     //n! is incremented by 2 so have to multiply one more time
        fmul    fact_r, fact_r, power_r				//do previous n! x n+1

        fdiv    equals_r, num_r, fact_r                         //equals = num / fact
        fadd    total_r, total_r, equals_r                      //total = total + equals

        b       compare_c					//compare with constant
sub_c:
        fmul    num_r, num_r, d0                                //num = num * x
        fmul    num_r, num_r, d0                                //increment a second time beacuse each terms exponent
                                                                //increments by 2
        fadd    power_r, power_r, increment                     //power = power + 1

        fmul    fact_r, fact_r, power_r                         //do previous n! x n+1
        fadd    power_r, power_r, increment                     //n! is incremented by 2 so have to multiply one more time
        fmul    fact_r, fact_r, power_r				//do previous n! x n+1

        fdiv    equals_r, num_r, fact_r                         //equals = num / fact
        fneg    equals_r, equals_r				//negate the terms for subtraction
        fadd    total_r, total_r, equals_r                      //total = total + equals

compare_c:
        //compare newest terms if less than 1.0e-10
        fabs    temp_r, equals_r
        fcmp    temp_r, stop_r                                  //if equals >= contant
        b.ge    loop_c

        fmov    d2, total_r                                     //d0 = total

        ldp     fp, lr, [sp], 16                                //deallocate mem for main
        ret
//-------------------------------------------------------------------------------
