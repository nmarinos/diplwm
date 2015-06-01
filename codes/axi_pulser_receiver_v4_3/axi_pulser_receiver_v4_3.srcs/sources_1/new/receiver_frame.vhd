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

entity receiver_frame is
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
end receiver_frame;

architecture Behavioral of receiver_frame is

attribute keep : string; 
type my_array is array (0 to CHANNELS-1) of std_logic_vector(5 downto 0);
type data_array is array (0 to CHANNELS-1) of std_logic_vector(11 downto 0);
--------------SIGNALS------------------
signal adc_clk_in_ibuf_s : std_logic;
signal adc_clk_in : std_logic;
signal adc_clk_div : std_logic;
signal not_adc_clk_in : std_logic;
signal din : std_logic_vector(CHANNELS-1 downto 0);
signal adc_data_serdes_s    : my_array;
signal adc_data_serdes_d    : my_array;
signal adc_data    : data_array;
signal adc_data_d    : data_array;
signal frame_in : std_logic;
signal adc_frame_serdes_s : std_logic_Vector(5 downto 0);
signal adc_frame_serdes_d : std_logic_Vector(5 downto 0);
signal adc_sel_out_s : std_logic := '0';
signal frame : std_logic_vector(11 downto 0) := (others => '0');
signal frame_d : std_logic_vector(11 downto 0) := (others => '0');
signal counter : std_logic_vector(11 downto 0) := (others => '0');
---------------------------------------

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
                
                 
i_frame_ibuf: IBUFDS  
     port map(
         I => frame_in_p,
         IB => frame_in_n,
         O => frame_in);
--6 bit data deserialiser
ISERDESE2_frame: ISERDESE2
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
          Q1 => adc_frame_serdes_s(0),
          Q2 => adc_frame_serdes_s(1),
          Q3 => adc_frame_serdes_s(2),
          Q4 => adc_frame_serdes_s(3),
          Q5 => adc_frame_serdes_s(4),
          Q6 => adc_frame_serdes_s(5),
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
          D => frame_in,                       -- 1-bit input: Data input
          DDLY => '0',                 -- 1-bit input: Serial data from IDELAYE2
          OFB => '0',                   -- 1-bit input: Data feedback from OSERDESE2
          OCLKB => '0',               -- 1-bit input: High speed negative edge output clock
          RST => rst_in,                   -- 1-bit input: Active high asynchronous reset
          -- SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
          SHIFTIN1 => '0',
          SHIFTIN2 => '0' );               
      


    adc_clk_out <= adc_clk_div;
--    adc_sel_out <= not adc_sel_out_s;

    
    process(adc_clk_div)
    begin
        if rising_edge(adc_clk_div) then
            adc_frame_serdes_d <= adc_frame_serdes_s;
            adc_data_serdes_d <= adc_data_serdes_s;
            adc_sel_out_s <= not adc_sel_out_s;
            adc_sel_out <= adc_sel_out_s;
--            receiver_ready <= receiver_ready;
--            alligning_out <= alligning_out;
            
            if adc_sel_out_s = '1' then
                
                
                for i in 0 to CHANNELS-1 loop
                    adc_data(i) <=  adc_data_serdes_d(i) & adc_data_serdes_s(i);
                    adc_data_d <= adc_data;
                    frame <= adc_frame_serdes_d & adc_frame_serdes_s;
                    frame_d <= frame;
                    allign_error_out <= '0';
                    receiver_ready <= '1';
                    alligning_out <= '0';
                    case frame_d is
                        when "111111000000" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(11 downto 0);
                        when "011111100000" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(10 downto 0) & adc_data(i)(11 downto 11);
                        when "001111110000" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(9 downto 0) & adc_data(i)(11 downto 10);
                        when "000111111000" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(8 downto 0) & adc_data(i)(11 downto 9);
                        when "000011111100" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(7 downto 0) & adc_data(i)(11 downto 8);
                        when "000001111110" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(6 downto 0) & adc_data(i)(11 downto 7);
                        when "000000111111" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(5 downto 0) & adc_data(i)(11 downto 6);
                        when "100000011111" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(4 downto 0) & adc_data(i)(11 downto 5);
                        when "110000001111" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(3 downto 0) & adc_data(i)(11 downto 4);
                        when "111000000111" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(2 downto 0) & adc_data(i)(11 downto 3);
                        when "111100000011" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(1 downto 0) & adc_data(i)(11 downto 2);
                        when "111110000001" => dout(16*(i+1)-1 downto 16*i) <= "0000" & adc_data_d(i)(0 downto 0) & adc_data(i)(11 downto 1);
                        when others => 
                            dout(16*(i+1)-1 downto 16*i) <= x"DDDD";
                            allign_error_out <= '1';
                            receiver_ready <= '0';
                            alligning_out <= '1';
                    end case;
                    
                if test_patt_en = '1' then 
                    counter <= std_logic_vector(unsigned(counter) + 1);
                    for i in 0 to CHANNELS-1 loop
                        dout(16*(i+1)-1 downto 16*i) <= "0000" & counter;
                    end loop;
                end if;
                    
                    
                    if prefix_en_in = '1' then
                        dout((i+1)*16-1 downto (i+1)*16-4) <= std_logic_vector(to_unsigned(i, 4));
                    end if;
                end loop;
            end if;
            
            
        
        
        
        end if; 
    end process;
    
        
end Behavioral;