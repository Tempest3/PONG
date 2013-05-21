; Program: PONG 
; Author: Brandon Michaud & Konrad Wiley
; Date: 12/4/12 -- 12/6/12
; Runs in 16-bit real mode. Made with Irvine's make16 batch file.

; Note:
; This program ran so quickly on Konrad's computer that it was entirely impossible to play.
; To try and alleviate this complication, two counting methods are in place to slow the ball down.
; If performance on your particular machine is not stellar... or if you want a bit of a challenge...
; comment-out the counting section from lines 337-342 (approx.). This will double the game speed.
; -Konrad Wiley



.model small
.stack 100h

.data;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\PONG DATA SEGMENT 

Paddle1 BYTE ?
Paddle2 BYTE ?
xball BYTE ?
yball BYTE ?
vert_dball BYTE ?
horiz_dball BYTE ?
count1 WORD ?
count2 BYTE ?
right_screen BYTE "Right paddle missed the ball!$"
left_screen BYTE "Left paddle missed the ball!$"





.code
main proc
        mov ax, @data                    ; Get access to my data segment
        mov ds, ax                       ; These two lines are required for all programs

        ; your code starts here************************************************************************************<<<<<<DONT PROGRAM BEFORE THIS DUMMY!!!



	Call ClearScrn
	Call DrawPaddles
	call DrawBall
	
	
	PaddleInput:;*****************************************************************************(Brandon Michaud Start)
		; Time to move that ball!
		;call MoveBall

		

		mov ah, 06h	;Lets program run even if a key isn't pressed
		mov dl, 0ffh
		int 21h
		
		


		cmp al, 'q'
		jz leftup

		cmp al, 'a'
		jz leftdown

		cmp al, 'o'
		jz rightup
		
		cmp al, 'l'
		jz rightdown

		cmp al, '`';******************************This compare breaks out of the loop to quit the program using the ` key
		jz quit
		

		
		
			
			
		jmp reloop

		
		leftup:			
			mov dh, [paddle1]
			
			cmp dh, 0 ; This part was added by Konrad Wiley
			je reloop ; --------------------------------------
			
			mov dl, 1
			mov bh, 0
			mov ah, 2
			int 10h
			
			mov dl, ' '
			mov ah, 2
			int 21h

			dec [paddle1]
			mov dh, [paddle1]
			mov dl, 1
			mov bh, 0
			mov ah, 2
			int 10h

			mov dl, '|'			
			mov ah, 2
			int 21h
			jmp reloop	
			
		leftdown:
			mov dh, [paddle1]
			
			cmp dh, 24 ; This part was added by Konrad Wiley
			je reloop ; ---------------------------------------
			
			mov dl, 1
			mov bh, 0
			mov ah, 2
			int 10h
			
			mov dl, ' '
			mov ah, 2
			int 21h

			inc [paddle1]
			mov dh, [paddle1]
			mov dl, 1
			mov bh, 0
			mov ah, 2
			int 10h
		
			
			mov dl, '|'			
			mov ah, 2
			int 21h
			jmp reloop	
			
		rightup:			
			mov dh, [paddle2]
			
			cmp dh, 0 ; This part was added by Konrad Wiley
			je reloop ; --------------------------------------
			
			mov dl, 78
			mov bh, 0
			mov ah, 2
			int 10h
			
			mov dl, ' '
			mov ah, 2
			int 21h

			dec [paddle2]

			mov dh, [paddle2]
			mov dl, 78
			mov bh, 0
			mov ah, 2
			int 10h

			mov dl, '|'			
			mov ah, 2
			int 21h
			jmp reloop
	
		rightdown:
			mov dh, [paddle2]
			
			cmp dh, 24 ; This part was added by Konrad Wiley
			je reloop ; ---------------------------------------
			
			mov dl, 78
			mov bh, 0
			mov ah, 2
			int 10h
			
			mov dl, ' '
			mov ah, 2
			int 21h

			inc [paddle2]
			mov dh, [paddle2]
			mov dl, 78
			mov bh, 0
			mov ah, 2
			int 10h
		
			mov dl, '|'			
			mov ah, 2
			int 21h
			
		reloop:
		
		; By Konrad Wiley----------------
		; Because of modern processor capabilitites (at least on mine...)
		; ...we had to slow the ball movement WAY down. It's still pretty snappy.
		mov cx, [count1]
		inc cx
		mov [count1], cx
		cmp cx, 0FFFFh
		jb PaddleInput
		
		; Now we move the ball... (at 1/2 speed still)
		call MoveBall
		
	flag_right:
		cmp al, 'R'
		jne flag_left
		call ClearScrn
		mov dh, 13
		mov dl, 24
		call SetCursor
		mov dx, offset right_screen
		mov ah, 9
		int 21h
		jmp quit
		
	flag_left:
		cmp al, 'L'
		jne PaddleInput
		call ClearScrn
		mov dh, 13
		mov dl, 24
		call SetCursor		
		mov dx, offset left_screen
		mov ah, 9
		int 21h
		jmp quit
		
		;--------------------------------

	jmp PaddleInput;******************************Artificial Loop doesn't use cx. ALWAYS RUNNING DO THE REST OF THE PROGRAMMING IN THIS LABEL(Brandon Michaud END)



	quit:
        ; your code ends here***************************************************************************************<<<<<DONT PROGRAM AFTER THIS DUMMY!!!!

        mov ax, 4C00h                    ; return to DOS
        int 21h

main endp


ClearScrn PROC;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(Brandon Michaud)

	mov cx, 2000

	clearloop:
		mov dl, ' '
		mov ah, 2
		int 21h
	loop clearloop

ret
ClearScrn ENDP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawPaddles PROC;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(Brandon Michaud)

	mov dh, 10
	mov dl, 1
	mov bh, 0
	mov ah, 2
	int 10h
	mov [paddle1], dh	

	mov dl, '|'
	mov ah, 2
	int 21h	
	
	mov dh, 10
	mov dl, 78
	mov bh, 0
	mov ah, 2
	int 10h
	mov [paddle2], dh

	mov dl, '|'
	mov ah, 2
	int 21h
	
	mov dh, 0
	mov dl, 4
	mov bh, 0
	mov ah, 2
	int 10h

ret
DrawPaddles ENDP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Designed and written by Konrad Wiley
; Places the ball (a smiley-face) in the middle of the window and sets
; the ball to initially bounce down and left.
;------------------------------------------------------------
DrawBall proc
	push ax
	push dx
	
	mov dh, 13
	mov dl, 38
	call SetCursor
	mov [xball], dl
	mov [yball], dh

	
	mov al, 01h
	call WriteK
	
	mov dh, 0
	mov dl, 0
	call SetCursor
	
	;set ball direction
	mov [vert_dball], 1
	mov [horiz_dball], 1
	
	mov [count1], 0
	mov [count2], 0

	
	pop dx
	pop ax
	ret

DrawBall endp
;-------------------------------------------------------------

; Designed and written by Konrad Wiley
; Finds the location of the ball, erases it, moves the coordinates, and prints a new ball.
; Cleans up after itself and returns any error codes in AL.
MoveBall proc
	push bx
	push dx
	
; Slow down the ball some more...
	mov al, [count2]
	xor al, 1
	mov [count2], al
	cmp al, 1	
	je quit
	
; Get heading
	mov bl, [vert_dball]
	mov bh, [horiz_dball]
	
	
; Erase the current ball.
	mov dh, [yball]
	mov dl, [xball]
	call SetCursor
	mov al, ' '
	call WriteK

; Find out the vertical ball heading...
set_vertical:
	shr bl, 1
	jc dir_down
	dec dh
	jmp calc_vertical
	
dir_down:
	or bl, 1
	inc dh

calc_vertical:
; If ball is at the bottom of the screen...
	cmp dh, 24
	ja change_vert

; If ball is at the top of the screen...
	cmp dh, 0
	jne set_horiz	
	
; Switch directions!	
change_vert:
	xor bl, 1
	jmp set_vertical

; Find out the horizontal ball heading...
set_horiz:
	shr bh, 1
	jc dir_left
	inc dl
	jmp calc_horiz
	
dir_left:
	or bh, 1
	dec dl
	
calc_horiz:
; If the ball is at the right of the screen...
	cmp dl, 78
	je find_right

; If the ball is at the left of the screen...
	cmp dl, 1
	jne print

; Finds the y-coordinate of the left paddle,
; compares it to +/- 2 of the location of the ball,
; and if the paddle touches -- makes the ball bounce.
; If the paddle does not touch, AL receives the ascii code for "L" and the proc exits.
find_left:
	mov ah, [paddle1]
	cmp ah, dh
	je change_horiz
	add ah, 1
	cmp ah, dh
	je change_horiz
	add ah, 1
	cmp ah, dh
	je change_horiz
	sub ah, 3
	cmp ah, dh
	je change_horiz
	sub ah, 1
	cmp ah, dh
	je change_horiz
	mov al, 'L'
	jmp quit

; Finds the y-coordinate of the right paddle,
; compares it to +/- 2 of the location of the ball,
; and if the paddle touches -- makes the ball bounce.
; If the paddle does not touch, AL receives the ascii code for "R" and the proc exits.
find_right:
	mov ah, [paddle2]
	cmp ah, dh
	je change_horiz
	add ah, 1
	cmp ah, dh
	je change_horiz
	add ah, 1
	cmp ah, dh
	je change_horiz
	sub ah, 3
	cmp ah, dh
	je change_horiz
	sub ah, 1
	cmp ah, dh
	je change_horiz
	mov al, 'R'
	jmp quit

change_horiz:
	xor bh, 1
	jmp set_horiz
	

; Executed at the end of this proc...
; Prints a new ball at the new coordinates.
print:
	call SetCursor
	mov al, 01h
	call WriteK
	
	mov [yball], dh
	mov [xball], dl
	mov [vert_dball], bl
	mov [horiz_dball], bh
	mov al, 0
quit:	
	pop dx
	pop bx
	ret
MoveBall endp
;-------------------------------------------------------------

; Designed and Written by Konrad Wiley
; An easier way of running the ms-dos command...
; Receives an ascii code from "standard-input" and places it in al
; (fully interchangeable with Irvine's "ReadChar")
; Cleans up after itself.
ReadK proc
	push bx
	push ax
	
	mov ah, 01h    
	int 21h
	
	pop bx
	mov ah, bh
	pop bx
	ret
    
    
ReadK endp
;-------------------------------------------------------------

; Designed and Written by Konrad Wiley
; An easier way of running the ms-dos command...
; Receives the ascii code on al, copies to dl for int 21h.
; (integration fully interchangeable with Irvine's "WriteChar")
; Cleans up after itself.
WriteK proc
	push ax
	push dx
	
	mov ah, 02h
	mov dl, al
	int 21h
	
	pop dx
	pop ax
	ret
WriteK endp
;-------------------------------------------------------------

; Designed and Written by Konrad Wiley
; An easier way of running the BIOS command...
; Receives the coordinates for the cursor from DH and DL.
; Cleans up after itself.
SetCursor proc
	push ax
	push bx
	
	mov ah, 2
	mov bh, 0
	
	int 10h
	
	pop bx
	pop ax
	ret
SetCursor endp

END main