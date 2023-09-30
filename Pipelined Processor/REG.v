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
    input [31:0] instrIn,
    input [31:0] pcIn,
    input [31:0] immExtIn,
    input [31:0] rsDataIn,
    input [31:0] rtDataIn,
	 input [31:0] aluResultIn,
	 input [31:0] memReadDataIn,
	 
	 output reg [31:0] instrOut,
    output reg [31:0] pcOut,
    output reg [31:0] immExtOut,
    output reg [31:0] rsDataOut,
    output reg [31:0] rtDataOut,
	 output reg [31:0] aluResultOut,
	 output reg [31:0] memReadDataOut
    );
	
	initial begin
		instrOut<=32'd0;
			pcOut<=32'd0;
    		immExtOut<=32'd0;
    		rsDataOut<=32'd0;
    		rtDataOut<=32'd0;
			aluResultOut<=32'd0;
			memReadDataOut<=32'd0;
	end
	always@(posedge clk)
	begin
		if(reset||clr)
		begin
			instrOut<=32'd0;
			pcOut<=32'd0;
    		immExtOut<=32'd0;
    		rsDataOut<=32'd0;
    		rtDataOut<=32'd0;
			aluResultOut<=32'd0;
			memReadDataOut<=32'd0;
		end
		else if(en)
		begin
			instrOut<=instrIn;
			pcOut<=pcIn;
    		immExtOut<=immExtIn;
    		rsDataOut<=rsDataIn;
    		rtDataOut<=rtDataIn;
			aluResultOut<=aluResultIn;
			memReadDataOut<=memReadDataIn;
		end
		else ;
	end
	
endmodule
