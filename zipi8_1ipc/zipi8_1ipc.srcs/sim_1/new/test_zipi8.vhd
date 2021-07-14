----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/24/2019 12:31:34 AM
-- Design Name: 
-- Module Name: test_zipi8 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use STD.textio.all;
use ieee.std_logic_textio.all;

use std.env.stop;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_zipi8 is
--  Port ( );
end test_zipi8;

    architecture Behavioral of test_zipi8 is

    component top is
        port (                        
              GPIO_PB_SW0 : in std_logic;
              CLK_300_N : in std_logic;
              CLK_300_P : in std_logic;
              GPIO_LED_0_LS_ZIPI8 : out std_logic;
              GPIO_LED_0_LS_KCPSM6 : out std_logic
        );
    end component;

    constant half_period100 : time := 5 ns; -- produce 100Mhz clock  


    signal clk100Mhz_p: std_logic := '0';
    signal clk100Mhz_n: std_logic := '1';
    signal reset: std_logic := '0';
    
    signal led_zipi8: std_logic;
    signal led_kcpsm6: std_logic;
 
    alias uut_clk is << signal uut.clk : std_logic >>;
    
begin
    clk100Mhz_p <= not clk100Mhz_p after half_period100;
    clk100Mhz_n <= not clk100Mhz_n after half_period100;
    
    

    uut: top port map (
        GPIO_PB_SW0 => reset,
        CLK_300_N => clk100Mhz_n,
        CLK_300_P => clk100Mhz_p,
        GPIO_LED_0_LS_ZIPI8 => led_zipi8,
        GPIO_LED_0_LS_KCPSM6 => led_kcpsm6
    );
    
    tb: process begin
        report "Test Started!" severity note;
        reset <= '1';
        wait for 200ns;
        reset <= '0';       -- running period for zipi8
        wait for 1000000ns;
        report "Simulation Finished." severity note;
        stop;
    end process;
    
   
  
    
end Behavioral;
