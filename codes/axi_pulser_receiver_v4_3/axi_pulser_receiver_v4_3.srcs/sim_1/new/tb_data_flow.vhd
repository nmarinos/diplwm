----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.08.2014 14:45:34
-- Design Name: 
-- Module Name: tb_data_flow - Behavioral
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

entity tb_data_flow is
end tb_data_flow;

architecture Behavioral of tb_data_flow is

    constant CHANNELS : integer := 8;
    constant OFFSET_BITS : integer := 16;
    constant SAMPLES_NUM_BITS : integer := 16;
    constant DATA_COUNTER_BITS   : integer range 1 to 32 := 16;
    
    
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
               alligning_out    : out std_logic);
    end component;
    
    signal adc_clk_in_p : STD_LOGIC := '0';
    signal adc_clk_in_n : STD_LOGIC := '1';
    signal frame_in_p   : STD_LOGIC;
    signal frame_in_n   : STD_LOGIC;
    signal din_p        : std_logic_vector(CHANNELS-1 downto 0);
    signal din_n        : std_logic_vector(CHANNELS-1 downto 0);
    signal rst_in       : std_logic;
    signal test_patt_en : std_logic := '0';
    signal prefix_en_in : std_logic := '1';
    signal dout         : std_logic_vector(16*CHANNELS-1 downto 0); --adc data
    signal adc_clk_out  : std_logic; --2*data freq
    signal adc_sel_out  : std_logic; --data valid
    signal allign_error_out : std_logic;
    signal alligning_out : std_logic;
    
    
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
    signal mode_in           : std_logic_vector (1 downto 0) := "00";
    signal samples_num       : std_logic_vector (samples_num_bits-1 downto 0);
    signal mask_in           : std_logic_vector (channels-1 downto 0) := "00001000";
    signal offsets_in        : std_logic_vector (channels*offset_bits-1 downto 0);
    signal data_out          : std_logic_vector (channels*16-1 downto 0);
    signal data_out_valid    : std_logic;
    signal data_out_last     : std_logic;
    signal stream_mode_out   : std_logic;



    component dataToAxis is
        generic (
            CHANNELS : integer := 8;
            DATA_COUNTER_BITS   : integer range 1 to 32 := 16   
            );
        Port (
            data_in : in std_logic_vector(CHANNELS*16-1 downto 0);
            data_in_valid : in std_logic;
            data_in_last : in std_logic;
            stream_mode : in std_logic; --0: keep all channels, 1: keep 1rst channels
            
            streamer_busy_out   : out std_logic;
            data_lost           : out std_logic;
            
            
            --AXI STREAM PORTS
            M_AXIS_ACLK	: in std_logic;
            -- 
            M_AXIS_ARESETN	: in std_logic;
            -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
            M_AXIS_TVALID	: out std_logic;
            -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
            M_AXIS_TDATA	: out std_logic_vector(CHANNELS*16-1 downto 0);
            -- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
--            M_AXIS_TSTRB	: out std_logic_vector((CHANNELS*16/8)-1 downto 0);
            -- TLAST indicates the boundary of a packet.
            M_AXIS_TLAST	: out std_logic;
            -- TREADY indicates that the slave can accept a transfer in the current cycle.
            M_AXIS_TREADY	: in std_logic;
            --tkeep signal indicates which is the last byte of the stream at the last beat of it
            M_AXIS_TKEEP    : out std_logic_vector((CHANNELS*16/8)-1 downto 0)
             );
    end component;


    signal data_in           : std_logic_vector (channels*16-1 downto 0);
    signal data_in_valid     : std_logic;
    signal data_in_last     : std_logic := '0';
    signal stream_mode       : std_logic := '0';
    signal streamer_busy_out : std_logic;
    signal data_lost         : std_logic;
    signal M_AXIS_ACLK       : std_logic;
    signal M_AXIS_ARESETN    : std_logic := '1';
    signal M_AXIS_TVALID     : std_logic;
    signal M_AXIS_TDATA      : std_logic_vector (channels*16-1 downto 0);
    signal M_AXIS_TKEEP      : std_logic_vector ((channels*16/8)-1 downto 0);
    signal M_AXIS_TLAST      : std_logic;
    signal M_AXIS_TREADY     : std_logic := '1';
    
    
    constant adc_clk_in_period : time := 10 ns;
    
    type data_array is array (0 to CHANNELS-1) of std_logic_vector(11 downto 0);
    signal data : data_array;
    signal data_counter : integer range 0 to 11 := 11;
begin


UUT_receiver: receiver
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
              alligning_out => alligning_out);

UUT_stream_proc: stream_proc
    generic map(CHANNELS => CHANNELS,
            OFFSET_BITS => OFFSET_BITS,
            SAMPLES_NUM_BITS => SAMPLES_NUM_BITS
            )
    port map (adc_clk_in        => adc_clk_out,
              adc_data_in       => dout,
              adc_data_valid_in => adc_sel_out,
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
              
              
              
              
UUT_dataToAxis: dataToAxis
    generic map(CHANNELS => CHANNELS)
    port map (data_in           => data_out,
            data_in_valid     => data_out_valid,
            data_in_last       => data_out_last,
            stream_mode       => stream_mode_out,
            streamer_busy_out => streamer_busy_out,
            data_lost         => data_lost,
            M_AXIS_ACLK       => adc_clk_out,
            M_AXIS_ARESETN    => M_AXIS_ARESETN,
            M_AXIS_TVALID     => M_AXIS_TVALID,
            M_AXIS_TDATA      => M_AXIS_TDATA,
    --              M_AXIS_TSTRB      => M_AXIS_TSTRB,
            M_AXIS_TLAST      => M_AXIS_TLAST,
            M_AXIS_TKEEP      => M_AXIS_TKEEP,
            M_AXIS_TREADY     => M_AXIS_TREADY);    
            
            
    adc_clk_in_p <= not adc_clk_in_p after adc_clk_in_period/2;
    adc_clk_in_n <= not adc_clk_in_n after adc_clk_in_period/2;  
    
    
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
        wait for adc_clk_in_period*100;
--        data <= (others => "101000110011");
--        test_patt_en <= '1';
        test_patt_en <= '1';
        wait for 10*adc_clk_in_period;
        mode_in <= "00";
        samples_num <= x"0020";
        mask_in <= "00001000";
        start_in <= '1';
        wait until running_out = '1';
        start_in <= '0';
        mode_in <= "00";
        samples_num <= x"0000";
    
        wait;
        
    end process;
                      
end Behavioral;
