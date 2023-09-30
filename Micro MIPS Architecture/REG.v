`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:07:11 11/13/2022 
// Design Name: 
// Module Name:    E_REG 
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
module REG(
    input clk,
    input reset,
    input clr,
	 input en,
	 input Req,
	 
    input [31:0] instrIn,
    input [31:0] pcIn,
	 input delaySlotIn,
	 input [4:0] excCodeIn,
    input [31:0] immExtIn,
    input [31:0] rsDataIn,
    input [31:0] rtDataIn,
	 input [31:0] aluResultIn,
	 input [31:0] memReadDataIn,
	 input [31:0] HILOOut1,
	 input exc_dmovIn,
	 input [31:0] cp0Out1,
	 
	 output reg [31:0] instrOut,
    output reg [31:0] pcOut,
	 output reg delaySlotOut,
	 output reg [4:0] excCodeOut,
    output reg [31:0] immExtOut,
    output reg [31:0] rsDataOut,
    output reg [31:0] rtDataOut,
	 output reg [31:0] aluResultOut,
	 output reg [31:0] memReadDataOut,
	 output reg [31:0] HILOOut2,
	 output reg exc_dmovOut,
	 output reg [31:0] cp0Out2
    );
	
	initial begin
		instrOut<=32'd0;
			pcOut<=32'd0;
			delaySlotOut<=1'd0;
			excCodeOut<=5'd0;
    		immExtOut<=32'd0;
    		rsDataOut<=32'd0;
    		rtDataOut<=32'd0;
			aluResultOut<=32'd0;
			memReadDataOut<=32'd0;
			HILOOut2<=32'd0;
			exc_dmovOut<=1'd0;
			cp0Out2<=32'd0;
	end
	always@(posedge clk)
	begin
		if(reset||clr||Req)
		begin
			instrOut<=Req?32'h0000_4180:32'd0;
			pcOut<=32'd0;
			delaySlotOut<=1'd0;
			excCodeOut<=5'd0;
    		immExtOut<=32'd0;
    		rsDataOut<=32'd0;
    		rtDataOut<=32'd0;
			aluResultOut<=32'd0;
			memReadDataOut<=32'd0;
			HILOOut2<=32'd0;
			exc_dmovOut<=1'd0;
			cp0Out2<=32'd0;
		end
		else if(en)
		begin
			instrOut<=instrIn;
			pcOut<=pcIn;
			delaySlotOut<=delaySlotOut;
			excCodeOut<=excCodeIn;
    		immExtOut<=immExtIn;
    		rsDataOut<=rsDataIn;
    		rtDataOut<=rtDataIn;
			aluResultOut<=aluResultIn;
			memReadDataOut<=memReadDataIn;
			HILOOut2<=HILOOut1;
			exc_dmovOut<=exc_dmovIn;
			cp0Out2<=cp0Out1;
		end
		else ;
	end
	
endmodule
