`timescale 1ns / 1ps
`define IM SR[15:10]
`define EXL SR[1]
`define IE SR[0]

`define BD Cause[31]
`define IP Cause[15:10]
`define excCode Cause[6:2]

module mips_cp0(
	input clk,
	input reset,
	input Req,
	input [31:0] PC,
	input isDelaySlot,
	input [4:0] excCodeIn,
	input [5:0] HWInt,
	//mfc0
	input [4:0] A1,
	//mtc0
	input [4:0] A2,
	input [31:0] dataIn,
	input WE,
	//eret
	input exlClr,
	
	output [31:0] EPCOut,
	output [31:0] dataOut
	//output TestIntResponse
    );

	reg [31:0] SR;//系统状态
	reg [31:0] Cause;//异常信息
	reg [31:0] EPC;//发生异常的位置
	//reg [31:0] PrID;//CPU型号

	wire IntReq = `IE&(!`EXL)&(|(HWInt&`IM));
	wire ExcReq = (|excCodeIn)&(!`EXL);
	assign Req = IntReq | ExcReq;
	
	initial begin 
		SR<=0;
		Cause<=0;
		EPC<=0;
	end
	wire [31:0] tmpEPC;
	assign tmpEPC = (Req)?(isDelaySlot?(PC-32'd4):PC):EPC;
	
	always@(posedge clk or posedge reset)begin
		if(reset)begin
			SR<=0;
			Cause<=0;
			EPC<=0;
		end
		else begin
			if(exlClr) `EXL<=1'b0;
			if(Req)begin
				`excCode <= IntReq?5'd0:excCodeIn;
				`EXL <=1'b1;
				EPC <=tmpEPC;
				`BD<=isDelaySlot;
			end
			else if(WE)begin
				if(A2==12) SR<=dataIn;
				else if(A2==14) EPC<=dataIn;
			end
			`IP<=HWInt;
		end
	end
	
	assign EPCOut = tmpEPC;
	assign dataOut = 	(A1==12)?SR:
							(A1==13)?Cause:
							(A1==14)?EPCOut:
							0;
endmodule
