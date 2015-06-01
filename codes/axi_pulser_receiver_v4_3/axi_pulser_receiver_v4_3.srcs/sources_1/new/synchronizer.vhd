----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.08.2014 10:30:39
-- Design Name: 
-- Module Name: synchronizer - Behavioral
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

entity synchronizer is
    generic (stages : integer := 2);
    Port ( clkA : in STD_LOGIC;
           Signal_in_clkA : in STD_LOGIC;
           clkB : in STD_LOGIC;
           Signal_out_clkB : out STD_LOGIC);
end synchronizer;

architecture Behavioral of synchronizer is

    signal FlagToggle_clkA : std_logic := '0';
    signal SyncA_clkA : std_logic_vector(1 downto 0) := (others => '0');  
    signal SyncA_clkB : std_logic_vector(2 downto 0) := (others => '0');  
    
--    signal SyncA_clkB : std_logic_vector(1 downto 0);
begin

    process(clkA)
    begin
        if rising_edge(clkA) then
--            SyncA_clkA(0) <= Signal_in_clkA;
--            SyncA_clkA(1) <= SyncA_clkA(0);
--            if (SyncA_clkA(0) = '1' and SyncA_clkA(1) = '0') then
--                FlagToggle_clkA <= not FlagToggle_clkA;
--            end if;
            FlagToggle_clkA <= FlagToggle_clkA xor Signal_in_clkA;
        end if;
    end process;
    
    process(clkB)
    begin
        if rising_edge(clkB) then
            SyncA_clkB <= SyncA_clkB(1 downto 0) & FlagToggle_clkA;
            
        end if;
    end process;
    Signal_out_clkB <= SyncA_clkB(2) xor SyncA_clkB(1);
--    process(clkB)
--    begin
--        if rising_edge(clkB) then
--            SyncA_clkB(0) <= Signal_in_clkA;
--            for i in 1 to stages-1 loop
--                SyncA_clkB(i) <= SyncA_clkB(i-1);
--            end loop;
--        end if;
--    end process;
--    Signal_out_clkB <= SyncA_clkB(stages-1);
end Behavioral;
