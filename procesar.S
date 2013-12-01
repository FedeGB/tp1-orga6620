#include <sys/syscall.h>
#include <mips/regdef.h>

# Procesa el archivo de entrada (puede ser stdin)
# Invierte las lineas del archivo y las imprime por stdout
# En caso satisfactorio devuelve 0, distinto de 0 en otros casos

# Variables declaradas
# nextChar, lineWidth, result, aux_special

	.text
	.align	2
	.global	procesarArchivo
	.extern mymalloc
	.extern myfree
	.ent	procesarArchivo
procesarArchivo:
	
	# Stackframe
	
	
