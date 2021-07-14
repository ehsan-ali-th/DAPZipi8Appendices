// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue May 26 21:40:54 2020
// Host        : DESKTOP-GB8O8RC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/workspace/Vivado_2019.2/zipi8_1ipc/zipi8_1ipc.srcs/sources_1/ip/program_memory/program_memory_stub.v
// Design      : program_memory
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu7ev-ffvc1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module program_memory(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, 
  dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[11:0],dina[17:0],douta[17:0],clkb,enb,web[0:0],addrb[11:0],dinb[17:0],doutb[17:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [11:0]addra;
  input [17:0]dina;
  output [17:0]douta;
  input clkb;
  input enb;
  input [0:0]web;
  input [11:0]addrb;
  input [17:0]dinb;
  output [17:0]doutb;
endmodule
