----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.08.2014 10:07:04
-- Design Name: 
-- Module Name: tb_control_unit - Behavioral
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

entity tb_control_unit is
end tb_control_unit;

architecture Behavioral of tb_control_unit is

    constant CHANNELS            : integer range 0 to 32   := 8;
    constant PATTERN_BITS        : integer range 0 to 32   := 32;
    constant OFFSET_BITS         : integer range 0 to 32   := 8;
    constant DATA_NUM_BITS       : integer range 0 to 32   := 16;
    constant FREQ_DIVIDER_BITS   : integer range 0 to 32   := 3;
    constant C_S_AXI_DATA_WIDTH	 : integer := 32;
    constant C_S_AXI_ADDR_WIDTH	 : integer := 6;
    constant maxis_raddr_width   : integer := 32;

    component control_unit_s_axi
        generic (
            CHANNELS            : integer range 0 to 32   := 8;
            PATTERN_BITS        : integer range 0 to 32   := 32;
            OFFSET_BITS         : integer range 0 to 32   := 8;
            DATA_NUM_BITS       : integer range 0 to 32   := 16;
            FREQ_DIVIDER_BITS   : integer range 0 to 32   := 3;
            maxis_raddr_width   : integer := 32;
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 6
            );
        port (
            rst_out        : out std_logic;
            rdata_addr_out : out std_logic_vector(maxis_raddr_width-1 downto 0);
            rdata_valid_out : out std_logic;
            mask_in : in std_logic_vector(CHANNELS-1 downto 0);
            offsets_in : in std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
            data_valid_in : in std_logic;
            pulse_out           : out std_logic_vector(CHANNELS-1 downto 0);
            pulse_freq_div_out  : out std_logic_vector(FREQ_DIVIDER_BITS-1 downto 0);              
            p_pattern_out       : out std_logic_vector(PATTERN_BITS-1 downto 0);
            clamp_pattern_out   : out std_logic_vector(PATTERN_BITS-1 downto 0);
            n_pattern_out       : out std_logic_vector(PATTERN_BITS-1 downto 0);
            offsets_out         : out std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
            pulsing_in          : in std_logic_vector(CHANNELS-1 downto 0);
            test_patt_en_out        : out std_logic;
            prefix_en_out           : out std_logic;
            receiver_allign_err_in  : in std_logic;
            receiver_alligning_in   : in std_logic;
            receiver_ready          : in std_logic;
            start_capture_out   : out std_logic;
            mode_out            : out std_logic_vector(1 downto 0);
            samples_num_out     : out std_logic_vector(DATA_NUM_BITS-1 downto 0);
            mask_out            : out std_logic_vector(CHANNELS-1 downto 0);
            stream_offsets_out  : out std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
            streamer_running_in : in std_logic;
            data_lost_in        : in std_logic;
            dataToAxis_busy_in  : in std_logic;
            S_AXI_ACLK	: in std_logic;
            S_AXI_ARESETN	: in std_logic;
            S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
            S_AXI_AWVALID	: in std_logic;
            S_AXI_AWREADY	: out std_logic;
            S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            S_AXI_WVALID	: in std_logic;
            S_AXI_WREADY	: out std_logic;
            S_AXI_BRESP	: out std_logic_vector(1 downto 0);
            S_AXI_BVALID	: out std_logic;
            S_AXI_BREADY	: in std_logic;
            S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
            S_AXI_ARVALID	: in std_logic;
            S_AXI_ARREADY	: out std_logic;
            S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_RRESP	: out std_logic_vector(1 downto 0);
            S_AXI_RVALID	: out std_logic;
            S_AXI_RREADY	: in std_logic
            );
    end component;


    signal rst_out: std_logic;
    signal rdata_addr_out: std_logic_vector(maxis_raddr_width-1 downto 0);
    signal rdata_valid_out: std_logic;
    signal mask_in: std_logic_vector(CHANNELS-1 downto 0);
    signal offsets_in: std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
    signal data_valid_in: std_logic;
    signal pulse_out: std_logic_vector(CHANNELS-1 downto 0);
    signal pulse_freq_div_out: std_logic_vector(FREQ_DIVIDER_BITS-1 downto 0);
    signal p_pattern_out: std_logic_vector(PATTERN_BITS-1 downto 0);
    signal clamp_pattern_out: std_logic_vector(PATTERN_BITS-1 downto 0);
    signal n_pattern_out: std_logic_vector(PATTERN_BITS-1 downto 0);
    signal offsets_out: std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
    signal pulsing_in: std_logic_vector(CHANNELS-1 downto 0);
    signal test_patt_en_out: std_logic;
    signal prefix_en_out: std_logic;
    signal receiver_allign_err_in: std_logic := '0';
    signal receiver_alligning_in: std_logic;
    signal receiver_ready: std_logic;
    signal start_capture_out: std_logic;
    signal mode_out: std_logic_vector(1 downto 0);
    signal samples_num_out: std_logic_vector(DATA_NUM_BITS-1 downto 0);
    signal mask_out: std_logic_vector(CHANNELS-1 downto 0);
    signal stream_offsets_out: std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
    signal streamer_running_in: std_logic := '0';
    signal data_lost_in: std_logic := '0';
    signal dataToAxis_busy_in: std_logic := '0';
    signal S_AXI_ACLK: std_logic;
    signal S_AXI_ARESETN: std_logic;
    signal S_AXI_AWADDR: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal S_AXI_AWPROT: std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID: std_logic;
    signal S_AXI_AWREADY: std_logic;
    signal S_AXI_WDATA: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal S_AXI_WSTRB: std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    signal S_AXI_WVALID: std_logic;
    signal S_AXI_WREADY: std_logic;
    signal S_AXI_BRESP: std_logic_vector(1 downto 0);
    signal S_AXI_BVALID: std_logic;
    signal S_AXI_BREADY: std_logic;
    signal S_AXI_ARADDR: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal S_AXI_ARPROT: std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID: std_logic;
    signal S_AXI_ARREADY: std_logic;
    signal S_AXI_RDATA: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal S_AXI_RRESP: std_logic_vector(1 downto 0);
    signal S_AXI_RVALID: std_logic;
    signal S_AXI_RREADY: std_logic ;
    
    constant C_CONTROL_REG      : integer := 0;
        constant C_CONTROL_RUN_BIT          : integer   := 0;                     
        constant C_CONTROL_RST_BIT          : integer   := 1;                     
        constant C_TEST_PATTERN_EN_BIT      : integer   := 2;                     
        constant C_CHANNEL_PREFIX_EN_BIT    : integer   := 3;                     
        --                constant C_TEST_PATTERN_EN_BIT0     : integer   := 4;                     
        --                constant C_TEST_PATTERN_EN_BIT1     : integer   := 5;  
        subtype  MODE_BITS_RANGE is  natural range 5 downto 4;                   
    constant C_STATUS_REG       : integer := 1*4;
        constant C_SYS_READY_BIT            : integer   := 0;
        constant C_RUNNING_BIT              : integer   := 1;
        constant C_CAPTURE_BUSY_BIT         : integer   := 2;
        constant C_ALLIGN_ERR_BIT           : integer   := 3;
        constant C_SAMPLE_LOST_BIT          : integer   := 3;
        constant C_PERIOD_ERR_BIT           : integer   := 3;
    constant C_P_FREQ_DIV        : integer := 2*4;
    constant C_P_PATT_REG        : integer := 3*4;
    constant C_CLAMP_PATT_REG    : integer := 4*4;
    constant C_N_PATT_REG        : integer := 5*4;
    constant C_CAPT_DELAY_REG    : integer := 6*4;
    constant C_CAPT_LENGTH_REG   : integer := 7*4;
    constant C_PULSE_PERIOD_REG  : integer := 8*4;
    constant C_MO_BASE_ADDR_REG  : integer := 9*4;
    constant C_MO_BASE_STEPS_REG : integer := 10*4;

    constant S_AXI_ACLK_period : time := 10 ns;
    constant adc_clk_period : time := 12.5 ns;
    signal adc_clk : std_logic;
