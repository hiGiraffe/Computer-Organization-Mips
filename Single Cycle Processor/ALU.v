`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:28:33 11/01/2022 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] srcA,
    input [31:0] srcB,
    input [2:0] aluOp,
    output [31:0] aluResult,
    output equalAlu
    );
	
	assign aluResult = 	(aluOp==3'd0)?srcA+srcB:
								(aluOp==3'd1)?srcA-srcB:
								(aluOp==3'd2)?srcA&srcB:
								(aluOp==3'd3)?srcA|srcB:0;
	
	assign equalAlu = (srcA==srcB)?1:0;
	
endmodule
