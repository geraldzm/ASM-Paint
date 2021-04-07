; Gerald Zamora Morales 2020053672, Arquitectura de computadores grupo 2
;
; Este programa muestra trata de sumular un paint
; este programa utiliza un archivo de macros.
; 
; ESC salir
; F1 hasta la F10 cambia de figuras en el orden esperado
; SPACE da clicks
;
; 		Tabla de evaluación
;
; Punto						A
; Linea 					A
; Isóseles	 				B     para calcular los angulos se hace una division, cuando la distancia es mucha rebasa los 2 bytes del ax y se comporta raro, no hacer triangulos muy grandes 
; Equilatero				A
; Escaleno					A
; Cuadrado					A
; Rectangulo				A
; Pentagono					A
; Hexagono					A
; Libre						A
; cambio de colores			A
; herramientas				B 	se muestran todas las herramientas menos la opción de salir
; movimiento 				B   Se mueve en columnas no en pixeles




unico segment

    assume  cs:unico, ds:unico, ss:unico

 org 100h

 start: jmp main 

 ; -------------- DATOS
include ./Macros.ASM
 ;---

; --- cursor
FIL DB 9
COL db 10
DIR db 0 ; 0 abajo 1 arriba 2 derecha 3 izquierda
CURRENT db 0 ; current opcion 0 punto, 1 linea, 2 triangulo equilatero, 3 triangulo Isoseles, 4  triángulo escaleno, 5 Cuadrado, 6 Rectangle, 7 libre, 8 hexagono, 9 Pentagono
CURSOR db '*', 03H   ; Fondo negro y asterisco verde cyan
POINT0 dw 2 dup(0); x, y
POINT1 dw 2 dup(0); x, y

SCALENO db 0 ; flag para marcar el escaleno
POINT3 dw 2 dup(0); x, y


ORIGIN dw 2 dup(0); punto de rotacion

FLAGPOINT db 0; indica cual punto va, 0 = Punto1, 1 = Punto2

BACKUP db 128 dup(0) ; 16x8 respaldamos lo que esta abajo del cursor


; --- end cursor

; -------------- DATOS FIN

switchMenuClick proc 
; dieron click sobre el menu
	; 40 cada columna osea 5 columnas para las opciones
	cmp COL, 5
	JCALLIFANDRET jl, f1Key

	cmp COL, 10
	JCALLIFANDRET jl, f2Key

	cmp COL, 15
	JCALLIFANDRET jl, f3Key

	cmp COL, 20
	JCALLIFANDRET jl, f4Key

	cmp COL, 25
	JCALLIFANDRET jl, f5Key

	cmp COL, 30
	JCALLIFANDRET jl, f6Key

	cmp COL, 35
	JCALLIFANDRET jl, f7Key

	cmp COL, 40
	JCALLIFANDRET jl, f8Key

	cmp COL, 45
	JCALLIFANDRET jl, f9Key

	cmp COL, 50
	JCALLIFANDRET jl, f10Key

	cmp COL, 55
	JCALLIFANDRET jl, f11Key

	cmp COL, 60
	JCALLIFANDRET jl, f12Key

	cmp COL, 65
	JCALLIFANDRET jl, f13Key

	cmp COL, 70
	JCALLIFANDRET jl, f14Key

	cmp COL, 75
	JCALLIFANDRET jl, f15Key

	cmp COL, 80
	JCALLIFANDRET jl, f16Key


	ret 
switchMenuClick endp 


switchTeclas proc 
; ah = codigo, al = ascci
	cmp ah, 01; ESCP
	CONEJO je fin

	; F1 = 3B ....
	cmp ah, 3Bh; f1
	CONEJO je f1Key

	cmp ah, 3Ch; f2
	CONEJO je f2Key

	cmp ah, 3Dh; f3
	CONEJO je f3Key

	cmp ah, 3Eh; f4
	CONEJO je f4Key

	cmp ah, 3Fh; f5
	CONEJO je f5Key

	cmp ah, 40h; f6
	CONEJO je f6Key

	cmp ah, 41h; f7
	CONEJO je f7Key

	cmp ah, 42h; f8
	CONEJO je f8Key

	cmp ah, 43h; f9
	CONEJO je f9Key

	cmp ah, 44h; f10
	CONEJO je f10Key

	cmp ah, 45h; f11
	CONEJO je f11Key

	cmp ah, 46h; f12
	CONEJO je f12Key


	cmp ah, 39h; space
	jne noSpace
	call click
	jmp finSwitchTeclas
noSpace:

	; comparamos si es un enter y si la opcion opcion de libre esta activada
	cmp [CURRENT], 7
	jne noLIbre
	cmp ah, 1Ch ; enter
	jne noLIbre

	; si era enter && opcion libre
	mov SCALENO, -1 ; para indicar que es el ultimo
	call drawLibre 


	jmp finSwitchTeclas



noLIbre:
; ^ 48h v 50h -> 4Dh <- 4Bh
; 0 abajo 1 arriba 2 derecha 3 izquierda

	CMPAHMOVDIRJUMFIN 50h, no0, 0 ; abajo
no0:
	CMPAHMOVDIRJUMFIN 48h, no1, 1 ; arriba
no1:
	CMPAHMOVDIRJUMFIN 4Dh, no2, 2 ; derecha
no2:
	CMPAHMOVDIRJUMFIN 4Bh, finSwitchTeclas, 3 ; izquierda

; si fue una tecla entonces nos movemos:
jmp finSwitchTeclas
finAndMovCursor:
call movCursor

finSwitchTeclas:
	ret
switchTeclas endp

switchOptionstools proc 

	; se valida cada opcion y se llama a su metodo correspondiente

	ret 
