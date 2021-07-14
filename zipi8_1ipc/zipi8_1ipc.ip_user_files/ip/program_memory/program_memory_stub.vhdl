-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Tue May 26 21:40:54 2020
-- Host        : DESKTOP-GB8O8RC running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               D:/workspace/Vivado_2019.2/zipi8_1ipc/zipi8_1ipc.srcs/sources_1/ip/program_memory/program_memory_stub.vhdl
-- Design      : program_memory
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu7ev-ffvc1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity program_memory is
  Port ( 
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 11 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 17 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 17 downto 0 );
    clkb : in STD_LOGIC;
    enb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 11 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 17 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 17 downto 0 )
  );

end program_memory;

architecture stub of program_memory is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,ena,wea[0:0],addra[11:0],dina[17:0],douta[17:0],clkb,enb,web[0:0],addrb[11:0],dinb[17:0],doutb[17:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_4,Vivado 2019.2";
begin
end;
