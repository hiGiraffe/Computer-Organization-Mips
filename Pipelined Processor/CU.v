`timescale 1ns / 1ps
`include "const.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:28:01 11/12/2022 
// Design Name: 
// Module Name:    CU 
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
module CU(
    input [31:0] instr,
    output [25:21] rs,
    output [20:16] rt,
    output [15:11] rd,
    output [15:0] imm,
    output [25:0] instrIndex,
	 
	 output add,
	 output sub,
	 output ori,
	 output lw,
	 output sw,
	 output beq,
	 output lui,
	 output jal,
	 output jr,
	 output isor,
	 //output xx,
	 
	 output [1:0] EXTOp,
	 
	 output [2:0] aluOp,
	 output [1:0] aluSrcBOp,
	 
	 output memWriteEn,
	 
	 output regWriteEn,
	 output [4:0]regWriteAddr,
	 output [2:0]regWriteOp
	 
	 
    );
	  
//D级
	assign rs = instr[25:21];
   assign rt = instr[20:16];
   assign rd = instr[15:11];
   assign imm = instr[15:0];
	assign instrIndex = instr[25:0];
	wire [31:26] opCode = instr[31:26];
   wire [5:0] func = instr[5:0];
	
	assign add 	= ((opCode==6'b000000)&&((func==6'b100000)||(func == 6'b100001)))?1:0;
	assign sub 	= ((opCode==6'b000000)&&((func==6'b100010)||(func == 6'b100011)))?1:0;
	assign isor 	= ((opCode==6'b000000)&&(func==6'b100101))?1:0;
	assign ori 	= (opCode==6'b001101)?1:0;
	assign lw 	= (opCode==6'b100011)?1:0;
	assign sw 	= (opCode==6'b101011)?1:0;
	assign beq 	= (opCode==6'b000100)?1:0;
	assign lui 	= (opCode==6'b001111)?1:0;
	assign jal 	= (opCode==6'b000011)?1:0;
	assign jr 	= ((opCode==6'b000000)&&(func==6'b001000))?1:0;

	//assign  = ()?1:0;
	
	assign EXTOp = (lw|sw|beq)?`immSignedExt:
						(lui)?`immLUI:
						`immUnsignedExt;
						
//E级
	assign aluOp = (sub)?`aluResultIsSub:
						//()?`aluResultIsAnd:
						(ori||isor)?`aluResultIsOr:
						`aluResultIsAdd;
	assign aluSrcBOp = 	(add||sub||beq||lui||isor)?`aluSrcBIsRtData:
								`aluSrcBIsImmExt;
//M级
	assign memWriteEn = sw?1'b1:
								1'b0;
//W级
	assign regWriteAddr = (add||sub||isor)?rd:
									(jal)?5'd31:
									// bgezalc===1'd1 ? (check===1'd1 ? 5'd31 : 5'd0) :
									rt;
	
	assign regWriteOp = 	(add||sub||ori||sw||isor)?`regWriteIsAluResult:
								(lui)?`regWriteIsImmLUI:
								(jal)?`regWriteIsPCJal:
								`regWriteIsMemReadData;
	assign regWriteEn = (add||sub||ori||lw||lui||jal||isor)?1'b1:
								1'b0;
	



endmodule
