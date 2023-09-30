`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:03:52 11/02/2022 
// Design Name: 
// Module Name:    NPC 
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
module NPC(
    input [31:0] PC,
    input [31:0] immExt,
    output [31:0] PCJal,
    output [31:0] nextPC,
	 input [25:0] instrIndex,
	 input [31:0] regJr,
    input ifBeq,
	 input ifJal,
	 input equalAlu,
	 input ifJr
    );
	
	wire [1:0]op;
	
	assign op = 	((ifBeq==1'b1)&&(equalAlu==1'b1))?2'd1: //PC+4+imm
						(ifJal==1'b1)?2'd2: //pc||instrIndex||00
						(ifJr==1'b1)?2'd3:
						2'b0;//PC+4
	assign PCJal = PC + 32'd4;//PC+4
	assign nextPC = 	(op==2'd0)?PC+32'd4:
							(op==2'd1)?PC+32'd4+(immExt<<2):
							(op==2'd2)?{PC[31:28],instrIndex,2'b0}:
							(op==2'd3)?regJr:
							0;
	
endmodule
