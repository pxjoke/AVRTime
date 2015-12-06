			
; MACRO
.macro lsl_n
	loop:
		lsl @0
		dec @1
		brne loop	
.endm

.macro lsr_n
	loop:
		lsr @0
		dec @1
		brne loop
.endm

.macro not_first_bit 
	mov tmp, @1
	ldi tmp2, 1
	eor tmp, tmp2
	mov @0, tmp
.endm

.macro and_three ; @0  <-- @1 and @2 and @3
	ldi @0, 0b00000001
	and @0, @1
	and @0, @2
	and @0, @3
.endm


; RUN

.def A = r1
.def B = r2
.def C = r3
.def D = r4
.def NotA = r5
.def NotB = r6
.def NotC = r7
.def NotD = r8

.def hours = r17
.def minutes = r18
.def seconds = r19

.def first_digit = r20
.def second_digit = r21
.def third_digit = r22
.def forth_digit = r23

.def tmp = r25
.def tmp2 = r26
.def tmp3 = r27

.def R_TmpA = r25
.def R_OprA = r26
.def R_Dat = r27

.def number = r28
.def overflows = r29
.def display = r30
.def system = r31


; END RUN

; END MACRO



; RAM
	.DSEG
; END RAM

; FLASH 
	.CSEG
	.ORG 0x0000
	rjmp Reset

	.ORG 0x0020
	rjmp timer_handler

; INTERRUPTS 

timer_handler:
   inc system 
   inc overflows         ; add 1 to the overflows variable
   cpi overflows, 61     ; compare with 61
   brne t_exit          ; Program Counter + 2 (skip next line) if not equal
   clr overflows ; if 61 overflows occured reset the counter to zero
   inc seconds
   cpi seconds, 60
   brne t_exit
   clr seconds
   inc minutes
   cpi minutes, 60
   brne t_exit
   clr minutes
	t_exit:
		
		reti  


; END INTERRUPTS 


Reset:   	LDI 	R16,Low(RAMEND)	; Stack init
		    OUT 	SPL,R16			

		 	LDI 	R16,High(RAMEND)
		 	OUT 	SPH,R16
	 
; CORE INIT
RAM_Flush:	LDI		ZL,Low(SRAM_START)	; RAM CLEAN
			LDI		ZH,High(SRAM_START)
			CLR		R16					
Flush:		ST 		Z+,R16				
			CPI		ZH,High(RAMEND)		
			BRNE	Flush				
 
			CPI		ZL,Low(RAMEND)		
			BRNE	Flush
 
			CLR		ZL					; REGISTERS CLEAN
			CLR		ZH
			CLR		R0
			CLR		R1
			CLR		R2
			CLR		R3
			CLR		R4
			CLR		R5
			CLR		R6
			CLR		R7
			CLR		R8
			CLR		R9
			CLR		R10
			CLR		R11
			CLR		R12
			CLR		R13
			CLR		R14
			CLR		R15
			CLR		R16
			CLR		R17
			CLR		R18
			CLR		R19
			CLR		R20
			CLR		R21
			CLR		R22
			CLR		R23
			CLR		R24
			CLR		R25
			CLR		R26
			CLR		R27
			CLR		R28
			CLR		R29
; END CORE INIT



; INTERNAL HARDWARE INIT

	
	ldi tmp,  0b00000101
	out TCCR0B, tmp      ; set the Clock Selector Bits CS00, CS01, CS02 to 101
                         ; this puts Timer Counter0, TCNT0 in to FCPU/1024 mode
                         ; so it ticks at the CPU freq/1024
	ldi tmp, 0b00000001
	sts TIMSK0, tmp      ; set the Timer Overflow Interrupt Enable (TOIE0) bit 
                         ; of the Timer Interrupt Mask Register (TIMSK0)

	sei                   ; enable global interrupts -- equivalent to "sbi SREG, I"

	clr tmp
	out TCNT0, tmp       ; initialize the Timer/Counter to 0

	ldi tmp,0b11111111 ; mark B and D port as output
	out DDRB,tmp
	out DDRD,tmp

