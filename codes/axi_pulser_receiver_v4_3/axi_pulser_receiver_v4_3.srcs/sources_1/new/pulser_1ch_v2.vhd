----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.08.2014 14:48:15
-- Design Name: 
-- Module Name: pulser_1ch_v2 - Behavioral
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

entity pulser_1ch_v2 is
    generic (
        PATTERN_BITS      : integer range 0 to 32 := 32;
        OFFSET_BITS       : integer range 0 to 32 := 10;
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
end pulser_1ch_v2;


architecture Behavioral of pulser_1ch_v2 is

    type state_type is (st0_IDLE, st1_OFFSET_WAITING, st2_PULSE, st3_SHIFT);
    signal state: state_type;
    
    signal s_offset_counter : std_logic_vector(OFFSET_BITS-1 downto 0);
    signal s_freq_divider     : std_logic_vector(FREQ_DIV_BITS-1 downto 0);
    signal s_p_shifter     : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal s_clamp_shifter     : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal s_n_shifter     : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal div_counter :  std_logic_vector(FREQ_DIV_BITS-1 downto 0);
    signal step_counter : integer range 0 to PATTERN_BITS-1;

begin

    process(pulser_clk)
    begin
        if rising_edge(pulser_clk) then
            s_offset_counter <= s_offset_counter;
            s_freq_divider <= s_freq_divider;
            s_p_shifter <= s_p_shifter;
            s_clamp_shifter <= s_clamp_shifter;
            s_n_shifter <= s_n_shifter;
            div_counter <= div_counter;
            
            pulse_out_en <= '0';
            pulse_out_p <= '0';
            pulse_out_clamp <= '0';
            pulse_out_n <= '0';
            step_counter <= step_counter;
            
            pulsing_out <= '0';
            
            s_offset_counter <= std_logic_vector(unsigned(s_offset_counter) - 1);
            div_counter <= std_logic_vector(unsigned(div_counter) - 1);
            
            case state is 
                --ready and waiting to pulse
                when st0_IDLE => 
                    s_offset_counter <= offset_in;
                    s_freq_divider <= freq_divider;
--                    div_counter <= freq_divider;
                    s_p_shifter <= p_pattern_in;
                    s_clamp_shifter <= clamp_pattern_in;
                    s_n_shifter <= n_pattern_in;
                    if pulse_sync_in = '1' then
                        state <= st1_OFFSET_WAITING;
                    else
                        state <= st0_IDLE;
                    end if;
                
                when st1_OFFSET_WAITING => 
--                    s_offset_counter <= std_logic_vector(unsigned(s_offset_counter) - 1);
                    step_counter <= 0;
                    div_counter <= s_freq_divider;
                    if s_offset_counter = std_logic_vector(to_unsigned(0,OFFSET_BITS)) then
                        state <= st2_PULSE;
                    else
                        state <= st1_OFFSET_WAITING;
                    end if;
                
                when st2_PULSE => 
                    pulse_out_en <= '1';
                    pulse_out_p <= s_p_shifter(PATTERN_BITS-1);
                    pulse_out_clamp <= s_clamp_shifter(PATTERN_BITS-1);
                    pulse_out_n <= s_n_shifter(PATTERN_BITS-1);
                     pulsing_out <= '1';
--                    div_counter <= std_logic_vector(unsigned(div_counter) - 1);
                    if div_counter = std_logic_vector(to_unsigned(1,FREQ_DIV_BITS)) then
                        state <= st3_SHIFT;
                    else
                        state <= st2_PULSE;
                    end if;
                
                when st3_SHIFT => 
                    pulse_out_en <= '1';
                    pulse_out_p <= s_p_shifter(PATTERN_BITS-1);
                    pulse_out_clamp <= s_clamp_shifter(PATTERN_BITS-1);
                    pulse_out_n <= s_n_shifter(PATTERN_BITS-1);
                    div_counter <= s_freq_divider;
                     pulsing_out <= '1';
                    --shift
                    s_p_shifter <= s_p_shifter(PATTERN_BITS-2 downto 0) & '0';
                    s_clamp_shifter <= s_clamp_shifter(PATTERN_BITS-2 downto 0) & '0';
                    s_n_shifter <= s_n_shifter(PATTERN_BITS-2 downto 0) & '0';
                    
                    step_counter <= step_counter + 1;
                    if step_counter = PATTERN_BITS - 1 then
                        state <= st0_IDLE;
                    else
                        state <= st2_PULSE;
                    end if;
                    
                
                when others => 
                    state <= st0_IDLE;
            end case;
        end if;
    end process;


end Behavioral;
