.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Vaporase",0
format db "%d",10,0
format2 db "%d ",0
newline db 10,0
area_width EQU 640
area_height EQU 480
area DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

button_x dd 18 dup(0)
button_y dd 18 dup(0)
len equ ($-button_y)

coord_x dd 0
coord_y dd 0
coord_x2 dd 0
coord_y2 dd 0
table_size equ 400
button_size equ 40 ; latura patratului
nimerit dd 0
nimerit_reset dd 0
ratat dd 0
fail dd 0
fail_reset dd 0
index dd 0
nrSuccess dd 0
nrEsec dd 0
inTabla dd 0
final_joc dd 0
nr_jocuri dd 1
nr1 dd 0
nr2 dd 0
matrice db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		
matriceGen db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

afis macro x
push x
push offset format
call printf
add esp, 8
endm

afis2 macro x
push x
push offset format2
call printf
add esp, 8
endm

coord_matriceX macro x, x0
mov eax, x
mov ebx, 40
mov edx, 0
div ebx

sub eax, 2
mov x0, eax
endm

coord_matriceY macro y, y0
mov eax, y
mov ebx, 40
mov edx, 0
div ebx

sub eax, 1
mov ebx, 10
mul ebx
mov y0, eax
endm

normalizeaza macro x
local bucla, gata
	mov eax, x
	mov ecx, x
	mov ebx, 40
	mov edx, 0
	div ebx
	cmp edx, 0
	je gata
bucla:
	dec ecx
	mov eax, ecx
	mov edx, 0
	div ebx
	cmp edx, 0
	jne bucla
gata:
mov x, ecx
endm

verifica_reset macro found
local cont1, cont2, cont3, cont4, cont5
	mov found, 0
	mov fail_reset, 0
		mov eax, [ebp+arg2]
		cmp eax, 500
		jg cont1
		mov fail_reset, 1
		
		cont1:
		mov ebx, 0
		add ebx, 500
		add ebx, button_size
		cmp eax, ebx
		jl cont2
		mov fail_reset, 1
		
		cont2:
		mov eax, [ebp+arg3]
		cmp eax, 120
		jg cont3
		mov fail_reset, 1
		
		cont3:
		mov ebx, 0
		add ebx, 120
		add ebx, button_size
		cmp eax, ebx
		jl cont4
		mov fail_reset, 1
		
		cont4:
		cmp fail_reset, 1
		je cont5
		mov found, 1
		
	cont5:
endm

verifica_patrat macro pozitie, found
local cont1, cont2, cont3, cont4, cont5
	mov found, 0
	mov fail, 0
	
	mov eax, [ebp+arg2]
	cmp eax, button_x[pozitie]
	jge cont1
	mov fail, 1
		
	cont1:
	mov ebx, 0
	add ebx, button_x[pozitie]
	add ebx, button_size
	cmp eax, ebx
	jle cont2
	mov fail, 1
		
	cont2:
	mov eax, [ebp+arg3]
	cmp eax, button_y[pozitie]
	jge cont3
	mov fail, 1
		
	cont3:
	mov ebx, 0
	add ebx, button_y[pozitie]
	add ebx, button_size
	cmp eax, ebx
	jle cont4
	mov fail, 1
		
	cont4:
	cmp fail, 1
	je cont5
	mov found, 1
		
	cont5:
endm

verifica_tabla macro found
local cont1, cont2, cont3, cont4, cont5
	mov fail, 0
	mov found, 0
	
	mov eax, [ebp+arg2]
	cmp eax, 80
	jg cont1
	mov fail, 1
	cont1:
	cmp eax, 80+table_size
	jl cont2
	mov fail, 1
	cont2:
	mov eax, [ebp+arg3]
	cmp eax, 40
	jg cont3
	mov fail,1
	cont3:
	cmp eax, 40+table_size
	jl cont4
	mov fail, 1
	cont4:
	cmp fail, 1
	je cont5
	mov found, 1
	cont5:
endm

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