begin


uut: control_unit_s_axi generic map   ( CHANNELS               => CHANNELS,
                                        PATTERN_BITS           => PATTERN_BITS,
                                        OFFSET_BITS            => OFFSET_BITS,
                                        DATA_NUM_BITS          => DATA_NUM_BITS,
                                        FREQ_DIVIDER_BITS      => FREQ_DIVIDER_BITS,
                                        C_S_AXI_DATA_WIDTH     => C_S_AXI_DATA_WIDTH,
                                        C_S_AXI_ADDR_WIDTH     => C_S_AXI_ADDR_WIDTH )
                             port map ( rst_out                => rst_out,
                                        rdata_addr_out         => rdata_addr_out,
                                        rdata_valid_out        => rdata_valid_out,
                                        mask_in                => mask_in,
                                        offsets_in             => offsets_in,
                                        data_valid_in          => data_valid_in,
                                        pulse_out              => pulse_out,
                                        pulse_freq_div_out     => pulse_freq_div_out,
                                        p_pattern_out          => p_pattern_out,
                                        clamp_pattern_out      => clamp_pattern_out,
                                        n_pattern_out          => n_pattern_out,
                                        offsets_out            => offsets_out,
                                        pulsing_in             => pulsing_in,
                                        test_patt_en_out       => test_patt_en_out,
                                        prefix_en_out          => prefix_en_out,
                                        receiver_allign_err_in => receiver_allign_err_in,
                                        receiver_alligning_in  => receiver_alligning_in,
                                        receiver_ready         => receiver_ready,
                                        start_capture_out      => start_capture_out,
                                        mode_out               => mode_out,
                                        samples_num_out        => samples_num_out,
                                        mask_out               => mask_out,
                                        stream_offsets_out     => stream_offsets_out,
                                        streamer_running_in    => streamer_running_in,
                                        data_lost_in           => data_lost_in,
                                        dataToAxis_busy_in     => dataToAxis_busy_in,
                                        S_AXI_ACLK             => S_AXI_ACLK,
                                        S_AXI_ARESETN          => S_AXI_ARESETN,
                                        S_AXI_AWADDR           => S_AXI_AWADDR,
                                        S_AXI_AWPROT           => S_AXI_AWPROT,
                                        S_AXI_AWVALID          => S_AXI_AWVALID,
                                        S_AXI_AWREADY          => S_AXI_AWREADY,
                                        S_AXI_WDATA            => S_AXI_WDATA,
                                        S_AXI_WSTRB            => S_AXI_WSTRB,
                                        S_AXI_WVALID           => S_AXI_WVALID,
                                        S_AXI_WREADY           => S_AXI_WREADY,
                                        S_AXI_BRESP            => S_AXI_BRESP,
                                        S_AXI_BVALID           => S_AXI_BVALID,
                                        S_AXI_BREADY           => S_AXI_BREADY,
                                        S_AXI_ARADDR           => S_AXI_ARADDR,
                                        S_AXI_ARPROT           => S_AXI_ARPROT,
                                        S_AXI_ARVALID          => S_AXI_ARVALID,
                                        S_AXI_ARREADY          => S_AXI_ARREADY,
                                        S_AXI_RDATA            => S_AXI_RDATA,
                                        S_AXI_RRESP            => S_AXI_RRESP,
                                        S_AXI_RVALID           => S_AXI_RVALID,
                                        S_AXI_RREADY           => S_AXI_RREADY );

  

