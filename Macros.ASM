;;-------------Generales---------------------
POPS Macro ListaRR
;; Hace una serie de Push a los registros que recibe en una lista
  IRP RR, <ListaRR>
     Pop RR
  EndM
EndM

PUSHS Macro ListaR
	
	IRP R, <ListaR>	
		Push R
	EndM
EndM
	
PRINT macro S
	;; imprime lo que haya en S
	PUSHS <ax, dx>

	mov ah, 09h
	lea dx, S
	int 21h

	POPS <dx, ax>
endm

INC2 Macro R

  Inc R
  Inc R
endm

CONEJO macro salto , etiqueta
  local et1
  local et2

  salto et1
  jmp et2
et1: jmp etiqueta
et2:  

endM

DSTOES macro
	
	push es
	push ds 
	pop es
endm

ESTODS macro
	
	push es 
	pop ds
	pop es 
endm

JCALLIFANDRET macro salto, procs
	local eta1
	local eta2

	salto eta1
	jmp eta2
eta1: 
	call procs	
	ret 
eta2:

endm


CALLIF macro salto, procs;; llama al procs si se cumple el salto
	local et1
	local et2

 
	salto et1
	jmp et2
et1: call procs	
et2:

endM

MOVE macro
	
	inc si
	dec cx
endm

LIGHTRED EQU 0CH
;;-------------end Generales---------------------
;;-------------especificas-------------

black           equ 0000b
blue            equ 0001b
green           equ 0010b
cyan            equ 0011b
red             equ 0100b
magenta         equ 0101b
brown           equ 0110b ; En pantalla se ve naranja
orange          equ 0110b ; En pantalla se ve naranja
lightGray       equ 0111b
darkGray        equ 1000b
lighBlue        equ 1001b
lightGreen      equ 1010b
lightCyan       equ 1011b
lightRed        equ 1100b
lightMagenta    equ 1101b
yellow          equ 1110b
white           equ 1111b

DRAWPIXELMACRO macro x, y, color
;; recibe el x, y del cursor
;; no volver a usar
	PUSHS <ax, cx, dx>

	call calculatePixelPosition

	mov al, color

	call drawPixel

	POPS <dx, cx, ax>
endm

JDRAWPIXELMACRO macro x, y, color

	PUSHS <ax, cx, dx>

	mov cx, x
	mov dx, y
	mov al, color
	call drawPixel

	POPS <dx, cx, ax>

endm

DRAWPOINTM macro x, y, letter, color

	PUSHS <ax, bx, dx>

	mov al, letter
	mov bl, color
	mov dh, y
	mov dl, x

	MOVCURSORPOSITION x, y

	call drawPoint

	MOVCURSORPOSITION COL, FIL

	POPS <dx, bx, ax>
endm

MOVCURSORPOSITION macro x, y

	push dx

	mov dh, y
	mov dl, x
	call setCursorPosition

	pop dx
endm

CMPAHMOVDIRJUMFIN macro code, noJmp, valDir
	cmp ah, code
	jne noJmp
	mov [DIR], valDir
	jmp finAndMovCursor
endm

LIMIT macro var, max, min
	local noSuperaMayor1
	local finLimitMacro1

	cmp var, max
	jle noSuperaMayor1
	mov var, max
	jmp finLimitMacro1

noSuperaMayor1:

	cmp var, min
	jge finLimitMacro1
	mov var, min

finLimitMacro1:

endm

CALLIFANDRET macro jump, jmpIfNot, procesoName
	local isJump1
	CALLIF jump, procesoName
	jmpIfNot isJump1
	ret
isJump1:

endm

FILPOINTMAC macro POINT
	;; ret: cx =x, dx=y
	mov POINT, cx
	mov word ptr [POINT+2], dx
endm

