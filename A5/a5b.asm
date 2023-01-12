//File: a5b.asm
//Author: Mohammed Hossain

// definitions
define(m_base, x20)
define(s_base, x27)
define(sea_base, x28)
//comand line register
define(argc_r, w21)
define(argv_r, x22)
//base address register
define(mon_r, w23)
define(day_r, w24)
//input register
define(month_in, w25)
define(day_in, w26)

fp	.req	x29
lr	.req	x30

// Strings
	.data
result_str:	.string "%s %d%s is %s\n"
usage_str:	.string "usage: a5b mm dd\n"

//Months
jan_str:	.string "January"
feb_str:	.string "February"
mar_str:	.string "March"
apr_str:	.string "April"
may_str:	.string "May"
jun_str:	.string "June"
jul_str:	.string "July"
aug_str:	.string "August"
sep_str:	.string "September"
oct_str:	.string "October"
nov_str:	.string "November"
dec_str:	.string "December"
//Seasons

winter_str:	.string "Winter"
spring_str:	.string "Spring"
summer_str:	.string "Summer"
fall_str:	.string "Fall"
//Suffixes
st:	.string "st"
nd:	.string "nd"
rd:	.string "rd"
th:	.string "th"


// all month, season, suffix names as .dword
	.balign 8
month_m:	.dword jan_str, feb_str, mar_str, apr_str, may_str, jun_str, jul_str, aug_str, sep_str, oct_str, nov_str, dec_str

suff_m:	.dword st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st

	.text

	.balign 4
	.global main

main:
	stp	fp, lr, [sp, -16]!
	mov	fp, sp

	mov	argc_r, w0			//copy argc: # of elements in array
	mov	argv_r, x1			//copy argv; base address of the array

	//store first arg for month
	mov	mon_r, 1
	//second for day
	mov	day_r, 2

	cmp	argc_r, 3			//compare number of pointers with 3
	b.ne	usage_error			//if not the right amount of argumnet then branch to usage error

check_input:
//get month input
	ldr	x0, [argv_r, mon_r, SXTW 3]
	bl	atoi
	mov	month_in, w0

//check month input
	cmp	month_in, 1			//month < 1 result in error
	b.lt	usage_error

	cmp	month_in, 12			//month > 12 result in error
	b.gt	usage_error

//get day input
	ldr	x0, [argv_r, day_r, SXTW 3]
	bl	atoi
	mov	day_in, w0

//check day  input
	cmp	day_in, 1			//day < 1 result in error
	b.lt	usage_error

	cmp	day_in, 31			//day > 31 result in error
	b.gt	usage_error

//check if the day input is within the months date range
// (ex if input is 02 29 then error should be given only 28 days in feb)
//all other months excpet the lsited ones have 31 days
month_range:
	cmp	month_in, 2
	b.eq	feb_range

	cmp	month_in, 4
	b.eq	april_range

	cmp	month_in, 6
	b.eq	june_range

	cmp	month_in, 9
	b.eq	september_range

	cmp	month_in, 11
	b.eq	november_range

	b	season_range

feb_range:
	cmp	day_in, 28
	b.ge	usage_error
	b	season_range			//if condition not true than continue program by branching season_range

april_range:
	cmp	day_in, 30
	b.ge	usage_error
	b	season_range

june_range:
	cmp	day_in, 30
	b.ge	usage_error
	b	season_range
september_range:
	cmp	day_in, 30
	b.ge	usage_error
	b	season_range
november_range:
	cmp	day_in, 30
	b.ge	usage_error


season_range:
//check what month is it then based of that branch to the correnct season
//if its a month that can be between 2 season then branch to check the date first
	cmp	month_in, 3
	b.eq	march_check

	cmp	month_in, 6
	b.eq	june_check

	cmp	month_in, 9
	b.eq	september_check

	cmp	month_in, 12
	b.eq	december_check

	cmp	month_in, 1
	b.eq	set_winter

	cmp	month_in, 2
	b.eq	set_winter

	cmp	month_in, 4
	b.eq	set_spring

	cmp	month_in, 5
	b.eq	set_spring

	cmp	month_in, 7
	b.eq	set_summer

	cmp	month_in, 8
	b.eq	set_summer

	cmp	month_in, 10
	b.eq	set_fall

	cmp	month_in, 11
	b.eq	set_fall

//when the date has been checked then branch to the right season
march_check:
	cmp	day_in, 20
	b.le	set_winter

	cmp	day_in, 21
	b.ge	set_spring

june_check:
	cmp	day_in, 20
	b.le	set_spring

	cmp	day_in, 21
	b.ge	set_summer

september_check:
	cmp	day_in, 20
	b.le	set_summer

	cmp	day_in, 21
	b.ge	set_fall

december_check:
	cmp	day_in, 20
	b.le	set_fall

	cmp	day_in, 21
	b.ge	set_winter

//set the right season for the last arg of the print statment
set_winter:
	ldr	x4, =winter_str
	b	output
set_spring:
	ldr	x4, =spring_str
	b	output

set_fall:
	ldr	x4, =fall_str
	b	output

set_summer:
	ldr	x4, =summer_str
        mov     w10, 1

	b	output

output:
//month
	adrp	m_base, month_m			//calc address of month
	add	m_base, m_base, :lo12:month_m	//add lower bits

	sub	month_in, month_in, 1		//subtract 1 due to array index
//suffix
	adrp	s_base, suff_m			//calc addres of suff_m
	add	s_base, s_base, :lo12:suff_m	//lower bits
	sub	w9, day_in, 1			//setting index

	ldr	x0, =result_str			//load sttring first arg
	ldr	x1, [m_base, month_in, SXTW 3]	//load month
	mov	w2, day_in			//load day
	ldr	x3, [s_base, w9, SXTW 3]	//load suffix
	//x4 has already been set (season)
	bl	printf

	b	end
usage_error:
	ldr	x0, =usage_str			//load string
	bl	printf				//cal printf

end:
	ldp	fp, lr, [sp], 16
	mov	w0, 0				//ret 0
	ret
