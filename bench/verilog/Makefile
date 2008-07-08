TBS = tb_sg

all: ${TBS}

tb_sg: tb_sgr.v ben_sgr.v ../../rtl/verilog/ss_sg.v
	iverilog -o tb_sgr $^

clean:
	rm -f ${TBS}
