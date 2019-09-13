.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc
include \masm32\macros\macros.asm
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\masm32.lib

.data

;-------    STRINGS   -----------

output  db 10 dup(0)									;	String seguida de nova linha e fim_de_string
write_count dd 0										;	Variavel para armazenar caracteres escritos na console
_input   db 10 dup(0)									;	String seguida de nova linha e fim_de_string
write_c dd 0
_str	db 10 dup(0)
write_str	dd 0

bemVindo db "Bem vindo ao robo furador em assembly :)", 0ah, 0ah
texto1   db "Digite o eixo X INICIAL: ", 0h
texto2  db "Digite o eixo Y INICIAL: ", 0h
texto3  db "Digite o eixo X FINAL: ", 0h
texto4  db "Digite o eixo Y FINAL: ", 0h
texto5  db "Digite a quantidade de furos: ", 0h
texto6  db "Deseja executar novamente o programa? 's' Sim 'n' = Nao ", 0ah, 0ah
texto7 db "X: ", 0h 
texto8 db "Y: ", 0h
texto9 db " ", 0ah


respostas  db "Furos feitos: ", 0h
erro  db "Nao foi possivel realizar os furos", 0h




;-------    HANDLES   -----------
chaveSaida   dd 0
chaveEntrada dd 0

;-------    CONSTANTES   -----------


_reset  real8 0.0
incr    real8 1.0

;-------    VARIAVEIS   -----------
numFurosInt dd 0

numFuros real8 0.0

cordFuroXinicial real8 0.0         ; variáveis para o eixo X
cordFuroXfinal real8 0.0
subtraidoX real8 0.0
distanciaX real8 0.0

cordFuroYinicial real8 0.0         ; variáveis para o eixo Y
cordFuroYfinal real8 0.0
subtraidoY real8 0.0
distanciaY real8 0.0

resultCalcDistriX real8 0.0
resultCalcDistriY real8 0.0


.code  
start:

	call OBTER_HANDLES

	
            invoke WriteConsole, chaveSaida, addr bemVindo, sizeof bemVindo, addr write_count, NULL

	WHILE_TRUE:

        call RESET_REG	

		invoke WriteConsole, chaveSaida, addr texto5, sizeof texto5, addr write_count, NULL	;	imprime na tela
		invoke ReadConsole, chaveEntrada, addr _input, sizeof _input, addr write_c, NULL;   lê a quantidade de furos
		
            ;INICIO DO PROCEDIMENTO PARA FAZER A STRING DO NUMERO INTEIRO TERMINAR COM \0, AO INVES DE \r \n \0
            mov esi, offset _input ; Armazenar apontador da string em esi
     proximo:
            mov al, [esi] ; Mover caracter atual para al
            inc esi ; Apontar para o proximo caracter
            cmp al, 48 ; Verificar se menor que ASCII 48 - FINALIZAR
            jl  terminar
            cmp al, 58 ; Verificar se menor que ASCII 58 - CONTINUAR
            jl  proximo
     terminar:
            dec esi ; Apontar para caracter anterior
            xor al, al ; 0 ou NULL
            mov [esi], al ; Inserir NULL logo apos o termino do numero
            ;FIM DO PROCEDIMENTO PARA REMOCAO DO \r \n

            invoke atodw, addr _input ; Converte string 'input' para inteiro de 32 bits - resultado gravado em eax
            mov numFurosInt, eax        ; Move conteudo de eax da instrucao anterior para variavel inteira de 32 bits


            invoke StrToFloat, addr [_input], addr [numFuros]

            ;   Obtem as coordenadas iniciais e finais do eixo X

		invoke WriteConsole, chaveSaida, addr texto3, sizeof texto3, addr write_count, NULL	;	imprime na tela
		invoke ReadConsole, chaveEntrada, addr _input, sizeof _input, addr write_c, NULL	;	Captura o dado pelo teclado
        invoke StrToFloat, addr [_input], addr [cordFuroXfinal]   ; envia para a pilha a coord X final

        invoke WriteConsole, chaveSaida, addr texto1, sizeof texto1, addr write_count, NULL	;	imprime na tela
		invoke ReadConsole, chaveEntrada, addr _input, sizeof _input, addr write_c, NULL	;	Captura o dado pelo teclado
        invoke StrToFloat, addr [_input], addr [cordFuroXinicial]     ; envia para a pilha a coord X Inicial




        

        ;   Obtem as coordenadas iniciais e finais do eixo Y


        invoke WriteConsole, chaveSaida, addr texto4, sizeof texto4, addr write_count, NULL	;	imprime na tela
		invoke ReadConsole, chaveEntrada, addr _input, sizeof _input, addr write_c, NULL	;	Captura o dado pelo teclado
        invoke StrToFloat, addr [_input], addr [cordFuroYfinal] 

        invoke WriteConsole, chaveSaida, addr texto2, sizeof texto2, addr write_count, NULL	;	imprime na tela
		invoke ReadConsole, chaveEntrada, addr _input, sizeof _input, addr write_c, NULL	;	Captura o dado pelo teclado
        invoke StrToFloat, addr [_input], addr [cordFuroYinicial] 


			
            	call FUNCAO_CALCINICIALX
                call FUNCAO_CALCFINALX              ; resultado na var distanciaX (dividido por numFuros)

                call FUNCAO_CALCINICIALY
                call FUNCAO_CALCFINALY 

                call COPIA_CONTEUDOX
                call COPIA_CONTEUDOY


        invoke StrToFloat, addr [_input], addr [numFuros]

        invoke WriteConsole, chaveSaida, addr texto7, sizeof texto7, addr write_count, NULL
        invoke FloatToStr, [cordFuroXinicial], addr [output]          ; printa a distancia entre os furos no eixo Y
        invoke WriteConsole, chaveSaida, addr output, sizeof output, addr write_count, NULL

        invoke WriteConsole, chaveSaida, addr texto8, sizeof texto8, addr write_count, NULL
        invoke FloatToStr, [cordFuroYinicial], addr [output]          ; printa a distancia entre os furos no eixo Y
        invoke WriteConsole, chaveSaida, addr output, sizeof output, addr write_count, NULL

        invoke WriteConsole, chaveSaida, addr texto9, sizeof texto9, addr write_count, NULL





