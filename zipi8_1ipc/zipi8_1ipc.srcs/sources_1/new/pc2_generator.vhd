----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/04/2019 07:07:33 PM
-- Design Name: 
-- Module Name: pc2_generator - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pc2_generator is
    Port (  clk : in STD_LOGIC;
            internal_reset : in STD_LOGIC;
            instruction2_17_downto_0  : in std_logic_vector(17 downto 0);
            shadow_bank : in STD_LOGIC;
            sx_addr4 : in STD_LOGIC;
            pc : in std_logic_vector(11 downto 0);
            sxB : in std_logic_vector(7 downto 0);
            syB : in std_logic_vector(7 downto 0);
            stack_memory : in std_logic_vector(11 downto 0);
            carry_flag : in STD_LOGIC;
            zero_flag : in STD_LOGIC;
            active_interrupt : in STD_LOGIC;
            sx_addrB : out std_logic_vector(4 downto 0);    
            sy_addrB : out std_logic_vector(4 downto 0); 
            pc2 : out std_logic_vector(11 downto 0) := B"0000_0000_0000"
            );
end pc2_generator;

architecture Behavioral of pc2_generator is

    component program_counter is
        Port ( 
             clk : in std_logic;
             register_vector : in std_logic_vector(11 downto 0);
             pc_vector : in std_logic_vector(11 downto 0);
             internal_reset_delayed : in std_logic;
             internal_reset : in std_logic;
             pc_mode : in std_logic_vector(2 downto 0);
             pc : out std_logic_vector(11 downto 0)
        );
    end component;    

    component x12_bit_program_address_generator is
        Port ( 
            instruction_12_downto_0 : in std_logic_vector(12 downto 0);
            sx : in std_logic_vector(3 downto 0);
            sy : in std_logic_vector(7 downto 0);
            stack_memory : in std_logic_vector(11 downto 0);
            register_vector : out std_logic_vector(11 downto 0);
            pc_vector : out std_logic_vector(11 downto 0)
        );
    end component;

    component decode4_pc_statck is
        Port (
             carry_flag : in std_logic;
             zero_flag : in std_logic;
             instruction_17_downto_12 : in std_logic_vector (17 downto 12);
             active_interrupt : in std_logic;
             pop_stack : out std_logic;
             push_stack : out std_logic;
             pc_mode : out std_logic_vector (2 downto 0)
         );
    end component;
    
    component register_bank_control is
        Port (
            clk : in std_logic; 
            instruction_17_downto_4  : in std_logic_vector(17 downto 4);
            instruction_0 : in std_logic;
            sx_addr4 : in std_logic;
            t_state_1 : in std_logic;
            internal_reset : in std_logic;
            shadow_bank : in std_logic;
            bank : out std_logic;
            sx_addr : out  std_logic_vector(4 downto 0);
            sy_addr : out  std_logic_vector(4 downto 0)
        );
    end component;    
    
    signal register_vector2 : std_logic_vector(11 downto 0);
    signal pc_vector2 : std_logic_vector(11 downto 0);
    signal pc_mode2 : std_logic_vector(2 downto 0);
    signal pc2_predicted : std_logic_vector(11 downto 0);
    signal bank : std_logic;

begin

--   program_counter_i: program_counter
--        port map (
--                                clk => clk,
--                    register_vector => register_vector2,
--                          pc_vector => pc_vector2,
--             internal_reset_delayed =< internal_reset_delayed,                          
--                     internal_reset => internal_reset,
--                            pc_mode => pc_mode2,
--                                 pc => pc2_predicted
--        );  

    x12_bit_program_address_generator_i: x12_bit_program_address_generator
        port map (
            instruction_12_downto_0 => instruction2_17_downto_0(12 downto 0),
                                 sx => sxB (3 downto 0),
                                 sy => syB,
                       stack_memory => stack_memory,
                    register_vector => register_vector2,
                          pc_vector => pc_vector2
        ); 
        
    decode4_pc_statck_i: decode4_pc_statck
        port map (
                      carry_flag => carry_flag,
                       zero_flag => zero_flag,
        instruction_17_downto_12 => instruction2_17_downto_0(17 downto 12),
                active_interrupt => active_interrupt,
                           pop_stack => open,
                      push_stack => open,
                         pc_mode => pc_mode2
        );  

    register_bank_control_i: register_bank_control 
        port map (
                            clk => clk,
        instruction_17_downto_4  => instruction2_17_downto_0(17 downto 4),
                   instruction_0 => instruction2_17_downto_0(0),
                        sx_addr4 => sx_addr4,
                       t_state_1 => '1',
                  internal_reset => internal_reset,
                     shadow_bank => shadow_bank,
                            bank => bank,
                         sx_addr => sx_addrB,
                         sy_addr => sy_addrB 
        );
        
    pc2_process: process (clk) begin
        --pc2 <= std_logic_vector (unsigned (pc2_predicted) + 1 ); 
         if rising_edge(clk) then
            if (internal_reset = '1') then 
                pc2 <= B"0000_0000_0001";    
            else
                pc2 <= pc2_predicted;    
            end if;    
        end if;       
    end process pc2_process;
    
   
   
end Behavioral;
