`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:30:29 11/13/2022 
// Design Name: 
// Module Name:    SU 
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
module SU(
    input [31:0] D_instr,
    input [31:0] E_instr,
    input [31:0] M_instr,
    output stall,
	 input busy
    );
//D级
	wire D_load;
   wire D_store;
   wire D_branch;
   wire D_calc_r;
   wire D_calc_i;
   wire D_md;
   wire D_mt;
   wire D_mf;
	wire D_jal;
	wire D_jr;
	wire D_eret;
	wire D_mfc0;
	wire D_mtc0;
	
	wire [4:0] D_rs;
	wire [4:0] D_rt;
	

	CU SU_D_cu(
		.instr(D_instr),
		.rs(D_rs),
		.rt(D_rt),
		
		.load(D_load),
		.store(D_store),
		.branch(D_branch),
		.calc_r(D_calc_r),
		.calc_i(D_calc_i),
		.md(D_md),
		.mt(D_mt),
		.mf(D_mf),
		.jal(D_jal),
		.jr(D_jr),
		.eret(D_eret),
      .mtc0(D_mtc0),
      .mfc0(D_mfc0)
	);
	
	wire TuseRs = 	(D_branch|D_jr)?3'd0:
						(D_calc_r|D_calc_i|D_load|D_store|D_md|D_mt)?3'd1:
						3'd3;//mf/jal/lui
	wire TuseRt = 	(D_branch)?3'd0:
						(D_calc_r|D_md)?3'd1:
						(D_store|D_mtc0)?3'd2:
						3'd3;//calc_i/load/mt/mf/jr/jal/lui
//E级
	wire [4:0]E_regWriteAddr;
	wire E_load;
   wire E_store;
   wire E_branch;
   wire E_calc_r;
   wire E_calc_i;
   wire E_md;
   wire E_mt;
   wire E_mf;
	wire E_jal;
	wire E_jr;
	wire [2:0] TnewE;
	wire E_eret;
	wire E_mfc0;
	wire E_mtc0;
	wire [4:0] E_rd;
	
	CU SU_E_cu(
		.instr(E_instr),
		.regWriteAddr(E_regWriteAddr),
		.rd(E_rd),
		.load(E_load),
		.store(E_store),
		.branch(E_branch),
		.calc_r(E_calc_r),
		.calc_i(E_calc_i),
		.md(E_md),
		.mt(E_mt),
		.mf(E_mf),
		.jal(E_jal),
		.jr(E_jr),
		.eret(E_eret),
      .mtc0(E_mtc0),
      .mfc0(E_mfc0)
	);
	
	assign TnewE = (E_calc_r|E_calc_i|E_mf)?3'd1:
						(E_load|E_mfc0)?3'd2:
						3'd0;//store/md/mt/branch/jal/jr/lui
//M级
	wire M_load;
	wire [4:0] M_regWriteAddr;
	wire [2:0] TnewM;
	wire M_eret;
	wire M_mfc0;
	wire M_mtc0;
	wire [4:0]M_rd;
	CU SU_M_cu(
		.instr(M_instr),
		.rd(M_rd),
		.load(M_load),
		.regWriteAddr(M_regWriteAddr),
		.eret(M_eret),
      .mtc0(M_mtc0),
      .mfc0(M_mfc0)
	);
	
	assign TnewM = (M_load|M_mfc0)?3'd1:
						3'd0;

//对比
	wire stallRsE;
	wire stallRsM;
	wire stallRtE;
	wire stallRtM;
	wire stallHILO;
	
	assign stallRsE = (TuseRs<TnewE)&&D_rs&&(D_rs==E_regWriteAddr);
	assign stallRsM = (TuseRs<TnewM)&&D_rs&&(D_rs==M_regWriteAddr);
	assign stallRtE = (TuseRs<TnewE)&&D_rt&&(D_rt==E_regWriteAddr);
	assign stallRtM = (TuseRs<TnewM)&&D_rt&&(D_rt==M_regWriteAddr);
	assign stallHILO = busy&(D_md|D_mt|D_mf);
	assign stallEret = (D_eret)&&((E_mtc0&&E_rd==5'd14)||(M_mtc0&&M_rd==5'd14));
	
	assign stall = stallRsE|stallRsM|stallRtE|stallRtM|stallHILO|stallEret;
endmodule
