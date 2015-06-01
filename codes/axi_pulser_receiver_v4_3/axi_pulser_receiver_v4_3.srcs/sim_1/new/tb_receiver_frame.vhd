----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2014 15:50:11
-- Design Name: 
-- Module Name: tb_receiver_frame - Behavioral
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

entity tb_receiver_frame is
end tb_receiver_frame;

architecture Behavioral of tb_receiver_frame is

    constant CHANNELS : integer := 8;
--    constant USE_FRAME : boolean := FALSE;
    component receiver_frame
        generic (
             CHANNELS : integer := 8
--             USE_FRAME: boolean := FALSE
             );
        Port (
             adc_clk_in_p : in STD_LOGIC;
             adc_clk_in_n : in STD_LOGIC;
             frame_in_p   : in STD_LOGIC;
             frame_in_n   : in STD_LOGIC;
             din_p        : in std_logic_vector(CHANNELS-1 downto 0);
             din_n        : in std_logic_vector(CHANNELS-1 downto 0);
             rst_in       : in std_logic;
             test_patt_en : in std_logic;
             prefix_en_in : in std_logic;
             dout         : out std_logic_vector(16*CHANNELS-1 downto 0);
             adc_clk_out  : out std_logic;
             adc_sel_out  : out std_logic;
             allign_error_out : out std_logic;
             alligning_out    : out std_logic;
             receiver_ready   : out std_logic);
    end component;
    
    signal adc_clk_in_p: STD_LOGIC;
    signal adc_clk_in_n: STD_LOGIC;
    signal frame_in_p: STD_LOGIC;
    signal frame_in_n: STD_LOGIC;
    signal din_p: std_logic_vector(CHANNELS-1 downto 0);
    signal din_n: std_logic_vector(CHANNELS-1 downto 0);
    signal rst_in: std_logic;
    signal test_patt_en: std_logic := '1';
    signal prefix_en_in: std_logic := '1';
    signal dout: std_logic_vector(16*CHANNELS-1 downto 0);
    signal adc_clk_out: std_logic;
    signal adc_sel_out: std_logic;
    signal allign_error_out: std_logic;
    signal alligning_out: std_logic;
    signal receiver_ready: std_logic;
    
    signal data : std_logic_vector(11 downto 0) := "101000110011";
    signal send : boolean := FALSE;
    
    constant adc_clk_period : time := 10 ns;
    
    
    
begin

uut: receiver_frame generic map ( CHANNELS         => CHANNELS)
--                                USE_FRAME        =>  TRUE)
                     port map ( adc_clk_in_p     => adc_clk_in_p,
                                adc_clk_in_n     => adc_clk_in_n,
                                frame_in_p       => frame_in_p,
                                frame_in_n       => frame_in_n,
                                din_p            => din_p,
                                din_n            => din_n,
                                rst_in           => rst_in,
                                test_patt_en     => test_patt_en,
                                prefix_en_in     => prefix_en_in,
                                dout             => dout,
                                adc_clk_out      => adc_clk_out,
                                adc_sel_out      => adc_sel_out,
                                allign_error_out => allign_error_out,
                                alligning_out    => alligning_out,
                                receiver_ready   => receiver_ready );

    
    
    
    process
    begin
        adc_clk_in_p <= '0';
        adc_clk_in_n <= '1';
        wait for adc_clk_period/2;
        adc_clk_in_p <= '1';
        adc_clk_in_n <= '0';
        wait for adc_clk_period/2;
    end process;
    
    --frame process
    process
    begin
        if send = TRUE then
            frame_in_p <= '1';
            frame_in_n <= '0';
            wait for adc_clk_period*3;
            frame_in_p <= '0';
            frame_in_n <= '1';
            wait for adc_clk_period*3;
        else
            wait for adc_clk_period/2;
        end if;
    end process;
    
    --data process
din_connection: for i in 0 to CHANNELS-1 generate 
        din_p(i) <= data(11);
        din_n(i) <= not data(11);
    end generate;
    process
    begin
        if send = TRUE then
            wait for adc_clk_period/2;
            data <= data(10 downto 0) & data(11);
        else
            wait for adc_clk_period/2;
        end if;
    end process;
    
    
    
stimuli: process
    begin
        wait for 100 ns;
        wait for adc_clk_period*16/2;
        send <= TRUE;
        wait for adc_clk_period*30;
        rst_in <= '1';
        wait for adc_clk_period*10;
        rst_in <= '0';
        
        
        
        wait;
    end process;    


end Behavioral;