; END INTERNAL HARDWARE INIT



; EXTERNAL HARDWARE INIT

; END EXTERNAL HARDWARE INIT







; MAIN
Main:
	/*ldi cx, 0b00000000
	

q:
	mov number, cx
	ldi display, 0b00001110
	call draw

	

	rcall delay
		
	
	//rcall delay
	inc cx
	cpi cx, 0b00010000
	brne q*/

	/*ldi display, 0b00001111	
	out PORTB, display	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	*/
	mov R_TmpA, seconds
	ldi R_Dat, 16
	call S_Div_ByteByte
	
	mov first_digit,  R_OprA
	mov second_digit,R_TmpA 

	/*ldi display, 0b00001111	
	out PORTB, display	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
nop*/	

	ldi display, 0b0000111
	mov number, first_digit
	call draw
	

	/*ldi display, 0b00001111	
	out PORTB, display	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	*/
	ldi display, 0b00001011
	mov number, second_digit
	call draw
	
	

	mov R_TmpA, minutes
	ldi R_Dat, 16
	call S_Div_ByteByte
	
	mov third_digit, R_OprA
	mov forth_digit, R_TmpA

	/*ldi display, 0b00001111	
	out PORTB, display	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	*/

	ldi display, 0b00001101
	mov number, third_digit
	call draw
	
	/*ldi display, 0b00001111	
	out PORTB, display
		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	*/
	ldi display, 0b00001110
	mov number, forth_digit
	call draw
	

		
JMP	Main
; END MAIN


draw: ; put number in number reg, 
	
	ldi tmp2, 4 ; we need the 4th bit in number
	call get_bit ; now the 4th bit of number is at the 1st place of tmp
	mov A, tmp ; now the 4th bit of number is at the 1st place of A

	ldi tmp2, 5
	call get_bit
	mov B, tmp

	
	ldi tmp2, 6
	call get_bit
	mov C, tmp

	ldi tmp2, 7
	call get_bit
	mov D, tmp
	
	not_first_bit NotA, A ; logical NOT of the 1st bit of A
	not_first_bit NotB, B
	not_first_bit NotC, C
	not_first_bit NotD, D

	/*clr tmp
	out PORTD, tmp	*/
	
	//out PORTB, display

	ldi tmp3, 1 ; just 1 const for the and command

	;f7:
	clr tmp
	clr tmp2
	
		and_three tmp2, NotB, C, tmp3 ; now tmp2 contains NotB and C and "1"
		or tmp, tmp2 ; add the result of AND to tmp

		and_three tmp2, A, NotB, tmp3
		or tmp, tmp2

		and_three tmp2, NotA, B, NotD
		or tmp, tmp2

		and_three tmp2, B, NotC, D
		or tmp, tmp2

		and_three tmp2, A, C, tmp3
		or tmp, tmp2

		lsl tmp ; 

	;f6:
		
		and_three tmp2, NotC, NotD, tmp3
		or tmp, tmp2

		and_three tmp2, NotA, B, NotC
		or tmp, tmp2
		
		and_three tmp2, B, NotD, tmp3
		or tmp, tmp2

		and_three tmp2, A, NotB, tmp3
		or tmp, tmp2

		and_three tmp2, A, C, tmp3
		or tmp, tmp2

		lsl tmp

	;f5:
		
		and_three tmp2, NotB, NotD, tmp3
		or tmp, tmp2

		and_three tmp2, C, NotD, tmp3
		or tmp, tmp2

		and_three tmp2, A, C, tmp3
		or tmp, tmp2

		and_three tmp2, A, B, tmp3
		or tmp, tmp2

		lsl tmp

	;f4:
		
		and_three tmp2, B, NotC, D
		or tmp, tmp2

		and_three tmp2, NotB, NotC, NotD
		or tmp, tmp2

		and_three tmp2, NotB, C, D
		or tmp, tmp2

		and_three tmp2, B, C, NotD
		or tmp, tmp2

		and_three tmp2, A, NotC, tmp3
		or tmp, tmp2

		and_three tmp2, NotA, C, NotD
		or tmp, tmp2


		lsl tmp

	;f3:
		
		and_three tmp2, NotA, B, tmp3
		or tmp, tmp2

		and_three tmp2, A, NotB, tmp3
		or tmp, tmp2

		and_three tmp2, NotC, D, tmp3
		or tmp, tmp2

		and_three tmp2, NotB, NotC, tmp3
		or tmp, tmp2

		and_three tmp2, NotB, D, tmp3
		or tmp, tmp2

		lsl tmp

	;f2:
		
		and_three tmp2, NotA, NotC, NotD
		or tmp, tmp2

		and_three tmp2, NotA, C, D
		or tmp, tmp2

		and_three tmp2, NotB, NotD, tmp3
		or tmp, tmp2

		and_three tmp2, A, NotC, D
		or tmp, tmp2

		and_three tmp2, NotB, NotC, tmp3
		or tmp, tmp2

		lsl tmp


	;f1:
				
		and_three tmp2, NotB, NotD, tmp3
		or tmp, tmp2
		and_three tmp2, NotA, C, tmp3
		or tmp, tmp2
		and_three tmp2, NotA, B, D
		or tmp, tmp2
		and_three tmp2, A, NotB, NotC
		or tmp, tmp2
		and_three tmp2, A, NotD, tmp3
		or tmp, tmp2
		and_three tmp2, B, C, tmp3
		or tmp, tmp2		

		lsl tmp
		out PORTB, display
		out PORTD, tmp