;######################### LAÇO PARA PRINTAR NA TELA AS DISTANCIAS #########################
        mov eax, [numFurosInt]              ; vamos usar eax para guardar o valor limite do laco. Pode ser outro registrador ou variavel
        ;dec eax                          ; eax = numFuros - 1
        xor ecx, ecx                     ; vamos usar ecx como contador do laco (variavel "i"). Essa instrucao inicializa o registrador com 0
    inicio_laco_1:
         push eax                        ; guarda na pilha de memoria o valor de eax, para evitar que ele seja sobrescrito
         push ecx                        ; guarda na pilha de memoria o valor de ecx, para evitar que ele seja sobrescrito
         
        call FUNCAO_DISTPRINTX
        invoke WriteConsole, chaveSaida, addr texto7, sizeof texto7, addr write_count, NULL
        invoke FloatToStr, [resultCalcDistriX], addr [output]          ; printa a distancia entre os furos no eixo X
        invoke WriteConsole, chaveSaida, addr output, sizeof output, addr write_count, NULL

        call FUNCAO_DISTPRINTY
        invoke WriteConsole, chaveSaida, addr texto8, sizeof texto8, addr write_count, NULL
        invoke FloatToStr, [resultCalcDistriY], addr [output]          ; printa a distancia entre os furos no eixo Y
        invoke WriteConsole, chaveSaida, addr output, sizeof output, addr write_count, NULL
        invoke WriteConsole, chaveSaida, addr texto9, sizeof texto9, addr write_count, NULL




         pop ecx
         pop eax
         cmp ecx, eax                    ; faz a subtracao ecx - eax para saber se ecx eh menor, igual ou maior que eax              
         jae  fim_laco_1                 ; encerrar o laco se ecx >= eax. Dessa forma, ele ira continuar no laco se ecx < eax
         inc ecx                         ; equivalente a i++
         jmp inicio_laco_1               ; voltar para o incio do laco, para uma nova iteracao

    fim_laco_1:

        invoke WriteConsole, chaveSaida, addr texto6, sizeof texto6, addr write_count, NULL	;	imprime na tela
	    invoke ReadConsole, chaveEntrada, addr _input, sizeof _input, addr write_c, NULL
			
	   cmp _input, 115                                           ;   Compara se input == 's'
	   je WHILE_TRUE


    FIM_WHILE_TRUE:

	invoke ExitProcess, 0


;##########################   FUNCOES ##########################

