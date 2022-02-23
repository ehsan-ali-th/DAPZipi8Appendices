----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/24/2019 12:07:08 AM
-- Design Name: 
-- Module Name: top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
     port (                        
        GPIO_PB_SW0 : in std_logic;
          CLK_300_N : in std_logic;
          CLK_300_P : in std_logic;
      GPIO_LED_0_LS_ZIPI8 : out std_logic;
      GPIO_LED_0_LS_KCPSM6 : out std_logic
     );
end top;

architecture Behavioral of top is
  
     
    -- Components
    component clk_wiz_0
        port
         (-- Clock in ports
          -- Clock out ports
          clk_out1          : out    std_logic;
          -- Status and control signals
          reset             : in     std_logic;
          locked            : out    std_logic;
          clk_in1_p         : in     std_logic;
          clk_in1_n         : in     std_logic
         );
    end component;
    
--    COMPONENT proc_sys_reset_0
--      PORT (
--        slowest_sync_clk : IN STD_LOGIC;
--        ext_reset_in : IN STD_LOGIC;
--        aux_reset_in : IN STD_LOGIC;
--        mb_debug_sys_rst : IN STD_LOGIC;
--        dcm_locked : IN STD_LOGIC;
--        mb_reset : OUT STD_LOGIC;
--        bus_struct_reset : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
--        peripheral_reset : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
--        interconnect_aresetn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
--        peripheral_aresetn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
--      );
--    END COMPONENT;

  COMPONENT program_memory
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
      );
    END COMPONENT;   

    COMPONENT zipi8 PORT (
                           address : out std_logic_vector(11 downto 0);
                          address2 : out std_logic_vector(11 downto 0);
                       bram_enable : out std_logic;
                          out_port : out std_logic_vector(7 downto 0);
                           port_id : out std_logic_vector(7 downto 0);
                      write_strobe : out std_logic;
                    k_write_strobe : out std_logic;
                       read_strobe : out std_logic;
                     interrupt_ack : out std_logic;
                     
                       instruction : in std_logic_vector(17 downto 0);
                      instruction2 : in std_logic_vector(17 downto 0);
                           in_port : in std_logic_vector(7 downto 0);
                         interrupt : in std_logic;
                             sleep : in std_logic;
                             reset : in std_logic;
                               clk : in std_logic
    );
    END COMPONENT;
    
    -- signals
    signal             clk : std_logic;
    signal           reset : std_logic;
    signal        mb_reset : std_logic;
    signal          locked : std_logic;
    signal         port_id : std_logic_vector(7 downto 0);
    signal    write_strobe : std_logic;
    signal  k_write_strobe : std_logic;
    signal        out_port : std_logic_vector(7 downto 0);
    signal     read_strobe : std_logic;
    signal         in_port : std_logic_vector(7 downto 0)  := X"00";
    signal   interrupt_ack : std_logic;
    signal         address : std_logic_vector(11 downto 0) := B"0000_0000_0000" ;
    signal     instruction : std_logic_vector(17 downto 0);
    signal     bram_enable : std_logic;
    signal             rdl : std_logic;
        
    signal             instruction2 : std_logic_vector(17 downto 0);
    signal                 address2 : std_logic_vector(11 downto 0) := B"0000_0000_0000" ;
    
begin

    clock_gen : clk_wiz_0 port map ( 
      -- Clock out ports  
       clk_out1 => clk,
      -- Status and control signals                
       reset => reset,
       locked => locked,
       -- Clock in ports
       clk_in1_p => CLK_300_P,
       clk_in1_n => CLK_300_N
    );
    
    reset <= GPIO_PB_SW0;

--    processor_reset : proc_sys_reset_0
--      PORT MAP (
--        slowest_sync_clk => clk,
--        ext_reset_in => reset,
--        aux_reset_in => '0',
--        mb_debug_sys_rst => '0',
--        dcm_locked => locked,
--        mb_reset => mb_reset,
--        bus_struct_reset => open,
--        peripheral_reset => open,
--        interconnect_aresetn =>open,
--        peripheral_aresetn => open
--      );
      
 
      test_program : program_memory PORT MAP (
        clka => clk,
        ena => bram_enable,
        wea => "0",
        addra => address,
        dina => B"00_0000_0000_0000_0000",
        douta => instruction,
        clkb => clk,
        enb =>  bram_enable,
        web => "0",
        addrb => address2,
        dinb => B"00_0000_0000_0000_0000", 
        doutb => instruction2
      );


    processor_zipi8 : zipi8 PORT MAP (
            address => address, 
           address2 => address2, 
        instruction => instruction,
       instruction2 => instruction2,
        bram_enable => bram_enable,
            in_port => in_port,
           out_port => out_port,
            port_id => port_id,
       write_strobe => write_strobe,
     k_write_strobe => k_write_strobe,
        read_strobe => read_strobe,
          interrupt => '0',
      interrupt_ack => interrupt_ack,
             sleep  => '0',
             reset  => reset,
               clk  => clk
    );
    
    
    
    GPIO_LED_0_LS_ZIPI8 <= out_port(0);
    GPIO_LED_0_LS_KCPSM6 <= out_port(0);
    


end Behavioral;