switchOptionstools endp

fillPoint proc 
; rec FIL COL (llena el punto que va con esa info)
; ret cf 0=no completo, 1= punto 2 se acaba de llenar
	push cx
	push dx

	call calculatePixelPosition; ret: cx =x, dx=y

	cmp FLAGPOINT, 0
	jne eraPoint2 
	FILPOINTMAC POINT0
	inc [flagpoint]
	clc
	jmp finFillPoint

eraPoint2:
	FILPOINTMAC POINT1
	mov [flagpoint], 0
	stc

finFillPoint:
	pop dx
	pop cx
	ret 
fillPoint endp

putPoint proc
; opcion uno de poner un punto 

	DRAWPIXELMACRO COL, FIL, [CURSOR+1]

	push ax 

	mov al, [CURSOR+1]
	mov BACKUP, al

	pop ax 
	ret
putPoint endp

lineOption proc
	call fillPoint ; ret cf, 1 si tiene los 2 puntos listos
	IFP1EQUP2THENPOINTRET jc
	CALLIF jc drawLine
	ret
lineOption endp


isoselesOption proc
	call fillPoint ; ret cf, 1 si tiene los 2 puntos listos
	IFP1EQUP2THENPOINTRET jc
	CALLIF jc drawIsoseles
	ret
isoselesOption endp

equilateroOption proc
	call fillPoint ; ret cf, 1 si tiene los 2 puntos listos
	IFP1EQUP2THENPOINTRET jc
	CALLIF jc drawEquilatero
	ret
equilateroOption endp

escalenoOption proc
	call fillPoint ; ret cf, 1 si tiene los 2 puntos listos
	IFP1EQUP2THENPOINTRET jc
	CALLIF jc drawEscaleno
	ret
escalenoOption endp

cuadradoOption proc
	call fillPoint ; ret cf, 1 si tiene los 2 puntos listos
	IFP1EQUP2THENPOINTRET jc
	CALLIF jc drawCuadrado
	ret
cuadradoOption endp

rectOption proc
	call fillPoint ; ret cf, 1 si tiene los 2 puntos listos
	IFP1EQUP2THENPOINTRET jc
	CALLIF jc drawRect
	ret
rectOption endp

libreOption proc
	call fillPoint ; ret cf, 1 si tiene los 2 puntos listos
	IFP1EQUP2THENPOINTRET jc
	CALLIF jc drawLibre
	ret
libreOption endp

hexagOption proc
	call fillPoint ; ret cf, 1 si tiene los 2 puntos listos
	CALLIF jc drawHexag
	IFP1EQUP2THENPOINTRET jc
	ret
hexagOption endp

pentaOption proc
	call fillPoint ; ret cf, 1 si tiene los 2 puntos listos
	CALLIF jc drawPenta
	IFP1EQUP2THENPOINTRET jc
	ret
pentaOption endp

f1Key proc 
	mov CURRENT, 0
	mov FLAGPOINT, 0
	ret
f1Key endp 

f2Key proc 

	mov CURRENT, 1
	mov FLAGPOINT, 0

	ret
f2Key endp 

f3Key proc 

	mov CURRENT, 3
	mov FLAGPOINT, 0
	ret
f3Key endp 

f4Key proc 

	mov CURRENT, 2
	mov FLAGPOINT, 0
	ret
f4Key endp 

f5Key proc 

	mov CURRENT, 4
	mov FLAGPOINT, 0
	ret
f5Key endp 

f6Key proc 
	mov CURRENT, 5
	mov FLAGPOINT, 0
	ret
f6Key endp 

f7Key proc 
mov CURRENT, 6
	mov FLAGPOINT, 0
	ret
f7Key endp 

f8Key proc 
	mov CURRENT, 9
	mov FLAGPOINT, 0
	ret
f8Key endp 

f9Key proc 
	mov CURRENT, 8
	mov FLAGPOINT, 0
	ret
f9Key endp 

f10Key proc 
	mov CURRENT, 7
	mov FLAGPOINT, 0
	ret
f10Key endp 

; aqui para abajo son colores
f11Key proc 
	mov [CURSOR+1], green
	ret
f11Key endp 

f12Key proc 
	mov [CURSOR+1], cyan
	ret
f12Key endp 

f13Key proc 
	mov [CURSOR+1], red
	ret
f13Key endp 

f14Key proc 
	mov [CURSOR+1], magenta
	ret
f14Key endp 

f15Key proc 
	mov [CURSOR+1], yellow
	ret
f15Key endp 

f16Key proc 
	mov [CURSOR+1], white
	ret
f16Key endp 

click proc

	; primero validar si esta sobre el menu
	cmp FIL, 27
	jl noSobreMenu

	call switchMenuClick

	jmp click_fueMenu
noSobreMenu:
	; sino sobre menu entonces accion current tool
	; switch de las tools
	cmp [CURRENT], 0
	CALLIFANDRET je, jne, putPoint

	cmp [CURRENT], 1
	CALLIFANDRET je, jne, lineOption

	cmp [CURRENT], 2
	CALLIFANDRET je, jne, equilateroOption

	cmp [CURRENT], 3
	CALLIFANDRET je, jne, isoselesOption

	cmp [CURRENT], 4
	CALLIFANDRET je, jne, escalenoOption

	cmp [CURRENT], 5
	CALLIFANDRET je, jne, cuadradoOption

	cmp [CURRENT], 6
	CALLIFANDRET je, jne, rectOption

	cmp [CURRENT], 7
	CALLIFANDRET je, jne, libreOption

	cmp [CURRENT], 8
	CALLIFANDRET je, jne, hexagOption
	
	cmp [CURRENT], 9
	CALLIFANDRET je, jne, pentaOption

