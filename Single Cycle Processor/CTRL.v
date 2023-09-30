`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:19:27 11/01/2022 
// Design Name: 
// Module Name:    CTRL 
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
module CTRL(
    input [31:26] opCode,
    input [5:0] func,
    output regWriteEn,
    output [2:0] aluOp,
    output memWriteEn,
    output extOp,
    output [1:0] grfWriteOp,
    output [1:0] aluInOp,
    output [1:0] grfWriteAddrOp,
    output ifBeq,
	 output ifJal,
	 output ifJr,
	 output ifBsoal
    );
	
	wire add;
	wire sub;
	wire ori;
	wire lw;
	wire sw;
	wire beq;
	wire lui;
	wire jal;
	//wire ;
	
	assign add 	= ((opCode==6'b000000)&&(func==6'b100000))?1:0;
	assign sub 	= ((opCode==6'b000000)&&(func==6'b100010))?1:0;
	assign ori 	= (opCode==6'b001101)?1:0;
	assign lw 	= (opCode==6'b100011)?1:0;
	assign sw 	= (opCode==6'b101011)?1:0;
	assign beq 	= (opCode==6'b000100)?1:0;
	assign lui 	= (opCode==6'b001111)?1:0;
	assign jal 	= (opCode==6'b000011)?1:0;
	assign jr 	= ((opCode==6'b000000)&&(func==6'b001000))?1:0;
	//assign  = ()?1:0;
	
	assign regWriteEn = (add||sub||ori||lw||lui||jal)?1'b1:1'b0;
   assign aluOp = (sub)?3'd1://+
								(ori)?3'd3://-
								//()?3'b100:
								3'd0;
   assign memWriteEn = (sw)?1'b1://
								1'b0;
   assign extOp = (lw||sw||beq)?1'b1://有符号拓展
								1'b0;//无符号拓展
   assign grfWriteOp = 	(add||sub||ori||sw)?2'd1://alu
								(lui)?2'd2://lui拓展
								(jal)?2'd3://jalPC地址
								0;//mem
   assign aluInOp = 	(add||sub||beq||lui)?2'b01://regRead2
							//()?2'b10:
							0;//immExt
   assign grfWriteAddrOp = (add||sub)?2'd1://rd
									(jal)?2'd2://31
									0;//rt
   assign ifBeq = (beq)?1'b1:1'b0;
	assign ifJal = (jal)?1'b1:1'b0;
	assign ifJr = (jr)?1'b1:1'b0;
	

endmodule