line_horizontal macro x, y, len, color
local bucla_lineH
	mov eax, y
	mov ebx, area_width
	mul ebx ; eax = y * area_width
	add eax, x
	shl eax, 2
	add eax, area
	
	mov ecx, len
	bucla_lineH:
		mov dword ptr [eax], color
		add eax, 4
		loop bucla_lineH
endm

line_vertical macro x,y,len,color
local bucla_lineV
	mov eax, y
	mov ebx, area_width
	mul ebx ; eax = y * area_width
	add eax, x ; eax = y * area_width
	shl eax, 2 ; eax = eax * 4
	add eax, area
	
	mov ecx, len
	bucla_lineV:
		mov dword ptr [eax], color
		add eax, area_width * 4
		loop bucla_lineV
endm

coloreaza_patrat macro x,y,culoare
local bucla
mov index, 0
bucla:
	mov ecx, x
	mov edx, y
	add edx, index
	line_horizontal ecx, edx, 40, culoare
	inc index
	cmp index, 40
jl bucla
endm

curata_tabla macro
local bucla1, bucla2
mov esi, 80
bucla1:
	mov edi, 40
	bucla2:
		coloreaza_patrat esi, edi, 0ffffffh
		add edi, 40
		cmp edi, 440
	jle bucla2
	add esi, 40
	cmp esi, 480
jle bucla1
endm

curata_matricea macro
local bucla1, bucla2
mov esi, 0
bucla1:
	mov edi, 0
	bucla2:
		mov matrice[esi][edi], 0
		inc edi
		cmp edi, 10
	jl bucla2
	add esi, 10
	cmp esi, 100
jle bucla1
endm

curata_matriceaGen macro
local bucla1, bucla2
mov esi, 0
bucla1:
	mov edi, 0
	bucla2:
		mov matriceGen[esi][edi], 0
		inc edi
		cmp edi, 10
	jl bucla2
	add esi, 10
	cmp esi, 100
jle bucla1
endm

gen_tabla_noua macro
local bucla_mare, bucla_rand1, bucla_rand2
mov esi, 0

bucla_mare:
	bucla_rand1:
		rdtsc
		mov edx, 0
		mov ebx, 401
		div ebx
		cmp edx, 80
		jle bucla_rand1
		
		normalizeaza edx
		coord_matriceX edx, nr2
	bucla_rand2:
		rdtsc
		mov edx, 0
		mov ebx, 401
		div ebx
		cmp edx, 40
		jle bucla_rand2
		
		normalizeaza edx
		coord_matriceY edx, nr1
	mov eax, nr1
	mov ebx, nr2
	cmp matriceGen[eax][ebx], 1
	je bucla_mare
	
	mov eax, nr1
	mov ebx, nr2
	mov matriceGen[eax][ebx], 1
	; reconstruim pt button_y
	mov edx, 0
	mov ecx, 10
	div ecx
	
	inc eax
	mov ecx, 40
	mul ecx
	mov nr2, eax
	
	; reconstrium pt button_x
	add ebx, 2
	mov eax, ebx
	mov ecx, 40
	mul ecx
	mov nr1, eax
	
	mov ecx, nr1
	mov button_x[esi*4], ecx
	;afis2 button_x[esi*4]
	mov ecx, nr2
	mov button_y[esi*4], ecx
	;afis2 button_y[esi*4]
	;afis2 esi
	;push offset newline
	;call printf
	;add esp, 4
	
	inc esi
	cmp esi, 18
jl bucla_mare
endm

curata_mesaj macro
	make_text_macro ' ', area, 80, 10
	make_text_macro ' ', area, 90, 10
	
	make_text_macro ' ', area, 110, 10
	make_text_macro ' ', area, 120, 10
	make_text_macro ' ', area, 130, 10
	make_text_macro ' ', area, 140, 10
	make_text_macro ' ', area, 150, 10
	
	make_text_macro ' ', area, 170, 10
	make_text_macro ' ', area, 180, 10
	make_text_macro ' ', area, 190, 10
	make_text_macro ' ', area, 200, 10
	make_text_macro ' ', area, 210, 10
	
	make_text_macro ' ', area, 230, 10
	make_text_macro ' ', area, 240, 10
	make_text_macro ' ', area, 250, 10
	make_text_macro ' ', area, 260, 10
	make_text_macro ' ', area, 270, 10
	make_text_macro ' ', area, 280, 10