click_fueMenu:

	ret
click endp

movCursor proc
; rc DIR
; mueve el cursor con esa dirección 
	PUSHS<ax, bx, dx>

	;DRAWPOINTM COL, FIL, <byte ptr [BACKUP]>, 0AH;<byte ptr [BACKUP+2]>, <byte ptr [BACKUP]>
	call drawBackUp

	; movemos el cursor
	cmp DIR, 0
	jne cmpotro1 
	inc FIL ; abajo
	jmp finMvShowCursor
cmpotro1:

	cmp DIR, 1
	jne cmpotro2 
	dec FIL ; ariba
	jmp finMvShowCursor

cmpotro2:

	cmp DIR, 2
	jne cmpotro3
	inc COL ; derecha
	jmp finMvShowCursor

cmpotro3:

	cmp DIR, 3
	jne finMoverNada 
	dec COL ; izquierda
	jmp finMvShowCursor

finMvShowCursor: ; muestra el cursor y se sale
	LIMIT FIL, 29, 0
	LIMIT COL, 79, 0
	call showCursor

finMoverNada: 

	POPS<dx, bx, ax>

	ret
movCursor endp 

showCursor proc
; muestra el cursor en pantalla
; respalda lo que este abajo en BACKUP
	PUSHS<ax, bx, cx, dx>
	
	mov dh, FIL
	mov dl, COL

	xor bh, bh
	mov ah, 2h
	int 10h ; setiamos la posicion del cursor

	; respaldamos
	call BackUpCurrent
	; --- respaldamos

	mov ah, 9h
	mov al, CURSOR ; carater
	xor bh, bh ; pagina
	mov bl, [cursor+1] ; color
	xor cx, cx 
	inc cx ; numero de caracteres a imprimir
	int 10h ; imprimimos el cursor

	POPS<dx, cx, bx, ax>
	ret 
showCursor endp 

BackUpCurrent proc
; respalda en la matriz backup todos los pixeles en la posicion FIL COL

	call calculatePixelPosition ; ret: cx =x, dx=y
	;AH=0Dh	 rc  BH = Page Number, CX = x, DX = y	rt AL = Color
	mov ah, 0Dh
	; x 16, y 8
	xor si, si ; mi x
	xor bx, bx ; mi y
	xor di, di ; mi contador

continueY:
	cmp si, 16
	jge finBackup 
		xor bx, bx 
		push cx ; x
	continueX:
		cmp bx, 8
		jge finXBackup
			int 10h ; al color
			mov [BACKUP+di], al
			inc bx
			inc di
			inc cx
		jmp continueX
	finXBackup:
	pop cx
	inc si
	inc dx ; y
	jmp continueY

	finBackup:

	ret 
BackUpCurrent endp

nestedFor proc 
; rc bx = x0, si = y0, ax = x1, cx = y1, dx = color
;; x0 < x1 && y0 < y1

	; local variables
	push bp ; old bp
	sub sp, 6 ; recervamos 2 variables
	mov bp, sp
	;hacemos los push que necesitamos
	PUSHS <ax, bx, cx, dx, di, si>
	; 		<- dp
	; y1 2
	; x1 4
	; old dp
	; --- end variables
	mov word ptr [bp+2], ax ; x1
	mov word ptr [bp+4], cx ; y1

	;AH=0Dh	 rc  BH = Page Number, CX = x, DX = y	rt AL = Color
	mov ah, 0Dh
	mov al, dl
	;si mi y
	;bx mi x


continueYFOR:
	cmp si, word ptr [bp+4]
	jge finBackupFOR 
		push bx ; x
	continueXFOR:
		cmp bx, word ptr [bp+2]
		jge finXBackupFOR
			JDRAWPIXELMACRO bx, si, al
			inc bx
		jmp continueXFOR
	finXBackupFOR:
	pop bx
	inc si
	jmp continueYFOR
	finBackupFOR:


	POPS <si, di, dx, cx, bx, ax>
	
	add sp, 6 ; sacamos las variables
	pop bp 

	ret
nestedFor endp 

drawBackUp proc 
; dibuja el backup en la posicion actual FIL COL
	
	call calculatePixelPosition ; ret: cx =x, dx=y
	;AL = Color, BH = Page Number, CX = x, DX = y
	mov ah, 0Ch
	; x 16, y 8
	xor si, si ; mi x
	xor bx, bx ; mi y
	xor di, di ; mi contador

continueYd:
	cmp si, 16
	jge finBackupd 
		xor bx, bx 
		push cx ; x
		continueXd:
		cmp bx, 8
		jge finXBackupd
			mov al, [BACKUP+di]
			int 10h
			inc bx
			inc di
			inc cx
		jmp continueXd
	finXBackupd:
	pop cx
	inc si
	inc dx ; y
	jmp continueYd

finBackupd:
	ret
drawBackUp endp 


calculatePixelPosition proc
; calcula la posicion del pixel con FIL COL
; ret: cx =x, dx=y
	push ax

	xor ah, ah
	mov al, COL

	mov dx, 8
	mul dl ; 640/80=8 8=pixeles cada columna

	mov cx, ax ; movemos x
	
	xor ah, ah
	mov al, FIL

	mov dx, 16
	mul dl  ; 480/30=16 16=pixeles cada fila

	mov dx, ax ; movemos y

	pop ax
	ret 
calculatePixelPosition endp

