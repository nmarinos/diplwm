----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2014 11:03:06
-- Design Name: 
-- Module Name: tb_top_lvl - Behavioral
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

entity tb_top_lvl is
end tb_top_lvl;

architecture Behavioral of tb_top_lvl is

    constant CHANNELS : integer := 8;
    constant PATTERN_BITS        : integer range 0 to 32   := 32;
    constant OFFSET_BITS         : integer range 0 to 32   := 8;
    constant DATA_NUM_BITS       : integer range 0 to 32   := 16;
    constant FREQ_DIV_BITS       : integer range 0 to 32   := 3;
    constant maxis_raddr_width   : integer := 32;
    constant C_S_AXI_DATA_WIDTH	: integer	:= 32;
    constant C_S_AXI_ADDR_WIDTH	: integer	:= 6;
    constant C_M_AXI_ID_WIDTH	: integer	:= 1;
    constant C_M_AXI_ADDR_WIDTH	: integer	:= 32;
    constant C_M_AXI_DATA_WIDTH	: integer	:= 32;
    constant C_M_AXI_AWUSER_WIDTH	: integer	:= 1;
    constant C_M_AXI_ARUSER_WIDTH	: integer	:= 1;
    constant C_M_AXI_WUSER_WIDTH	: integer	:= 1;
    constant C_M_AXI_RUSER_WIDTH	: integer	:= 1;
    constant C_M_AXI_BUSER_WIDTH	: integer	:= 1;
    constant USE_FRAME: boolean := TRUE;


    component axi_pulser_receiver_v4
        Generic (
            CHANNELS : integer := 8;
            PATTERN_BITS        : integer range 0 to 32   := 32;
            OFFSET_BITS         : integer range 0 to 32   := 8;
            DATA_NUM_BITS       : integer range 0 to 32   := 16;
            FREQ_DIV_BITS       : integer range 0 to 32   := 3;
            USE_FRAME: boolean := FALSE; --not in use at the moment;
            maxis_raddr_width   : integer := 32;
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 6;
            C_M_AXI_ID_WIDTH	: integer	:= 1;
            C_M_AXI_ADDR_WIDTH	: integer	:= 32;
            C_M_AXI_DATA_WIDTH	: integer	:= 32;
            C_M_AXI_AWUSER_WIDTH	: integer	:= 1;
            C_M_AXI_ARUSER_WIDTH	: integer	:= 1;
            C_M_AXI_WUSER_WIDTH	: integer	:= 1;
            C_M_AXI_RUSER_WIDTH	: integer	:= 1;
            C_M_AXI_BUSER_WIDTH	: integer	:= 1
            );      
        Port (
            intr_out       : out std_logic;
            pulser_clk       : in std_logic;
            pulse_out_en     : out std_logic;
            pulse_out_p      : out std_logic_vector(CHANNELS-1 downto 0);
            pulse_out_clamp  : out std_logic_vector(CHANNELS-1 downto 0);
            pulse_out_n      : out std_logic_vector(CHANNELS-1 downto 0);
            adc_clk_in_p : in STD_LOGIC;
            adc_clk_in_n : in STD_LOGIC;
            frame_in_p   : in STD_LOGIC;
            frame_in_n   : in STD_LOGIC;
            din_p        : in std_logic_vector(CHANNELS-1 downto 0);
            din_n        : in std_logic_vector(CHANNELS-1 downto 0);
            adc_clk_out  : out std_logic;
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
            S_AXI_RREADY	: in std_logic;
            M_AXIS_ACLK	: in std_logic;
            M_AXIS_ARESETN	: in std_logic;
            M_AXIS_TVALID	: out std_logic;
            M_AXIS_TDATA	: out std_logic_vector(CHANNELS*16-1 downto 0);
            M_AXIS_TLAST	: out std_logic;
            M_AXIS_TREADY	: in std_logic;
            M_AXIS_TKEEP    : out std_logic_vector((CHANNELS*16/8)-1 downto 0);
            M_AXI_ACLK	: in std_logic;
            M_AXI_ARESETN	: in std_logic;
            M_AXI_AWID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
            M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
            M_AXI_AWLEN	: out std_logic_vector(7 downto 0);
            M_AXI_AWSIZE	: out std_logic_vector(2 downto 0);
            M_AXI_AWBURST	: out std_logic_vector(1 downto 0);
            M_AXI_AWLOCK	: out std_logic;
            M_AXI_AWCACHE	: out std_logic_vector(3 downto 0);
            M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
            M_AXI_AWQOS	: out std_logic_vector(3 downto 0);
            M_AXI_AWUSER	: out std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
            M_AXI_AWVALID	: out std_logic;
            M_AXI_AWREADY	: in std_logic;
            M_AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
            M_AXI_WSTRB	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
            M_AXI_WLAST	: out std_logic;
            M_AXI_WUSER	: out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
            M_AXI_WVALID	: out std_logic;
            M_AXI_WREADY	: in std_logic;
            M_AXI_BID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
            M_AXI_BRESP	: in std_logic_vector(1 downto 0);
            M_AXI_BUSER	: in std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
            M_AXI_BVALID	: in std_logic;
            M_AXI_BREADY	: out std_logic;
            M_AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
            M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
            M_AXI_ARLEN	: out std_logic_vector(7 downto 0);
            M_AXI_ARSIZE	: out std_logic_vector(2 downto 0);
            M_AXI_ARBURST	: out std_logic_vector(1 downto 0);
            M_AXI_ARLOCK	: out std_logic;
            M_AXI_ARCACHE	: out std_logic_vector(3 downto 0);
            M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
            M_AXI_ARQOS	: out std_logic_vector(3 downto 0);
            M_AXI_ARUSER	: out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
            M_AXI_ARVALID	: out std_logic;
            M_AXI_ARREADY	: in std_logic;
            M_AXI_RID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
            M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
            M_AXI_RRESP	: in std_logic_vector(1 downto 0);
            M_AXI_RLAST	: in std_logic;
            M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
            M_AXI_RVALID	: in std_logic;
            M_AXI_RREADY	: out std_logic
            ); 
    end component;


    signal intr_out: std_logic;
    signal pulser_clk: std_logic;
    signal pulse_out_en: std_logic;
    signal pulse_out_p: std_logic_vector(CHANNELS-1 downto 0);
    signal pulse_out_clamp: std_logic_vector(CHANNELS-1 downto 0);
    signal pulse_out_n: std_logic_vector(CHANNELS-1 downto 0);
    signal adc_clk_in_p: STD_LOGIC;
    signal adc_clk_in_n: STD_LOGIC;
    signal frame_in_p: STD_LOGIC;
    signal frame_in_n: STD_LOGIC;
    signal din_p: std_logic_vector(CHANNELS-1 downto 0);
    signal din_n: std_logic_vector(CHANNELS-1 downto 0);
    signal adc_clk_out: std_logic;
    signal S_AXI_ACLK: std_logic;
    signal S_AXI_ARESETN: std_logic := '1';
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
    signal S_AXI_RREADY: std_logic;
    signal M_AXIS_ACLK: std_logic;
    signal M_AXIS_ARESETN: std_logic := '1';
    signal M_AXIS_TVALID: std_logic;
    signal M_AXIS_TDATA: std_logic_vector(CHANNELS*16-1 downto 0);
    signal M_AXIS_TLAST: std_logic;
    signal M_AXIS_TREADY: std_logic := '1';
    signal M_AXIS_TKEEP: std_logic_vector((CHANNELS*16/8)-1 downto 0);
    signal M_AXI_ACLK: std_logic;
    signal M_AXI_ARESETN: std_logic;
    signal M_AXI_AWID: std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    signal M_AXI_AWADDR: std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal M_AXI_AWLEN: std_logic_vector(7 downto 0);
    signal M_AXI_AWSIZE: std_logic_vector(2 downto 0);
    signal M_AXI_AWBURST: std_logic_vector(1 downto 0);
    signal M_AXI_AWLOCK: std_logic;
    signal M_AXI_AWCACHE: std_logic_vector(3 downto 0);
    signal M_AXI_AWPROT: std_logic_vector(2 downto 0);
    signal M_AXI_AWQOS: std_logic_vector(3 downto 0);
    signal M_AXI_AWUSER: std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
    signal M_AXI_AWVALID: std_logic;
    signal M_AXI_AWREADY: std_logic;
    signal M_AXI_WDATA: std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    signal M_AXI_WSTRB: std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
    signal M_AXI_WLAST: std_logic;
    signal M_AXI_WUSER: std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
    signal M_AXI_WVALID: std_logic;
    signal M_AXI_WREADY: std_logic;
    signal M_AXI_BID: std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    signal M_AXI_BRESP: std_logic_vector(1 downto 0);
    signal M_AXI_BUSER: std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
    signal M_AXI_BVALID: std_logic;
    signal M_AXI_BREADY: std_logic;
    signal M_AXI_ARID: std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    signal M_AXI_ARADDR: std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal M_AXI_ARLEN: std_logic_vector(7 downto 0);
    signal M_AXI_ARSIZE: std_logic_vector(2 downto 0);
    signal M_AXI_ARBURST: std_logic_vector(1 downto 0);
    signal M_AXI_ARLOCK: std_logic;
    signal M_AXI_ARCACHE: std_logic_vector(3 downto 0);
    signal M_AXI_ARPROT: std_logic_vector(2 downto 0);
    signal M_AXI_ARQOS: std_logic_vector(3 downto 0);
    signal M_AXI_ARUSER: std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
    signal M_AXI_ARVALID: std_logic;
    signal M_AXI_ARREADY: std_logic := '1';
    signal M_AXI_RID: std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    signal M_AXI_RDATA: std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal M_AXI_RRESP: std_logic_vector(1 downto 0);
    signal M_AXI_RLAST: std_logic;
    signal M_AXI_RUSER: std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
    signal M_AXI_RVALID: std_logic;
    signal M_AXI_RREADY: std_logic ;
    
    type data_array is array (0 to CHANNELS-1) of std_logic_vector(11 downto 0);
    signal data : data_array;
    signal data_counter : integer range 0 to 11 := 11;

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
        constant C_P_FREQ_DIV_REG    : integer := 2*4;
        constant C_P_PATT_REG        : integer := 3*4;
        constant C_CLAMP_PATT_REG    : integer := 4*4;
        constant C_N_PATT_REG        : integer := 5*4;
        constant C_CAPT_DELAY_REG    : integer := 6*4;
        constant C_CAPT_LENGTH_REG   : integer := 7*4;
        constant C_PULSE_PERIOD_REG  : integer := 8*4;
        constant C_MO_BASE_ADDR_REG  : integer := 9*4;
        constant C_MO_BASE_STEPS_REG : integer := 10*4;
        
        constant pulser_clk_period : time := 3.125 ns;
        constant adc_clk_period : time := 12.5 ns;
        constant axi_clk_period : time := 10 ns;
