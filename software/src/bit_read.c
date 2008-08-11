#include <stdio.h> 

static unsigned char bit_buf[2 * 1024 * 1024];  /* 2M */

 
unsigned char * bit_read(char *file, unsigned int *len) 
{ 
    FILE *bitfile; 

    unsigned char head_key; 
    unsigned int length=0;
    unsigned char length1;
    unsigned char length2;
    unsigned char length3;
    unsigned char length4;

    bitfile = fopen(file, "rb"); 

    if(bitfile== NULL) {
        printf("Cant open File \n");
        return NULL; 
    }        

    head_key = 0; 
    fseek(bitfile, 30L, SEEK_SET);

    while (head_key != 0x65) { 
        fread(&head_key, 1, 1, bitfile); 
        //printf("%02x ",head_key);

        if (head_key == 0x65) { 
            // Cant use fread to read 4 bytes in one go because 
            // I end up with words switched and bytes within words switched.
            // read Byte 1
            fread(&length1, 1, 1, bitfile); 
            length = (length1<<24);
            // read Byte 2
            fread(&length2, 1, 1, bitfile); 
            length = length | (length2<<16);
            // read Byte 3
            fread(&length3, 1, 1, bitfile); 
            length = length | (length3<<8);
            // read Byte 4
            fread(&length4, 1, 1, bitfile); 
            length = length | (length4);

            fread(&head_key, 1, 1, bitfile);
            if (head_key != 0xff)
                continue;
            head_key = 0x65;
            bit_buf[0] = 0xff;

            // Now read length bytes into the buffer.
            int ret = fread(&bit_buf[1], 1, length-1, bitfile); 
            if (ret != length-1) {
                printf("%d, %d\n", ret, length);
            }
        } 
    } 

    fclose(bitfile); 

    *len = length;

    return bit_buf; 
}