drawToolBar proc

	; punto

	; coloreamos de gris la barra de herramientas

	; 10 opciones, 5 de ancho cada cuadro = 50 columnas, 50*8=400
	; 1 de alto, 1*16 = 16
	NESTEDFORMAC 0, 432, 400, 480, darkGray ; pintamos esos cuadros
	; ponemos las figuras en cada cuadrado


	; colores: 6 colors, primeras 5 con 5 columnas, ultima con 4 columnas

	NESTEDFORMAC 400, 432, 440, 480, green ; pintamos esos cuadros

	NESTEDFORMAC 440, 432, 480, 480, cyan ; pintamos esos cuadros

	NESTEDFORMAC 480, 432, 520, 480, red ; pintamos esos cuadros

	NESTEDFORMAC 520, 432, 560, 480, magenta ; pintamos esos cuadros

	NESTEDFORMAC 560, 432, 600, 480, yellow ; pintamos esos cuadros

	NESTEDFORMAC 600, 432, 640, 480, white ; pintamos esos cuadros

	; lineas que separan las figuras
	mov cx, 10
	xor ax, ax
lineasOp:
	add ax, 40
	mov word ptr [POINT0], ax 
	mov word ptr [POINT0+2], 432 

	mov word ptr [POINT1], ax 
	mov word ptr [POINT1+2], 480 

	call drawLine

loop lineasOp


	; figuras: ; alto 48 ancho 40 cada una
	; comenzando de x = 0 y = 432, hasta 400, 480

	mov cx, 20 ; 
	mov dx, 456
	mov al, [CURSOR+1]
	call drawPixel ; punto

	; linea
	mov word ptr [POINT0], 70 
	mov word ptr [POINT0+2], 440 

	mov word ptr [POINT1], 50 
	mov word ptr [POINT1+2], 470 

	call drawLine ; linea

	; isósceles

	mov word ptr [POINT0], 100 
	mov word ptr [POINT0+2], 440 

	mov word ptr [POINT1], 100 
	mov word ptr [POINT1+2], 475 

	call drawIsoseles

	;equilátero

	mov word ptr [POINT0], 140 
	mov word ptr [POINT0+2], 440 

	mov word ptr [POINT1], 125 
	mov word ptr [POINT1+2], 470 

	call drawEquilatero

	; 3 puntos trian
	mov word ptr [POINT0], 180 
	mov word ptr [POINT0+2], 440 

	mov word ptr [POINT1], 165 
	mov word ptr [POINT1+2], 470 

	call drawEquilatero

	; cuadro
	mov word ptr [POINT0], 205 
	mov word ptr [POINT0+2], 440 

	mov word ptr [POINT1], 205 
	mov word ptr [POINT1+2], 470 

	call drawCuadrado

	; rectangle
	mov word ptr [POINT0], 245 
	mov word ptr [POINT0+2], 440 

	mov word ptr [POINT1], 275 
	mov word ptr [POINT1+2], 465 

	call drawRect

	; pentagono

	mov word ptr [POINT0], 285 
	mov word ptr [POINT0+2], 470 

	mov word ptr [POINT1], 310 
	mov word ptr [POINT1+2], 470 

	call drawPenta

	; hexagono
	
	mov word ptr [POINT0], 325 
	mov word ptr [POINT0+2], 470 

	mov word ptr [POINT1], 348 
	mov word ptr [POINT1+2], 470 

	call drawHexag

	; libre
	mov word ptr [POINT0], 365 
	mov word ptr [POINT0+2], 440 

	mov word ptr [POINT1], 388 
	mov word ptr [POINT1+2], 470 

	call drawLine ; linea

	mov word ptr [POINT1], 388 
	mov word ptr [POINT1+2], 440 

	call drawLine ; linea
	
	mov word ptr [POINT0], 365 
	mov word ptr [POINT0+2], 470 

	call drawLine ; linea

	
	ret
drawToolBar endp

drawPixel proc
; pinta el pixel que le digamos
; rec al = color, cx = x, dx = y
	PUSHS <ax, bx>

	mov ah, 0Ch
	xor bh, bh ; pagina
	int 10h ; imprimimos el pixel

	POPS <bx, ax>
	ret
drawPixel endp

drawPoint proc
; pinta el punto que le pasemos
; rec al = letter, bl = color, dh = x, dl = y
	PUSHS <ax, bx, cx>

	mov ah, 9h
	xor bh, bh ; pagina
	xor cx, cx 
	inc cx ; numero de caracteres a imprimir
	int 10h ; imprimimos el cursor
	POPS <cx, bx, ax>
	ret
drawPoint endp

; drawing line stuff 
plotLineLow proc
; rec POINT0, POINT1
	; local variables
	push bp ; old bp
	sub sp, 10 ; recervamos 4 variables
	mov bp, sp
	;hacemos los push que necesitamos
	PUSHS <ax, bx, di, si>
	; 		<- dp
	; D 2
	; yi 4
	; dy 6
	; dx 8
	; old dp
	; --- end variables
	
	mov ax, word ptr [POINT1] ; x1
	sub ax, word ptr [POINT0] ; x1 - x0
	mov word ptr [bp+8], ax ; dx

	mov ax, word ptr [POINT1+2] ; y1
	sub ax, word ptr [POINT0+2] ; y1 - y0
	mov word ptr [bp+6], ax ; dy

	mov word ptr [bp+4], 1 ; yi = 1
	
	cmp word ptr [bp+6], 0
	jge noNegativoll ; if dy < 0
		mov word ptr [bp+4], -1 ; yi = -1
		mov ax, word ptr [bp+6] ; dy
		mov bx, 0FFFFh ; todos en 1
		xor ax, bx 
		inc ax ; lo complementamos, dy = -dy
		mov word ptr [bp+6], ax ; dx
