/*
 * covert the S2 ROM to HEX
 *
 *  AN21XX_8.pdf page 79
 *
 */

#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


static void hexdump(char *data, unsigned size)
{
        char *start = data;
        while (size) {
                unsigned char *p;
                int w = 16, n = size < w? size: w, pad = w - n;
                fprintf(stderr, "%04x:  ", data-start);
                for (p = data; p < (unsigned char *)data + n;)
                        fprintf(stderr, "%02hx ", *p++);
                fprintf(stderr, "%*.s  \"", pad*3, "");
                for (p = data; p < (unsigned char *)data + n;) {
                        int c = *p++;
                        fprintf(stderr, "%c", c < ' ' || c > 127 ? '.' : c);
                }
                fprintf(stderr, "\"\n");
                data += w;
                size -= n;
        }
}

int main(int argc, char **argv)
{
        uint8_t buf[4096], *p;
        int fd, ret;
        
        fd = open("/tmp/s2.bit", O_RDONLY);
        if (fd == -1) {
                perror("open");
                return -1;
        }
        ret = read(fd, buf, 4096);
        if (ret != 4096) {
                perror("read");
                return -2;
        }
        p = buf;

        /* 
         * 0 0xB2 
         * 1 VID L
         * 2 VID H
         * 3 PID L
         * 4 PID H
         * 5 DID L
         * 6 DID H
         */
        hexdump(p, 7);
        p += 7;

        uint16_t len, addr, sum;
        do {
                len = *p << 8; 
                p ++;
                len += *p;
                p ++;

                addr = *p << 8; 
                p ++;
                addr += *p;
                p ++;

                if (len == 0x8001) {
                        printf(":00000001FF\n");
                        break;
                }
                hexdump(p, len);
                sum = len;
                fprintf(stderr, "len %04x, addr %04x\n", len, addr);
                printf(":");
                printf("%02X", len);
                printf("%04X00", addr);
                sum += addr;

                int j = 0;
                for (j = 0; j < len; j++) {
                        printf("%02X", p[j]);
                        sum += p[j];
                }
                printf("%02X\n", (0x100 - sum)&0xff);

                p += len;
        } while (len != 0x8001);
}
