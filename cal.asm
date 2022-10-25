assume cs:code

; 年/月/日 时：分：秒
;可以位此程序设计两个子程序，一个用来接收单元参数
;一个用来接收格式参数(:/)，并显示字符串
 
code segment  
;unit段存放各字段再CMOS RAM的位置
unit:	db 9, 8, 7, 4, 2, 0
;return数据段用来存放show_what子程序的返回值（修改后的ax值）
return:   dw 0
start:		
	mov ax, cs
	mov ds, ax
	;si用来记录unit中的偏移量
	;di用来记录显示字符串的偏移量
	mov si, offset unit
	mov di, 0
	; :的ASCII码值为58 ; 这个值由dl来存储 
	; /的ASCII码值位47
	mov dl, 47	
	mov cx, 6	;一共要循环六次，依次取出年月日时分秒
s:	mov al, ds:[si]
	call show_what
	inc si
	cmp si, 3
	;一旦年月日输出完毕，就将格式符换成 :
	je hour
	cmp si, 6
	;当时间也已经输出完毕之后，就不需要再输出格式化符了
	je null
	jmp year
null:		mov dl, 0
			;如果不跳转到year代码的话，程序还是会顺序执行到
			;hour代码处，从而覆盖dl的值
			jmp year
hour:		mov dl, 58 
year:		call show_how	
			add di, 6
			loop s
			
			mov ax, 4c00h
			int 21h   
			  
show_what:	
		push cx
		push ax 
		push si
			
		out 70h, al
		in al, 71h	;1 读出年份
			
		mov ah, al
		mov cl, 4
		shr ah, cl
		and al, 00001111b
			
		add ah, 30h
		add al, 30h 
		
		mov si,offset return ;存入return 中
		mov ds:[si], ax  	    
			
		pop si 
		pop ax
		pop cx
		ret
			
show_how:	push bx
			push ax
			push dx
			push di
			push si 
			
			mov bx, 0b800h
			mov es, bx 
			mov si, offset return
			mov ax, ds:[si]
			mov byte ptr es:[160*24+di], ah
			;设置背景色为绿色
			mov ah, 2
			mov byte ptr es:[160*24+di+1], ah
			
			mov byte ptr es:[160*24+2+di], al 
			mov byte ptr es:[160*24+2+di+1], ah
			;显示格式化符
			mov byte ptr es:[160*24+4+di], dl
			mov byte ptr es:[160*24+4+di+1], ah
			 
			pop si
			pop di
			pop dx
			pop ax
			pop bx
			ret
code ends
end start
