//File:assign4.asm
//Author:Mohammed Hossain
initial_str:   	.string "Initial cuboid value:\n"
changed_str:   	.string "\nChanged cuboid value:\n"

first_str: 	.string "first"
second_str: 	.string "second"

//printCuboid
origin_str:	.string "Cuboid %s origin = (%d,%d)\n"
wh_str:		.string "\tBase width = %d,Base length = %d\n"
height_str:	.string "\tHeight = %d\n"
volume_str:	.string "\tVolume = %d\n\n"

define(True, 1)
define(False, 0)
define(result_r, w19)

//-------------------------------------------------------------------------------------------------
	//offsets for the the point struct
        point_x = 0                             			//offset = 0 bytes (size = 4)
        point_y = 4                             			//offset = 4 bytes (size 4)
        			                			//total size = 8 bytes
        //offsets for the demension struct
      	dimension_width = 0                    				 //offset = 0 bytes (size = 4)
      	dimension_length = 4                   				 //offset = 4 bytes (size = 4)
      				             				 //total size = 8 bytes
        //struct cuboid
        cuboid_origin = 0						//offset = 0 bytes (size = 8)
        cuboid_base = 8							//offset = 8 bytes (size = 8)
        cuboid_height = 16         	       				//offset = 16 bytes (size = 4)
	cuboid_volume = 20						//offset = 20 bytes (size 4)

	cuboid_struct_size = 24						//total size = 24
	//c offset
	cuboid_c = 16							//cuboid.c stored below fp
//-------------------------------------------------------------------------------------------------
fp      .req    x29
lr      .req    x30

        .balign 4
	.global main

        alloc = -(16 + cuboid_struct_size) & -16
        dealloc = -alloc
//-------------------------------------------------------------------------------------------------
//struct cuboid newcuboid
newCuboid:
	stp     fp, lr, [sp, alloc]!					//save fp and lr to stack
        mov     fp, sp              	           			//set fp on top of stack

	add	x9, fp, cuboid_c					//address base of struct cuboid

	//set value of c.origin
	mov     w10, 0
        str     w10, [x9, cuboid_origin + point_x]			//c.origin.x = 0
        str     w10, [x9, cuboid_origin + point_y] 			//c.origin.y = 0

        // set value of c.base
        mov     w10, 2
        str     w10, [x9, cuboid_base + dimension_width]		//c.base.width = 2
        str     w10, [x9, cuboid_base + dimension_length]		//c.base.length = 2

	//set value of c.height
	mov	w10, 3
	str	w10, [x9, cuboid_height]				//c.height = 3

	//set value of c. volume
	ldr	w10, [x9, cuboid_base + dimension_width]		//load c.base.width
	ldr	w11, [x9, cuboid_base + dimension_length]		//load c.base.length
	ldr	w12, [x9, cuboid_height]				//load c.base.length

	mul	w10, w10, w11						//w9 = width * length
	mul	w10, w10, w12						//w9 = (width * length) * height

	str	w10, [x9, cuboid_volume]				//c.volume = w9

	//copy elements into struct into the address pointed to x8
	ldr	w10, [x9, cuboid_origin + point_x]
	str	w10, [x8, cuboid_origin + point_x]

	ldr	w10, [x9, cuboid_origin + point_y]
	str	w10, [x8, cuboid_origin + point_y]

	ldr     w10, [x9, cuboid_base + dimension_width]
	str     w10, [x8, cuboid_base + dimension_width]

	ldr     w10, [x9, cuboid_base + dimension_length]
	str     w10, [x8, cuboid_base + dimension_length]

	ldr     w10, [x9, cuboid_height]
	str     w10, [x8, cuboid_height]

	ldr     w10, [x9, cuboid_volume]
	str     w10, [x8, cuboid_volume]

        ldp     fp, lr, [sp], dealloc
        ret
//--------------------------------------------------------------------------------------------------
//move()
move:
	stp	fp, lr, [sp, alloc]!
	mov	fp, sp

	mov	x15, x3
	//load orgin value x and y
	ldr     w9, [x15, cuboid_origin + point_x]
        ldr     w10, [x15, cuboid_origin + point_y]

	add	w9, w9, w0						//origin.x =+ deltax
	add	w10, w10, w2						//origin.y =+ deltay

	str     w9, [x15, cuboid_origin + point_x]			//store new x value
        str     w10, [x15, cuboid_origin + point_y]			//store new x value

	ldp	fp, lr, [sp], dealloc
	ret
