//Author:Mohammed Hossain
//File: a5a.asm

define(ret_val, w21)
define(base_r, x22)
define(i_r, w23)
define(j_r, w24)
define(count_r, w25)


QUEUESIZE = 8
MODMASK = 0X7
FALSE = 0
TRUE = 1


//Global variables
	.data						//Global var
	.global head
	.global tail
head:	.word	-1
tail:	.word	-1

      	.bss                                          	 //Global var
        .global queue
queue:  .skip   QUEUESIZE * 4                        	//allocate memory of 8 elements each 4 bytes


//print statment
	.text
overFlow_str:	.string "\nQueue overflow! Cannot enqueue into a full queue.\n"
underFlow_str:	.string "\nQueue underflow! Cannot dequeue from an empty queue.\n"
empty_str:	.string "\nEmpty queue\n"
current_str:	.string	"\nCurrent queue contents:\n"
head_str:	.string	" <-- head of queue"
tail_str:	.string " <-- tail of queue"
newLine_str:	.string	"\n"
value_str:	.string	"%d"


fp	.req	x29
lr	.req	x30
//----------------------------------------------------------------------------------------------------------
//void enqueue(int value)
	.global enqueue
	.balign	4
enqueue:
	stp	fp, lr, [sp, -16]!
	mov	fp, sp

	mov	w19, w0					//store inputed value into w19 --> w19 = w0

	bl	queueFull				//call queueFull
	mov	ret_val, w0				//put the returned value into ret_val
	cmp	ret_val, TRUE				//if queuefull return true than queue is full
	b.ne	enqueue2_if				//if not true than go to next if condition

	//if queueFull is full then print overFlow_str
	ldr	x0, =overFlow_str
	bl	printf
	bl	end					//branch to end of enqueue

enqueue2_if:
	bl	queueEmpty				//call queueEmpty
	mov	ret_val, w0				//put retuned value into ret_val
	cmp	ret_val, TRUE				//cmp ret_val and TRUE
	b.ne	enqueue_else					//if not true then go to else condition

	// head = tail = 0
  	ldr	base_r, =tail				//get address of global variable => base_r = tail
      	ldr     w7, [base_r]				//set w7 = tail

        mov     w7, 0                                   //tail = 0
        str     w7, [base_r]

	ldr	base_r, =head				//get address of global variable => base_r = head
      	ldr     w6, [base_r]				//set w6 = head

	mov	w6, w7					//head = tail = 0
	str	w6, [base_r]				//save on ram lopvation where head is stored
	bl	queue_val				//branch to end of enqueue

enqueue_else:
	//tail = ++tail & MODMASK
	ldr	base_r, =tail				//get address of global variable => base_r = tail
        ldr     w7, [base_r]				//set w7 = tail

	add	w7, w7, 1				// ++tail
	and	w7, w7, MODMASK				// tail = ++tail & MODMASK
	str	w7, [base_r]

queue_val:
	//queue[tail] = value
	ldr	base_r, =tail				//get address of global variable => base_r = tail
	ldr	w7, [base_r]				//set w7 = tail

	ldr	base_r, =queue				//base_r = is base address
	str	w19, [base_r, w7, SXTW 2]		//set tail value to inputted value
end:
	ldp	fp, lr, [sp], 16
	ret
//---------------------------------------------------------------------------------------------------------
//int dequeue()
	.global dequeue
	.balign	4
dequeue:
	stp	fp, lr, [sp, -16]!
	mov	fp, sp

	bl	queueEmpty				//call queueEmpty
	mov	ret_val, w0				//store what value queueEmpty returned in ret_val
	cmp	ret_val, TRUE				////cmp returned val with TRUE
	b.ne	dequeue2_if				//if not ture than branch to second if condition

	//if queue is empty then print underflow_str
	ldr	x0, =underFlow_str
	bl	printf
	mov	w0, -1					//return (-1)
	b	dequeue_end				//end dequeue

	//value = queue[head]
dequeue2_if:
	ldr	base_r, =head				//get addrews of head
	ldr	w6, [base_r]				//set w6 = head

	ldr	base_r, =queue				//base_r is base address
	ldr	w19, [base_r, w6, SXTW 2]		//w19 = value = queue[head]

	ldr	base_r, =head				//get address of head
	ldr	w6, [base_r]				//load head

	ldr	base_r, =tail				//get address of tail
	ldr	w7, [base_r]				//load tail

	cmp	w6, w7					// compare head and tail
	b.ne	dequeue_else				//if not true than branch

	//if true than

	mov	w7, -1					//tail = w7 = -1
	str	w7, [base_r]				//get address

	ldr	base_r, =head				//get address
	mov	w6, w7					// head = tail
	str	w6, [base_r]				//store 26 in ram

	b	return_val				//return value

