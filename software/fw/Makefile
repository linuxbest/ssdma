#
# 
#
#

all:	fpga_firmware
clean:	 clean_firmware

# asx8051 -logs vec.asm
fpga_firmware:	vectors.rel misc.rel fpga_control_fw.ihx

vectors.rel:	vectors.asm
		asx8051 -xlogs vectors.asm

misc.rel:	misc.asm
		asx8051 -xlogs misc.asm

##
## ezusb TRM v1.9 page 3-1 (54)
##
fpga_control_fw.ihx:	fpga_control_fw.c fpga_control_fw.h misc.asm vectors.asm \
			fpga_common.h
			sdcc \
			misc.rel fpga_control_fw.c

boot.ihx: boot.c
	sdcc boot.c

clean_firmware:
		rm -f fpga_control_fw.asm fpga_control_fw.cdb fpga_control_fw.ihx \
		fpga_control_fw.lnk fpga_control_fw.lst fpga_control_fw.map \
		fpga_control_fw.rel fpga_control_fw.rst fpga_control_fw.sym \
		vectors.lst vectors.rel vectors.rst vectors.sym          \
		misc.lst misc.rel misc.rst misc.sym