S_AXI_ACLK_proc: process
    begin
        S_AXI_ACLK <= '0';
        wait for S_AXI_ACLK_period/2;
        S_AXI_ACLK <= '1';
        wait for S_AXI_ACLK_period/2;
    end process;
    
adc_clk_proc: process
    begin
        adc_clk <= '0';
        wait for adc_clk_period/2;
        adc_clk <= '1';
        wait for adc_clk_period/2;
    end process;
    
pulse_process: process
    begin
        wait for S_AXI_ACLK_period;
        pulsing_in <= pulse_out;
    end process;   
    
stream_proc_resp: process(adc_clk)
    begin
        if rising_edge(adc_clk) then
            streamer_running_in <= '0';
            if start_capture_out = '1' then
                streamer_running_in <= '1';
            end if;
        end if;
    end process;  
    
maxi_rdata_resp: process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            offsets_in <= (others => '0');
            if rdata_valid_out = '1' then
                data_valid_in <= '1';
                mask_in <= x"05";
            else
                data_valid_in <= '0';
                mask_in <= x"00";
            end if;
        end if;
    end process;   

stimuli: process
        procedure axi_write
           (addr : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
           data : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)) is
        begin
           s_axi_wstrb <= x"f";
           S_AXI_AWVALID <= '1';
           S_AXI_WVALID <= '1';
           S_AXI_AWADDR <= addr;
           S_AXI_WDATA <= data;
           
           wait until S_AXI_AWREADY = '1';
           wait for S_AXI_ACLK_period*2;
           S_AXI_AWVALID <= '0';
           S_AXI_WVALID <= '0';
           S_AXI_AWADDR <= (others => '0');
           S_AXI_WDATA <= (others => '0');
           wait for S_AXI_ACLK_period;
        end axi_write;
    
    begin
        wait for 100 ns;
        
        
        axi_write(std_logic_vector(to_unsigned(C_P_PATT_REG, C_S_AXI_ADDR_WIDTH)), x"ff000000");
        axi_write(std_logic_vector(to_unsigned(C_CLAMP_PATT_REG, C_S_AXI_ADDR_WIDTH)), x"00ff0000");
        axi_write(std_logic_vector(to_unsigned(C_N_PATT_REG, C_S_AXI_ADDR_WIDTH)), x"0000ff00");       
        axi_write(std_logic_vector(to_unsigned(C_P_FREQ_DIV, C_S_AXI_ADDR_WIDTH)), x"00000004");       
        axi_write(std_logic_vector(to_unsigned(C_PULSE_PERIOD_REG, C_S_AXI_ADDR_WIDTH)), x"000000ff");       
        axi_write(std_logic_vector(to_unsigned(C_MO_BASE_ADDR_REG, C_S_AXI_ADDR_WIDTH)), x"00000000");       
        axi_write(std_logic_vector(to_unsigned(C_MO_BASE_STEPS_REG, C_S_AXI_ADDR_WIDTH)), x"0000000b");  
        axi_write(std_logic_vector(to_unsigned(C_CAPT_DELAY_REG, C_S_AXI_ADDR_WIDTH)), x"00000000");  
        axi_write(std_logic_vector(to_unsigned(C_CAPT_LENGTH_REG, C_S_AXI_ADDR_WIDTH)), x"0000000c");  
        
        receiver_ready <= '1';
        wait for S_AXI_ACLK_period*5;
        --start
        axi_write(std_logic_vector(to_unsigned(C_CONTROL_REG, C_S_AXI_ADDR_WIDTH)), x"00000011");  
        
        
        wait for S_AXI_ACLK_period*5000;
        --stop
        axi_write(std_logic_vector(to_unsigned(C_CONTROL_REG, C_S_AXI_ADDR_WIDTH)), x"00000010");  
            
        
        
        
        wait;
    end process;

end Behavioral;
