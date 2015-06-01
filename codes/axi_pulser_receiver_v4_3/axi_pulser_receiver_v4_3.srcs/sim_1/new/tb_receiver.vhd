----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.07.2014 14:35:24
-- Design Name: 
-- Module Name: tb_receiver - Behavioral
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

entity tb_receiver is

end tb_receiver;

architecture Behavioral of tb_receiver is

constant CHANNELS : integer := 8;
component receiver
    generic (
           CHANNELS : integer := 8;
           USE_FRAME: boolean := FALSE --not in use at the moment
           );
    Port ( 
           --adc signals
           adc_clk_in_p : in STD_LOGIC;
           adc_clk_in_n : in STD_LOGIC;
           frame_in_p   : in STD_LOGIC;
           frame_in_n   : in STD_LOGIC;
           din_p        : in std_logic_vector(CHANNELS-1 downto 0);
           din_n        : in std_logic_vector(CHANNELS-1 downto 0);
           --control signals
           rst_in       : in std_logic;
           test_patt_en : in std_logic;
           prefix_en_in : in std_logic;
           --outputs
           dout         : out std_logic_vector(16*CHANNELS-1 downto 0); --adc data
           adc_clk_out  : out std_logic; --2*data freq
           adc_sel_out  : out std_logic; --data valid
           allign_error_out : out std_logic;
           alligning_out    : out std_logic;
           receiver_ready   : out std_logic);
end component;

signal adc_clk_in_p : STD_LOGIC := '0';
signal adc_clk_in_n : STD_LOGIC := '1';
signal frame_in_p   : STD_LOGIC;
signal frame_in_n   : STD_LOGIC;
signal din_p        : std_logic_vector(CHANNELS-1 downto 0);
signal din_n        : std_logic_vector(CHANNELS-1 downto 0);
signal rst_in       : std_logic;
signal test_patt_en : std_logic;
signal prefix_en_in : std_logic := '1';
signal dout         : std_logic_vector(16*CHANNELS-1 downto 0); --adc data
signal adc_clk_out  : std_logic; --2*data freq
signal adc_sel_out  : std_logic; --data valid
signal allign_error_out : std_logic;
signal alligning_out : std_logic;
signal receiver_ready : std_logic;

type data_array is array (0 to CHANNELS-1) of std_logic_vector(11 downto 0);
signal data : data_array;
signal data_counter : integer range 0 to 11 := 11;

constant adc_clk_in_period : time := 10 ns;

begin

    adc_clk_in_p <= not adc_clk_in_p after adc_clk_in_period/2;
    adc_clk_in_n <= not adc_clk_in_n after adc_clk_in_period/2;
    
UUT: receiver
    generic map(CHANNELS => 8,
                USE_FRAME => FALSE)
    port map (adc_clk_in_p => adc_clk_in_p,
              adc_clk_in_n => adc_clk_in_n,
              frame_in_p   => frame_in_p,
              frame_in_n   => frame_in_n,
              din_p        => din_p,
              din_n        => din_n,
              rst_in       => rst_in,
              test_patt_en => test_patt_en,
              prefix_en_in => prefix_en_in,
              dout         => dout,
              adc_clk_out  => adc_clk_out,
              adc_sel_out  => adc_sel_out,
              allign_error_out => allign_error_out,
              alligning_out => alligning_out,
              receiver_ready => receiver_ready);

data_process: process
    begin
        for i in 0 to CHANNELS-1 loop
            din_p(i) <= data(i)(data_counter);
            din_n(i) <=  not data(i)(data_counter);
        end loop;
        if data_counter = 0 then
            data_counter <= 11;
        else
            data_counter <= data_counter - 1;
        end if;
        wait for adc_clk_in_period/2;
    end process;

stimuli: process
    begin
        wait for 100 ns;
        data <= (others => "000000111111");
        wait for 100 ns;
        rst_in <= '1';
        wait for adc_clk_in_period*10;
        rst_in <= '0';
        wait for adc_clk_in_period*1000;
        data <= (others => "101000110011");
--        test_patt_en <= '1';
        wait;
        
    end process;


end Behavioral;
