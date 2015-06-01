----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.07.2014 15:18:42
-- Design Name: 
-- Module Name: receiver - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity receiver is
generic (
       CHANNELS : integer := 8
--       USE_FRAME: boolean := FALSE --not in use at the moment
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
end receiver;

architecture Behavioral of receiver is

attribute keep : string; 
signal CLKFBOUT    : std_logic;
signal CLKFBOUT_s    : std_logic;
signal adc_clk_in_ibuf_s    : std_logic;
signal adc_clk_in           : std_logic;
signal not_adc_clk_in           : std_logic;
signal adc_clk_in_s         : std_logic;
signal adc_clk_div          : std_logic;
signal adc_clk_div_s        : std_logic;
signal adc_data_clk         : std_logic;
signal s_adc_clk_out        : std_logic;
signal adc_sel              : std_logic := '0';
signal din                  : std_logic_vector(CHANNELS-1 downto 0);
signal counter              : std_logic_vector(11 downto 0) := (others => '0');
type frame_array_type is array (0 to CHANNELS-1) of std_logic_vector(11 downto 0);
signal frame                : frame_array_type;
    attribute keep of frame: signal is "true";

type my_array is array (0 to CHANNELS-1) of std_logic_vector(5 downto 0);
type data_array is array (0 to CHANNELS-1) of std_logic_vector(11 downto 0);
signal adc_data_serdes_s    : my_array;
signal adc_data_serdes_d    : my_array;
    attribute keep of adc_data_serdes_d: signal is "true";
signal adc_data_serdes      : my_array;
    attribute keep of adc_data_serdes: signal is "true";
signal adc_data             : data_array;
signal adc_data_d           : data_array;

type state_type is (st0_alligning, st1_receiving);
signal state                : state_type;
    attribute keep of state: signal is "true";
signal s_allign_err : std_logic_vector(CHANNELS-1 downto 0);
signal s_channel_is_framed : std_logic_vector(CHANNELS-1 downto 0);
     attribute keep of s_channel_is_framed: signal is "true";
     
 signal s_frame_position    : std_logic_vector(CHANNELS*4-1 downto 0); 
 signal s_receiver_ready    : std_logic := '0';

begin

--differential clock to single
i_clk_ibuf: IBUFGDS  
        port map(
        I => adc_clk_in_p,
        IB => adc_clk_in_n,
        O => adc_clk_in_ibuf_s);


-----------------------------------------------------------              
BUFIO_inst: BUFIO
    port map (
       O => adc_clk_in,     -- Buffer output
       I => adc_clk_in_ibuf_s      -- Buffer input (connect directly to top-level port)
    );
                
--If the clock is not on clock capable pins use uncomment this and comment the BUFIO above
--    serdes_clk_bufr: BUFR 
--            generic map (
--                BUFR_DIVIDE => "1")
--            port map (
--                CLR =>'0',
--                CE => '1',
--                I => adc_clk_in_ibuf_s,
--                O => adc_clk_in); 
                
    serdes_clk_div_bufr: BUFR 
            generic map (
                BUFR_DIVIDE => "3")
            port map (
                CLR =>'0',
                CE => '1',
                I => adc_clk_in_ibuf_s,
                O => adc_clk_div); 
    
-- adc_clk_out <= adc_clk_in;           
  not_adc_clk_in <= not adc_clk_in;        
            
serd_loop: for i in 0 to CHANNELS-1 generate            
    --differential data to single
    i_data_ibuf: IBUFDS  
            port map(
                I => din_p(i),
                IB => din_n(i),
                O => din(i));
    --6 bit data deserialiser
    ISERDESE2_data: ISERDESE2
              generic map (
                 DATA_RATE => "DDR",           -- DDR, SDR
                 DATA_WIDTH => 6,              -- Parallel data width (2-8,10,14)
                 INTERFACE_TYPE => "NETWORKING",   -- MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
                 IOBDELAY => "NONE",           -- NONE, BOTH, IBUF, IFD
                 NUM_CE => 2,                  -- Number of clock enables (1,2)
                 OFB_USED => "FALSE",          -- Select OFB path (FALSE, TRUE)
                 SERDES_MODE => "MASTER",      -- MASTER, SLAVE
                 DYN_CLKDIV_INV_EN => "FALSE",
                 DYN_CLK_INV_EN => "FALSE"
              )
              port map (
    --                 O => O,                       -- 1-bit output: Combinatorial output
                 -- Q1 - Q8: 1-bit (each) output: Registered data outputs
                 Q1 => adc_data_serdes_s(i)(0),
                 Q2 => adc_data_serdes_s(i)(1),
                 Q3 => adc_data_serdes_s(i)(2),
                 Q4 => adc_data_serdes_s(i)(3),
                 Q5 => adc_data_serdes_s(i)(4),
                 Q6 => adc_data_serdes_s(i)(5),
                 -- SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
    --                 SHIFTOUT1 => SHIFTOUT1,
    --                 SHIFTOUT2 => SHIFTOUT2,
                 BITSLIP => '0',                      
                 -- CE1, CE2: 1-bit (each) input: Data register clock enable inputs
                 CE1 => '1',
                 CE2 => '1',
    --                 CLKDIVP => CLKDIVP,           -- 1-bit input: TBD
                 -- Clocks: 1-bit (each) input: ISERDESE2 clock input ports
                 CLK => adc_clk_in,                   -- 1-bit input: High-speed clock
                 CLKB => not_adc_clk_in,                 -- 1-bit input: High-speed secondary clock
                 CLKDIV => adc_clk_div,             -- 1-bit input: Divided clock
                 OCLK => '0',
                 clkdivp => '0',
                 -- Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
                 DYNCLKDIVSEL => '0', -- 1-bit input: Dynamic CLKDIV inversion
                 DYNCLKSEL => '0',       -- 1-bit input: Dynamic CLK/CLKB inversion
                 -- Input Data: 1-bit (each) input: ISERDESE2 data input ports
                 D => din(i),                       -- 1-bit input: Data input
                 DDLY => '0',                 -- 1-bit input: Serial data from IDELAYE2
                 OFB => '0',                   -- 1-bit input: Data feedback from OSERDESE2
                 OCLKB => '0',               -- 1-bit input: High speed negative edge output clock
                 RST => rst_in,                   -- 1-bit input: Active high asynchronous reset
                 -- SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
                 SHIFTIN1 => '0',
                 SHIFTIN2 => '0' );               
end generate;  


    adc_clk_out <= adc_clk_div;
    process(adc_clk_div)
    begin
        if rising_edge(adc_clk_div) then
            adc_sel_out <= '0';
            adc_sel <= not adc_sel;
            adc_data_serdes <= adc_data_serdes_s;
            adc_data_serdes_d <= adc_data_serdes;
            dout <= (others => '0');
            s_receiver_ready <= s_receiver_ready;
            receiver_ready <= s_receiver_ready;
            if s_allign_err = std_logic_vector(to_unsigned(0, CHANNELS)) then
                allign_error_out <= '0';
            else
                allign_error_out <= '1';
            end if;
            
            if adc_sel = '1' then
                adc_sel_out <= '1';
                --if test pattern mode, increase the counter. This counter gets connected to the dout
                if test_patt_en = '1' then 
                    counter <= std_logic_vector(unsigned(counter) + 1);
                end if;
                
                for i in 0 to channels-1 loop
                    
                    if test_patt_en = '1' then 
                        dout((i+1)*16-5 downto i*16) <= counter;
                    else
                        case s_frame_position(4*(i+1)-1 downto 4*i) is
                            when x"0" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i);
                            when x"1" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(10 downto 0) & adc_data(i)(11 downto 11);
                            when x"2" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(9 downto 0) & adc_data(i)(11 downto 10);
                            when x"3" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(8 downto 0) & adc_data(i)(11 downto 9);
                            when x"4" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(7 downto 0) & adc_data(i)(11 downto 8);
                            when x"5" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(6 downto 0) & adc_data(i)(11 downto 7);
                            when x"6" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(5 downto 0) & adc_data(i)(11 downto 6);
                            when x"7" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(4 downto 0) & adc_data(i)(11 downto 5);
                            when x"8" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(3 downto 0) & adc_data(i)(11 downto 4);
                            when x"9" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(2 downto 0) & adc_data(i)(11 downto 3);
                            when x"a" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(1 downto 0) & adc_data(i)(11 downto 2);
                            when x"b" => dout((i+1)*16-5 downto i*16) <= adc_data_d(i)(0 downto 0) & adc_data(i)(11 downto 1);
                            when others => dout((i+1)*12-1 downto i*12) <= x"Da1";
                                s_allign_err(i) <= '1';
                        end case;
                     end if;   
                        
                    adc_data(i) <= adc_data_serdes_d(i) & adc_data_serdes(i);
                    
                    if prefix_en_in = '1' then
                        dout((i+1)*16-1 downto (i+1)*16-4) <= std_logic_vector(to_unsigned(i, 4));
                    end if;
                    
                end loop;
                adc_data_d <= adc_data;
                case state is
                    when st0_alligning =>
                        alligning_out <= '1';
                        for i in 0 to CHANNELS-1 loop
                            frame(i) <= adc_data_serdes_d(i) & adc_data_serdes(i);

                             s_channel_is_framed(i) <= '0';
                             case frame(i)is
                                when "000000111111" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"0";
                                when "100000011111" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"1";
                                when "110000001111" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"2";
                                when "111000000111" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"3";
                                when "111100000011" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"4";
                                when "111110000001" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"5";
                                when "111111000000" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"6";
                                when "011111100000" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"7";
                                when "001111110000" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"7";
                                when "000111111000" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"8";
                                when "000011111100" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"9";
                                when "000001111110" =>
                                    s_channel_is_framed(i) <= '1';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"a";
                                when others =>
                                    s_channel_is_framed(i) <= '0';
                                    s_frame_position(4*(i+1)-1 downto 4*i) <= x"f";
                                    s_allign_err(i) <= '1';
                            end case;
                        end loop;
                        if s_channel_is_framed = "11111111" then
                            state <= st1_receiving;
                            s_receiver_ready <= '1';
                        else
                            state <= st0_alligning;
                        end if;
                        dout <= (others => '0');
                        dout(11 downto 0) <= x"a11";
                    when st1_receiving =>
                        alligning_out <= '0';
                        frame <= frame;
                        s_allign_err <= (others => '0');
                        if rst_in = '1' then
                            state <= st0_alligning;
                        else
                            state <= st1_receiving;
                        end if;
                    when others =>
                        alligning_out <= '0';
                        state <= st1_receiving;
                end case;
            end if;
        end if;
    end process;
    
        
end Behavioral;