#include <mips/regdef.h>
#include <sys/syscall.h>

	.text
	.align	2

	.globl	procesarArchivo
	.globl  reverse_errmsg
	.extern mymalloc
	.extern myfree
	.ent	procesarArchivo
procesarArchivo:
# init frame declaration
	.frame	$fp, 56, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp, sp, 56
	.cprestore 40
	sw	ra,  48(sp)
	sw	$fp, 44(sp)
	move	$fp, sp
# end frame declaration
	sw a0, 56($fp)
	sw a1, 60($fp)

	li a0, 1
	sw a0, 0($fp)
	jal mymalloc
	sw v0, 16($fp) # malloc para la lectura del caracter
	beqz v0, first_bad_malloc
	li a0, 1
	sw a0, 0($fp)
	jal mymalloc
	sw v0, 20($fp)
	beqz v0, second_bad_malloc
	li t0, 0
	sw t0, 24($fp)
while: li v0, SYS_read
	lw a0, 56($fp)
	lw a1, 16($fp)
	li a2, 1
	syscall # leo el caracter
	bnez a3, error_reading # si ocurrio un error interumpo el bucle
	beqz v0, end_while # si se llego a eof voy al fin del bucle
	lw t0, 16($fp)
	lbu t1, 0(t0)
	beq t1, 0xa, end_line # si el caracter es un caracter de fin de linea termino 				      # de parsear la linea
	lw t0, 24($fp)
	addi t0, t0, 1
	sw t0, 24($fp) # aumento el tamano del listado, width ++

	lw t0, 20($fp) # 
	sw t0, 32($fp) # aux2 <- w

	lw a0, 24($fp)
	jal mymalloc
	sw v0, 20($fp) # w <- malloc
	beqz v0, error_malloc
	lw t0, 24($fp)
	beq t0, 1, end_for # si solo tengo un elemento entonces no tengo que copiar nada
	sw zero, 28($fp)
for:	lw t0, 28($fp)
	lw t1, 24($fp)
	subu t1, t1, 1
	beq t0, t1, end_for
	lw t1, 20($fp)
	lw t0, 28($fp)
	addu t1, t1, t0
	lw t3, 32($fp)
	addu t3, t3, t0
	lb t2, 0(t3)
	sb t2, 0(t1) # w[pos] = aux2[pos]
	lw t0, 28($fp)
	addiu t0, t0, 1
	sw t0, 28($fp)
	b for
end_for:
	lw t0, 24($fp)
	subu t0, t0, 1
	lw t1, 20($fp)
	addu t1, t0, t1
	lw t3, 16($fp)
	lb t2, 0(t3)
	sb t2, 0(t1) # w[pos-1] = charActual
	lw t0, 24($fp)
	lw a0, 32($fp)
	sw a0, 0($fp)
	jal myfree   # aux2 = null
	b while
end_line: lw a0, 20($fp)
	lw a1, 24($fp)
	li a2, 1
	lw a3, 60($fp)
	jal write_line_bacwards
	lw a0, 20($fp)
	jal myfree
	li a0, 1
	sw a0, 0($fp)
	jal mymalloc
	sw v0, 20($fp)
	beqz v0, second_bad_malloc
	li t0, 0
	sw t0, 24($fp)
	b while
end_while: lw a0, 20($fp)
	lw a1, 24($fp)
	li a2, 0
	lw a3, 60($fp)
	jal write_line_bacwards
	li t0, 0
	sw t0, 36($fp)
	lw a0, 16($fp)
	sw a0, 0($fp)
	jal myfree
	lw a0, 20($fp)
	sw a0, 0($fp)
	jal myfree
	b end_procesarArchivo
error_malloc: lw t0, 32($fp)
	sw t0, 20($fp)
error_reading: li t0, 2
	sw t0, 36($fp)
	lw a0, 20($fp)
	sw a0, 0($fp)
	jal myfree
second_bad_malloc: lw a0, 16($fp)
	sw a0, 0($fp)
	jal myfree
first_bad_malloc:
	lw t0, 36($fp)
	beq t0, 2, end_procesarArchivo
	li t0, 1
	sw t0, 36($fp)
end_procesarArchivo: lw	v0, 36($fp)
# init frame destruction
	lw	ra,  48(sp)
	lw	$fp, 44(sp)
	addu	sp, sp, 56
	j	ra
	.end	procesarArchivo
# end frame destruction
.ent write_line_bacwards
write_line_bacwards: .frame $fp, 16, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp, sp, 16
	.cprestore 8
	sw	$fp, 12(sp)
	move	$fp, sp
	sw	a0, 16($fp)
	sw	a1, 20($fp)
	sw	a1, 0($fp)
	sw	a2, 24($fp)
	sw	a3, 28($fp)

write_for: lw t0, 0($fp)
	subu t0, t0, 1
	sw t0, 0($fp)
	ble t0, -1, write_finish
	li v0, SYS_write
	lw a0, 28($fp)
	lw a1, 16($fp)
	lw t0, 0($fp)
	addu a1, t0, a1
	li a2, 1
	syscall
	b write_for

write_finish:
	lw a2, 24($fp)
	beqz a2, no_line
	li v0, SYS_write
	lw a0, 28($fp)
	la a1, ascii_line
	li a2, 1
	syscall
no_line: lw	$fp, 12(sp)
	addu	sp, sp, 16
	j	ra	
.end write_line_bacwards
.rdata
ascii_line: .asciiz "\n"
.align 2
reverse_errmsg: .word noerror,error1, error2
.align 0
noerror: .asciiz "La aplicacion se ejecuto exitosamente"
error1:	.asciiz "Hubo un problema al intentar leer un caracter, por favor intente mas tarde nuevamente"
error2: .asciiz "Hubo un problema al intentar alocar memoria, por favor intente mas tarde nuevamente"
