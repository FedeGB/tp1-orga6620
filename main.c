#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "procesar.h"

#define VERSION 3

// Funcion principal
int main(int argc, char** argv) {
        int status = 0;
        int fd;

        if (argc == 2) {
                if (strcmp(argv[1], "-V") == 0) {
                        printf("Version: %d\n", VERSION);
                        return 0;
                }
                if (strcmp(argv[1], "-h") == 0) {
                        printf("Comandos y argumentos disponibles:\n");
                        printf("-V Version del programa\n");
                        printf("[File...] (Archivo/s de entrada)\n");
                        printf(
                                        "En caso de no pasar archivos se toma la entrada estandar\n");
                        printf("Cada linea se cuenta hasta un enter\n");
                        printf(
                                        "Para finalizar el programa estando con la entrada estandar");
                        printf(" pulsar 'ctrl+d' para un correcto cierre del mismo");
                        // Y cualquier otra cosa que se quiera agregar
                        return 0;
                }
        }
        if (argc == 1) {
            status = procesarArchivo(fileno(stdin),fileno(stdout));
        } else {
                int arch = 1;
                FILE* entrada;
                while (arch < argc) {
                        entrada = fopen(argv[arch], "r");
                        if (!entrada) {
                                fprintf(stderr, "No se pudo abrir el archivo: %s\n",
                                                argv[arch]);
                                return 1;
                        }
                        fd = fileno(entrada);
                        status = procesarArchivo(fd,fileno(stdout));
                        if (status){
                        	return status;
                        }
                        fclose(entrada);
                        entrada = NULL;
                        arch++;
                }
        }
        return status;

}
