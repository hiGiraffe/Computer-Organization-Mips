`timescale 1ns / 1ps
`include "const.v"
`define	N		4096
module F_IFU(
    input [31:0] nextPC,
    input clk,
    input reset,
	 input F_IFU_en,
    output [31:0] instr,
    output [31:0] PC
    );
	
	integer i;
	
	reg [31:0] tmpPC;
	wire [31:0] addrPC;
	reg [31:0] ROM [4095:0];
	
	initial begin 
		tmpPC=32'h00003000;
		for (i=0;i < `N;i=i+1) ROM[i]=0;
		$readmemh("code.txt", ROM);
	end
	
	always @(posedge clk)
	begin
		if(reset) tmpPC <=32'h00003000;
		else if(F_IFU_en) tmpPC = nextPC;
	end
	
	assign addrPC = tmpPC-32'h00003000;
	assign instr = ROM[addrPC[31:2]];
	assign PC = tmpPC;
endmodule