noNegativoll:

	mov ax, word ptr [bp+6] ; dy
	shl ax, 1 ; 2 * dy
	sub ax, word ptr [bp+8]  ; 2 * dy - dx
	mov word ptr [bp+2], ax ; movemos eso al D

	mov si, word ptr [POINT0] ; x0 si va a ser mi x
	mov di, word ptr [POINT0+2] ; y0 di va a ser mi y

	; rango, x0 va a ser menor
	mov cx, word ptr [POINT1] ; x1
	sub cx, word ptr [POINT0]; x1 - x0
forLineHighl: 

		JDRAWPIXELMACRO si, di, <byte ptr [CURSOR+1]> ;; pintamos
		inc si; rango x0 hasta x1

		cmp word ptr [bp+2], 0 ; if D > 0
		jl dmayorl
			add di, word ptr [bp+4] ; y = y + yi
			mov ax, word ptr [bp+6] ; dy
			sub ax, word ptr [bp+8] ; dy - dx
			shl ax, 1 ; 2 * (dy - dx)
			add word ptr [bp+2], ax; D
			
			loop forLineHighl ; continuamos el for
			jmp finLoopYl
		dmayorl: ; else
			mov ax, word ptr [bp+6] ; dy
			shl ax, 1 ; 2 * dy
			add word ptr [bp+2], ax ; D += 2*dy
		loop forLineHighl ; continuamos el for
		jmp finLoopYl
finLoopYl:

	POPS <si, di, bx, ax>
	
	add sp, 10 ; sacamos las variables
	pop bp 

	ret
plotLineLow endp

plotLineHigh proc
; rec POINT0, POINT1
	; local variables
	push bp ; old bp
	sub sp, 10 ; recervamos 4 variables
	mov bp, sp
	;hacemos los push que necesitamos
	PUSHS <ax, bx, di, si>
	; 		<- dp
	; D 2
	; xi 4
	; dy 6
	; dx 8
	; old dp
	; --- end variables
	
	mov ax, word ptr [POINT1] ; x1
	sub ax, word ptr [POINT0] ; x1 - x0
	mov word ptr [bp+8], ax ; dx

	mov ax, word ptr [POINT1+2] ; y1
	sub ax, word ptr [POINT0+2] ; y1 - y0
	mov word ptr [bp+6], ax ; dy

	mov word ptr [bp+4], 1 ; xi = 1
	
	cmp word ptr [bp+8], 0
	jge noNegativo ; if dx < 0
		mov word ptr [bp+4], -1 ; xi = -1
		mov ax, word ptr [bp+8] ; dx
		mov bx, 0FFFFh ; todos en 1
		xor ax, bx 
		inc ax ; lo complementamos, dx = -dx
		mov word ptr [bp+8], ax ; dx
noNegativo:

	mov ax, word ptr [bp+8] ; dx
	shl ax, 1 ; 2 * dx 
	sub ax, word ptr [bp+6]  ; 2 * dx - dy
	mov word ptr [bp+2], ax ; movemos eso al D

	mov si, word ptr [POINT0] ; x0 si va a ser mi x
	mov di, word ptr [POINT0+2] ; y0 di va a ser mi y

	; rango, y0 va a ser menor
	mov cx, word ptr [POINT1+2] ; y1
	sub cx, word ptr [POINT0+2]; y1 - y0
forLineHigh: 

		JDRAWPIXELMACRO si, di, <byte ptr [CURSOR+1]> ;; pintamos
		inc di; rango y0 hasta y1

		cmp word ptr [bp+2], 0 ; if D > 0
		jl dmayor
			add si, word ptr [bp+4] ; x = x + xi
			mov ax, word ptr [bp+8] ; dx
			sub ax, word ptr [bp+6] ; dx - dy
			shl ax, 1 ; 2 * (dx - dy)
			add word ptr [bp+2], ax; D
			
			loop forLineHigh ; continuamos el for
			jmp finLoopY
		dmayor: ; else
			mov ax, word ptr [bp+8] ; dx
			shl ax, 1 ; 2 * dx
			add word ptr [bp+2], ax ; D += 2*dx
		loop forLineHigh ; continuamos el for
		jmp finLoopY
finLoopY:

	POPS <si, di, bx, ax>
	
	add sp, 10 ; sacamos las variables
	pop bp 

	ret
plotLineHigh endp

drawLine proc
; decide cual algoritmo usar para dibujar la linea
; dibuja la linea con los 2 puntos POINT0 y POINT1
	PUSHS<ax, bx, cx, dx>
	push word ptr [POINT0]
	push word ptr [POINT0+2]
	push word ptr [POINT1]
	push word ptr [POINT1+2]


	mov ax, word ptr [POINT1+2] ; y1
	sub ax, word ptr [POINT0+2] ; y1 - y0
	cmp ax, 0
	jge noNegativoL
	mov bx, 0FFFFh ; todos en 1
	xor ax, bx 
	inc ax ; lo ponemos positivo	 
noNegativoL:
	mov bx, ax ; bx = y1 - y0
	mov ax, word ptr [POINT1] ; x1
	sub ax, word ptr [POINT0] ; x1 - x0
	cmp ax, 0
	jge noNegativoL2
	mov dx, 0FFFFh ; todos en 1
	xor ax, dx 
	inc ax ; lo ponemos positivo	
noNegativoL2:
	cmp bx, ax ; if
	jg HighLines ; cmp abs(y1-y0) > abs(x1 - x0)
	;dentro del if
	mov ax, word ptr [POINT0] ; x0
	cmp ax, word ptr [POINT1] ; cmp x0, x1
	jg x0Mayor ; if x0 > x1

		call plotLineLow ; posiciones quedan normal

	jmp findrawlines
	x0Mayor:

		; x1, y1, x0, y0 se invierte
		mov ax, word ptr [POINT0] ; x0
		xchg ax, word ptr [POINT1]; x1
		mov word ptr [POINT0], ax

		mov ax, word ptr [POINT0+2] ; y0
		xchg ax, word ptr [POINT1+2]; y1
		mov word ptr [POINT0+2], ax

		call plotLineLow ; posiciones quedan normal

	jmp findrawlines
