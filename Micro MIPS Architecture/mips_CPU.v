`timescale 1ns / 1ps
`include "const.v"
`define exc_int     5'd0
`define exc_adel    5'd4
`define exc_ades    5'd5
`define exc_ri      5'd10
`define exc_ov      5'd12
`define exc_none    5'd0
`define syscall	  5'd8

module mips_CPU(
		input clk,
		input reset,
		
		output [31:0] i_inst_addr,
		input [31:0] i_inst_rdata,
		
		output [31:0] m_data_addr,
		output [31:0] m_data_wdata,
		output [3 :0] m_data_byteen,
		output [31:0] m_inst_addr,
		input [31:0] m_data_rdata,
		
		output w_grf_we,
		output [4:0] w_grf_addr,
		output [31:0] w_grf_wdata,
		output [31:0] w_inst_addr,
		
		input [5:0] HWInt,//外部中断信号
		output [31:0] macro_pc//宏观pc
		//output TestIntResponse//是否回应外部中断
    );
		//F
		//IFU
		wire [31:0] F_nextPC;
		wire [31:0] F_instr;
		wire [31:0] F_pc;	 
		wire [31:0] F_tmp_pc;
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
		wire D_bne;
		wire D_jal;
		wire D_jr;
		//D_GRF
		wire [31:0] D_rsData;
		wire [31:0] D_rtData;
		//D_CMP
		wire [31:0] D_rsDataTrue;
		wire [31:0] D_rtDataTrue;
		wire D_B_judge;
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
		wire E_aluAriOv;
		wire E_aluDMOv;
		//E_ALU
		wire [31:0] E_rsDataTrue;
		wire [31:0] E_rtDataTrue;
		wire [31:0] E_srcA;
		wire [31:0] E_srcB;
		wire [31:0] E_aluResult;
		//E_HILO
		wire [3:0] E_HYLOOp;
		wire [31:0] E_HILOOut;
		wire busy;
		
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
		wire [31:0] M_HILOOut;
		//M_CU
		wire M_memWriteEn;
		wire M_regWriteEn;
		wire [31:0] M_regWriteData;
		wire [4:0] M_regWriteAddr;
		wire [2:0] M_regWriteOp;
		wire [4:0] M_rt;
		wire [4:0] M_rd;
		wire M_cp0WriteEn;
		//M_DM
		wire [31:0] M_memWriteData;
		wire [31:0] M_memReadData;
		wire M_sb;
		wire M_sh;
		wire M_sw;
		wire M_lb;
		wire M_lh;
		wire M_lw;
		//M_cp0
		wire [31:0] M_cp0Out;
		
		//W级
		//W_REG
		wire W_REG_clr;
		wire W_REG_en;
		wire [31:0] W_pc;
		wire [31:0] W_immExt;
		wire [31:0] W_instr;
		wire [31:0] W_aluResult;
		wire [31:0] W_memReadData;
		wire [31:0] W_HILOOut;
		wire [31:0] W_cp0Out;
		//W_CU
		wire W_regWriteEn;
		wire [2:0] W_regWriteOp;
		wire [4:0] W_regWriteAddr;
		wire [31:0] W_regWriteData;
		
		wire W_lb;
		wire W_lh;
		
		//SU
		wire stall;
		
		
		//延迟槽指令
		wire F_delaySlot;
		wire D_delaySlot;
		wire E_delaySlot;
		wire M_delaySlot;
		
		//异常信息指令
		wire [4:0] F_excCode;
		wire [4:0] D_excCode;
		wire [4:0] E_excCode;
		wire [4:0] M_excCode;
		
		wire [4:0] D_tmp_excCode;
		wire [4:0] E_tmp_excCode;
		wire [4:0] M_tmp_excCode;
		
		//异常提示信息
		wire F_exc_adel;//取值异常、PC爆了
		wire D_exc_ri;//未知指令
		wire E_exc_ariov;//算术溢出
		wire E_exc_dmov;//dm溢出
		wire M_exc_dmov;
		wire M_exc_adel;//取指异常（load类）
		wire M_exc_ades;//存数异常（store类）
		
		//eret
		wire D_eret;
		wire E_eret;
		wire M_eret;
		
		//EPC
		wire [31:0] EPC;
		wire Req;//进入异常处理请求
		
		//SU
	SU su(
		.D_instr(D_instr),
		.E_instr(E_instr),
		.M_instr(M_instr),
		.busy(busy),
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
		.F_IFU_en(F_IFU_en|Req),
		.reset(reset),
		//.instr(F_instr),
		.PC(F_tmp_pc)
	);
	
	assign F_pc = D_eret?EPC:F_tmp_pc;//
	//F_异常
	assign F_exc_adel = 	((|F_pc[1:0])|//未字对齐
								((F_pc<32'h00003000)|(F_pc>32'h00006ffc)))//超出范围
								&!D_eret;
	//initial//		
	assign i_inst_addr = F_pc;
	assign F_instr = (F_exc_adel)?32'b0:i_inst_rdata;
	//异常信息
	assign F_excCode = F_exc_adel? `exc_adel:`exc_none;
	assign F_delaySlot = !(D_beq|D_bne|D_jal|D_jr);						
//——————D级——————//
//D_REG
	
	D_REG D_reg(
		.clk(clk),
		.reset(reset),
		.en(D_REG_en),
		.clr(D_REG_clr),
		.Req(Req),
		
		.instrIn(F_instr),
		.pcIn(F_pc),
		.delaySlotIn(F_delaySlot),
		.excCodeIn(F_excCode),
		
		.instrOut(D_instr),
		.pcOut(D_pc),
		.delaySlotOut(D_delaySlot),
		.excCodeOut(D_tmp_excCode)
	);
//D_CU
   wire D_syscall;
	CU D_cu(
		.instr(D_instr),
		.rs(D_rs),
		.rt(D_rt),
		.rd(D_rd),
		.imm(D_imm),
		.instrIndex(D_instrIndex),
		.EXTOp(D_EXTOp),
		.beq(D_beq),
		.bne(D_bne),
		.jal(D_jal),
		.jr(D_jr),
		
		.eret(D_eret),
		.exc_ri(D_exc_ri),
		.syscall(D_syscall)
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
	
	assign w_grf_we = W_regWriteEn; 
	assign w_grf_addr = W_regWriteAddr;
	assign w_grf_wdata=W_regWriteData;
	assign w_inst_addr = W_pc;
	
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
		.bne(D_bne),
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
		.bne(D_bne),
		.jr(D_jr),
		.regJr(D_rsDataTrue),
		.B_judge(D_B_judge),
		
		.Req(Req),
		.eret(D_eret),
		.EPC(EPC)
	);
	
	assign D_excCode = 	(D_tmp_excCode)? D_tmp_excCode:
								(D_exc_ri)? `exc_ri:
								(D_syscall)? `syscall:
								`exc_none;
