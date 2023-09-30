`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:46:24 11/01/2022 
// Design Name: 
// Module Name:    mips 
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
module mips(
    input clk,
    input reset
    );
	//定义
	//IFU
	wire [31:0] nextPC;
	wire [31:0] instr;
	wire [31:0] PC;
	//InstrSplitter
	wire [31:26] opCode;
   wire [5:0] func;
   wire [25:21] rs;
   wire [20:16] rt;
   wire [15:11] rd;
   wire [15:0] imm;
	wire [25:0] instrIndex;
	//PC
	wire [31:0] PCJal;
	//EXT
	wire [31:0]immExt;
	wire [31:0]immLUI;
	//CTRL
	wire regWriteEn;
	wire [2:0] aluOp;
	wire memWriteEn;
	wire extOp;
	wire [1:0] grfWriteOp;
	wire [1:0] aluInOp;
	wire [1:0] grfWriteAddrOp;
	wire ifBeq;
	wire ifJal;
	wire ifJr;
	//wire if;
	//GRF
	wire [4:0] regReadAddr1;
	wire [4:0] regReadAddr2;
	wire [4:0] regWriteAddr;
	wire [31:0] regWriteData;
	wire [31:0] regReadData1;
	wire [31:0] regReadData2;
	//ALU
	wire [31:0] srcA;
   wire [31:0] srcB;
   wire [31:0] aluResult;
   wire equalAlu;
	//DM
	wire [4:0] memAddr;
   wire [31:0] memWriteData;
   wire [31:0] memReadData;
	
	//连接
	//IFU
	IFU ifu(
		.nextPC(nextPC),
		.clk(clk),
		.reset(reset),
		.instr(instr),
		.PC(PC)
	);
	
	//InstrSplitter
	assign opCode = instr[31:26];
   assign func = instr[5:0];
   assign rs = instr[25:21];
   assign rt = instr[20:16];
   assign rd = instr[15:11];
   assign imm = instr[15:0];
	assign instrIndex = instr[25:0];
	
	//EXT
	assign immExt =	(extOp==1'b0)?{16'b0,imm}: //无符号拓展
							{{16{imm[15]}},imm}; //有符号拓展
	assign immLUI = {imm,16'b0};
	
	//CTRL
	CTRL ctrl(
		.opCode(opCode),
		.func(func),
		.regWriteEn(regWriteEn),
		.aluOp(aluOp),
		.memWriteEn(memWriteEn),
    	.extOp(extOp),
    	.grfWriteOp(grfWriteOp),
   	.aluInOp(aluInOp),
    	.grfWriteAddrOp(grfWriteAddrOp),
    	.ifBeq(ifBeq),
		.ifJal(ifJal),
		//.ifBsoal(ifBsoal),
		.ifJr(ifJr)
	);

	//NPC
	NPC npc(
		.PC(PC),
		.immExt(immExt),
		.PCJal(PCJal),
		.nextPC(nextPC),
		.instrIndex(instrIndex),
		.ifBeq(ifBeq),
		.ifJal(ifJal),
		.ifJr(ifJr),
		.regJr(regReadData1),
		.equalAlu(equalAlu)
    );
	
	//GRF
	assign regReadAddr1=rs;
	assign regReadAddr2=rt;
	assign regWriteAddr=(grfWriteAddrOp==2'd1)?rd:
								(grfWriteAddrOp==2'd2)?5'd31:
								rt;
	assign regWriteData=	(grfWriteOp==2'd1)?aluResult:
								(grfWriteOp==2'd2)?immLUI:
								(grfWriteOp==2'd3)?PCJal:
								memReadData;
	GRF grf(
		.clk(clk),
    	.reset(reset),
		.PC(PC),
    	.regWriteEn(regWriteEn),
    	.regReadAddr1(regReadAddr1),
    	.regReadAddr2(regReadAddr2),
    	.regWriteAddr(regWriteAddr),
    	.regWriteData(regWriteData),
    	.regReadData1(regReadData1),
    	.regReadData2(regReadData2)
	);
	
	//ALU
	assign srcA = regReadData1;
	assign srcB = 	(aluInOp==2'b0)?immExt:
						regReadData2;//aluInOp==1
	ALU alu(
		.srcA(srcA),
    	.srcB(srcB),
    	.aluOp(aluOp),
    	.aluResult(aluResult),
    	.equalAlu(equalAlu)
	);
	
	//DM
	//assign memAddr = aluResult;
	assign memWriteData = regReadData2;
	DM dm(
		.memAddr(aluResult),
    	.memWriteData(memWriteData),
    	.memWriteEn(memWriteEn),
    	.clk(clk),
    	.reset(reset),
		.PC(PC),
    	.memReadData(memReadData)
	);
	
endmodule