//--------------------------------------------------------------------------------------------------
//scale()
scale:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp

	mov	x15, x3
	//load	dimension and height
        ldr     w9, [x15, cuboid_base + dimension_width]		//load width
        ldr     w10, [x15, cuboid_base + dimension_length]		//load length
        ldr     w11, [x15, cuboid_height]				//load height

	mul	w9, w9, w0						//width *= factor
	mul	w10, w10, w0						//length *= factor
	mul	w11, w11, w0						//height *= factor

	mul	w12, w9, w10
	mul	w12, w12, w11						// w12 = (width * length * height)

        str     w9, [x15, cuboid_base + dimension_width]			//c->base.width *= factor
        str     w10, [x15, cuboid_base + dimension_length]		//c->base.length *= factor
        str     w11, [x15, cuboid_height]				//c->height *= factor
	str	w12, [x15, cuboid_volume]				//c->volume = c->base.width * c->base.length * c->height

        ldp     fp, lr, [sp], dealloc
        ret
//--------------------------------------------------------------------------------------------------
//struct printCuboid
printCuboid:
	stp	fp, lr, [sp, alloc]!
	mov 	fp, sp


	mov	x15, x3
	//print orgin
	mov	x1, x0							//load x0 into x1 wich is the string (first or second)
	ldr	x0, =origin_str
	ldr	w2, [x15, cuboid_origin + point_x]			//second arg
	ldr	w3, [x15, cuboid_origin + point_y]			//third arg
	bl	printf
	//print width and length
	ldr	x0, =wh_str
	ldr	w1, [x15, cuboid_base + dimension_width]
	ldr	w2, [x15, cuboid_base + dimension_length]
	bl	printf

	//print height
	ldr	x0, =height_str
	ldr	w1, [x15, cuboid_height]				//first arg
	bl	printf

	//print volume
	ldr	x0, =volume_str
	ldr	w1, [x15, cuboid_volume]				//first arg
	bl	printf

	ldp	fp, lr, [sp], dealloc
	ret
//-------------------------------------------------------------------------------------------------
//equalSize()
equalSize:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp

	mov	x14, x1
	mov	x14, x2

	mov	w9, False						//w9 = False
        //load cuboid width value and compare
	ldr     w10, [x14, cuboid_base + dimension_width]
	ldr     w11, [x15, cuboid_base + dimension_width]
	cmp	w10, w11						//compare width of cuboids
	b.ne	notEqual

	//load cuboid length and compare
        ldr     w10, [x14, cuboid_base + dimension_length]
	ldr 	w11, [x15, cuboid_base + dimension_length]
	cmp 	w10, w11
	b.ne 	notEqual						//compare length of cuboid

	//laod cuboid height and compare
	ldr     w10, [x14, cuboid_height]
	ldr     w11, [x15, cuboid_height]
	cmp	w10, w11
	b.ne	notEqual						//compare height of cuboid

	mov	w0, True						//if all conditons hold then set True
	ldp	fp, lr, [sp], dealloc
	ret
notEqual:
	mov	w0, False						//set False
        ldp     fp, lr, [sp], dealloc
        ret
//-------------------------------------------------------------------------------------------------
	cuboid_size_first = 24						//size of first cuboid
	cuboid_size_second = 24						//size of second cuboid

	alloc = -(16 + cuboid_size_first + cuboid_size_second) & -16
	dealloc = -alloc

	first_off = 16							//offset of first cuboid
	second_off = 40							//offset of second cuboid

main:
	stp	fp, lr, [sp, alloc]!
	mov	fp, sp

	//print inital value string
	ldr	x0, =initial_str
	bl	printf

	//first newCuboid
	add	x8, fp, first_off
	bl 	newCuboid
	//print first cuboid
	ldr	x0, =first_str						//store str in x0 for printcuboid
	add	x3, fp, first_off					//first cuboid addresses for printcuboid
	bl	printCuboid
gdb1:
	//second newcuboid
	add	x8, fp, second_off					//store address in x8 for newCuboid
	bl	newCuboid						//creat second cuboid
	//print second cuboid
	ldr	x0, =second_str						//store second str in x0 for print
	add	x3, fp, second_off					//store second cuboid address in x3
	bl	printCuboid
gdb2:

	//equalSize()
	add	x1, fp, first_off					// x1 address for first cuboid
	add	x2, fp, second_off					//x2 address for second cuboid
	bl	equalSize
	mov	result_r, w0
	cmp	result_r, True
	b.ne	continue						//if condition if not true then branch

	//if statment
	//move()
	add	x3, fp, first_off					//address of cuboid 1 for move()
	mov	w0, 3							//deltaX = 3
	mov	w2, -6							//deltaY = -6
	bl	move
gdb3:
	//scale()
	add	x3, fp, second_off					//address of cuboid second for scale()
	mov	w0, 4							//int factor = 4
	bl	scale

	//branch to continue if statment is not true
continue:
        //print changed value string
        ldr     x0, =changed_str
        bl      printf

	//print first cuboid
        add     x3, fp, first_off					//address of first cuboid for print
    	ldr     x0, =first_str
        bl      printCuboid
gdb4:
        //print second cuboid
        add     x3, fp, second_off					//address of second cuboid for print
        ldr     x0, =second_str
        bl      printCuboid

	ldp	fp, lr, [sp], dealloc
	mov	w0, 0
	ret