//——————E级——————//
	
	E_REG E_reg(
		  .clk(clk),
        .reset(reset),
        .clr(E_REG_clr),
	     .en(E_REG_en),
		  .Req(Req),
		  .stall(stall),
		  
        .instrIn(D_exc_ri?32'd0:D_instr),
        .pcIn(D_pc),
		  .delaySlotIn(D_delaySlot),
		  .excCodeIn(D_excCode),
        .immExtIn(D_immExt),
        .rsDataIn(D_rsDataTrue),
        .rtDataIn(D_rtDataTrue),
		  
	     .instrOut(E_instr),
        .pcOut(E_pc),
		  .delaySlotOut(E_delaySlot),
		  .excCodeOut(E_tmp_excCode),
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
		.regWriteOp(E_regWriteOp),
		.HYLOOp(E_HYLOOp),
		
		.eret(E_eret),
		.aluDMOv(E_aluDMOv),
		.aluAriOv(E_aluAriOv)
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
    	.aluResult(E_aluResult),
		
		.aluDMOv(E_aluDMOv),
		.aluAriOv(E_aluAriOv),
		
		.exc_AriOv(E_exc_ariov),
		.exc_DMOv(E_exc_dmov)
	);

//E_HILO
	E_HILO E_hilo(
		.clk(clk),
		.reset(reset),
		.HYLOOp(E_HYLOOp),
		.rsData(E_rsDataTrue),
		.rtData(E_rtDataTrue),
		.HILOOut(E_HILOOut),
		.busy(busy),
		.Req(Req)
		
	);

	assign E_excCode = 	(E_tmp_excCode)? E_tmp_excCode:
								(E_exc_ariov)?`exc_ov:
								`exc_none;

//——————M级——————//
//M_REG
	M_REG M_reg(
		  .clk(clk),
        .reset(reset),
        .clr(M_REG_clr),
	     .en(M_REG_en),
		  .Req(Req),
		  
        .instrIn(E_instr),
        .pcIn(E_pc),
        .immExtIn(E_immExt),
        .rsDataIn(E_rsDataTrue),
        .rtDataIn(E_rtDataTrue),
		  .aluResultIn(E_aluResult),
		  .HILOOut1(E_HILOOut),
		  .delaySlotIn(E_delaySlot),
		  .excCodeIn(E_excCode),
		  .exc_dmovIn(E_exc_dmov),
		  
	     .instrOut(M_instr),
        .pcOut(M_pc),
        .immExtOut(M_immExt),
        .rsDataOut(M_rsData),
        .rtDataOut(M_rtData),
		  .aluResultOut(M_aluResult),
		  .HILOOut2(M_HILOOut),
		  .delaySlotOut(M_delaySlot),
		  .excCodeOut(M_tmp_excCode),
		  .exc_dmovOut(M_exc_dmov)
	);
	
//M_CU
	CU M_cu(
		.instr(M_instr),
		.rt(M_rt),
		.rd(M_rd),
		.regWriteEn(M_regWriteEn),
		.memWriteEn(M_memWriteEn),
		.memByteen(m_data_byteen),
		.regWriteAddr(M_regWriteAddr),
		.regWriteOp(M_regWriteOp),
		.M_aluResult(M_aluResult),
		.sb(M_sb),
		.sh(M_sh),
		.sw(M_sw),
		.lb(M_lb),
		.lh(M_lh),
		.lw(M_lw),
		.eret(M_eret),
		.cp0WriteEn(M_cp0WriteEn)
	);

	assign M_regWriteData=	//(M_regWriteOp==`regWriteIsMemReadData)?M_memReadData:
									(M_regWriteOp==`regWriteIsAluResult)?M_aluResult:
									(M_regWriteOp==`regWriteIsImmLUI)?M_immExt:
									(M_regWriteOp==`regWriteIsPCJal)?M_pc+8:
									(M_regWriteOp==`regWriteIsHILO)?M_HILOOut:
									0;
//M_DM
	
	
	assign M_memWriteData = 	(M_rt==5'd0)?32'd0:
									(M_rt==W_regWriteAddr&&W_regWriteEn)?W_regWriteData:
									M_rtData;
		
	M_ErrStore M_errStore(
		.sw(M_sw),
		.sh(M_sh),
		.sb(M_sb),
		.addr(M_aluResult),
		.exc_dmov(M_exc_dmov),
		.exc_ades(M_exc_ades)
	);
	M_ErrLoad M_errLoad(
		.lw(M_lw),
		.lh(M_lh),
		.lb(M_lb),
		.addr(M_aluResult),
		.exc_dmov(M_exc_dmov),
		.exc_adel(M_exc_adel)
	);
	assign m_data_addr = M_aluResult;
	assign m_data_wdata = 	(M_sb)?{M_memWriteData[7:0],M_memWriteData[7:0],M_memWriteData[7:0],M_memWriteData[7:0]}:
									(M_sh)?{M_memWriteData[15:0],M_memWriteData[15:0]}:
									M_memWriteData;
	assign m_inst_addr = M_pc;
	assign M_memReadData = m_data_rdata;
	
	
	assign M_excCode = 	(M_tmp_excCode)?M_tmp_excCode:
								(M_exc_ades)? `exc_ades:
								(M_exc_adel)? `exc_adel:
								`exc_none;
	wire [31:0]M_rtDataTrue = 		(M_rt==5'd0)?32'd0:
									(M_rt==W_regWriteAddr&&W_regWriteEn)?W_regWriteData:
									M_rtData;
//	M_DM M_dm(
//		.memAddr(M_aluResult),
//    	.memWriteData(M_memWriteData),
//    	.memWriteEn(M_memWriteEn),
//    	.clk(clk),
//    	.reset(reset),
//		.PC(M_pc),
//    	.memReadData(M_memReadData)
//	);
	mips_cp0 mips_CP0(
		.clk(clk),
		.reset(reset),
		.Req(Req),
		.PC(M_pc),
		.isDelaySlot(M_delaySlot),
		.excCodeIn(M_excCode),
		.HWInt(HWInt),
		.A1(M_rd),
		.A2(M_rd),
		.dataIn(M_rtDataTrue),
		.WE(M_cp0WriteEn),
		.exlClr(M_eret),
		.EPCOut(EPC),
		.dataOut(M_cp0Out)
	);
	
//——————W级——————//
//W_REG
	REG W_reg(
		.clk(clk),
        .reset(reset),
        .clr(W_REG_clr),
	     .en(W_REG_en),
		  .Req(Req),
		  
        .instrIn(M_instr),
        .pcIn(M_pc),
        .immExtIn(M_immExt),
		  .memReadDataIn(M_memReadData),
		  .aluResultIn(M_aluResult),
		  .HILOOut1(M_HILOOut),
		  .cp0Out1(M_cp0Out),
		  
	     .instrOut(W_instr),
        .pcOut(W_pc),
        .immExtOut(W_immExt),
        .memReadDataOut(W_memReadData),
		  .aluResultOut(W_aluResult),
		  .HILOOut2(W_HILOOut),
		  .cp0Out2(W_cp0Out)
	); 
	
//W_CU
	CU W_cu(
		.instr(W_instr),
		.regWriteOp(W_regWriteOp),
		.regWriteAddr(W_regWriteAddr),
		.regWriteEn(W_regWriteEn),
		.lb(W_lb),
		.lh(W_lh)
	);
	
	assign W_regWriteData=	//(W_lb)?{{24{W_aluResult[1]}},W_memReadData[7+8*W_aluResult[1:0]:8*W_aluResult[1:0]]}:
									//(W_lh)?{{16{15+16*W_aluResult[1]}},W_memReadData[15+16*W_aluResult[1]:16*W_aluResult[1]]}:
									(W_lb)?{{24{W_memReadData[8*W_aluResult[1:0]+7]}},W_memReadData[8*W_aluResult[1:0]+:8]}:
									(W_lh)?{{16{W_memReadData[15+16*W_aluResult[1]]}},W_memReadData[16*W_aluResult[1]+:16]}:
									(W_regWriteOp==`regWriteIsMemReadData)?W_memReadData:
									(W_regWriteOp==`regWriteIsAluResult)?W_aluResult:
									(W_regWriteOp==`regWriteIsImmLUI)?W_immExt:
									(W_regWriteOp==`regWriteIsPCJal)?W_pc+8:
									(W_regWriteOp==`regWriteIsHILO)?W_HILOOut:
									(W_regWriteOp==`regWriteIsCp0)?W_cp0Out:
									0;
								

	
endmodule
