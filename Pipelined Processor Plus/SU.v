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
		.jr(D_jr)
	);
	
	wire TuseRs = 	(D_branch|D_jr)?3'd0:
						(D_calc_r|D_calc_i|D_load|D_store|D_md|D_mt)?3'd1:
						3'd3;//mf/jal/lui
	wire TuseRt = 	(D_branch)?3'd0:
						(D_calc_r|D_md)?3'd1:
						(D_store)?3'd2:
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
	
	CU SU_E_cu(
		.instr(E_instr),
		.regWriteAddr(E_regWriteAddr),
		
		.load(E_load),
		.store(E_store),
		.branch(E_branch),
		.calc_r(E_calc_r),
		.calc_i(E_calc_i),
		.md(E_md),
		.mt(E_mt),
		.mf(E_mf),
		.jal(E_jal),
		.jr(E_jr)
	);
	
	assign TnewE = (E_calc_r|E_calc_i|E_mf)?3'd1:
						(E_load)?3'd2:
						3'd0;//store/md/mt/branch/jal/jr/lui
//M级
	wire M_load;
	wire [4:0] M_regWriteAddr;
	wire [2:0] TnewM;
	CU SU_M_cu(
		.instr(M_instr),
		.load(M_load),
		.regWriteAddr(M_regWriteAddr)
	);
	
	assign TnewM = (M_load)?3'd1:
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
	
	assign stall = stallRsE|stallRsM|stallRtE|stallRtM|stallHILO;
endmodule
