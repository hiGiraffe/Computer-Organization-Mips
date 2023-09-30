`timescale 1ns / 1ps
`include "const.v"

module mips(
    input clk,
    input reset
    );
		//F
		//IFU
		wire [31:0] F_nextPC;
		wire [31:0] F_instr;
		wire [31:0] F_pc;	 
		wire  F_IFU_en;
		//D
		//D_REG
		wire D_REG_en;
		wire D_REG_clr;
		wire [31:0] D_instr;
		wire [31:0] D_pc;
		//D_CU
		wire [25:21] D_rs;
		wire [20:16] D_rt;
		wire [15:11] D_rd;
		wire [15:0] D_imm;
		wire [25:0] D_instrIndex;
		wire [1:0] D_EXTOp;
		wire D_beq;
		wire D_jal;
		wire D_jr;
		//D_GRF
		wire [31:0] D_rsData;
		wire [31:0] D_rtData;
		//D_CMP
		wire [31:0] D_rsDataTrue;
		wire [31:0] D_rtDataTrue;
		wire D_B_judge;
		wire nullCI;
		//D_EXT
		wire [31:0]D_immExt;
		
		//E
		//E_REG
		wire E_REG_clr;
		wire E_REG_en;
		wire [31:0] E_pc;
		wire [31:0] E_rsData;
		wire [31:0] E_rtData;
		wire [31:0] E_immExt;
		wire [31:0] E_instr;
		//E_CU
		wire [4:0] E_regWriteAddr;
		wire [2:0] E_regWriteOp;
		wire [31:0] E_regWriteData;
		wire E_regWriteEn;
		wire [4:0] E_rs;
		wire [4:0] E_rt;
		wire [1:0] E_aluSrcBOp;
		wire [2:0] E_aluOp;
		//E_ALU
		wire [31:0] E_rsDataTrue;
		wire [31:0] E_rtDataTrue;
		wire [31:0] E_srcA;
		wire [31:0] E_srcB;
		wire [31:0] E_aluResult;
		
		//M
		//M_REG
		wire M_REG_clr;
		wire M_REG_en;
		wire [31:0] M_pc;
		wire [31:0] M_rsData;
		wire [31:0] M_rtData;
		wire [31:0] M_immExt;
		wire [31:0] M_instr;
		wire [31:0] M_aluResult;
		//M_CU
		wire M_memWriteEn;
		wire M_regWriteEn;
		wire [31:0] M_regWriteData;
		wire [4:0] M_regWriteAddr;
		wire [2:0] M_regWriteOp;
		wire [4:0] M_rt;
		//M_DM
		wire [31:0] M_memWriteData;
		wire [31:0] M_memReadData;
		
		//W级
		//W_REG
		wire W_REG_clr;
		wire W_REG_en;
		wire [31:0] W_pc;
		wire [31:0] W_immExt;
		wire [31:0] W_instr;
		wire [31:0] W_aluResult;
		wire [31:0] W_memReadData;
		//W_CU
		wire W_regWriteEn;
		wire [2:0] W_regWriteOp;
		wire [4:0] W_regWriteAddr;
		wire [31:0] W_regWriteData;
		
		//SU
		wire stall;
		
		
		//考试写入数据
		
		//SU
	SU su(
		.D_instr(D_instr),
		.E_instr(E_instr),
		.M_instr(M_instr),
		.stall(stall)
	);
	
	assign F_IFU_en = !stall;
	assign D_REG_en = !stall;
	assign E_REG_en = 1'b1;
	assign M_REG_en = 1'b1;
	assign W_REG_en = 1'b1;
	
	assign D_REG_clr = 1'b0;
	assign E_REG_clr = stall;
	assign M_REG_clr = 1'b0;
	assign W_REG_clr = 1'b0;
	
	
//——————F级——————//
//IFU
	
	 
	F_IFU F_ifu(
		.nextPC(F_nextPC),
		.clk(clk),
		.F_IFU_en(F_IFU_en),
		.reset(reset),
		.instr(F_instr),
		.PC(F_pc)
	);
