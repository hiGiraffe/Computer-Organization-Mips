`timescale 1ns / 1ps
//`define dmData 0000_0000 0000_2FFF
//`define dmInstr 0000_3000 0000_6FFF
//`define t1 0000_7F00 0000_7F0B
//`define t2 0000_7F10 0000_7F1B
//`define stop 0000_7F20 0000_7F23
/////////////////////////////////////////////////////////////////////////////////////
module M_ErrStore(
	input sw,
	input sh,
	input sb,
	input [31:0] addr,
	input exc_dmov,
	output exc_ades
    );
	wire errUnalign = (sw&(|addr[1:0]))|(sh&addr[0]);
	wire errOutOfRange = !(
								((addr>=32'h0000_0000)&&(addr<=32'h0000_2fff))|
								((addr>=32'h0000_7f00)&&(addr<=32'h0000_7f0b))|
								((addr>=32'h0000_7f10)&&(addr<=32'h0000_7f1b))|
								((addr>=32'h0000_7f20)&&(addr<=32'h0000_7f23))
								);
	wire errTimer = 	(addr>= 32'h0000_7f08 && addr<=32'h0000_7f0b)||
							(addr>= 32'h0000_7f18 && addr<=32'h0000_7f1b)||
							((sb|sh)&&(addr>32'h0000_7f00));
	assign exc_ades = (sb|sh|sw)&&(errUnalign|errOutOfRange|errTimer|exc_dmov);
endmodule
