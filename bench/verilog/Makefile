TBS = tb_sg tpci tc

all: ${TBS}

tb_sg: tb_sgr.v ben_sgr.v ../../rtl/verilog/ss_sg.v
	iverilog -Wall -o tb_sgr $^

PCISIM?=/p/hw/pcisim/
OC_DIR?=/p/hw/oc-pci/rtl/verilog
LZFDMA?=/p/hw/lzs/kernel
VPATH=../../rtl/verilog:$(PCISIM)/ver

tpci: top.v pci_tb.v pci_arbiter.v  pci_master.v  pci_memory.v
	iverilog -Wall -y $(OC_DIR) -I $(OC_DIR) -y ../../rtl/verilog/ -o $@ $^
trun: tpci tc
	vvp -M${PCISIM}/vpi/ -mpci tpci
tc: pci_test.c
	${CC} -g -o $@ -I${LZFDMA} -I${PCISIM}/libpcisim/ $< -L${PCISIM}/libpcisim/ -lpcisim -Wl,-rpath,${PCISIM}/libpcisim

clean:
	rm -f ${TBS}
