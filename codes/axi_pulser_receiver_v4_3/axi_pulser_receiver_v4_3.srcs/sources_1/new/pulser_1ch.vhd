----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.07.2014 12:31:53
-- Design Name: 
-- Module Name: pulser_1ch - Behavioral
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

entity pulser_1ch is
    generic (
        PATTERN_BITS      : integer range 0 to 32 := 32;
        OFFSET_BITS       : integer range 0 to 32 := 8;
        MAX_FREQ_DIVIDER : integer range 0 to 32 := 8
        );
    Port (
        pulser_clk       : in std_logic;
        freq_divider     : in std_logic_vector(MAX_FREQ_DIVIDER-1 downto 0);
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
end pulser_1ch;

architecture Behavioral of pulser_1ch is

    type state_type is (st0_IDLE, st1_OFFSET_WAITING, st2_PULSING);
    signal state: state_type;
    
    signal offset_counter : std_logic_vector(OFFSET_BITS-1 downto 0);
    signal pattern_counter : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal p_pattern_shift : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal clamp_pattern_shift : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal n_pattern_shift : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal clk_div_counter : std_logic_vector(MAX_FREQ_DIVIDER-1 downto 0);
    signal freq_divider_s  : std_logic_vector(MAX_FREQ_DIVIDER-1 downto 0);
    signal p_pattern_buff     : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal clamp_pattern_buff     : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal n_pattern_buff     : std_logic_vector(PATTERN_BITS-1 downto 0);

begin

    process(pulser_clk)
    begin
        if rising_edge(pulser_clk) then
            pulsing_out <= '0';
            pulse_out_en <= '0';
            p_pattern_shift <= p_pattern_shift;
            clamp_pattern_shift <= clamp_pattern_shift;
            n_pattern_shift <= n_pattern_shift;
            pattern_counter <= (others => '0');
            clk_div_counter <= (others => '0');

            
            
            case state is
                when st0_IDLE =>
                    pattern_counter <= (others => '0');
                    clk_div_counter <= (others => '0');
                    if pulse_sync_in = '1' then 
                        --store inputs into buffers
                        freq_divider_s <= freq_divider;
                        p_pattern_buff <= p_pattern_in;
                        clamp_pattern_buff <= clamp_pattern_in;
                        n_pattern_buff <= n_pattern_in;
                        --next state
                        state <= st1_OFFSET_WAITING;
                        offset_counter <= offset_in; --initialize offset counter
                    end if; 
                ----------------------------------------------------
                when st1_OFFSET_WAITING => 
                    state <= st1_OFFSET_WAITING;
                    pulsing_out <= '1';
                    offset_counter <= std_logic_vector(unsigned(offset_counter) - 1);
                    if offset_counter = std_logic_vector(to_unsigned(0,OFFSET_BITS)) then
                        state <= st2_PULSING;
                        pattern_counter(PATTERN_BITS-1) <= '1'; --initialize pattern counter
--                        pattern_counter(0) <= '1';
                        clk_div_counter <= freq_divider_s;
                        p_pattern_shift <= p_pattern_buff;
                        clamp_pattern_shift <= clamp_pattern_buff;
                        n_pattern_shift <= n_pattern_buff;
                    end if;
                ----------------------------------------------------
                when st2_PULSING => 
                    state <= st2_PULSING;
                    pulsing_out <= '1';
                    pulse_out_en <= '1';
                    pattern_counter <= pattern_counter;
                    clk_div_counter <= '0' & clk_div_counter(MAX_FREQ_DIVIDER-1 downto 1);
                    if clk_div_counter(0) = '1' then
                        --pattern counter
                        pattern_counter <= '0' & pattern_counter(PATTERN_BITS-1 downto 1);
                        --pattern shift
                        p_pattern_shift <= p_pattern_shift(PATTERN_BITS-2 downto 0) & '0';
                        clamp_pattern_shift <= clamp_pattern_shift(PATTERN_BITS-2 downto 0) & '0';
                        n_pattern_shift <= n_pattern_shift(PATTERN_BITS-2 downto 0) & '0';
                        --reset division counter
                        clk_div_counter <= freq_divider_s;
                        if pattern_counter(0) = '1' then
                            state <= st0_IDLE;
                        end if;
                    end if; 
                ---------------------------------------------------
                when others => 
                    state <= st0_IDLE;
            end case;    
        end if;
    end process;

    pulse_out_p <= p_pattern_shift(PATTERN_BITS-1);
    pulse_out_clamp <= clamp_pattern_shift(PATTERN_BITS-1);
    pulse_out_n <= n_pattern_shift(PATTERN_BITS-1);
end Behavioral;
