`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:49:35 11/01/2022 
// Design Name: 
// Module Name:    DM 
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
module M_DM(
    input [31:0] memAddr,
    input [31:0] memWriteData,
    input memWriteEn,
    input clk,
    input reset,
	 input [31:0] PC,
    output [31:0] memReadData
    );
	
	integer i;
	reg [31:0] RAM [3071:0];
	wire [31:0] RAMnum;
	
	initial begin
		for(i=0;i<3072;i=i+1) RAM[i]=0;
	end
	
	always @(posedge clk)
	begin
		if(reset)
		begin
			for(i=0;i<3072;i = i+1) RAM[i]=0;
		end
		else
		begin
			if(memWriteEn)
			begin
				//$display("%d@%h: *%h <= %h", $time, PC, memAddr, memWriteData);
				$display("@%h: *%h <= %h", PC, memAddr, memWriteData);
				RAM[RAMnum] <= memWriteData;
			end
			else ;
		end
	end
	assign RAMnum ={2'b0, memAddr[31:2]};
	assign memReadData = RAM[RAMnum];

endmodule
