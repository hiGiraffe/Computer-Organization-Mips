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
module D_NPC(
    input [31:0] F_pc,
	 input [31:0] D_pc,
    input [31:0] immExt,
    output [31:0] nextPC,
	 input [25:0] instrIndex,
	 input [31:0] regJr,
    input beq,
	 input bne,
	 input jal,
	 input B_judge,
	 input jr,
	 
	 input Req,
	 input eret,
	 input [31:0] EPC
    );
	
	wire [2:0]op;
	
	assign op = 	(Req)?3'd5:
						(eret)?3'd4:
						((beq&B_judge)||(bne&&B_judge))?3'd1: //PC+4+imm
						(jal)?3'd2: //pc||instrIndex||00
						(jr)?3'd3:
						3'b0;//PC+4
	assign nextPC = 	(op==3'd0)?F_pc+32'd4:
							(op==3'd1)?D_pc+32'd4+(immExt<<2):
							(op==3'd2)?{D_pc[31:28],instrIndex,2'b0}:
							(op==3'd3)?regJr:
							(op==3'd4)? EPC+4:
							(op==3'd5)?32'h0000_4180:
							F_pc+32'd4;
	
endmodule
