----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2014 14:15:20
-- Design Name: 
-- Module Name: stream_proc - Behavioral
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

entity stream_proc is
    generic (
        CHANNELS : integer := 8;
        OFFSET_BITS : integer := 16;
        SAMPLES_NUM_BITS : integer := 16
        );
    Port (
        --signals from adc receiver
        adc_clk_in : in std_logic;
        adc_data_in : in std_logic_vector(CHANNELS*16-1 downto 0);
        adc_data_valid_in : in std_logic;
        
        --signals from/to control unit
        start_in : in std_logic;
        running_out : out std_logic;
        mode_in : in std_logic_vector(1 downto 0);
        samples_num : in std_logic_vector(SAMPLES_NUM_BITS-1 downto 0);
        mask_in : in std_logic_vector(CHANNELS-1 downto 0);
        offsets_in : in std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
        rst_in : in std_logic;
        
        
        --signals to dataToAxis
        data_out : out std_logic_vector(CHANNELS*16-1 downto 0);
        data_out_valid : out std_logic;
        data_out_last : out std_logic;
        stream_mode_out : out std_logic
    
     );
end stream_proc;

architecture Behavioral of stream_proc is


    type state_type is (IDLE, STREAM_1CH, STREAM_ALL_CH);
    signal state : state_type; 
    
    signal s_samples_counter : std_logic_vector(SAMPLES_NUM_BITS-1 downto 0);
    signal s_mask : std_logic_vector(CHANNELS-1 downto 0);
    signal s_offsets : std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);

begin

    process(adc_clk_in)
    begin
        if rising_edge(adc_clk_in) then
            if rst_in = '1' then
            
            else
                --default values of the output signals
                running_out <= '0';
                data_out_valid <= '0';
                data_out_last <= '0';
                data_out <= (others => '0');
                stream_mode_out <= '0';
                
                case state is
                    when IDLE =>
                        state <= IDLE;
                        s_mask <= mask_in;
                        s_offsets <= offsets_in;
                        s_samples_counter <= samples_num;
                        if start_in = '1' then
                            case mode_in is
                                when "00" => --1 channel pulsed, 1 channel to stream
                                    state <= STREAM_1CH;
                                when "01" => --masked channels pulse, all channels to stream 
                                    state <= STREAM_ALL_CH;
                                when "10" => --masked cannels pulse, beamforming, 1 ch to stream
                                when others =>
                            end case; --mode
                        end if;
                    ---------------------------------
                    when STREAM_1CH =>
                        state <= STREAM_1CH;
                        running_out <= '1';
                        stream_mode_out <= '1';
                        if adc_data_valid_in = '1' then
                            s_samples_counter <= std_logic_vector(unsigned(s_samples_counter) - 1);
                            data_out_valid <= '1';
                            data_out <= (others => '0');
                            case s_mask is --choose the channel that pulsed and connect it to the first channel output
                                when "00000001" =>
                                    data_out(15 downto 0) <= adc_data_in(15 downto 0);
                                when "00000010" =>
                                    data_out(15 downto 0) <= adc_data_in(31 downto 16);
                                when "00000100" =>
                                    data_out(15 downto 0) <= adc_data_in(47 downto 32);
                                when "00001000" =>
                                    data_out(15 downto 0) <= adc_data_in(63 downto 48);
                                when "00010000" =>
                                    data_out(15 downto 0) <= adc_data_in(79 downto 64);
                                when "00100000" =>
                                    data_out(15 downto 0) <= adc_data_in(95 downto 80);
                                when "01000000" =>
                                    data_out(15 downto 0) <= adc_data_in(111 downto 96);
                                when "10000000" =>
                                    data_out(15 downto 0) <= adc_data_in(127 downto 112);
                                when others =>
                                    data_out(15 downto 0) <= x"abcd";
                            end case;
                            
                            if s_samples_counter = std_logic_vector(to_unsigned(1, SAMPLES_NUM_BITS)) then
                                state <= IDLE;
                                data_out_last <= '1';
                            end if;
                        else 
                            s_samples_counter <= s_samples_counter;
                            data_out_valid <= '0';
                            data_out <= (others => '0');
                        end if;
                    ---------------------------------
                    when STREAM_ALL_CH =>
                        state <= STREAM_ALL_CH;
                        running_out <= '1';
                        stream_mode_out <= '0';
                        if adc_data_valid_in = '1' then
                            s_samples_counter <= std_logic_vector(unsigned(s_samples_counter) - 1);
                            data_out_valid <= '1';
                            data_out <= adc_data_in;
                            if s_samples_counter = std_logic_vector(to_unsigned(1, SAMPLES_NUM_BITS)) then
                                state <= IDLE;
                                data_out_last <= '1';
                            end if;
                        else 
                            s_samples_counter <= s_samples_counter;
                            data_out_valid <= '0';
                            data_out <= (others => '0');
                        end if;
                    
                    
                    
                    ---------------------------------
                    when others =>
                        state <= IDLE;
                end case; --state
            end if; --rst
        end if; --clk
    end process;




end Behavioral;