begin

uut: axi_pulser_receiver_v4 generic map ( CHANNELS             => CHANNELS,
                                            PATTERN_BITS         => PATTERN_BITS,
                                            OFFSET_BITS          => OFFSET_BITS,
                                            DATA_NUM_BITS        => DATA_NUM_BITS,
                                            FREQ_DIV_BITS        => FREQ_DIV_BITS,
                                            USE_FRAME            => USE_FRAME,
                                            maxis_raddr_width    => maxis_raddr_width,
                                            C_S_AXI_DATA_WIDTH   => C_S_AXI_DATA_WIDTH,
                                            C_S_AXI_ADDR_WIDTH   => C_S_AXI_ADDR_WIDTH,
                                            C_M_AXI_ID_WIDTH     => C_M_AXI_ID_WIDTH,
                                            C_M_AXI_ADDR_WIDTH   => C_M_AXI_ADDR_WIDTH,
                                            C_M_AXI_DATA_WIDTH   => C_M_AXI_DATA_WIDTH,
                                            C_M_AXI_AWUSER_WIDTH => C_M_AXI_AWUSER_WIDTH,
                                            C_M_AXI_ARUSER_WIDTH => C_M_AXI_ARUSER_WIDTH,
                                            C_M_AXI_WUSER_WIDTH  => C_M_AXI_WUSER_WIDTH,
                                            C_M_AXI_RUSER_WIDTH  => C_M_AXI_RUSER_WIDTH,
                                            C_M_AXI_BUSER_WIDTH  => C_M_AXI_BUSER_WIDTH )
                                 port map ( intr_out             => intr_out,
                                            pulser_clk           => pulser_clk,
                                            pulse_out_en         => pulse_out_en,
                                            pulse_out_p          => pulse_out_p,
                                            pulse_out_clamp      => pulse_out_clamp,
                                            pulse_out_n          => pulse_out_n,
                                            adc_clk_in_p         => adc_clk_in_p,
                                            adc_clk_in_n         => adc_clk_in_n,
                                            frame_in_p           => frame_in_p,
                                            frame_in_n           => frame_in_n,
                                            din_p                => din_p,
                                            din_n                => din_n,
                                            adc_clk_out          => adc_clk_out,
                                            S_AXI_ACLK           => S_AXI_ACLK,
                                            S_AXI_ARESETN        => S_AXI_ARESETN,
                                            S_AXI_AWADDR         => S_AXI_AWADDR,
                                            S_AXI_AWPROT         => S_AXI_AWPROT,
                                            S_AXI_AWVALID        => S_AXI_AWVALID,
                                            S_AXI_AWREADY        => S_AXI_AWREADY,
                                            S_AXI_WDATA          => S_AXI_WDATA,
                                            S_AXI_WSTRB          => S_AXI_WSTRB,
                                            S_AXI_WVALID         => S_AXI_WVALID,
                                            S_AXI_WREADY         => S_AXI_WREADY,
                                            S_AXI_BRESP          => S_AXI_BRESP,
                                            S_AXI_BVALID         => S_AXI_BVALID,
                                            S_AXI_BREADY         => S_AXI_BREADY,
                                            S_AXI_ARADDR         => S_AXI_ARADDR,
                                            S_AXI_ARPROT         => S_AXI_ARPROT,
                                            S_AXI_ARVALID        => S_AXI_ARVALID,
                                            S_AXI_ARREADY        => S_AXI_ARREADY,
                                            S_AXI_RDATA          => S_AXI_RDATA,
                                            S_AXI_RRESP          => S_AXI_RRESP,
                                            S_AXI_RVALID         => S_AXI_RVALID,
                                            S_AXI_RREADY         => S_AXI_RREADY,
                                            M_AXIS_ACLK          => M_AXIS_ACLK,
                                            M_AXIS_ARESETN       => M_AXIS_ARESETN,
                                            M_AXIS_TVALID        => M_AXIS_TVALID,
                                            M_AXIS_TDATA         => M_AXIS_TDATA,
                                            M_AXIS_TLAST         => M_AXIS_TLAST,
                                            M_AXIS_TREADY        => M_AXIS_TREADY,
                                            M_AXIS_TKEEP         => M_AXIS_TKEEP,
                                            M_AXI_ACLK           => M_AXI_ACLK,
                                            M_AXI_ARESETN        => M_AXI_ARESETN,
                                            M_AXI_AWID           => M_AXI_AWID,
                                            M_AXI_AWADDR         => M_AXI_AWADDR,
                                            M_AXI_AWLEN          => M_AXI_AWLEN,
                                            M_AXI_AWSIZE         => M_AXI_AWSIZE,
                                            M_AXI_AWBURST        => M_AXI_AWBURST,
                                            M_AXI_AWLOCK         => M_AXI_AWLOCK,
                                            M_AXI_AWCACHE        => M_AXI_AWCACHE,
                                            M_AXI_AWPROT         => M_AXI_AWPROT,
                                            M_AXI_AWQOS          => M_AXI_AWQOS,
                                            M_AXI_AWUSER         => M_AXI_AWUSER,
                                            M_AXI_AWVALID        => M_AXI_AWVALID,
                                            M_AXI_AWREADY        => M_AXI_AWREADY,
                                            M_AXI_WDATA          => M_AXI_WDATA,
                                            M_AXI_WSTRB          => M_AXI_WSTRB,
                                            M_AXI_WLAST          => M_AXI_WLAST,
                                            M_AXI_WUSER          => M_AXI_WUSER,
                                            M_AXI_WVALID         => M_AXI_WVALID,
                                            M_AXI_WREADY         => M_AXI_WREADY,
                                            M_AXI_BID            => M_AXI_BID,
                                            M_AXI_BRESP          => M_AXI_BRESP,
                                            M_AXI_BUSER          => M_AXI_BUSER,
                                            M_AXI_BVALID         => M_AXI_BVALID,
                                            M_AXI_BREADY         => M_AXI_BREADY,
                                            M_AXI_ARID           => M_AXI_ARID,
                                            M_AXI_ARADDR         => M_AXI_ARADDR,
                                            M_AXI_ARLEN          => M_AXI_ARLEN,
                                            M_AXI_ARSIZE         => M_AXI_ARSIZE,
                                            M_AXI_ARBURST        => M_AXI_ARBURST,
                                            M_AXI_ARLOCK         => M_AXI_ARLOCK,
                                            M_AXI_ARCACHE        => M_AXI_ARCACHE,
                                            M_AXI_ARPROT         => M_AXI_ARPROT,
                                            M_AXI_ARQOS          => M_AXI_ARQOS,
                                            M_AXI_ARUSER         => M_AXI_ARUSER,
                                            M_AXI_ARVALID        => M_AXI_ARVALID,
                                            M_AXI_ARREADY        => M_AXI_ARREADY,
                                            M_AXI_RID            => M_AXI_RID,
                                            M_AXI_RDATA          => M_AXI_RDATA,
                                            M_AXI_RRESP          => M_AXI_RRESP,
                                            M_AXI_RLAST          => M_AXI_RLAST,
                                            M_AXI_RUSER          => M_AXI_RUSER,
                                            M_AXI_RVALID         => M_AXI_RVALID,
                                            M_AXI_RREADY         => M_AXI_RREADY );