ROTATE60MAC macro POINTORIGIN, POINT
	PUSHS<ax, cx, dx>

	mov ax, word ptr [POINTORIGIN]
	mov word ptr [ORIGIN], ax 
	mov ax, word ptr [POINTORIGIN+2]
	mov word ptr [ORIGIN+2], ax 

	mov cx, word ptr [POINT] ;; x
	mov dx, word ptr [POINT+2] ;; y

	call rotate60

	mov word ptr [POINT], cx ;; x
	mov word ptr [POINT+2], dx ;; y 

	POPS<dx, cx, ax>
endm

ROTATE108MAC macro POINTORIGIN, POINT
	PUSHS<ax, cx, dx>

	mov ax, word ptr [POINTORIGIN]
	mov word ptr [ORIGIN], ax 
	mov ax, word ptr [POINTORIGIN+2]
	mov word ptr [ORIGIN+2], ax 

	mov cx, word ptr [POINT] ;; x
	mov dx, word ptr [POINT+2] ;; y

	call rotate108

	mov word ptr [POINT], cx ;; x
	mov word ptr [POINT+2], dx ;; y 

	POPS<dx, cx, ax>

endm


ROTATE90MAC macro POINTORIGIN, POINT, DIR

	push ax
	mov ax, word ptr [POINTORIGIN]
	mov word ptr [ORIGIN], ax 
	mov ax, word ptr [POINTORIGIN+2]
	mov word ptr [ORIGIN+2], ax 

	mov cx, word ptr [POINT] ;; x
	mov dx, word ptr [POINT+2] ;; y

	mov al, DIR; por ahora todos van contra reloj

	call rotate90
	pop ax 
endm

MOVTOPOINT macro x, y, POINT
	mov word ptr [POINT], x
	mov word ptr [POINT+2], y
endm

PUSHPOINT macro POINT
	push word ptr [POINT] ;; x
	push word ptr [POINT+2] ;; y
endm 


POPPOINT macro POINT
	pop word ptr [POINT+2] ;; y
	pop word ptr [POINT] ;; x
endm 

MULTCONSIG macro a, b

	PUSHS<cx, dx>
	mov ax, a
	mov cx, b

	imul cx

	POPS<dx, cx>

endm 


DIVIDCONSIG macro divi, divisor
	local positovoAX1

;; retorna el ax
	
	PUSHS<cx, dx>
	mov ax, divi
	mov cx, divisor

	xor dx, dx ; flag si ax era positivo 
 	cmp ax, 0
	jge positovoAX1
	mov dx, 0FFFFH 
positovoAX1:

	idiv cx

	POPS<dx, cx>

endm

GETANGLE macro numerador, denominador, point

;; rs ax
	push cx
	mov ax, point
	mov cx, numerador
	imul cl

	DIVIDCONSIG ax, denominador

	pop cx
endm

XCHGVAR4B macro VAR1, VAR2

	push ax

	mov ax, word ptr [VAR1] 
	xchg ax, word ptr [VAR2] 
	mov word ptr [VAR1], ax


	mov ax, word ptr [VAR1+2] 
	xchg ax, word ptr [VAR2+2] 
	mov word ptr [VAR1+2], ax

	pop ax

endm

IFP1EQUP2THENPOINTRET macro salto 
local noFIn1 
	local nFIn1
	local nFIn1Carry1

	push ax
	salto noFIn1
	jmp nFIn1
noFIn1: ;; se ingresaron 2 puntos, se comparan, si son iguales se dibuja un punto y se retorna	

	mov ax, word ptr [POINT0] 
	cmp ax, word ptr [POINT1]
	jne nFIn1Carry1 ; si x no igual

	mov ax, word ptr [POINT0+2] 
	cmp ax, word ptr [POINT1+2]
	jne nFIn1Carry1 ; si y no igual

	pop ax

	call putPoint
	stc
	ret

nFIn1Carry1:
	stc

nFIn1:
	pop ax

endm

NESTEDFORMAC macro x0, y0, x1, y1, color


	PUSHS<ax, bx, cx, dx, si>
	mov bx, x0
	mov si, y0
	mov ax, x1
	mov cx, y1
	mov dx, color

	call nestedFor

	POPS<si, dx, cx, bx, ax>
endm

