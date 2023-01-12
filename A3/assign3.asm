//File:assign3.asm
//Author: Mohammed Hossain

//print statment for array
outPut_str:	.string "V[%d]: %d\n"
//print statment
sorted_str:	.string "\nSorted array:\n"

define(i_r, w19)
define(j_r, w20)
define(temp_r, w21)
define(rando_r, w22)


//set SIZE = 40
size = 40

//4 bytes fo the for  variables
i_size = 4
j_size = 4
temp_size = 4
array_size = size * 4						//array * 4 for each int

base_size = 16


//offset for variable and array
i_off = base_size						//16
j_off = i_off + 4						//20
temp_off = j_off + 4						//24
array_off = temp_off + 4					//28

allocate = -(base_size + i_size + j_size + temp_size  + array_size) & -16
deallocate = -allocate

fp	.req	x29
lr	.req	x30

	.balign 4						//i_rnstuction address is div by 4
	.global main						//main lable visible

main:
	stp	fp, lr, [sp, allocate]!				//save Frame pointer and Link registers to the stack
	mov	fp, sp						//update fp to the top of the stack

//-----------------------------------------------------------------------------------------------
//initialize array to random positve integers
loop1:
	bl 	rand						//generate a 4 byte random number
	and	rando_r, w0, 0xFF				//store rand variable in rando_r

	ldr	i_r, [fp, i_off]				//load i_r
	add	x0, fp, array_off				//calc base address
	str	rando_r, [x0, i_r, SXTW 2]			//store random value to index i

	//print
	ldr	x0, =outPut_str
	ldr	w1, [fp, i_off]
	mov	w2, rando_r
	bl	printf

	//increment i++
	ldr	i_r, [fp, i_off]
	add	i_r, i_r, 1
	str	i_r, [fp, i_off]

test_loop1:
	ldr	i_r, [fp, i_off]				//load index value from stack
	cmp	i_r, size

	b.lt	loop1

//------------------------------------------------------------------------------------------------
//sort the array using a bubble sort

	//initialize i value to  i = size -1
	mov	i_r, 39						//set i = 40 - 1 = 39
	str	i_r, [fp, i_off]

outerloop:
	//set j = 1
	ldr	j_r, [fp, j_off]
	mov	j_r, 1
	str	j_r, [fp, j_off]

	bl	inner_test

innerloop:
	//compare elements
	//load v[j] and v[j-1]

	ldr	j_r, [fp, j_off]
	add	x0, fp, array_off
	ldr	w23, [x0, j_r, SXTW 2]				//store w23 = v[j]

	ldr	j_r, [fp, j_off]
	sub	w24, j_r, 1					// w24 = j-1
	ldr	w25, [x0, w24, SXTW 2]				//store w25 = v[j-1]

	cmp	w23, w25

	b.ge	continue					//if v[j-1] <= v[j] then skip if statment portion
//-----------------------------------------------------------------------------------------------
	//if statment section
	//Swap elements
	ldr	temp_r, [fp, temp_off]
	mov	temp_r, w25
	str	temp_r, [fp, temp_off]				//temp = v[j-1]


	ldr	w26, [x0, j_r, SXTW 2]				// w26 = v[j]


	str	w26, [x0, w24, SXTW 2]				//v[j-1] = w26(v[j])


	str	temp_r, [x0, j_r, SXTW 2]			//temp = v[j]
//--------------------------------------------------------------------------------------------------

continue:

	//increment j
	ldr	j_r, [fp, j_off]
	add	j_r, j_r, 1
	str	j_r, [fp, j_off]

inner_test:
	//compare j and i
	ldr	j_r, [fp, j_off]
	ldr	i_r, [fp, i_off]
	cmp	j_r, i_r

	b.le innerloop

	//decrement i by one
	ldr	i_r, [fp, i_off]
	sub	i_r, i_r, 1
	str	i_r, [fp, i_off]

outer_test:
	ldr	i_r, [fp, i_off]
	cmp	i_r, 0						//compare i to 0
	b.ge	outerloop					//if i>=0 than loop if not then it continues


//--------------------------------------------------------------------------------------------------
//print sorted array
	ldr	x0, =sorted_str
	bl	printf

	ldr	i_r, [fp, i_off]
	mov	i_r, 0
	str 	i_r, [fp, i_off]
printloop:

	ldr	i_r, [fp, i_off]
	add	x0, fp, array_off
	ldr	w28, [x0, i_r, SXTW 2]

	//print
	ldr	x0, =outPut_str
	ldr	w1, [fp, i_off]
	mov	w2, w28
	bl	printf

	//increment i++
	ldr	i_r, [fp, i_off]
	add	i_r, i_r, 1
	str	i_r, [fp, i_off]

Print_test:
	ldr	i_r, [fp, i_off]			//load index value from stack
	cmp	i_r, size

	b.lt	printloop

//--------------------------------------------------------------------------------------------------
	ldp	fp, lr, [sp], deallocate
	ret
