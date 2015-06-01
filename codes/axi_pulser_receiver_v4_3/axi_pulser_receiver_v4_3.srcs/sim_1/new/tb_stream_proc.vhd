----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.08.2014 10:23:25
-- Design Name: 
-- Module Name: tb_stream_proc - Behavioral
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

entity tb_stream_proc is
end tb_stream_proc;

architecture Behavioral of tb_stream_proc is

    constant CHANNELS : integer := 8;
    constant OFFSET_BITS : integer := 16;
    constant SAMPLES_NUM_BITS : integer := 16;
    constant adc_clk_period : time := 10 ns;

    component stream_proc is
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
    end component;

    signal adc_clk_in        : std_logic;
    signal adc_data_in       : std_logic_vector (channels*16-1 downto 0) := (others => '0');
    signal adc_data_valid_in : std_logic;
    signal start_in          : std_logic;
    signal running_out       : std_logic;
    signal mode_in           : std_logic_vector (1 downto 0);
    signal samples_num       : std_logic_vector (samples_num_bits-1 downto 0);
    signal mask_in           : std_logic_vector (channels-1 downto 0) := "00001000";
    signal offsets_in        : std_logic_vector (channels*offset_bits-1 downto 0);
    signal rst_in            : std_logic;
    signal data_out          : std_logic_vector (channels*16-1 downto 0);
    signal data_out_valid    : std_logic;
    signal data_out_last     : std_logic;
    signal stream_mode_out   : std_logic;
    
    signal counter            : std_logic_vector(11 downto 0) := (others => '0');


begin



dut: stream_proc
    generic map(CHANNELS => CHANNELS,
            OFFSET_BITS => OFFSET_BITS,
            SAMPLES_NUM_BITS => SAMPLES_NUM_BITS
            )
    port map (adc_clk_in        => adc_clk_in,
              adc_data_in       => adc_data_in,
              adc_data_valid_in => adc_data_valid_in,
              start_in          => start_in,
              running_out       => running_out,
              mode_in           => mode_in,
              samples_num       => samples_num,
              mask_in           => mask_in,
              offsets_in        => offsets_in,
              rst_in            => rst_in,
              data_out          => data_out,
              data_out_valid    => data_out_valid,
              data_out_last     => data_out_last,
              stream_mode_out   => stream_mode_out);

clk_proc: process
    begin
        adc_clk_in <= '0';
        wait for adc_clk_period/2;
        adc_clk_in <= '1';
        wait for adc_clk_period/2;
    end process;
    
    
--adc_data_in_proc: process
--    begin
--        wait for adc_clk_period;
--        adc_data_in <= std_logic_vector(unsigned(adc_data_in) + 1);
--        adc_data_valid_in <= '1';
--        wait for adc_clk_period;
--        adc_data_valid_in <= '0';
--    end process;
    
counter_proc: process
    begin
        wait for adc_clk_period;
            counter <= std_logic_vector(unsigned(counter) + 1);
            adc_data_valid_in <= '1';
            wait for adc_clk_period;
            adc_data_valid_in <= '0';
    end process;
    
data_gen: for i in 0 to CHANNELS-1 generate
        adc_data_in(16*(i+1)-1 downto 16*i) <= std_logic_vector(to_unsigned(i,4)) & counter;
    end generate;    
    
stimuli: process
    begin
        wait for 100 ns;
        mode_in <= "01";
        samples_num <= x"0020";
        mask_in <= mask_in(channels-2 downto 0) & mask_in(channels-1);
        start_in <= '1';
        wait until running_out = '1';
        start_in <= '0';
        mode_in <= "00";
        samples_num <= x"0000";
--        mask_in <= "00000000";
        
        wait for 100*adc_clk_period;
        
        
--        wait;
    end process;    

end Behavioral;
