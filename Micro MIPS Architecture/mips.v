`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:41:39 12/11/2022 
// Design Name: 
// Module Name:    mips 
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
module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
    );
	wire [31:0] m_tmp_data_addr;
	wire [31:0] m_tmp_data_rdata;
	wire [31:0] m_tmp_data_wdata;
	wire [3:0] m_tmp_data_byteen;
	
	//bridge

   wire [5:0] HWInt = {3'b0, interrupt, TC1_IRQ, TC0_IRQ};
	
	//timer
	wire [31:0] TC0_Addr;
	wire [31:0] TC0_Din;
	wire [31:0] TC0_Dout;
   wire TC0_WD;

   wire [31:0] TC1_Addr;
	wire [31:0] TC1_Din;
	wire [31:0] TC1_Dout;
   wire TC1_WD;
	
	
//cp0
	mips_CPU mips_cpu(
		.clk(clk),
		.reset(reset),
		
		.i_inst_addr(i_inst_addr),
      .i_inst_rdata(i_inst_rdata),
		
		.m_data_addr(m_tmp_data_addr),
      .m_data_wdata(m_tmp_data_wdata),
      .m_data_byteen(m_tmp_data_byteen),
      .m_inst_addr(m_inst_addr),
      .m_data_rdata(m_tmp_data_rdata),
		 
		.w_grf_we(w_grf_we),
      .w_grf_addr(w_grf_addr),
      .w_grf_wdata(w_grf_wdata),
      .w_inst_addr(w_inst_addr),
		
		.HWInt(HWInt),
      .macro_pc(macroscopic_pc)
	);
	
	bridge Bridge(
		.m_tmp_data_addr(m_tmp_data_addr),
      .m_tmp_data_wdata(m_tmp_data_wdata),
      .m_tmp_data_byteen(m_tmp_data_byteen),
      .m_data_addr(m_data_addr),
      .m_data_wdata(m_data_wdata),
      .m_data_byteen(m_data_byteen),
		 
      .m_data_rdata(m_data_rdata),
		.m_tmp_data_rdata(m_tmp_data_rdata),

      .TC0_Addr(TC0_Addr),
      .TC0_WE(TC0_WE),
      .TC0_Din(TC0_Din),
      .TC0_Dout(TC0_Dout),

      .TC1_Addr(TC1_Addr),
      .TC1_WE(TC1_WE),
      .TC1_Din(TC1_Din),
      .TC1_Dout(TC1_Dout),
		
		.m_int_addr(m_int_addr),
		.m_int_byteen(m_int_byteen)
    );
	TC tc0(
		.clk(clk),
      .reset(reset),
      .Addr(TC0_Addr[31:2]),
      .WE(TC0_WE),
      .Din(TC0_Din),
      .Dout(TC0_Dout),
      .IRQ(TC0_IRQ)
	);
	TC tc1(
		.clk(clk),
      .reset(reset),
      .Addr(TC1_Addr[31:2]),
      .WE(TC1_WE),
      .Din(TC1_Din),
      .Dout(TC1_Dout),
      .IRQ(TC1_IRQ)
	);
endmodule