;********************** SUBTRAÇÃO DOS EIXOS X   ****************************

    FUNCAO_CALCINICIALX PROC
                        
		fld cordFuroXfinal		    ;   add eixoXFinal na pilha da FPU
        fld cordFuroXinicial        ;   add eixoXInicial na pilha da FPU
		fsub						;	eixoFinal - eixoInicial
		fstp subtraidoX				;	sub = eixoFinal - eixoInicial
        ret
    FUNCAO_CALCINICIALX ENDP

;********************** SUBTRAÇÃO DOS EIXOS Y  ****************************

    FUNCAO_CALCINICIALY PROC
                        
		fld cordFuroYfinal		    ;   add eixoYFinal na pilha da FPU
        fld cordFuroYinicial        ;   add eixoYInicial na pilha da FPU
		fsub						;	eixoFinal - eixoInicial
		fstp subtraidoY				;	sub = eixoFinal - eixoInicial
        ret
    FUNCAO_CALCINICIALY ENDP    
	
;********************** DIVISÃO PELO NÚMERO DE FUROS X    **************************

    FUNCAO_CALCFINALX PROC

		finit
        fld incr
        fld numFuros
        fadd
        fstp numFuros

		fld subtraidoX		;	empilha valor subtraido
		fld numFuros		;	empilha quantidade de furos
		fdiv				;	subtraido / furos
		fstp distanciaX		;	distancia = subtraido / furos

        ret

    FUNCAO_CALCFINALX ENDP	

;********************** DIVISÃO PELO NÚMERO DE FUROS Y    **************************

    FUNCAO_CALCFINALY PROC

		fld subtraidoY		;	empilha valor subtraido
		fld numFuros		;	empilha quantidade de furos
		fdiv				;	subtraido / furos
		fstp distanciaY		;	distancia = subtraido / furos

        ret

    FUNCAO_CALCFINALY ENDP	

;********************** COPIA COORDENADA DE X PARA RESULT   ****************************

    COPIA_CONTEUDOX PROC
        finit
        fld cordFuroXinicial
        fstp resultCalcDistriX

        ret
    COPIA_CONTEUDOX ENDP

;********************** COPIA COORDENADA DE Y PARA RESULT   ****************************

    COPIA_CONTEUDOY PROC
        finit
        fld cordFuroYinicial
        fstp resultCalcDistriY

        ret
    COPIA_CONTEUDOY ENDP


;********************** CALCULO DA DISTANCIA PARA O PRINTX    **************************

    FUNCAO_DISTPRINTX PROC

		finit
		fld resultCalcDistriX   ;	empilha valor inicial do x
		fld distanciaX		    ;	empilha distancia do x
		fadd				    ;	soma
		fstp resultCalcDistriX		;	resultcordx = inicial + distancia

        ret

    FUNCAO_DISTPRINTX ENDP	

;********************** CALCULO DA DISTANCIA PARA O PRINTY    **************************

    FUNCAO_DISTPRINTY PROC

		finit
		fld resultCalcDistriY   ;	empilha valor inicial do y
		fld distanciaY		    ;	empilha distancia do y
		fadd				    ;	soma
		fstp resultCalcDistriY		;	resultcordy = inicial + distancia

        ret

    FUNCAO_DISTPRINTY ENDP	


    ;********************** RESETA REGISTRADORES E VARIAVEIS  *******************

    RESET_REG PROC

    fld _reset
    fstp numFurosInt 

    fld _reset
    fstp numFuros 

    fld _reset
    fstp cordFuroXinicial 
    
    fld _reset
    fstp cordFuroXfinal 
    
    fld _reset
    fstp subtraidoX 
    
    fld _reset
    fstp distanciaX 

    fld _reset
    fstp cordFuroYinicial 
    
    fld _reset
    fstp cordFuroYfinal 
    
    fld _reset
    fstp subtraidoY 
    
    fld _reset
    fstp distanciaY 

    fld _reset
    fstp resultCalcDistriX 
    
    fld _reset
    fstp resultCalcDistriY 
		
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        xor edx, edx
		
        finit						;	Reseta FPU

        ret

    RESET_REG ENDP


;********************** OBTER HANDLES  *******************

    OBTER_HANDLES PROC
    
        pop ebx                     	;   guarda endereco de retorno
        
        push STD_OUTPUT_HANDLE          ;   Capturando handle de saida
        call GetStdHandle
        mov chaveSaida, eax             ;   colocando o handle de saida em um endereco de memoria

        push STD_INPUT_HANDLE           ;   Capturando handle de entrada
        call GetStdHandle
        mov chaveEntrada, eax

        push ebx                    	;   realoca endereco de retorno
        ret

    OBTER_HANDLES ENDP

	
	end start