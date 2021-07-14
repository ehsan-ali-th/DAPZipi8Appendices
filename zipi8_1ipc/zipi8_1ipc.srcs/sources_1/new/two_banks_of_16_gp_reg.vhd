----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2019 11:16:37 PM
-- Design Name: 
-- Module Name: two_banks_of_16_gp_reg - Behavioral
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

entity two_banks_of_16_gp_reg is
    Port ( 
        clk : in std_logic;
        alu_result: in std_logic_vector(7 downto 0);    
        sx_addrA: in std_logic_vector(4 downto 0);    
        sy_addrA: in std_logic_vector(4 downto 0);   
        sx_addrB: in std_logic_vector(4 downto 0);    
        sy_addrB: in std_logic_vector(4 downto 0);   
        register_enable : in std_logic; 
        sxA: out std_logic_vector(7 downto 0) := B"0000_0000";
        syA: out std_logic_vector(7 downto 0) := B"0000_0000";
        sxB: out std_logic_vector(7 downto 0) := B"0000_0000";
        syB: out std_logic_vector(7 downto 0) := B"0000_0000"
    );
end two_banks_of_16_gp_reg;

architecture Behavioral of two_banks_of_16_gp_reg is
     component ram is        
        generic (
            DATA_WIDTH : positive;
            ADDRESS_WIDTH : positive);
        port ( 
            WCLK : in std_logic;
            WE : in std_logic;
            DI: in std_logic_vector (DATA_WIDTH-1 downto 0);
            ADDRA: in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
            DOA: out std_logic_vector (DATA_WIDTH-1 downto 0);
            ADDRB: in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
            DOB: out std_logic_vector (DATA_WIDTH-1 downto 0) 
        );
    end component;
    
    component ram32m_behav is
    generic (DATA_WIDTH : positive;
           ADDRESS_WIDTH : positive);
    port ( 
            WCLK : in std_logic;
            WE : in std_logic;
            DI: in std_logic_vector (DATA_WIDTH-1 downto 0);
            ADDR_RDA: in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
            ADDR_WR: in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
            DOA: out std_logic_vector (DATA_WIDTH-1 downto 0); 
            ADDR_RDB: in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
            DOB: out std_logic_vector (DATA_WIDTH-1 downto 0)
    );
    end component;
    
    --**********************************************************************************
    --
    -- Signals between these *** lines are only made visible during simulation 
    --
    --synthesis translate off
    --
    signal        sim_bank_a_s0 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_s1 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_s2 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_s3 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_s4 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_s5 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_s6 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_s7 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_s8 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_s9 : std_logic_vector(7 downto 0);
    signal        sim_bank_a_sA : std_logic_vector(7 downto 0);
    signal        sim_bank_a_sB : std_logic_vector(7 downto 0);
    signal        sim_bank_a_sC : std_logic_vector(7 downto 0);
    signal        sim_bank_a_sD : std_logic_vector(7 downto 0);
    signal        sim_bank_a_sE : std_logic_vector(7 downto 0);
    signal        sim_bank_a_sF : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s0 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s1 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s2 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s3 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s4 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s5 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s6 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s7 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s8 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_s9 : std_logic_vector(7 downto 0);
    signal        sim_bank_b_sA : std_logic_vector(7 downto 0);
    signal        sim_bank_b_sB : std_logic_vector(7 downto 0);
    signal        sim_bank_b_sC : std_logic_vector(7 downto 0);
    signal        sim_bank_b_sD : std_logic_vector(7 downto 0);
    signal        sim_bank_b_sE : std_logic_vector(7 downto 0);
    signal        sim_bank_b_sF : std_logic_vector(7 downto 0);
    --
    --synthesis translate on
    --
    