HighLines: ; else
	;dentro del else
	mov ax, word ptr [POINT0+2] ; y0
	cmp ax, word ptr [POINT1+2] ; cmp y0, y1
	jg y0Mayor ; if y0 > y1

		call plotLineHigh ; posiciones quedan normal
	
	jmp finDrawLines
	y0Mayor: ; else
		; x1, y1, x0, y0 se invierte
		mov ax, word ptr [POINT0] ; x0
		xchg ax, word ptr [POINT1]; x1
		mov word ptr [POINT0], ax

		mov ax, word ptr [POINT0+2] ; y0
		xchg ax, word ptr [POINT1+2]; y1
		mov word ptr [POINT0+2], ax

		call plotLineHigh ; posiciones quedan normal
		
finDrawLines:


	pop word ptr [POINT1+2]
	pop word ptr [POINT1]
	pop word ptr [POINT0+2]
	pop word ptr [POINT0]
	POPS<dx, cx, bx, ax>


	ret
drawLine endp

drawIsoseles proc

	PUSHPOINT POINT1

	; cos(PI/12) aprox = 96/100
	; sin(PI/12) aprox = 25/100

	mov ax, word ptr [point1]
	sub ax, word ptr [point0]

	mov bx, word ptr [point1+2]
	sub bx, word ptr [point0+2]

	push ax  ; x, y restados
	push bx 
	; 1. sacar x = xCos - ySin

	GETANGLE 96, 100, ax ; xCos

	xchg ax, bx

	GETANGLE 25, 100, ax ; ySin

	xchg ax, bx

	sub ax, bx ; xCos - ySin

	add ax, word ptr [point0] ; le sumamos el punt y queda el X
	mov word ptr [point1], ax

	; 2. sacar el y= xSin + yCos
	pop bx ; valores restados
	pop ax 

	GETANGLE 25, 100, ax ; xSin

	xchg ax, bx

	GETANGLE 96, 100, ax ; yCos

	xchg ax, bx

	add ax, bx ;  xSin + yCos

	add ax, word ptr [point0+2] ; le sumamos el punt y queda el Y
	mov word ptr [point1+2], ax

	call drawLine

	
	; ahora rotamos para el otro lado 
	; xCos + ySin = x
	; -xSin + yCos = y

	; respladamos el punto de la primera linea

	mov ax, word ptr [point1]
	mov bx, word ptr [point1+2]

	POPPOINT POINT1 ; sacamos el punto del centro
	push ax ; respladamos el punto
	push bx

	mov ax, word ptr [point1] ; movemos el punto del centro para el nuevo angulo
	mov bx, word ptr [point1+2]

	sub ax, word ptr [point0]
	sub bx, word ptr [point0+2]

	push ax  ; x, y restados
	push bx 

	; 1. xCos + ySin = x
	GETANGLE 96, 100, ax ; xCos
	xchg ax, bx
	GETANGLE 25, 100, ax ; ySin
	xchg ax, bx
	add ax, bx ; xCos + ySin
	add ax, word ptr [point0] ; le sumamos el punt y queda el X
	mov word ptr [point1], ax ; el x

	;2.-xSin + yCos = y
	pop bx 
	pop ax
	xchg ax, bx
	GETANGLE 96, 100, ax ;yCos
	xchg ax, bx
	GETANGLE 25, 100, ax ; xSin
	
	sub bx ,ax ; yCos - xSin
	add bx, word ptr [point0+2] ; le sumamos el punt y queda el Y
	mov word ptr [point1+2], bx ; el y

	call drawLine
	
	POPPOINT POINT0 ; sacamos el punto del centro

	call drawLine


	ret 
drawIsoseles endp 

drawPenta proc

	PUSHPOINT POINT0
	
	call drawLine

	ROTATE108MAC POINT1, POINT0

	call drawLine

	ROTATE108MAC POINT0, POINT1
	
	call drawLine

	ROTATE108MAC POINT1, POINT0
	
	call drawLine

	POPPOINT POINT1

	call drawLine

	ret 
drawPenta endp

drawHexag proc 

	PUSHPOINT POINT0
	
	call drawLine

	ROTATE60MAC POINT1, POINT0
	ROTATE60MAC POINT1, POINT0

	call drawLine

	ROTATE60MAC POINT0, POINT1
	ROTATE60MAC POINT0, POINT1

	call drawLine

	ROTATE60MAC POINT1, POINT0
	ROTATE60MAC POINT1, POINT0

	call drawLine

	ROTATE60MAC POINT0, POINT1
	ROTATE60MAC POINT0, POINT1

	call drawLine

	POPPOINT POINT0

	call drawLine

	ret 
drawHexag endp 

drawLibre proc 


	cmp SCALENO, 0
	jne drawLibre_noPrimero

	; respaldamos el primer punto
	mov ax, word ptr [POINT0]
	mov word ptr [POINT3], ax

	mov ax, word ptr [POINT0+2]
	mov word ptr [POINT3+2], ax

	inc [SCALENO]
	jmp drawLibre_NoEnter
drawLibre_noPrimero:

	cmp SCALENO, -1
	jne drawLibre_NoEnter
	; enter 

	XCHGVAR4B POINT3, POINT1

	call drawLine

	mov FLAGPOINT, 0
	mov SCALENO, 0

	jmp drawLibre_fin
