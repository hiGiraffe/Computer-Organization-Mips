`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:59:35 12/10/2022 
// Design Name: 
// Module Name:    M_ErrLoad 
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
module M_ErrLoad(
	input lw,
	input lh,
	input lb,
	input [31:0] addr,
	input exc_dmov,
	output exc_adel
    );
	wire errUnalign = (lw&(|addr[1:0]))|(lh&addr[0]);
	wire errOutOfRange = !(
								((addr>=32'h0000_0000)&&(addr<=32'h0000_2fff))|
								((addr>=32'h0000_7f00)&&(addr<=32'h0000_7f0b))|
								((addr>=32'h0000_7f10)&&(addr<=32'h0000_7f1b))|
								((addr>=32'h0000_7f20)&&(addr<=32'h0000_7f23))
								);
	wire errTimer = 	(lb|lh)&&(addr>32'h0000_7f00);
	assign exc_adel = (lb|lh|lw)&&(errUnalign|errOutOfRange|errTimer|exc_dmov);

endmodule
