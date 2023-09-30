`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:47:47 11/01/2022 
// Design Name: 
// Module Name:    IFU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module IFU(
    input [31:0] nextPC,
    input clk,
    input reset,
    output [31:0] instr,
    output [31:0] PC
    );
	
	integer i;
	reg [31:0] tmpPC;
	wire [31:0] addrPC;
	reg [31:0] ROM [4095:0];
	
	initial begin 
		tmpPC=32'h00003000;
		for (i=0;i<4096;i=i+1) ROM[i]=0;
		$readmemh("code.txt", ROM);
	end
	
	always @(posedge clk)
	begin
		tmpPC = nextPC;
		if(reset) tmpPC <=32'h00003000;
	end
	assign addrPC = tmpPC-32'h00003000;
	assign instr = ROM[addrPC[11:2]];
	assign PC = tmpPC;
endmodule
