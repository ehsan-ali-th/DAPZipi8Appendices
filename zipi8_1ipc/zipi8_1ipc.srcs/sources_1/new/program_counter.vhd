----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2019 11:15:52 PM
-- Design Name: 
-- Module Name: program_counter - Behavioral
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

entity program_counter is
    Port ( 
        clk : in std_logic;
        register_vector : in std_logic_vector(11 downto 0);
        pc_vector : in std_logic_vector(11 downto 0);
        internal_reset : in std_logic;
        pc_mode : in std_logic_vector(2 downto 0);
        pc : out std_logic_vector(11 downto 0) := B"0000_0000_0000";
        -- added for pc2
        internal_reset_delayed : in std_logic;
        instruction2_17_downto_0  : in std_logic_vector(17 downto 0);
        pc2 : out std_logic_vector(11 downto 0) := B"0000_0000_0000";
        push_stack2 : out STD_LOGIC;
        pop_stack2 : out STD_LOGIC;
        sxB : in std_logic_vector(7 downto 0);
        syB : in std_logic_vector(7 downto 0);
        stack_memory : in std_logic_vector(11 downto 0);
        carry_flag_value : in STD_LOGIC;
        zero_flag_value : in STD_LOGIC;
        active_interrupt : in STD_LOGIC;
        sx_addrB : out std_logic_vector(4 downto 0);    
        sy_addrB : out std_logic_vector(4 downto 0);
        sx_addr4 : in STD_LOGIC;
        shadow_bank : in STD_LOGIC
    );
end program_counter;

architecture Behavioral of program_counter is

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

    signal pc_value :  std_logic_vector(11 downto 0);
   
    signal half_pc :  std_logic_vector(11 downto 0);
    signal carry_pc :  std_logic_vector(10 downto 0);

    signal pc2_value :  std_logic_vector(11 downto 0);
    signal half_pc2 :  std_logic_vector(11 downto 0);
    signal carry_pc2 :  std_logic_vector(10 downto 0);
    signal register_vector2 : std_logic_vector(11 downto 0);
    signal pc2_vector : std_logic_vector(11 downto 0);
    signal pc2_mode : std_logic_vector(2 downto 0);
    signal pc2_predicted : std_logic_vector(11 downto 0);
    signal bank : std_logic;
    signal pc2_value_valid : std_logic;
    signal guessed_value_is_used : std_logic;
   
    
