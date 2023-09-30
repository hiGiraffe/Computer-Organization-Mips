`timescale 1ns / 1ps
`include "const.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:14:05 11/18/2022 
// Design Name: 
// Module Name:    E_HILO 
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
module E_HILO(
    input clk,
    input reset,
    input [3:0] HYLOOp,
    input [31:0] rsData,
    input [31:0] rtData,
    output [31:0] HILOOut,
    output busy
    );
	
	
	wire mult;
	wire multu;
	wire div;
	wire divu;
	wire mflo;
	wire mfhi;
	wire mtlo;
	wire mthi;
	assign mult = (HYLOOp==`mult);
	assign multu = (HYLOOp==`multu);
	assign div = (HYLOOp==`div);
	assign divu = (HYLOOp==`divu);
	assign mflo = (HYLOOp==`mflo);
	assign mfhi = (HYLOOp==`mfhi);
	assign mtlo = (HYLOOp==`mtlo);
	assign mthi = (HYLOOp==`mthi);
	
	reg [31:0] HI;
	reg [31:0] LO;
	integer state;
	
	initial begin
		HI <= 32'd0;
		LO <= 32'd0;
		state <= 32'd0;
	end
	//{HI, LO} = $signed($signed({HI, LO}) - $signed(A) × $signed(B))
	//madd {temp_hi, temp_lo} <= {hi, lo} + $signed($signed(64'd0) + $signed(rs) * $signed(rt));
	always @(posedge clk)
	begin
		if(reset) begin
			HI <= 32'd0;
			LO <= 32'd0;
			state <= 32'd0;
		end
		else if(HYLOOp==4'd9)begin
			LO <= $signed(rsData) / $signed(rtData);
				HI <= $signed(rsData) % $signed(rtData);
				state<=3;
		end
		else if(mult||multu||div||divu) begin
			if(mult) begin
				{HI,LO} <= $signed(rsData) * $signed(rtData);
				state<=5;
			end
			else if(multu) begin
				{HI,LO} <= rsData * rtData;
				state<=5;
			end
			else if(div) begin
				LO <= $signed(rsData) / $signed(rtData);
				HI <= $signed(rsData) % $signed(rtData);
				state<=10;
			end
			else if(divu) begin
				LO <= rsData/rtData;
				HI <= rsData%rtData;
				state<=10;
			end
			else ;
		end
		else if (mthi) HI <= rsData;
		else if (mtlo) LO <= rsData;
		else if (state != 0) state <= state -1;
		else ;
	end
	assign busy = (state!=0);
	assign HILOOut = 	(mfhi)?HI:
							(mflo)?LO:
							0;
endmodule