endm 

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	cmp eax, 3
	jz evt_timer; s-a apasat o tasta
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	mov esi, 0
	mov ratat, 1
	verifica_reset nimerit_reset
	cmp nimerit_reset, 1
	jne not_reset
	; curata tabla
	curata_tabla
	; curata matricile
	curata_matricea
	curata_matriceaGen
	; reseteaza nrSuccess si nrEsec
	mov nrSuccess, 0
	mov nrEsec, 0
	; sterge mesajul de castig, daca se vrea noua partida
	curata_mesaj
	mov final_joc, 0
	; incrementam numarul de jocuri
	inc nr_jocuri
	; dam reset la tabla
	gen_tabla_noua
	not_reset:
	cmp final_joc, 1
	je final_draw
	bucla_patrat:
		verifica_patrat esi, nimerit
		cmp nimerit, 1
	    jne cont
		; s-a lovit un vaporas
		mov inTabla, 0
		verifica_tabla inTabla
		cmp inTabla,1
		jne nxt
		normalizeaza [ebp+arg2]
		normalizeaza [ebp+arg3]
		coord_matriceX [ebp+arg2], coord_y
		coord_matriceY [ebp+arg3], coord_x
		afis coord_x
		afis coord_y
		mov eax, coord_x
		mov ebx, coord_y
		cmp matrice[eax][ebx], 1
		je nxt
		mov matrice[eax][ebx], 1
		mov ecx, 0
		mov cl, matrice[eax][ebx]
		afis ecx
		
		cont1:
		inc nrSuccess
		
		colorat:
		coloreaza_patrat [ebp+arg2], [ebp+arg3], 0ff0000h
		mov ratat, 0
		cont:
		add ESI, 4
		cmp ESI, len
	jl bucla_patrat
	cmp ratat, 1
	jne nxt
	mov inTabla, 0
	verifica_tabla inTabla
	cmp inTabla,1
	jne nxt
	normalizeaza [ebp+arg2]
	normalizeaza [ebp+arg3]
	coord_matriceX [ebp+arg2], coord_y2
	coord_matriceY [ebp+arg3], coord_x2
	afis coord_x2
	afis coord_y2
	mov eax, coord_x2
	mov ebx, coord_y2
	cmp matrice[eax][ebx], 1
	je nxt
	mov matrice[eax][ebx], 1 
	mov ecx, 0
	mov cl, matrice[eax][ebx]
	afis ecx
	
	cont2:
	inc nrEsec
	
	coror:
	coloreaza_patrat [ebp+arg2], [ebp+arg3], 0ffh
	mov eax, [ebp+arg2]
	mov ebx, [ebp+arg3]
	nxt:
	jmp afisare_litere
	
evt_timer:
	;inc counter

afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, nr_jocuri
	
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 550, 200
	
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 540, 200
	
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 530, 200
	
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 520, 200
	
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 510, 200
	
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 500, 200
	
	; facem spatiul de joc
	line_horizontal 80, 40, 400, 0h
	line_horizontal 80, 80, 400, 0h
	line_horizontal 80, 120, 400, 0h
	line_horizontal 80, 160, 400, 0h
	line_horizontal 80, 200, 400, 0h
	line_horizontal 80, 240, 400, 0h
	line_horizontal 80, 280, 400, 0h
	line_horizontal 80, 320, 400, 0h
	line_horizontal 80, 360, 400, 0h
	line_horizontal 80, 400, 400, 0h
	line_horizontal 80, 440, 400, 0h
	
	line_vertical 80, 40, 400, 0h
	line_vertical 120, 40, 400, 0h
	line_vertical 160, 40, 400, 0h
	line_vertical 200, 40, 400, 0h
	line_vertical 240, 40, 400, 0h
	line_vertical 280, 40, 400, 0h
	line_vertical 320, 40, 400, 0h
	line_vertical 360, 40, 400, 0h
	line_vertical 400, 40, 400, 0h
	line_vertical 440, 40, 400, 0h
	line_vertical 480, 40, 400, 0h
	
	; facem un buton de reset
	make_text_macro 'R', area, 500, 100
	make_text_macro 'E', area, 510, 100
	make_text_macro 'S', area, 520, 100
	make_text_macro 'E', area, 530, 100
	make_text_macro 'T', area, 540, 100
	line_horizontal 500, 120, 40, 0h
	line_horizontal 500, 160, 40, 0h
	line_vertical 500, 120, 40, 0h
	line_vertical 540, 120, 40, 0h
	
	; numar de jocuri
	make_text_macro 'N', area, 500, 180
	make_text_macro 'U', area, 510, 180
	make_text_macro 'M', area, 520, 180
	make_text_macro 'A', area, 530, 180
	make_text_macro 'R', area, 540, 180
	
	make_text_macro 'J', area, 560, 180
	make_text_macro 'O', area, 570, 180
	make_text_macro 'C', area, 580, 180
	make_text_macro 'U', area, 590, 180
	make_text_macro 'R', area, 600, 180
	make_text_macro 'I', area, 610, 180
	
	make_text_macro 'R', area, 500, 40
	make_text_macro 'A', area, 510, 40
	make_text_macro 'M', area, 520, 40
	make_text_macro 'A', area, 530, 40
	make_text_macro 'S', area, 540, 40
	make_text_macro 'E', area, 550, 40
	
	make_text_macro 'R', area, 500, 80
	make_text_macro 'A', area, 510, 80
	make_text_macro 'T', area, 520, 80
	make_text_macro 'A', area, 530, 80
	make_text_macro 'R', area, 540, 80
	make_text_macro 'I', area, 550, 80
	
	mov eax, nrEsec
	mov ebx, 10
	mov edx, 0
	div ebx
	add eax, '0'
	make_text_macro eax, area, 570, 80
	add edx, '0'
	make_text_macro edx, area, 580, 80
	
	mov eax, 18
	mov ebx, 10
	sub eax, nrSuccess
	cmp eax, 0
	jne continua
	
	make_text_macro 'A', area, 80, 10
	make_text_macro 'I', area, 90, 10
	
	make_text_macro 'L', area, 110, 10
	make_text_macro 'O', area, 120, 10
	make_text_macro 'V', area, 130, 10
	make_text_macro 'I', area, 140, 10
	make_text_macro 'T', area, 150, 10
	
	make_text_macro 'T', area, 170, 10
	make_text_macro 'O', area, 180, 10
	make_text_macro 'A', area, 190, 10
	make_text_macro 'T', area, 200, 10
	make_text_macro 'E', area, 210, 10
	
	make_text_macro 'N', area, 230, 10
	make_text_macro 'A', area, 240, 10
	make_text_macro 'V', area, 250, 10
	make_text_macro 'E', area, 260, 10
	make_text_macro 'L', area, 270, 10
	make_text_macro 'E', area, 280, 10
	
	make_text_macro '0', area, 580, 40
	make_text_macro '8', area, 580, 80
	mov final_joc, 1
	jmp final_draw
	
	continua:
	mov edx, 0
	div ebx
	add eax, '0'
	make_text_macro eax, area, 570, 40
	add edx, '0'
	make_text_macro edx, area, 580, 40
	
	make_text_macro 'L', area, 500, 60
	make_text_macro 'O', area, 510, 60
	make_text_macro 'V', area, 520, 60
	make_text_macro 'I', area, 530, 60
	make_text_macro 'T', area, 540, 60
	make_text_macro 'E', area, 550, 60
	mov eax, nrSuccess
	mov edx, 0
	div ebx
	add eax, '0'
	make_text_macro eax, area, 570, 60
	add edx, '0'
	make_text_macro edx, area, 580, 60
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	gen_tabla_noua
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	;terminarea programului
	push 0
	call exit
end start
