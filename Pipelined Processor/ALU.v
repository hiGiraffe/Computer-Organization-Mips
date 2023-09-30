`timescale 1ns / 1ps
`include "const.v"
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
module E_ALU(
    input [31:0] srcA,
    input [31:0] srcB,
    input [2:0] aluOp,
    output reg [31:0] aluResult
    );
	
    always @(*)
    begin
        if(aluOp==`aluResultIsAdd) aluResult=srcA+srcB;
        else if(aluOp==`aluResultIsSub) aluResult=srcA-srcB;
        else if(aluOp==`aluResultIsAnd) aluResult=srcA&srcB;
        else if(aluOp==`aluResultIsOr) aluResult=srcA|srcB;
        else aluResult=0;
    end
	//assign aluResult = 	(aluOp==`aluResultIsAdd)?srcA+srcB:
	//							(aluOp==`aluResultIsSub)?srcA-srcB:
	//							(aluOp==`aluResultIsAnd)?srcA&srcB:
	//							(aluOp==`aluResultIsOr)?srcA|srcB:0;
	
	
endmodule