//——————D级——————//
//D_REG
	
	REG D_reg(
		.clk(clk),
		.reset(reset||(nullCI===1'b1)),
		.en(D_REG_en),
		.clr(D_REG_clr),
		.instrIn(F_instr),
		.pcIn(F_pc),
		.instrOut(D_instr),
		.pcOut(D_pc)
	);
//D_CU
   
	CU D_cu(
		.instr(D_instr),
		.rs(D_rs),
		.rt(D_rt),
		.rd(D_rd),
		.imm(D_imm),
		.instrIndex(D_instrIndex),
		.EXTOp(D_EXTOp),
		.beq(D_beq),
		.jal(D_jal),
		.jr(D_jr)
	);
	
//D_GRF
	

	D_GRF D_grf(
		.clk(clk),
    	.reset(reset),
		.PC(W_pc),
    	.regWriteEn(W_regWriteEn),
    	.regReadAddr1(D_rs),
    	.regReadAddr2(D_rt),
    	.regWriteAddr(W_regWriteAddr),
    	.regWriteData(W_regWriteData),
    	.regReadData1(D_rsData),
    	.regReadData2(D_rtData)
	);
	
//D_EXT
	
	assign D_immExt = (D_EXTOp==`immUnsignedExt)?{16'b0,D_imm}:
							(D_EXTOp==`immSignedExt)?{{16{D_imm[15]}},D_imm}:
							(D_EXTOp==`immLUI)?{D_imm,16'b0}:
							32'd0;

//CMP
	
	
	assign D_rsDataTrue = 	(D_rs==5'd0)?32'd0:
									(D_rs==E_regWriteAddr&&E_regWriteEn)?E_regWriteData:
									(D_rs==M_regWriteAddr&&M_regWriteEn)?M_regWriteData:
									(D_rs==W_regWriteAddr&&W_regWriteEn)?W_regWriteData:
									D_rsData;
	assign D_rtDataTrue = 	(D_rt==5'd0)?32'd0:
									(D_rt==E_regWriteAddr&&E_regWriteEn)?E_regWriteData:
									(D_rt==M_regWriteAddr&&M_regWriteEn)?M_regWriteData:
									(D_rt==W_regWriteAddr&&W_regWriteEn)?W_regWriteData:
									D_rtData;
	
	D_CMP D_cmp(
		.rsData(D_rsDataTrue),
		.rtData(D_rtDataTrue),
		.beq(D_beq),
		.nullCI(nullCI),
		.judge(D_B_judge)
	);
	
//D_NPC
	D_NPC D_npc(
		.F_pc(F_pc),
		.D_pc(D_pc),
		.immExt(D_immExt),
		.nextPC(F_nextPC),
		.instrIndex(D_instrIndex),
		.beq(D_beq),
		.jal(D_jal),
		.jr(D_jr),
		.regJr(D_rsDataTrue),
		.B_judge(D_B_judge)
	);
	
//——————E级——————//
	
	REG E_reg(
		  .clk(clk),
        .reset(reset),
        .clr(E_REG_clr),
	     .en(E_REG_en),
		  
        .instrIn(D_instr),
        .pcIn(D_pc),
        .immExtIn(D_immExt),
        .rsDataIn(D_rsDataTrue),
        .rtDataIn(D_rtDataTrue),
		  
	     .instrOut(E_instr),
        .pcOut(E_pc),
        .immExtOut(E_immExt),
        .rsDataOut(E_rsData),
        .rtDataOut(E_rtData)
	);

//CU
	
	CU E_cu(
		.instr(E_instr),
		.rs(E_rs),
		.rt(E_rt),
		.aluSrcBOp(E_aluSrcBOp),
		.regWriteEn(E_regWriteEn),
		.aluOp(E_aluOp),
		.regWriteAddr(E_regWriteAddr),
		.regWriteOp(E_regWriteOp)
	);
	
	assign E_regWriteData=	//(E_regWriteOp==`regWriteIsMemReadData)?E_memReadData:
									//(E_regWriteOp==`regWriteIsAluResult)?E_aluResult:
									(E_regWriteOp==`regWriteIsImmLUI)?E_immExt:
									(E_regWriteOp==`regWriteIsPCJal)?E_pc+8:
									0;
	
//E_ALU
	
	
	assign E_rsDataTrue = 	(E_rs==5'd0)?32'd0:
									(E_rs==M_regWriteAddr&&M_regWriteEn)?M_regWriteData:
									(E_rs==W_regWriteAddr&&W_regWriteEn)?W_regWriteData:
									E_rsData;
	assign E_rtDataTrue = 	(E_rt==5'd0)?32'd0:
									(E_rt==M_regWriteAddr&&M_regWriteEn)?M_regWriteData:
									(E_rt==W_regWriteAddr&&W_regWriteEn)?W_regWriteData:
									E_rtData;
	assign E_srcA = 	E_rsDataTrue;
	assign E_srcB = 	(E_aluSrcBOp==`aluSrcBIsImmExt)?E_immExt:
							(E_aluSrcBOp==`aluSrcBIsRtData)?E_rtDataTrue:
							E_immExt;
	
	E_ALU E_alu(
		.srcA(E_srcA),
    	.srcB(E_srcB),
    	.aluOp(E_aluOp),
    	.aluResult(E_aluResult)
	);

//——————M级——————//
//M_REG
	REG M_reg(
		  .clk(clk),
        .reset(reset),
        .clr(M_REG_clr),
	     .en(M_REG_en),
		  
        .instrIn(E_instr),
        .pcIn(E_pc),
        .immExtIn(E_immExt),
        .rsDataIn(E_rsDataTrue),
        .rtDataIn(E_rtDataTrue),
		  .aluResultIn(E_aluResult),
		  
	     .instrOut(M_instr),
        .pcOut(M_pc),
        .immExtOut(M_immExt),
        .rsDataOut(M_rsData),
        .rtDataOut(M_rtData),
		  .aluResultOut(M_aluResult)
	);
	
//M_CU
	
	CU M_cu(
		.instr(M_instr),
		.rt(M_rt),
		.regWriteEn(M_regWriteEn),
		.memWriteEn(M_memWriteEn),
		.regWriteAddr(M_regWriteAddr),
		.regWriteOp(M_regWriteOp)
	);

	assign M_regWriteData=	//(M_regWriteOp==`regWriteIsMemReadData)?M_memReadData:
									(M_regWriteOp==`regWriteIsAluResult)?M_aluResult:
									(M_regWriteOp==`regWriteIsImmLUI)?M_immExt:
									(M_regWriteOp==`regWriteIsPCJal)?M_pc+8:
									0;
//M_DM
	
	
	assign M_memWriteData = 	(M_rt==5'd0)?32'd0:
									(M_rt==W_regWriteAddr&&W_regWriteEn)?W_regWriteData:
									M_rtData;
	M_DM M_dm(
		.memAddr(M_aluResult),
    	.memWriteData(M_memWriteData),
    	.memWriteEn(M_memWriteEn),
    	.clk(clk),
    	.reset(reset),
		.PC(M_pc),
    	.memReadData(M_memReadData)
	);
	
	
//——————W级——————//
//W_REG
	REG W_reg(
		.clk(clk),
        .reset(reset),
        .clr(W_REG_clr),
	     .en(W_REG_en),
		  
        .instrIn(M_instr),
        .pcIn(M_pc),
        .immExtIn(M_immExt),
		  .memReadDataIn(M_memReadData),
		  .aluResultIn(M_aluResult),
		  
	     .instrOut(W_instr),
        .pcOut(W_pc),
        .immExtOut(W_immExt),
        .memReadDataOut(W_memReadData),
		  .aluResultOut(W_aluResult)
	); 
	
//W_CU
	CU W_cu(
		.instr(W_instr),
		.regWriteOp(W_regWriteOp),
		.regWriteAddr(W_regWriteAddr),
		.regWriteEn(W_regWriteEn)
	);
	
	assign W_regWriteData=	(W_regWriteOp==`regWriteIsMemReadData)?W_memReadData:
									(W_regWriteOp==`regWriteIsAluResult)?W_aluResult:
									(W_regWriteOp==`regWriteIsImmLUI)?W_immExt:
									(W_regWriteOp==`regWriteIsPCJal)?W_pc+8:
									0;
									

	
endmodule
