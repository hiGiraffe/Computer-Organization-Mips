`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:35:39 11/01/2022 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
    input clk,
    input reset,
    input regWriteEn,
    input [4:0] regReadAddr1,
    input [4:0] regReadAddr2,
    input [4:0] regWriteAddr,
    input [31:0] regWriteData,
	 input [31:0] PC,
    output [31:0] regReadData1,
    output [31:0] regReadData2
    );
	
	reg [31:0] REG [31:0];
	integer i;

	initial begin
		for(i = 0; i < 32 ;i = i+1) REG[i]=0;
	end
	
	assign regReadData1 = REG[regReadAddr1];
	assign regReadData2 = REG[regReadAddr2];
	
	always @(posedge clk)
	begin
		if(reset)
		begin
			for(i=0;i<32;i=i+1) REG[i]=0;
		end
		else begin
			if(regWriteEn==1)begin//记得清零！记得初始化！
			$display("@%h: $%d <= %h", PC, regWriteAddr, regWriteData);
				if(regWriteAddr==0) ;
				else
				begin
					REG[regWriteAddr] <= regWriteData;
				end
			end
			else ;
		end
	end
endmodule