drawLibre_NoEnter:

	call drawLine

	mov FLAGPOINT, 1 ; para que siga entrando
	
	XCHGVAR4B POINT0, POINT1

drawLibre_fin:

	ret
drawLibre endp

drawRect proc 



	; comparamos si hay posiciones iguales
	mov ax, word ptr [POINT0+2]
	cmp ax, word ptr [POINT1+2]
	je drawRect_iguales

	mov ax, word ptr [POINT0]
	cmp ax, word ptr [POINT1]
	je drawRect_iguales

	; primero x0, y0 con x1, y0
	PUSHPOINT POINT1 ;respaldamos el 1

	mov ax, word ptr [POINT0+2]
	mov word ptr [POINT1+2], ax ; y0

	call drawLine

	POPPOINT POINT1

	PUSHPOINT POINT1 ;respaldamos el 1

	; ahora  x0, y0 con x0, y1
	mov ax, word ptr [POINT0]
	mov word ptr [POINT1], ax ; x1

	call drawLine

	POPPOINT POINT1

	PUSHPOINT POINT0 ;respaldamos el 0

	; ahora  x0, y1 con x1, y1
	mov ax, word ptr [POINT1+2]
	mov word ptr [POINT0+2], ax ; y1

	call drawLine 

	POPPOINT POINT0
	; ahora  x1, y0 con x1, y1
	mov ax, word ptr [POINT1]
	mov word ptr [POINT0], ax ; x1

	call drawLine  

	jmp drawRect_fin
drawRect_iguales:

	call drawLine  

drawRect_fin:
	ret
drawRect endp 

drawCuadrado proc 

	call drawLine ; base

	mov cx, word ptr POINT0
	mov al, -1 ; contra reloj
	cmp cx, word ptr POINT1 
	jge drawCuadrado_contraRej
	mov al, 1
drawCuadrado_contraRej:

	ROTATE90MAC POINT0, POINT1, al
	mov word ptr POINT1, cx
	mov word ptr [POINT1+2], dx
	call drawLine

	ROTATE90MAC POINT1, POINT0, al
	mov word ptr POINT0, cx
	mov word ptr [POINT0+2], dx
	call drawLine

	ROTATE90MAC POINT0, POINT1, al
	mov word ptr POINT1, cx
	mov word ptr [POINT1+2], dx
	call drawLine



drawCuadrado_fin:

	ret
drawCuadrado endp 

drawEscaleno proc 

	call drawLine ; segnunda vez, dibujamos la linea entre los 2 putnos

	cmp byte ptr SCALENO, 1
	je isThird

	; segunda vez
		; respaldamos el primer punto
	XCHGVAR4B POINT3, POINT0 
		; movemos el segundo punto al primero para dibujar entre el segundo punto y el siguiente
	XCHGVAR4B POINT0, POINT1 
	mov [FLAGPOINT], 1 ; para que tomo el siguiente punto en el POINT2 y entre aqui
	mov [SCALENO], 1 ; para indicar que va a ser la tercera vez con el punto
	jmp drawEscaleno_fin

isThird:
	; si esta es la tercera vez que preciona la tecla 

	
	call drawLine ; entre el 1 y el 2
	XCHGVAR4B POINT3, POINT0 ; recuperamos el 0
	call drawLine ; entre el 0 y el 2

	mov [SCALENO], 0

falta3:

drawEscaleno_fin:

	ret 
drawEscaleno endp

drawEquilatero proc

	;1. dibujamos la linea entre esos 2 puntos
	call drawLine

	PUSHPOINT POINT0
	PUSHPOINT POINT1
	

	; cos(PI/3) aprox = 100/200
	; sin(PI/3) aprox = 86/100

	; 1. restamos al punto 0 el punto 1, para girar el 0 con base en el 1
	mov ax, word ptr [point0]
	sub ax, word ptr [point1]

	mov bx, word ptr [point0+2]
	sub bx, word ptr [point1+2]

	push ax  ; x, y restados
	push bx 

	; 2. sacamos el x = xCos - ySin
	
	DIVIDCONSIG ax, 2 ; xCos

	push ax ; xCos

	mov ax, bx
	mov cx, 86
	
	imul cl

	DIVIDCONSIG ax, 100 ; ySin = ax


	mov bx, ax
	pop ax 

	sub ax, bx ; xCos - ySin = x

	mov word ptr [point0], ax ; guardamos el x	

	pop bx ;y los puntos restados
	pop ax ;x

	;3. sacar y
	; y = xSin + yCos
	mov cx, 86 ; sin
	imul cl
	
	DIVIDCONSIG ax, 100 ; xSin
	
	push ax ; xSin

	mov ax, bx
	DIVIDCONSIG ax, 2 ; yCos

	mov bx, ax ; yCos
	pop ax ; xSin

	add ax, bx; xSin + yCos

	mov word ptr [point0+2], ax ; guardamos el x	

	;4. sumar de nuevo el punto 1 ya que se esta rotando con base a el
	mov ax, word ptr [point1];x
	add word ptr [point0], ax 

	mov ax, word ptr [point1+2];y
	add word ptr [point0+2], ax 

	; en el punto 0 quedo el punto rotado

	POPPOINT POINT1
	call drawLine
	POPPOINT POINT1
	call drawLine



	ret
drawEquilatero endp
; --- end drawing line stuff 

; start rotation stuff

