`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:52:42 12/11/2022 
// Design Name: 
// Module Name:    bridge 
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
module bridge(
	input [31:0]m_tmp_data_addr,
	input [31:0]m_tmp_data_wdata,
	input [3:0]m_tmp_data_byteen,
	output [31:0] m_data_addr,
	output [31:0] m_data_wdata,
   output [3:0] m_data_byteen,
	
	input [31:0] m_data_rdata,
	output [31:0] m_tmp_data_rdata,
	
	output [31:0] TC0_Addr,
   output TC0_WE,
   output [31:0] TC0_Din,
   input [31:0] TC0_Dout,

   output [31:0] TC1_Addr,
   output TC1_WE,
   output [31:0] TC1_Din,
   input [31:0] TC1_Dout,
	
	output [31:0] m_int_addr,     // 中断发生器待写入地址
	output [3 :0] m_int_byteen  // 中断发生器字节使能信号
    );
	wire WE=(|m_tmp_data_byteen);
	
   wire SelTC0 = (m_tmp_data_addr>=32'h0000_7f00)&(m_tmp_data_addr<=32'h0000_7f0b);
   wire SelTC1 = (m_tmp_data_addr>=32'h0000_7f10)&(m_tmp_data_addr<=32'h0000_7f1b);

   assign TC0_WE=WE&SelTC0;
   assign TC1_WE=WE&SelTC1;
   
   assign m_tmp_data_rdata = (SelTC0)?TC0_Dout:
                             (SelTC1)?TC1_Dout:
                             m_data_rdata;
	assign m_data_byteen = (SelTC0|SelTC1)?4'd0:m_tmp_data_byteen;
   
	assign m_data_wdata = m_tmp_data_wdata;
	assign TC0_Din = m_tmp_data_wdata;
   assign TC1_Din = m_tmp_data_wdata;

	assign m_data_addr = m_tmp_data_addr;
   assign TC0_Addr = m_tmp_data_addr;
   assign TC1_Addr = m_tmp_data_addr;
	
	assign m_int_addr = (m_tmp_data_addr==32'h0000_7F20)? m_tmp_data_addr:32'd0;
	assign m_int_byteen = (m_tmp_data_addr==32'h0000_7F20)? m_tmp_data_byteen:4'd0;

endmodule
