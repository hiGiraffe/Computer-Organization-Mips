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
    output reg [31:0] aluResult,
	 
	 input aluDMOv,
	 input aluAriOv,
	 output exc_AriOv,
	 output exc_DMOv
    );
	
    always @(*)
    begin
        if(aluOp==`aluResultIsAdd) aluResult=srcA+srcB;
        else if(aluOp==`aluResultIsSub) aluResult=srcA-srcB;
        else if(aluOp==`aluResultIsAnd) aluResult=srcA&srcB;
        else if(aluOp==`aluResultIsOr) aluResult=srcA|srcB;
		  else if(aluOp==`aluResultIsSlt) aluResult = ($signed(srcA)<$signed(srcB))?32'b1:32'b0;
        else if(aluOp==`aluResultIsSltu) aluResult = (srcA<srcB)?32'b1:32'b0;
		  else aluResult=0;
    end
	//assign aluResult = 	(aluOp==`aluResultIsAdd)?srcA+srcB:
	//							(aluOp==`aluResultIsSub)?srcA-srcB:
	//							(aluOp==`aluResultIsAnd)?srcA&srcB:
	//							(aluOp==`aluResultIsOr)?srcA|srcB:0;
	
	wire [32:0] srcAext = {srcA[31],srcA};
	wire [32:0] srcBext = {srcB[31],srcB};
	wire [32:0] addext = srcAext + srcBext;
	wire [32:0] subext = srcBext - srcBext;
	assign exc_AriOv = (aluAriOv)&((addext[31]!=addext[32])|(subext[31]!=subext[32]));
	assign exc_DMOv = (aluDMOv)&(addext[31]!=addext[32]);
	
endmodule

		
		
		
		