ret

delay:
   clr system         ; set overflows to 0 
   sec_count:
     cpi system, 0    ; compare number of overflows and 30
   brne sec_count        ; branch to back to sec_count if not equal 
   ret 

; PROCEDURES

get_bit: ;input, output, bit_num  -- get_bit from, to, 3 
	mov tmp, number	
	lsl_n tmp, tmp2
	ldi tmp2, 7
	lsr_n tmp, tmp2	
ret

; ------------------------------------------------------------------------------
; Деление байта на байт ////////////////////////////////////////////////////////
; ------------------------------------------------------------------------------
; --> R_TmpA -- делимое, R_Dat -- делитель
; <-- R_TmpA -- частное, R_OprA -- остаток
; Меняет: R_TmpA, R_OprA, XL
; Описание:
; Действия аналогичны вычитанию в столбик. В остатке собирается число сдвигом 
; влево делимого через флаг C. На каждом шаге из остатка вычитается делитель. 
; Если результат < 0, делитель прибавляется, восстанавливая остаток, и в мл. бит
; частного записыв. "1", после чего частное сдвигается влево. Если результат 
; >= 0, остаток не восстанавливается, в мл. бит частного записыв. "0" и частное
; сдвигается влево. Число шагов = числу разрядов частного. Здесь роль частного 
; играет само делимое, кроме того, собирается инвертированное частное и после
; прохождения цикла командой com оно переводится в правильное частное.




S_Div_ByteByte:
    ldi        system, 9                    ; Количество разрядов + бит C
    clr        R_OprA                   ; Остаток
    clc                                 ; C=0, важная команда
S_Div_ByteByte_Loop:
    rol        R_OprA                   ; Сдвиг влево, Rd(0) = С
    sub        R_OprA, R_Dat            ; Остаток минус делитель
    brcc    S_Div_ByteByte_1            ; Переход, если остаток > делителя (C=0)
        add        R_OprA, R_Dat        ; Восстановление остатка (C=1)
S_Div_ByteByte_1:
    rol        R_TmpA                   ; Сбор инвертир. частного, Rd(0) = C
    dec        system                       ; Не влияет на флаг C
    brne    S_Div_ByteByte_Loop
    com        R_TmpA                   ; Инверсия -> правильное частное
    ret


; END PROCEDURES


; EEPROM 
.ESEG