pulser_clk_proc: process
    begin
        pulser_clk <= '0';
        wait for pulser_clk_period/2;
        pulser_clk <= '1';
        wait for pulser_clk_period/2;
    end process;
    
axi_clk_proc: process
    begin
        M_AXI_ACLK <= '0';
        S_AXI_ACLK <= '0';
        wait for axi_clk_period/2;
        M_AXI_ACLK <= '1';
        S_AXI_ACLK <= '1';
        wait for axi_clk_period/2;
    end process;
    
adc_clk_proc: process
    begin
        adc_clk_in_p <= '0';
        adc_clk_in_n <= '1';
        wait for adc_clk_period/2;
        adc_clk_in_p <= '1';
        adc_clk_in_n <= '0';
        wait for adc_clk_period/2;
    end process;    
      
   M_AXIS_ACLK <= adc_clk_out;
   
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
       wait for adc_clk_period/2;
   end process;    
   
slave_axi_read_answer: process
    begin
        wait until M_AXI_ARVALID = '1';
        wait for axi_clk_period;
        M_AXI_ARREADY <= '1';
        wait for axi_clk_period;
        M_AXI_ARREADY <= '0';
--        wait for axi_clk_period*10;
        M_AXI_RVALID <= '1';
        wait for axi_clk_period*8;
        M_AXI_RLAST <= '1';
        wait for axi_clk_period;
        M_AXI_RLAST <= '0';
        M_AXI_RVALID <= '0';
    
    end process; 
    