rotate108 proc 
; rota 108 grados el punto en base al ORIGIN, la direccion depende de los parametros
; rc CX = x, DX = y
; rt CX = x, DX = y con el nuevo punto
	; COS(3PI/5) = -30/100
	; SIN(3PI/5) = 95/100

	; x = (xCos - ySin)
	; y = (xSin + yCos)
	PUSHS<ax, bx>

	;1. restamos para girar en base a ese punto 
	mov ax, word ptr [ORIGIN]
	sub cx, ax

	mov bx, word ptr [ORIGIN+2]
	sub dx, bx

	push cx  ; x, y restados
	push dx 

	mov ax, cx 
	mov bx, dx
	; 2. sacamos el x = xCos - ySin
	MULTCONSIG ax, -30; xCos
	DIVIDCONSIG ax, 100 ; xCos
	push ax ; xCos

	mov ax, bx

	MULTCONSIG ax, 95
	DIVIDCONSIG ax, 100 ; ySin = ax
	mov bx, ax
	
	pop ax 

	sub ax, bx 

	mov cx, ax; xCos - ySin = x
	
	pop bx ;y los puntos restados
	pop ax ;x

	push cx ; xCos - ySin = x

	;3. sacar y
	; y = xSin + yCos
	MULTCONSIG ax, 95
	DIVIDCONSIG ax, 100 ; xSin = ax
	push ax ; xSin

	mov ax, bx
	MULTCONSIG ax, -30; yCos
	DIVIDCONSIG ax, 100 ; yCos
	mov bx, ax ; yCos

	pop ax ; xSin

	add ax, bx; xSin + yCos

	mov dx, ax ; y
	pop cx; x

	mov ax, word ptr [ORIGIN]
	add cx, ax

	mov bx, word ptr [ORIGIN+2]
	add dx, bx

	POPS<bx, ax>

	ret
rotate108 endp 

rotate60 proc
; rota 60 grados el punto en base al ORIGIN, la direccion depende de los parametros
; rc CX = x, DX = y
; rt CX = x, DX = y con el nuevo punto

	PUSHS<ax, bx>

	;1. restamos para girar en base a ese punto 
	mov ax, word ptr [ORIGIN]
	sub cx, ax

	mov bx, word ptr [ORIGIN+2]
	sub dx, bx

	push cx  ; x, y restados
	push dx 

	mov ax, cx 
	mov bx, dx
	; 2. sacamos el x = xCos - ySin
	
	DIVIDCONSIG ax, 2 ; xCos
	push ax ; xCos

	mov ax, bx
	MULTCONSIG ax, 86

	DIVIDCONSIG ax, 100 ; ySin = ax

	mov bx, ax
	pop ax 

	sub ax, bx 

	mov cx, ax; xCos - ySin = x
	
	pop bx ;y los puntos restados
	pop ax ;x

	push cx ; xCos - ySin = x

	;3. sacar y
	; y = xSin + yCos

	MULTCONSIG ax, 86; sixSinn

	DIVIDCONSIG ax, 100 ; xSin
	
	push ax ; xSin

	mov ax, bx
	DIVIDCONSIG ax, 2 ; yCos

	mov bx, ax ; yCos
	pop ax ; xSin

	add ax, bx; xSin + yCos

	mov dx, ax ; y
	pop cx; x

	mov ax, word ptr [ORIGIN]
	add cx, ax

	mov bx, word ptr [ORIGIN+2]
	add dx, bx
	
	POPS<bx, ax>
	ret
rotate60 endp

rotate90 proc
; rota 90 grados el punto en base al ORIGIN, la direccion depende de los parametros
; rc CX = x, DX = y, al = direccion, -1 contra reloj, 1 reloj 
; rt CX = x, DX = y con el nuevo punto

	PUSHS <ax, bx>

	mov bx, cx ; bx = x
	xor cx, cx 
	inc cx ; para que se haga 1 vez minimo

	cmp al, -1
	je contrRej ; if solo se hace una vez salte
	; si va en la direccion del reloj
	inc cx ; para que se haga 3 
	inc cx ; para que se haga 3, 270 grados

contrRej: ; bx, dx

	;1. al punto se le resta el origen
	sub bx, word ptr [ORIGIN]  
	sub dx, word ptr [ORIGIN+2] 

	;2. se pone la y negativa 
	xor dx, 0FFFFH
	inc dx

	;3. se intercambia x,y por y,x
	xchg bx, dx

	;4. se suma el origen
	add bx, word ptr [ORIGIN]
	add dx, word ptr [ORIGIN+2]

	loop contrRej

	mov cx, bx ; pasamos el x porque ser retorna en el cx

	POPS <bx, ax>


	ret 
rotate90 endp

; --- end rotation stuff


;	AH=02h	BH = Page Number, DH = Row, DL = Column
setCursorPosition proc
; setea la posicion del cursor en el lugar 
; rec DH = Row, DL = Column
	PUSHS <ax, bx>
	mov ah, 02h
	mov bh, 0
	int 10h ; mueve el cursor
	POPS <bx, ax>
	ret
setCursorPosition endp

getInput proc
; pide el input, y hace el algo de acuerdo a lo que ingresaron

	mov ah, 00H ; rt ax, al=ascii, ah=code
	int 16H

	call switchTeclas
	ret 
getInput endp

init proc
    ; setiamos el modo de video
    mov ax, 12h
    int 10h

    ret 
init endp
 ; -------------- PROCEDIMIENTOS FIN


main: 
	
	;mov ax, -40
	;mov cx, 2
	;mov dx, 0FFFFH 
	;idiv cx ; xCos = ax
	
;	mov ax, -40
;	mov cx, 2
;	xor dx, dx 
;	div cx ; xCos = ax
	
;	jmp fin
	; pruebas
    call init
	call drawToolBar
	call showCursor

loopTeclas: ; no sale a menos que sea ESC
	call getInput
	jmp loopTeclas

fin:
    mov ax, 4C00h    ; protocolo de finalización del programa.
    int 21h
     
unico ends

end start

