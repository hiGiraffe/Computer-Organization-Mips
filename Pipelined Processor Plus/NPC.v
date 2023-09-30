`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:03:52 11/02/2022 
// Design Name: 
// Module Name:    NPC 
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
module D_NPC(
    input [31:0] F_pc,
	 input [31:0] D_pc,
    input [31:0] immExt,
    output reg [31:0] nextPC,
	 input [25:0] instrIndex,
	 input [31:0] regJr,
    input beq,
	 input bne,
	 input jal,
	 input B_judge,
	 input ifBlz,
	 input jr
    );
	
	wire [1:0]op;
	
	assign op = 	((beq&B_judge)||(bne&&B_judge))?2'd1: //PC+4+imm
						(jal)?2'd2: //pc||instrIndex||00
						(jr)?2'd3:
						2'b0;//PC+4
	//assign nextPC = 	(op==2'd0)?F_pc+32'd4:
		//					(op==2'd1)?D_pc+32'd4+(immExt<<2):
			//				(op==2'd2)?{D_pc[31:28],instrIndex,2'b0}:
				//			(op==2'd3)?regJr:
					//		F_pc+32'd4;
	reg [31:0]tmp;
	integer i;
	
 	always@(*)
	begin
		if(op==2'd1) nextPC=D_pc+32'd4+(immExt<<2);
		else if(op==2'd2) nextPC={D_pc[31:28],instrIndex,2'b0};
		else if(op==2'd3) nextPC=regJr;
		//else if(blztal&&ifBlz) begin
		//	tmp = {{immExt[29:0]},2'b0};
		//	for(i = 0;i<rtData[1:0];i= i+1) tmp={{tmp[30:0]},1'b0};
		//	nextPC = D_pc+tmp+32'd4;
		//end
		else nextPC =F_pc+32'd4;
	end
	
endmodule
