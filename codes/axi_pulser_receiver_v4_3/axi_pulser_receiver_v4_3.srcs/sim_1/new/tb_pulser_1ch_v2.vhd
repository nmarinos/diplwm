----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.08.2014 15:46:33
-- Design Name: 
-- Module Name: tb_pulser_1ch_v2 - Behavioral
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

entity tb_pulser_1ch_v2 is
end tb_pulser_1ch_v2;




architecture Behavioral of tb_pulser_1ch_v2 is

    constant PATTERN_BITS      : integer range 0 to 32 := 32;
    constant OFFSET_BITS       : integer range 0 to 32 := 16;
    constant FREQ_DIV_BITS     : integer range 0 to 32 := 4;



    component pulser_1ch_v2
        generic (
            PATTERN_BITS      : integer range 0 to 32 := 32;
            OFFSET_BITS       : integer range 0 to 32 := 16;
            FREQ_DIV_BITS     : integer range 0 to 32 := 4
        );
        Port (
            pulser_clk       : in std_logic;
            freq_divider     : in std_logic_vector(FREQ_DIV_BITS-1 downto 0);
            pulse_sync_in    : in std_logic;
            p_pattern_in     : in std_logic_vector(PATTERN_BITS-1 downto 0);
            clamp_pattern_in : in std_logic_vector(PATTERN_BITS-1 downto 0);
            n_pattern_in     : in std_logic_vector(PATTERN_BITS-1 downto 0);
            offset_in        : in std_logic_vector(OFFSET_BITS-1 downto 0);
            pulse_out_en     : out std_logic;
            pulse_out_p      : out std_logic;
            pulse_out_clamp  : out std_logic;
            pulse_out_n      : out std_logic;
            pulsing_out      : out std_logic
        );
    end component;
  
  
    signal pulser_clk: std_logic;
    signal freq_divider: std_logic_vector(FREQ_DIV_BITS-1 downto 0);
    signal pulse_sync_in: std_logic := '0';
    signal p_pattern_in: std_logic_vector(PATTERN_BITS-1 downto 0);
    signal clamp_pattern_in: std_logic_vector(PATTERN_BITS-1 downto 0);
    signal n_pattern_in: std_logic_vector(PATTERN_BITS-1 downto 0);
    signal offset_in: std_logic_vector(OFFSET_BITS-1 downto 0);
    signal pulse_out_en: std_logic;
    signal pulse_out_p: std_logic;
    signal pulse_out_clamp: std_logic;
    signal pulse_out_n: std_logic;
    signal pulsing_out: std_logic ;
    
    constant pulser_clk_period : time := 3.125 ns;

begin

uut: pulser_1ch_v2 generic map ( PATTERN_BITS     => PATTERN_BITS,
                                   OFFSET_BITS      => OFFSET_BITS,
                                   FREQ_DIV_BITS    =>  FREQ_DIV_BITS)
                        port map ( pulser_clk       => pulser_clk,
                                   freq_divider     => freq_divider,
                                   pulse_sync_in    => pulse_sync_in,
                                   p_pattern_in     => p_pattern_in,
                                   clamp_pattern_in => clamp_pattern_in,
                                   n_pattern_in     => n_pattern_in,
                                   offset_in        => offset_in,
                                   pulse_out_en     => pulse_out_en,
                                   pulse_out_p      => pulse_out_p,
                                   pulse_out_clamp  => pulse_out_clamp,
                                   pulse_out_n      => pulse_out_n,
                                   pulsing_out      => pulsing_out );

pulser_clk_proc: process
    begin
        pulser_clk <= '0';
        wait for pulser_clk_period/2;
        pulser_clk <= '1';
        wait for pulser_clk_period/2;
    end process;
    
stimuli: process
    begin
        wait for 100 ns;
        pulse_sync_in <= '1';
        p_pattern_in <= x"80000000";
        clamp_pattern_in <= x"70000000";
        n_pattern_in <= x"03000000";
        freq_divider <= x"3";
        offset_in <= x"0005";
        wait for pulser_clk_period;
        pulse_sync_in <= '0';
        p_pattern_in <= (others => '0');
        clamp_pattern_in <= (others => '0');
        n_pattern_in <= (others => '0');
        freq_divider <= (others => '0');
        offset_in <= (others => '0');
        
        wait;
    end process;   
    
end Behavioral;
