`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:27:20 11/13/2022 
// Design Name: 
// Module Name:    D_CMP 
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
module D_CMP(
    input [31:0] rsData,
    input [31:0] rtData,
    input beq,
	 input bne,
    output judge
    );

	assign judge = (beq&(rsData==rtData))||(bne&(rsData!=rtData));
	
endmodule