dequeue_else:
	//head = ++head & MODMASK
        ldr     base_r, =head                           //get address of global variable => base_r = head
        ldr     w6, [base_r]                            //set w6 = head

        add     w6, w6, 1                               // ++head
        and     w6, w6, MODMASK                         // head = ++head & MODMASK
        str     w6, [base_r]				// store w6 in memory

return_val:
	mov	w0, w19					//value is returned

dequeue_end:
	ldp	fp, lr, [sp], 16
	ret
//-----------------------------------------------------------------------------------------------------------
//int queueFull()
	.global queueFull
	.balign 4

queueFull:
	stp	fp, lr, [sp, -16]!
	mov	fp, sp

	ldr	base_r, = tail				//get address of tail
	ldr	w7, [base_r]				//store tail in 27
	add	w7, w7, 1				//tail + 1
	and	w7, w7, MODMASK				//(tail + 1) & MODMASK

	ldr	base_r, =head				//get address of head
	ldr	w6, [base_r]				//store head in 26

	cmp	w7, w6					//(tail + 1) & MODMASK == head
	b.ne	queueFull_else				//if not true than branch to else condition

	mov	w0, TRUE				//return TRUE
	b	queueFull_end

queueFull_else:
	mov	w0, FALSE				//return FALSE

queueFull_end:
	ldp	fp, lr, [sp], 16
	ret
//-----------------------------------------------------------------------------------------------------------
//int queueEmpty()
	.global queueEmpty
	.balign 4

queueEmpty:
	stp	fp, lr, [sp, -16]!
	mov	fp, sp

	ldr	base_r, =head				//get head address
	ldr	w6, [base_r]

	cmp	w6, -1					//compare head and -1
	b.ne	queueEmpty_else
	//if ( head == -1)
	mov	w0, TRUE				//return TRUE
	b	queueEmpty_end

queueEmpty_else:
	mov	w0, FALSE				//return FALSE

queueEmpty_end:
	ldp	fp, lr, [sp], 16
	ret
//-----------------------------------------------------------------------------------------------------------
//void display()
	.global display
	.balign 4

display:
	stp	fp, lr, [sp, -16]!
	mov	fp, sp

	bl	queueEmpty				//call queueEmpty
	mov	ret_val, w0				//store returned value
	cmp	ret_val, TRUE				//compare the returned value with TRUE
	b.ne	display2_if				//if not true then go to next if condition

	//print string is empty
	ldr	x0, =empty_str
	bl	printf
	b	display_end				//return

display2_if:
	//count = tail - head + 1
	ldr	base_r, =head				//get address
	ldr	w6, [base_r]				//w6 = head

	ldr	base_r, =tail				//get address
	ldr	w7, [base_r]				//w7 = tail
	//w15 = count
	sub	count_r, w7, w6				//count = tail - head
	add	count_r, count_r, 1

	//if(count <=0)
	cmp	count_r, 0				//compare count and 0
	b.gt	next					// if count > 0 then branch to next condition

	// count += QUEUESIZE
	add	count_r, count_r, QUEUESIZE		//count += QUEUESIZE

next:
	//print current_str => printf("\nCurrent queue contents:\n")
	ldr	x0, =current_str
	bl	printf

	ldr	base_r, =head				//get address
	ldr	w6, [base_r]				//w6 = head
	//w10 = i
	mov	i_r, w6					// i = head

	mov	j_r, 0					// j = 0
	b	test_loop				//branch to test
display_for:
        ldr     base_r, =queue                       	//base_r is base address
        ldr     w2, [base_r, i_r, SXTW 2]            	//w19 = value = queue[i]

	//print out value at queue[i]
	ldr	x0, =value_str
	mov	w1, w2
	bl	printf

	//if (i ==head)
	ldr	base_r, =head				//get address
	ldr	w6, [base_r]				// w6 = head

	cmp	i_r, w6					//compare i and head
	b.ne	tail_if					//if not equal than branch to next if condition

	//print: " <-- head of queue"
	ldr	x0, =head_str
	bl	printf

tail_if:
	ldr	base_r, =tail				//get address
	ldr	w7, [base_r]				//27 = tail

	cmp	i_r, w7					//compare i and tail
	b.ne	continue				// if not equal then branch to continue

	ldr	x0, =tail_str
	bl	printf

continue:
	ldr	x0, =newLine_str			//"\n"
	bl	printf

	add	i_r, i_r, 1				// ++i
	and	i_r, i_r, MODMASK			// i = ++i & MODMASK

	add	j_r, j_r, 1				//j++
test_loop:
	cmp	j_r, count_r				//compare j and count
	b.lt	display_for				//if j < count than loop

display_end:
	ldp	fp, lr, [sp], 16
	ret
//---------------------------------------------------------------------------------------------------------------
















