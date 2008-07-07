TBS = tb_sgr

all: ${TBS}

tb_sgr: tb_sgr.v ben_sgr.v ../../rtl/verilog/ss_sgr.v
	iverilog -o tb_sgr $^

clean:
	rm -f ${TBS}
