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
	 output And,
	 output Or,
	 output slt,
	 output sltu,
	 output ori,
	 output lw,
	 output sw,
	 output beq,
	 output lui,
	 output jal,
	 output jr,
	 output addi,
	 output andi,
	 output lb,
	 output lh,
	 output sb,
	 output sh,
	 output bne,
	 output mult,
	 output multu,
	 output div,
	 output divu,
	 output mfhi,
	 output mflo,
	 output mthi,
	 output mtlo,
	 output mfc0,
	 output mtc0,
	 output eret,
	 output syscall,
	 //output xx,
	 
	 output load,
    output store,
    output branch,
    output calc_r,
    output calc_i,
    output md,
    output mt,
    output mf,
	 //jr
	 //jal
	 
	 output [1:0] EXTOp,
	 
	 output [2:0] aluOp,
	 output [1:0] aluSrcBOp,
	 output [3:0] HYLOOp,
	 
	 input [31:0] M_aluResult,
	 output memWriteEn,
	 output [3:0]memByteen,
	 
	 output cp0WriteEn,
	 
	 output regWriteEn,
	 output [4:0]regWriteAddr,
	 output [2:0]regWriteOp,
	 
	 //output eret,
	 output aluDMOv,
	 output aluAriOv,
	 output exc_ri//未知指令
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
	assign And 	= ((opCode==6'b000000)&&(func==6'b100100))?1:0;
	assign Or 	= ((opCode==6'b000000)&&(func==6'b100101))?1:0;
	assign slt 	= ((opCode==6'b000000)&&(func==6'b101010))?1:0;
	assign sltu = ((opCode==6'b000000)&&(func==6'b101011))?1:0;
	assign lui 	= (opCode==6'b001111)?1:0;
	
	assign addi	= ((opCode==6'b001000)||(opCode==6'b001001))?1:0;
	assign andi = (opCode==6'b001100)?1:0;
	assign ori 	= (opCode==6'b001101)?1:0;
	
	assign lb  	= (opCode==6'b100000)?1:0;
	assign lh 	= (opCode==6'b100001)?1:0;
	assign lw 	= (opCode==6'b100011)?1:0;
	assign sb 	= (opCode==6'b101000)?1:0;
	assign sh 	= (opCode==6'b101001)?1:0;
	assign sw 	= (opCode==6'b101011)?1:0;
	
	assign mult = ((opCode==6'b000000)&&(func==6'b011000))?1:0;
	assign multu= ((opCode==6'b000000)&&(func==6'b011001))?1:0;
	assign div	= ((opCode==6'b000000)&&(func==6'b011010))?1:0;
	assign divu = ((opCode==6'b000000)&&(func==6'b011011))?1:0;
	assign mfhi = ((opCode==6'b000000)&&(func==6'b010000))?1:0;
	assign mflo = ((opCode==6'b000000)&&(func==6'b010010))?1:0;
	assign mthi = ((opCode==6'b000000)&&(func==6'b010001))?1:0;
	assign mtlo = ((opCode==6'b000000)&&(func==6'b010011))?1:0;
	
	assign beq 	= (opCode==6'b000100)?1:0;
	assign bne 	= (opCode==6'b000101)?1:0;
	assign jal 	= (opCode==6'b000011)?1:0;
	assign jr 	= ((opCode==6'b000000)&&(func==6'b001000))?1:0;
	
	//output mfc0,
	// output mtc0,
	// output eret,
	 //output syscall,
	assign mfc0 = (opCode==6'b010000)&&(rs==5'b00000)?1:0;
	assign mtc0 = (opCode==6'b010000)&&(rs==5'b00100)?1:0;
	assign eret = (instr == 32'b010000_1000_0000_0000_0000_0000_011000)?1:0;
	assign syscall = ((opCode==6'b000000)&&(func==6'b001100))?1:0;
	//assign  = ()?1:0;
//SU
	assign load   = lw | lh | lb;
   assign store  = sw | sh | sb;
   assign branch = beq | bne;

   assign calc_r = add| sub| slt | sltu |And | Or; // exclude jr & jalr & mt/mf/md
   assign calc_i = addi | andi | ori; // exclude lui

   assign md = mult | multu | div | divu;
   assign mt = mtlo | mthi;
   assign mf = mflo | mfhi;
	wire nop = (instr==32'h0000_0000);
   //assign j_r = jr;
   //assign j_addr = j | jal;
   //assign j_l = jal | jalr;
//eret
	//assign eret = (Instr == 32'b010000_1000_0000_0000_0000_0000_011000);
//未知指令
	assign exc_ri = !(add|sub|And|Or|slt|sltu|ori|lw|sw|beq|lui|jal|jr|addi|andi
	|lb|lh|sb|sh|bne|mult|multu|div|divu|mfhi|mflo|mthi|mtlo|eret
	|mfc0|mtc0|eret|syscall|nop);
	
//D级	
	assign EXTOp = (lw|sw|beq||addi||lb||lh||lb||sb||sh||bne)?`immSignedExt:
						(lui)?`immLUI:
						`immUnsignedExt;
						
//E级
	assign aluOp = (sub)?`aluResultIsSub:
						(And||andi)?`aluResultIsAnd:
						(ori||Or)?`aluResultIsOr:
						(slt)?`aluResultIsSlt:
						(sltu)?`aluResultIsSltu:
						`aluResultIsAdd;
	assign aluSrcBOp = 	(add||sub||beq||lui||Or||And||slt||sltu)?`aluSrcBIsRtData:
								`aluSrcBIsImmExt;
	
	assign HYLOOp = (mult)?`mult:
							(multu)?`multu:
							(div)?`div:
							(divu)?`divu:
							(mfhi)?`mfhi:
							(mflo)?`mflo:
							(mthi)?`mthi:
							(mtlo)?`mtlo:
							3'd0;
	
	assign aluAriOv = (add|addi|sub);
	assign aluDMOv = (store|load);
//M级
	assign memWriteEn = (sw||sh||sb)?1'b1:
								1'b0;
	assign memByteen = 	(sw)?4'b1111:
								(sb&&M_aluResult[1:0]==2'd0)?4'b0001:
								(sb&&M_aluResult[1:0]==2'd1)?4'b0010:
								(sb&&M_aluResult[1:0]==2'd2)?4'b0100:
								(sb&&M_aluResult[1:0]==2'd3)?4'b1000:
								(sh&&M_aluResult[1]==1'b0)?4'b0011:
								(sh&&M_aluResult[1]==1'b1)?4'b1100:
								4'b0;
								
	assign cp0WriteEn = mtc0;
//W级
	assign regWriteAddr = (add||sub||Or||And||slt||sltu||mfhi||mflo)?rd:
									(jal)?5'd31:
									rt;
	
	assign regWriteOp = 	(add||sub||ori||Or||And||slt||sltu||addi||andi)?`regWriteIsAluResult:
								(lui)?`regWriteIsImmLUI:
								(jal)?`regWriteIsPCJal:
								(mfhi||mflo)?`regWriteIsHILO:
								(mfc0)?`regWriteIsCp0:
								`regWriteIsMemReadData;
	assign regWriteEn = (add||sub||ori||lw||lui||jal||Or||And||slt||sltu||addi||andi||lb||lh||mfhi||mflo||mfc0)?1'b1:
								1'b0;
	



endmodule