begin

    sx_bank: ram 
        generic map (
            DATA_WIDTH => 8,        -- 16x8-bit RAM
            ADDRESS_WIDTH => 5    
        )
        port map (
            WCLK => clk,
            WE => '1',
            DI => alu_result,
            ADDRA => sx_addrA,
            DOA => sxA,   
            ADDRB => sx_addrB,
            DOB => sxB   
        );

    sy_bank: ram32m_behav 
        generic map (
            DATA_WIDTH => 8,        -- 16x8-bit RAM
            ADDRESS_WIDTH => 5    
        )
        port map (
            WCLK => clk,
            WE => '1',
            DI => alu_result,
            ADDR_RDA => sy_addrA,
            ADDR_WR => sx_addrA,
            DOA => syA,
            ADDR_RDB => sy_addrB,
            DOB => syB   
        );
        
        
        --All of this section is ignored during synthesis.
    --synthesis translate off
    simulation: process (clk)
        variable bank_a_s0 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_s1 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_s2 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_s3 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_s4 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_s5 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_s6 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_s7 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_s8 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_s9 : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_sa : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_sb : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_sc : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_sd : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_se : std_logic_vector(7 downto 0) := X"00";
        variable bank_a_sf : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s0 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s1 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s2 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s3 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s4 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s5 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s6 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s7 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s8 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_s9 : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_sa : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_sb : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_sc : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_sd : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_se : std_logic_vector(7 downto 0) := X"00";
        variable bank_b_sf : std_logic_vector(7 downto 0) := X"00"; 
        
        begin
        
        -- Simulation of register contents
        if clk'event and clk = '1' then 
                case sx_addrA is
                    when "00000" => bank_a_s0 := alu_result;
                    when "00001" => bank_a_s1 := alu_result;
                    when "00010" => bank_a_s2 := alu_result;
                    when "00011" => bank_a_s3 := alu_result;
                    when "00100" => bank_a_s4 := alu_result;
                    when "00101" => bank_a_s5 := alu_result;
                    when "00110" => bank_a_s6 := alu_result;
                    when "00111" => bank_a_s7 := alu_result;
                    when "01000" => bank_a_s8 := alu_result;
                    when "01001" => bank_a_s9 := alu_result;
                    when "01010" => bank_a_sa := alu_result;
                    when "01011" => bank_a_sb := alu_result;
                    when "01100" => bank_a_sc := alu_result;
                    when "01101" => bank_a_sd := alu_result;
                    when "01110" => bank_a_se := alu_result;
                    when "01111" => bank_a_sf := alu_result;
                    when "10000" => bank_b_s0 := alu_result;
                    when "10001" => bank_b_s1 := alu_result;
                    when "10010" => bank_b_s2 := alu_result;
                    when "10011" => bank_b_s3 := alu_result;
                    when "10100" => bank_b_s4 := alu_result;
                    when "10101" => bank_b_s5 := alu_result;
                    when "10110" => bank_b_s6 := alu_result;
                    when "10111" => bank_b_s7 := alu_result;
                    when "11000" => bank_b_s8 := alu_result;
                    when "11001" => bank_b_s9 := alu_result;
                    when "11010" => bank_b_sa := alu_result;
                    when "11011" => bank_b_sb := alu_result;
                    when "11100" => bank_b_sc := alu_result;
                    when "11101" => bank_b_sd := alu_result;
                    when "11110" => bank_b_se := alu_result;
                    when "11111" => bank_b_sf := alu_result;
                    when others => null;
                end case;
        end if;
        --
       
        sim_bank_a_s0 <= bank_a_s0;
        sim_bank_a_s1 <= bank_a_s1;
        sim_bank_a_s2 <= bank_a_s2;
        sim_bank_a_s3 <= bank_a_s3;
        sim_bank_a_s4 <= bank_a_s4;
        sim_bank_a_s5 <= bank_a_s5;
        sim_bank_a_s6 <= bank_a_s6;
        sim_bank_a_s7 <= bank_a_s7;
        sim_bank_a_s8 <= bank_a_s8;
        sim_bank_a_s9 <= bank_a_s9;
        sim_bank_a_sA <= bank_a_sA;
        sim_bank_a_sB <= bank_a_sB;
        sim_bank_a_sC <= bank_a_sC;
        sim_bank_a_sD <= bank_a_sD;
        sim_bank_a_sE <= bank_a_sE;
        sim_bank_a_sF <= bank_a_sF;
        
        sim_bank_b_s0 <= bank_b_s0;
        sim_bank_b_s1 <= bank_b_s1;
        sim_bank_b_s2 <= bank_b_s2;
        sim_bank_b_s3 <= bank_b_s3;
        sim_bank_b_s4 <= bank_b_s4;
        sim_bank_b_s5 <= bank_b_s5;
        sim_bank_b_s6 <= bank_b_s6;
        sim_bank_b_s7 <= bank_b_s7;
        sim_bank_b_s8 <= bank_b_s8;
        sim_bank_b_s9 <= bank_b_s9;
        sim_bank_b_sA <= bank_b_sA;
        sim_bank_b_sB <= bank_b_sB;
        sim_bank_b_sC <= bank_b_sC;
        sim_bank_b_sD <= bank_b_sD;
        sim_bank_b_sE <= bank_b_sE;
        sim_bank_b_sF <= bank_b_sF;
        
        end process simulation;
    --synthesis translate on
        

       
end Behavioral;
