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
    output stall
    );
	
//D级
	wire D_add;
	wire D_sub;
	wire D_ori;
	wire D_lw;
	wire D_sw;
	wire D_beq;
	wire D_lui;
	wire D_jal;
	wire D_jr;
	wire D_or;
	
	wire [4:0] D_rs;
	wire [4:0] D_rt;
	

	CU SU_D_cu(
		.instr(D_instr),
		.rs(D_rs),
		.rt(D_rt),
		
		.isor(D_or),
		.add(D_add),
		.sub(D_sub),
		.ori(D_ori),
		.lw(D_lw),
		.sw(D_sw),
		.beq(D_beq),
		.lui(D_lui),
		.jal(D_jal),
		.jr(D_jr)
	);
	
	wire TuseRs = 	(D_beq|D_jr)?3'd0:
						(D_add|D_sub|D_ori|D_lw|D_sw|D_or)?3'd1:
						3'd3;//jal/lui
	wire TuseRt = 	(D_beq)?3'd0:
						(D_add|D_sub)?3'd1:
						(D_sw)?3'd2:
						3'd3;
//E级
	wire [4:0]E_regWriteAddr;
	wire E_add;
	wire E_sub;
	wire E_ori;
	wire E_lw;
	wire E_sw;
	wire E_beq;
	wire E_lui;
	wire E_jal;
	wire E_jr;
	wire [2:0] TnewE;
	
	CU SU_E_cu(
		.instr(E_instr),
		.regWriteAddr(E_regWriteAddr),
		
		.isor(E_or),
		.add(E_add),
		.sub(E_sub),
		.ori(E_ori),
		.lw(E_lw),
		.sw(E_sw),
		.beq(E_beq),
		.lui(E_lui),
		.jal(E_jal),
		.jr(E_jr)
	);
	
	assign TnewE = (E_add|E_sub|E_ori|E_or)?3'd1:
						(E_lw)?3'd2:
						3'd0;//sw/beq/jal/jr/lui
//M级
	wire M_lw;
	wire [4:0] M_regWriteAddr;
	wire [2:0] TnewM;
	CU SU_M_cu(
		.instr(M_instr),
		.lw(M_lw),
		.regWriteAddr(M_regWriteAddr)
	);
	
	assign TnewM = (M_lw)?3'd1:
						3'd0;

//对比
	wire stallRsE;
	wire stallRsM;
	wire stallRtE;
	wire stallRtM;
	
	assign stallRsE = (TuseRs<TnewE)&&D_rs&&(D_rs==E_regWriteAddr);
	assign stallRsM = (TuseRs<TnewM)&&D_rs&&(D_rs==M_regWriteAddr);
	assign stallRtE = (TuseRs<TnewE)&&D_rt&&(D_rt==E_regWriteAddr);
	assign stallRtM = (TuseRs<TnewM)&&D_rt&&(D_rt==M_regWriteAddr);
	
	assign stall = stallRsE|stallRsM|stallRtE|stallRtM;
endmodule