rdata_proc: process
    begin
        wait for axi_clk_period;
        M_AXI_RDATA <= std_logic_vector(unsigned(M_AXI_RDATA) + 1);
    end process;   
    
    --frame process
    process
    begin
--        if send = TRUE then
            frame_in_p <= '1';
            frame_in_n <= '0';
            wait for adc_clk_period*3;
            frame_in_p <= '0';
            frame_in_n <= '1';
            wait for adc_clk_period*3;
--        else
--            wait for adc_clk_period/2;
--        end if;
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
           wait for axi_clk_period*2;
           S_AXI_AWVALID <= '0';
           S_AXI_WVALID <= '0';
           S_AXI_AWADDR <= (others => '0');
           S_AXI_WDATA <= (others => '0');
           wait for axi_clk_period;
        end axi_write;
    begin
        wait for 100 ns;
        wait for 100 ns;
        data <= (others => "000000111111");
        wait for axi_clk_period;
        S_AXI_ARESETN <= '0';
        wait for axi_clk_period;
        S_AXI_ARESETN <= '1';
        wait for axi_clk_period*5;
        axi_write(std_logic_vector(to_unsigned(C_P_PATT_REG, C_S_AXI_ADDR_WIDTH)), x"ff000000");
        axi_write(std_logic_vector(to_unsigned(C_CLAMP_PATT_REG, C_S_AXI_ADDR_WIDTH)), x"00ff0000");
        axi_write(std_logic_vector(to_unsigned(C_N_PATT_REG, C_S_AXI_ADDR_WIDTH)), x"0000ff00");       
        axi_write(std_logic_vector(to_unsigned(C_P_FREQ_DIV_REG, C_S_AXI_ADDR_WIDTH)), x"00000004");       
        axi_write(std_logic_vector(to_unsigned(C_PULSE_PERIOD_REG, C_S_AXI_ADDR_WIDTH)), x"000000ff");       
        axi_write(std_logic_vector(to_unsigned(C_MO_BASE_ADDR_REG, C_S_AXI_ADDR_WIDTH)), x"00000000");       
        axi_write(std_logic_vector(to_unsigned(C_MO_BASE_STEPS_REG, C_S_AXI_ADDR_WIDTH)), x"00000003");  
        axi_write(std_logic_vector(to_unsigned(C_CAPT_DELAY_REG, C_S_AXI_ADDR_WIDTH)), x"00000000");  
        axi_write(std_logic_vector(to_unsigned(C_CAPT_LENGTH_REG, C_S_AXI_ADDR_WIDTH)), x"0000000c");  
        
        
        --start
        axi_write(std_logic_vector(to_unsigned(C_CONTROL_REG, C_S_AXI_ADDR_WIDTH)), x"00000001");  
        wait;
    end process;   
end Behavioral;