begin

    pc2_process: process (clk) begin
        if rising_edge(clk) then
            if (internal_reset_delayed = '1') then 
                pc2 <= B"0000_0000_0000"; 
               
            else
                if (pc2_mode = B"001") then
                    pc2 <= pc2_value; 
                else
                    pc2 <= std_logic_vector (to_unsigned (to_integer (unsigned (pc2_value)) + 1, pc2_value'length));
                end if; 

             
             end if;
        end if;
     end process pc2_process; 
     
     -- Remove the t_state(1) signal so pc can be updated every clk cycle.
      flipflops_R_CE_process: process (clk) begin
        if rising_edge(clk) then
            if (internal_reset = '1') then 
                pc <= B"0000_0000_0000";     
                guessed_value_is_used <= '0';      
            else
                if (guessed_value_is_used = '1') then 
                    pc <= std_logic_vector (to_unsigned (to_integer (unsigned (pc)) + 1, pc'length));
                    guessed_value_is_used <= '0';
                else   
                    if (pc2_mode = B"001") then         -- Normal mode
                        pc <= pc_value;  
                        guessed_value_is_used <= '0';
                    elsif (pc2_mode = B"011") then      -- for RETURN
                        pc <= pc2_value;  
                        guessed_value_is_used <= '1';
                    elsif (pc2_mode = B"110") then      -- for CALL @(sX, sY)
                        pc <= pc2_value;  
                        guessed_value_is_used <= '1';
                    else
                        pc <= pc2_value;        -- pc = guessed value (gv)     
                        guessed_value_is_used <= '1';
                    end if; 
                end if;    
            end if;    
        end if;
     end process flipflops_R_CE_process; 
     
    
      
 

    -- note: half_pc depends on generic interrupt_vector. For now we set it to constant 0x3FF

    -- calculate half_pc(0)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(0)               = F
    -- pc_vector(0)                     = E
    -- pc(0)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc0_process: process (pc_mode(2 downto 0), pc(0), pc_vector(0), register_vector(0)) begin
        half_pc(0) <=  
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(0)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and not pc(0)) or
                (not pc_mode(2) and pc_mode(1) and not pc_mode(0) and pc_vector(0)) or
                (not pc_mode(2) and pc_mode(1) and pc_mode(0) and not pc_vector(0));             
    end process calc_half_pc0_process;     

    -- calculate half_pc(1)
    -- LUT INIT = 0x00AA00FFCCCCF000
    -- y = A'BE + AB'C' + AC'F + A'B'CD
    -- register_vector(1)               = F
    -- pc_vector(1)                     = E
    -- pc(1)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc1_process: process (pc_mode(2 downto 0), pc(1), pc_vector(1), register_vector(1)) begin
        half_pc(1) <=  
                (not pc_mode(2) and pc_mode(1) and pc_vector(1)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(1)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(1));            
    end process calc_half_pc1_process;     

    -- calculate half_pc(2)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(2)               = F
    -- pc_vector(2)                     = E
    -- pc(2)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc2_process: process (pc_mode(2 downto 0), pc(2), pc_vector(2), register_vector(2)) begin
        half_pc(2) <=  
               (not pc_mode(2) and pc_mode(1) and pc_vector(2)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(2)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(2));         
    end process calc_half_pc2_process;     

   -- calculate half_pc(3)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(3)               = F
    -- pc_vector(3)                     = E
    -- pc(3)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc3_process: process (pc_mode(2 downto 0), pc(3), pc_vector(3), register_vector(3)) begin
        half_pc(3) <=  
               (not pc_mode(2) and pc_mode(1) and pc_vector(3)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(3)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(3));             
    end process calc_half_pc3_process;     

   -- calculate half_pc(4)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(4)               = F
    -- pc_vector(4)                     = E
    -- pc(4)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc4_process: process (pc_mode(2 downto 0), pc(4), pc_vector(4), register_vector(4)) begin
        half_pc(4) <=  
                (not pc_mode(2) and pc_mode(1) and pc_vector(4)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(4)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(4));             
    end process calc_half_pc4_process;     

    -- calculate half_pc(*)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(5)               = F
    -- pc_vector(5)                     = E
    -- pc(5)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc5_process: process (pc_mode(2 downto 0), pc(5), pc_vector(5), register_vector(5)) begin
        half_pc(5) <=  
              (not pc_mode(2) and pc_mode(1) and pc_vector(5)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(5)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(5));             
    end process calc_half_pc5_process;         
    
    -- calculate half_pc(6)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(6)               = F
    -- pc_vector(6)                     = E
    -- pc(6)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc6_process: process (pc_mode(2 downto 0), pc(6), pc_vector(6), register_vector(6)) begin
        half_pc(6) <=  
               (not pc_mode(2) and pc_mode(1) and pc_vector(6)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(6)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(6));            
    end process calc_half_pc6_process;
    
    
    -- calculate half_pc(7)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(7)               = F
    -- pc_vector(7)                     = E
    -- pc(7)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc7_process: process (pc_mode(2 downto 0), pc(7), pc_vector(7), register_vector(7)) begin
        half_pc(7) <=  
                (not pc_mode(2) and pc_mode(1) and pc_vector(7)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(7)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(7));           
    end process calc_half_pc7_process;     

    -- calculate half_pc(8)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(8)               = F
    -- pc_vector(8)                     = E
    -- pc(8)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc8_process: process (pc_mode(2 downto 0), pc(8), pc_vector(8), register_vector(8)) begin
        half_pc(8) <=  
                (not pc_mode(2) and pc_mode(1) and pc_vector(8)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(8)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(8));               
    end process calc_half_pc8_process;    
            
    -- calculate half_pc(9)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(9)               = F
    -- pc_vector(9)                     = E
    -- pc(9)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc9_process: process (pc_mode(2 downto 0), pc(9), pc_vector(9), register_vector(9)) begin
        half_pc(9) <=  
                (not pc_mode(2) and pc_mode(1) and pc_vector(9)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(9)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(9));              
    end process calc_half_pc9_process;
    
    -- calculate half_pc(10)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(10)               = F
    -- pc_vector(10)                     = E
    -- pc(10)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc10_process: process (pc_mode(2 downto 0), pc(10), pc_vector(10), register_vector(10)) begin
        half_pc(10) <=  
                (not pc_mode(2) and pc_mode(1) and pc_vector(10)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(10)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(10));               
    end process calc_half_pc10_process;
    
    -- calculate half_pc(11)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector(11)               = F
    -- pc_vector(11)                     = E
    -- pc(11)                            = D
    -- pc_mode(0)	                    = C
    -- pc_mode(1)	                    = B
    -- pc_mode(2)	                    = A
    calc_half_pc11_process: process (pc_mode(2 downto 0), pc(11), pc_vector(11), register_vector(11)) begin
        half_pc(11) <=  
                (not pc_mode(2) and pc_mode(1) and pc_vector(11)) or
                (pc_mode(2) and not pc_mode(1) and not pc_mode(0)) or
                (pc_mode(2) and not pc_mode(0) and register_vector(11)) or
                (not pc_mode(2) and not pc_mode(1) and pc_mode(0) and pc(11));             
    end process calc_half_pc11_process;
    
    pc_value(0) <= half_pc(0) xor '0';
    pc_value(1) <= half_pc(1) xor carry_pc(0);
    pc_value(2) <= half_pc(2) xor carry_pc(1);
    pc_value(3) <= half_pc(3) xor carry_pc(2);
    pc_value(4) <= half_pc(4) xor carry_pc(3);
    pc_value(5) <= half_pc(5) xor carry_pc(4);
    pc_value(6) <= half_pc(6) xor carry_pc(5);
    pc_value(7) <= half_pc(7) xor carry_pc(6);
    pc_value(8) <= half_pc(8) xor carry_pc(7);
    pc_value(9) <= half_pc(9) xor carry_pc(8);
    pc_value(10) <= half_pc(10) xor carry_pc(9);
    pc_value(11) <= half_pc(11) xor carry_pc(10);

   
    
    -- pc_muxcy0
    -- calculate carry_pc(0)
    calc_carry_pc0_process: process (pc_mode(0), half_pc(0)) begin
        case half_pc(0) is
           when '0' =>
             carry_pc(0) <= pc_mode(0);
           when '1' =>
             carry_pc(0) <= '0';	
           when others =>
             carry_pc(0) <= 'X';
        end case; 
    end process calc_carry_pc0_process;
    
    -- pc_muxcy1
    -- calculate carry_pc(1)
    calc_carry_pc1_process: process (carry_pc(0), half_pc(1)) begin
        case half_pc(1) is
           when '0' =>
             carry_pc(1) <= '0';
           when '1' =>
             carry_pc(1) <= carry_pc(0);	
           when others =>
             carry_pc(1) <= 'X';
        end case; 
    end process calc_carry_pc1_process;
    
    -- pc_muxcy2
    -- calculate carry_pc(2)
    calc_carry_pc2_process: process (carry_pc(1), half_pc(2)) begin
        case half_pc(2) is
           when '0' =>
             carry_pc(2) <= '0';
           when '1' =>
             carry_pc(2) <= carry_pc(1);	
           when others =>
             carry_pc(2) <= 'X';
        end case; 
    end process calc_carry_pc2_process;
    
    -- pc_muxcy3
    -- calculate carry_pc(3)
    calc_carry_pc3_process: process (carry_pc(2), half_pc(3)) begin
        case half_pc(3) is
           when '0' =>
             carry_pc(3) <= '0';
           when '1' =>
             carry_pc(3) <= carry_pc(2);	
           when others =>
             carry_pc(3) <= 'X';
        end case; 
    end process calc_carry_pc3_process;
    
    -- pc_muxcy4
    -- calculate carry_pc(4)
    calc_carry_pc4_process: process (carry_pc(3), half_pc(4)) begin
        case half_pc(4) is
           when '0' =>
             carry_pc(4) <= '0';
           when '1' =>
             carry_pc(4) <= carry_pc(3);	
           when others =>
             carry_pc(4) <= 'X';
        end case; 
    end process calc_carry_pc4_process;
    
    -- pc_muxcy5
    -- calculate carry_pc(5)
    calc_carry_pc5_process: process (carry_pc(4), half_pc(5)) begin
        case half_pc(5) is
           when '0' =>
             carry_pc(5) <= '0';
           when '1' =>
             carry_pc(5) <= carry_pc(4);	
           when others =>
             carry_pc(5) <= 'X';
        end case; 
    end process calc_carry_pc5_process;
    
    -- pc_muxcy6
    -- calculate carry_pc(6)
    calc_carry_pc6_process: process (carry_pc(5), half_pc(6)) begin
        case half_pc(6) is
           when '0' =>
             carry_pc(6) <= '0';
           when '1' =>
             carry_pc(6) <= carry_pc(5);	
           when others =>
             carry_pc(6) <= 'X';
        end case; 
    end process calc_carry_pc6_process;
    
    -- pc_muxcy7
    -- calculate carry_pc(7)
    calc_carry_pc7_process: process (carry_pc(6), half_pc(7)) begin
        case half_pc(7) is
           when '0' =>
             carry_pc(7) <= '0';
           when '1' =>
             carry_pc(7) <= carry_pc(6);	
           when others =>
             carry_pc(7) <= 'X';
        end case; 
    end process calc_carry_pc7_process;
    
    -- pc_muxcy8
    -- calculate carry_pc(8)
    calc_carry_pc8_process: process (carry_pc(7), half_pc(8)) begin
        case half_pc(8) is
           when '0' =>
             carry_pc(8) <= '0';
           when '1' =>
             carry_pc(8) <= carry_pc(7);	
           when others =>
             carry_pc(8) <= 'X';
        end case; 
    end process calc_carry_pc8_process;
    
    -- pc_muxcy9
    -- calculate carry_pc(9)
    calc_carry_pc9_process: process (carry_pc(8), half_pc(9)) begin
        case half_pc(9) is
           when '0' =>
             carry_pc(9) <= '0';
           when '1' =>
             carry_pc(9) <= carry_pc(8);	
           when others =>
             carry_pc(9) <= 'X';
        end case; 
    end process calc_carry_pc9_process;
    
    -- pc_muxcy10
    -- calculate carry_pc(10)
    calc_carry_pc10_process: process (carry_pc(9), half_pc(10)) begin
        case half_pc(10) is
           when '0' =>
             carry_pc(10) <= '0';
           when '1' =>
             carry_pc(10) <= carry_pc(9);	
           when others =>
             carry_pc(10) <= 'X';
        end case; 
    end process calc_carry_pc10_process;
    
    
    
    -- pc prediction part
    pc2_value(0) <= half_pc2(0) xor '0';
    pc2_value(1) <= half_pc2(1) xor carry_pc2(0);
    pc2_value(2) <= half_pc2(2) xor carry_pc2(1);
    pc2_value(3) <= half_pc2(3) xor carry_pc2(2);
    pc2_value(4) <= half_pc2(4) xor carry_pc2(3);
    pc2_value(5) <= half_pc2(5) xor carry_pc2(4);
    pc2_value(6) <= half_pc2(6) xor carry_pc2(5);
    pc2_value(7) <= half_pc2(7) xor carry_pc2(6);
    pc2_value(8) <= half_pc2(8) xor carry_pc2(7);
    pc2_value(9) <= half_pc2(9) xor carry_pc2(8);
    pc2_value(10) <= half_pc2(10) xor carry_pc2(9);
    pc2_value(11) <= half_pc2(11) xor carry_pc2(10);
    
    -- calculate half_pc2(0)    
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(0)               = F
    -- pc2_vector(0)                     = E
    -- pc2(0)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_0_process: process (pc2_mode(2 downto 0), pc2(0), pc2_vector(0), register_vector2(0)) begin
        half_pc2(0) <=  
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(0)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and not pc2(0)) or
                (not pc2_mode(2) and pc2_mode(1) and not pc2_mode(0) and pc2_vector(0)) or
                (not pc2_mode(2) and pc2_mode(1) and pc2_mode(0) and not pc2_vector(0));             
    end process calc_half_pc2_0_process;     

    -- calculate half_pc2(1)
    -- LUT INIT = 0x00AA00FFCCCCF000
    -- y = A'BE + AB'C' + AC'F + A'B'CD
    -- register_vector2(1)               = F
    -- pc2_vector(1)                     = E
    -- pc2(1)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_1_process: process (pc2_mode(2 downto 0), pc2(1), pc2_vector(1), register_vector2(1)) begin
        half_pc2(1) <=  
                (not pc2_mode(2) and pc2_mode(1) and pc2_vector(1)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(1)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(1));            
    end process calc_half_pc2_1_process;     

    -- calculate half_pc2(2)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(2)               = F
    -- pc2_vector(2)                     = E
    -- pc2(2)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_2_process: process (pc2_mode(2 downto 0), pc2(2), pc2_vector(2), register_vector2(2)) begin
        half_pc2(2) <=  
               (not pc2_mode(2) and pc2_mode(1) and pc2_vector(2)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(2)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(2));         
    end process calc_half_pc2_2_process;     

   -- calculate half_pc2(3)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(3)               = F
    -- pc2_vector(3)                     = E
    -- pc2(3)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_3_process: process (pc2_mode(2 downto 0), pc2(3), pc2_vector(3), register_vector2(3)) begin
        half_pc2(3) <=  
               (not pc2_mode(2) and pc2_mode(1) and pc2_vector(3)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(3)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(3));             
    end process calc_half_pc2_3_process;     

   -- calculate half_pc2(4)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(4)               = F
    -- pc2_vector(4)                     = E
    -- pc2(4)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_4_process: process (pc2_mode(2 downto 0), pc2(4), pc2_vector(4), register_vector2(4)) begin
        half_pc2(4) <=  
                (not pc2_mode(2) and pc2_mode(1) and pc2_vector(4)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(4)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(4));             
    end process calc_half_pc2_4_process;     

    -- calculate half_pc2(*)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(5)               = F
    -- pc2_vector(5)                     = E
    -- pc2(5)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_5_process: process (pc2_mode(2 downto 0), pc2(5), pc2_vector(5), register_vector2(5)) begin
        half_pc2(5) <=  
              (not pc2_mode(2) and pc2_mode(1) and pc2_vector(5)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(5)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(5));             
    end process calc_half_pc2_5_process;         
    
    -- calculate half_pc2(6)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(6)               = F
    -- pc2_vector(6)                     = E
    -- pc2(6)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_6_process: process (pc2_mode(2 downto 0), pc2(6), pc2_vector(6), register_vector2(6)) begin
        half_pc2(6) <=  
               (not pc2_mode(2) and pc2_mode(1) and pc2_vector(6)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(6)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(6));            
    end process calc_half_pc2_6_process;
    
    
    -- calculate half_pc2(7)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(7)               = F
    -- pc2_vector(7)                     = E
    -- pc2(7)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_7_process: process (pc2_mode(2 downto 0), pc2(7), pc2_vector(7), register_vector2(7)) begin
        half_pc2(7) <=  
                (not pc2_mode(2) and pc2_mode(1) and pc2_vector(7)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(7)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(7));           
    end process calc_half_pc2_7_process;     

    -- calculate half_pc2(8)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(8)               = F
    -- pc2_vector(8)                     = E
    -- pc2(8)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_8_process: process (pc2_mode(2 downto 0), pc2(8), pc2_vector(8), register_vector2(8)) begin
        half_pc2(8) <=  
                (not pc2_mode(2) and pc2_mode(1) and pc2_vector(8)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(8)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(8));               
    end process calc_half_pc2_8_process;    
            
    -- calculate half_pc2(9)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(9)               = F
    -- pc2_vector(9)                     = E
    -- pc2(9)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_9_process: process (pc2_mode(2 downto 0), pc2(9), pc2_vector(9), register_vector2(9)) begin
        half_pc2(9) <=  
                (not pc2_mode(2) and pc2_mode(1) and pc2_vector(9)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(9)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(9));              
    end process calc_half_pc2_9_process;
    
    -- calculate half_pc2(10)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(10)               = F
    -- pc2_vector(10)                     = E
    -- pc2(10)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_10_process: process (pc2_mode(2 downto 0), pc2(10), pc2_vector(10), register_vector2(10)) begin
        half_pc2(10) <=  
                (not pc2_mode(2) and pc2_mode(1) and pc2_vector(10)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(10)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(10));               
    end process calc_half_pc2_10_process;
    
    -- calculate half_pc2(11)
    -- LUT INIT = 0x00AA00FF33CC0F00
    -- y = AB'C' + AC'F + A'B'CD' + A'BC'E + A'BCE'
    -- register_vector2(11)               = F
    -- pc2_vector(11)                     = E
    -- pc2(11)                            = D
    -- pc2_mode(0)	                    = C
    -- pc2_mode(1)	                    = B
    -- pc2_mode(2)	                    = A
    calc_half_pc2_11_process: process (pc2_mode(2 downto 0), pc2(11), pc2_vector(11), register_vector2(11)) begin
        half_pc2(11) <=  
                (not pc2_mode(2) and pc2_mode(1) and pc2_vector(11)) or
                (pc2_mode(2) and not pc2_mode(1) and not pc2_mode(0)) or
                (pc2_mode(2) and not pc2_mode(0) and register_vector2(11)) or
                (not pc2_mode(2) and not pc2_mode(1) and pc2_mode(0) and pc2(11));             
    end process calc_half_pc2_11_process;
    
    -- pc_muxcy0
    -- calculate carry_pc2(0)
    calc_carry_pc22_0_process: process (pc2_mode(0), half_pc2(0)) begin
        case half_pc2(0) is
           when '0' =>
             carry_pc2(0) <= pc2_mode(0);
           when '1' =>
             carry_pc2(0) <= '0';	
           when others =>
             carry_pc2(0) <= 'X';
        end case; 
    end process calc_carry_pc22_0_process;
    
    -- pc_muxcy1
    -- calculate carry_pc2(1)
    calc_carry_pc22_1_process: process (carry_pc2(0), half_pc2(1)) begin
        case half_pc2(1) is
           when '0' =>
             carry_pc2(1) <= '0';
           when '1' =>
             carry_pc2(1) <= carry_pc2(0);	
           when others =>
             carry_pc2(1) <= 'X';
        end case; 
    end process calc_carry_pc22_1_process;
    
    -- pc_muxcy2
    -- calculate carry_pc2(2)
    calc_carry_pc22_2_process: process (carry_pc2(1), half_pc2(2)) begin
        case half_pc2(2) is
           when '0' =>
             carry_pc2(2) <= '0';
           when '1' =>
             carry_pc2(2) <= carry_pc2(1);	
           when others =>
             carry_pc2(2) <= 'X';
        end case; 
    end process calc_carry_pc22_2_process;
    
    -- pc_muxcy3
    -- calculate carry_pc2(3)
    calc_carry_pc22_3_process: process (carry_pc2(2), half_pc2(3)) begin
        case half_pc2(3) is
           when '0' =>
             carry_pc2(3) <= '0';
           when '1' =>
             carry_pc2(3) <= carry_pc2(2);	
           when others =>
             carry_pc2(3) <= 'X';
        end case; 
    end process calc_carry_pc22_3_process;
    
    -- pc_muxcy4
    -- calculate carry_pc2(4)
    calc_carry_pc22_4_process: process (carry_pc2(3), half_pc2(4)) begin
        case half_pc2(4) is
           when '0' =>
             carry_pc2(4) <= '0';
           when '1' =>
             carry_pc2(4) <= carry_pc2(3);	
           when others =>
             carry_pc2(4) <= 'X';
        end case; 
    end process calc_carry_pc22_4_process;
    
    -- pc_muxcy5
    -- calculate carry_pc2(5)
    calc_carry_pc22_5_process: process (carry_pc2(4), half_pc2(5)) begin
        case half_pc2(5) is
           when '0' =>
             carry_pc2(5) <= '0';
           when '1' =>
             carry_pc2(5) <= carry_pc2(4);	
           when others =>
             carry_pc2(5) <= 'X';
        end case; 
    end process calc_carry_pc22_5_process;
    
    -- pc_muxcy6
    -- calculate carry_pc2(6)
    calc_carry_pc22_6_process: process (carry_pc2(5), half_pc2(6)) begin
        case half_pc2(6) is
           when '0' =>
             carry_pc2(6) <= '0';
           when '1' =>
             carry_pc2(6) <= carry_pc2(5);	
           when others =>
             carry_pc2(6) <= 'X';
        end case; 
    end process calc_carry_pc22_6_process;
    
    -- pc_muxcy7
    -- calculate carry_pc2(7)
    calc_carry_pc22_7_process: process (carry_pc2(6), half_pc2(7)) begin
        case half_pc2(7) is
           when '0' =>
             carry_pc2(7) <= '0';
           when '1' =>
             carry_pc2(7) <= carry_pc2(6);	
           when others =>
             carry_pc2(7) <= 'X';
        end case; 
    end process calc_carry_pc22_7_process;
    
    -- pc_muxcy8
    -- calculate carry_pc2(8)
    calc_carry_pc22_8_process: process (carry_pc2(7), half_pc2(8)) begin
        case half_pc2(8) is
           when '0' =>
             carry_pc2(8) <= '0';
           when '1' =>
             carry_pc2(8) <= carry_pc2(7);	
           when others =>
             carry_pc2(8) <= 'X';
        end case; 
    end process calc_carry_pc22_8_process;
    
    -- pc_muxcy9
    -- calculate carry_pc2(9)
    calc_carry_pc22_9_process: process (carry_pc2(8), half_pc2(9)) begin
        case half_pc2(9) is
           when '0' =>
             carry_pc2(9) <= '0';
           when '1' =>
             carry_pc2(9) <= carry_pc2(8);	
           when others =>
             carry_pc2(9) <= 'X';
        end case; 
    end process calc_carry_pc22_9_process;
    
    -- pc_muxcy10
    -- calculate carry_pc2(10)
    calc_carry_pc22_10_process: process (carry_pc2(9), half_pc2(10)) begin
        case half_pc2(10) is
           when '0' =>
             carry_pc2(10) <= '0';
           when '1' =>
             carry_pc2(10) <= carry_pc2(9);	
           when others =>
             carry_pc2(10) <= 'X';
        end case; 
    end process calc_carry_pc22_10_process;
    
      x12_bit_program_address_generator_i: x12_bit_program_address_generator
        port map (
            instruction_12_downto_0 => instruction2_17_downto_0(12 downto 0),
                                 sx => sxB (3 downto 0),
                                 sy => syB,
                       stack_memory => stack_memory,
                    register_vector => register_vector2,
                          pc_vector => pc2_vector
        ); 
        
    decode4_pc_statck_i: decode4_pc_statck
        port map (
                      carry_flag => carry_flag_value,
                       zero_flag => zero_flag_value,
        instruction_17_downto_12 => instruction2_17_downto_0(17 downto 12),
                active_interrupt => active_interrupt,
                           pop_stack => pop_stack2,
                      push_stack => push_stack2,
                         pc_mode => pc2_mode
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
    
  
    
end Behavioral;
