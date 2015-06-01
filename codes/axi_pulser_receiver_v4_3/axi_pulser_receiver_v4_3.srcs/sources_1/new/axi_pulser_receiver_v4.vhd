----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.08.2014 16:52:07
-- Design Name: 
-- Module Name: axi_pulser_receiver_v4 - Behavioral
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

entity axi_pulser_receiver_v4 is
    Generic (
        CHANNELS : integer := 8;
        PATTERN_BITS        : integer range 0 to 32   := 32;
        OFFSET_BITS         : integer range 0 to 32   := 8;
        DATA_NUM_BITS       : integer range 0 to 32   := 16;
        FREQ_DIV_BITS       : integer range 0 to 32   := 3;
        USE_FRAME: boolean := TRUE; 
        maxis_raddr_width   : integer := 32;
        -- Width of S_AXI data bus
        C_S_AXI_DATA_WIDTH	: integer	:= 32;
        -- Width of S_AXI address bus
        C_S_AXI_ADDR_WIDTH	: integer	:= 6;
        
        -- Thread ID Width
        C_M_AXI_ID_WIDTH	: integer	:= 1;
        -- Width of Address Bus
        C_M_AXI_ADDR_WIDTH	: integer	:= 32;
        -- Width of Data Bus
        C_M_AXI_DATA_WIDTH	: integer	:= 32;
        -- Width of User Write Address Bus
        C_M_AXI_AWUSER_WIDTH	: integer	:= 1;
        -- Width of User Read Address Bus
        C_M_AXI_ARUSER_WIDTH	: integer	:= 1;
        -- Width of User Write Data Bus
        C_M_AXI_WUSER_WIDTH	: integer	:= 1;
        -- Width of User Read Data Bus
        C_M_AXI_RUSER_WIDTH	: integer	:= 1;
        -- Width of User Response Bus
        C_M_AXI_BUSER_WIDTH	: integer	:= 1
        );    
    Port (
        
        intr_out       : out std_logic; -- interrupt
        
        
        -------------------------------------------------------------------------------
        --Pulser
        pulser_clk       : in std_logic;
        pulse_out_en     : out std_logic;
        pulse_out_p      : out std_logic_vector(CHANNELS-1 downto 0);
        pulse_out_clamp  : out std_logic_vector(CHANNELS-1 downto 0);
        pulse_out_n      : out std_logic_vector(CHANNELS-1 downto 0);
        
        -------------------------------------------------------------------------------
        --receiver ports
        adc_clk_in_p : in STD_LOGIC;
        adc_clk_in_n : in STD_LOGIC;
        frame_in_p   : in STD_LOGIC;
        frame_in_n   : in STD_LOGIC;
        din_p        : in std_logic_vector(CHANNELS-1 downto 0);
        din_n        : in std_logic_vector(CHANNELS-1 downto 0);
        adc_clk_out  : out std_logic; --2*data freq
        
        
        -------------------------------------------------------------------------------
        --SLAVE AXI interface
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
        
        
        -------------------------------------------------------------------------------
        --MASTER AXI STREAM interface 
        M_AXIS_ACLK	: in std_logic;
        M_AXIS_ARESETN	: in std_logic;
        M_AXIS_TVALID	: out std_logic;
        M_AXIS_TDATA	: out std_logic_vector(CHANNELS*16-1 downto 0);
        M_AXIS_TLAST	: out std_logic;
        M_AXIS_TREADY	: in std_logic;
        M_AXIS_TKEEP    : out std_logic_vector((CHANNELS*16/8)-1 downto 0);

        -------------------------------------------------------------------------------
        --MASTER AXI interface used to read mask and offsets from the frame
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
end axi_pulser_receiver_v4;

architecture Behavioral of axi_pulser_receiver_v4 is


    component synchronizer is
        generic (stages : integer := 2);
        Port ( clkA : in STD_LOGIC;
               Signal_in_clkA : in STD_LOGIC;
               clkB : in STD_LOGIC;
               Signal_out_clkB : out STD_LOGIC);
    end component;


    component control_unit_s_axi
        generic (
            CHANNELS            : integer range 0 to 32   := 8;
            PATTERN_BITS        : integer range 0 to 32   := 32;
            OFFSET_BITS         : integer range 0 to 32   := 8;
            DATA_NUM_BITS       : integer range 0 to 32   := 16;
            FREQ_DIV_BITS       : integer range 0 to 32   := 3;
            maxis_raddr_width   : integer := 32;
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 6
        );
        port (
            rst_out   : out std_logic;
            intr_out  : out std_logic;
            -------------------------------------------------------------------------------
            --To/From M_AXI_read_data
            rdata_addr_out  : out std_logic_vector(maxis_raddr_width-1 downto 0);
            rdata_valid_out : out std_logic;
            mask_in         : in std_logic_vector(CHANNELS-1 downto 0);
            offsets_in      : in std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
            data_valid_in   : in std_logic;
            -------------------------------------------------------------------------------
            --To/From pulser
            pulse_out           : out std_logic_vector(CHANNELS-1 downto 0);
            pulse_freq_div_out  : out std_logic_vector(FREQ_DIV_BITS-1 downto 0);              
            p_pattern_out       : out std_logic_vector(PATTERN_BITS-1 downto 0);
            clamp_pattern_out   : out std_logic_vector(PATTERN_BITS-1 downto 0);
            n_pattern_out       : out std_logic_vector(PATTERN_BITS-1 downto 0);
            offsets_out         : out std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
            pulsing_in          : in std_logic_vector(CHANNELS-1 downto 0);
            -------------------------------------------------------------------------------
            --To/From receiver
            test_patt_en_out        : out std_logic;
            prefix_en_out           : out std_logic;
            receiver_allign_err_in  : in std_logic;
            receiver_alligning_in   : in std_logic;
            receiver_ready          : in std_logic;
            -------------------------------------------------------------------------------
            --To/From stream_proc
            start_capture_out   : out std_logic;
            mode_out            : out std_logic_vector(1 downto 0);
            samples_num_out     : out std_logic_vector(DATA_NUM_BITS-1 downto 0);
            mask_out            : out std_logic_vector(CHANNELS-1 downto 0);
            stream_offsets_out  : out std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
            streamer_running_in : in std_logic;
            -------------------------------------------------------------------------------
            --TO/from dataToAxis
            data_lost_in        : in std_logic;
            dataToAxis_busy_in  : in std_logic;
            -------------------------------------------------------------------------------
            --SLAVE AXI interface
            S_AXI_ACLK	    : in std_logic;
            S_AXI_ARESETN	: in std_logic;
            S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
            S_AXI_AWVALID	: in std_logic;
            S_AXI_AWREADY	: out std_logic;
            S_AXI_WDATA	    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB	    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            S_AXI_WVALID	: in std_logic;
            S_AXI_WREADY	: out std_logic;
            S_AXI_BRESP	    : out std_logic_vector(1 downto 0);
            S_AXI_BVALID	: out std_logic;
            S_AXI_BREADY	: in std_logic;
            S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
            S_AXI_ARVALID	: in std_logic;
            S_AXI_ARREADY	: out std_logic;
            S_AXI_RDATA	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_RRESP	    : out std_logic_vector(1 downto 0);
            S_AXI_RVALID	: out std_logic;
            S_AXI_RREADY	: in std_logic
        );
    end component;


    component pulser_1ch_v2 is
        generic (
            PATTERN_BITS      : integer range 0 to 32 := 32;
            OFFSET_BITS       : integer range 0 to 32 := 8;
            FREQ_DIV_BITS     : integer range 0 to 32 := 8
            );
        Port (
            pulser_clk       : in std_logic;
            freq_divider     : in std_logic_vector(FREQ_DIV_BITS-1 downto 0);
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
    end component;



    component receiver is
        generic (
            CHANNELS : integer := 8
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

    component receiver_frame is
        generic (
            CHANNELS : integer := 8
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

    component dataToAxis
        generic (
            CHANNELS : integer := 8
        );
        Port (
            data_in : in std_logic_vector(CHANNELS*16-1 downto 0);
            data_in_valid : in std_logic;
            data_in_last : in std_logic;
            stream_mode : in std_logic;
            streamer_busy_out   : out std_logic;
            data_lost           : out std_logic;
            M_AXIS_ACLK	: in std_logic;
            M_AXIS_ARESETN	: in std_logic;
            M_AXIS_TVALID	: out std_logic;
            M_AXIS_TDATA	: out std_logic_vector(CHANNELS*16-1 downto 0);
            M_AXIS_TLAST	: out std_logic;
            M_AXIS_TREADY	: in std_logic;
            M_AXIS_TKEEP    : out std_logic_vector((CHANNELS*16/8)-1 downto 0)
        );
    end component;

    component M_AXI_read_data
        generic (
            CHANNELS : integer := 8;
            OFFSET_BITS : integer := 16;
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
            rdata_addr_in : in std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
            rdata_valid_in : in std_logic;
            mask_out : out std_logic_vector(CHANNELS-1 downto 0);
            offsets_out : out std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
            data_out_valid : out std_logic;
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

    ----------------------------------------------------------------------------------
    -- WIRES
    signal w_rst_from_cotrol : std_logic;
    signal w_raddr_control2rdata : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal w_rd_valid_control2rdata : std_logic;
    signal w_mask_rdata2control : std_logic_vector(CHANNELS-1 downto 0);
    signal w_offsets_rdata2control : std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
    signal w_data_valid_rdata2control : std_logic;
    signal w_pulse_control2pulsers : std_logic_vector(CHANNELS-1 downto 0);
    signal w_pulse_control2pulsers_sync : std_logic_vector(CHANNELS-1 downto 0);
    signal w_freq_div_control2pulsers : std_logic_vector(FREQ_DIV_BITS-1 downto 0);
    signal w_p_pat_control2pulsers : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal w_clamp_pat_control2pulsers : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal w_n_pat_control2pulsers : std_logic_vector(PATTERN_BITS-1 downto 0);
    signal w_offsets_control2pulsers : std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
    signal w_pulsing_pulsers2control : std_logic_vector(CHANNELS-1 downto 0);
    signal w_test_pat_control2receiver : std_logic;
    signal w_prefix_control2receiver : std_logic;
    signal w_align_err_receiver2control : std_logic;
    signal w_aligning_receiver2control : std_logic;
    signal w_ready_receiver2control : std_logic;
    signal w_start_control2strmproc : std_logic;
    signal w_start_control2strmproc_synchr : std_logic;
    signal w_mode_control2strmproc : std_logic_vector(1 downto 0);
    signal w_samplesnum_control2strmproc : std_logic_vector(DATA_NUM_BITS-1 downto 0);
    signal w_mask_control2strmproc : std_logic_vector(CHANNELS-1 downto 0);
    signal w_offsets_control2strmproc : std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
    signal w_running_streamer2control : std_logic;
    signal w_data_lost_axis2control : std_logic;
    signal w_busy_axis2control : std_logic;
    signal w_data_receiver2strmproc : std_logic_vector(CHANNELS*16-1 downto 0);
    signal w_adc_sel_receiver2strmproc : std_logic;
    signal w_data_strmproc2axis : std_logic_vector(CHANNELS*16-1 downto 0);
    signal w_datavalid_strmproc2axis : std_logic;
    signal w_datalast_strmproc2axis : std_logic;
    signal w_strmmode_strmproc2axis : std_logic;
    signal w_adc_clk_from_receiver : std_logic;
    signal s_pulse_out_en : std_logic_vector(CHANNELS-1 downto 0);


    ---------------------------------------------------------------------------------
begin


i_control_unit: control_unit_s_axi generic map ( CHANNELS             => CHANNELS,
                                    PATTERN_BITS           => PATTERN_BITS,
                                    OFFSET_BITS            => OFFSET_BITS,
                                    DATA_NUM_BITS          => DATA_NUM_BITS,
                                    FREQ_DIV_BITS          => FREQ_DIV_BITS,
                                    maxis_raddr_width      => maxis_raddr_width,
                                    C_S_AXI_DATA_WIDTH     => C_S_AXI_DATA_WIDTH,
                                    C_S_AXI_ADDR_WIDTH     => C_S_AXI_ADDR_WIDTH )
                         port map ( rst_out                => w_rst_from_cotrol,
                                    intr_out               => intr_out,
                                    rdata_addr_out         => w_raddr_control2rdata,
                                    rdata_valid_out        => w_rd_valid_control2rdata,
                                    mask_in                => w_mask_rdata2control,
                                    offsets_in             => w_offsets_rdata2control,
                                    data_valid_in          => w_data_valid_rdata2control,
                                    pulse_out              => w_pulse_control2pulsers,
                                    pulse_freq_div_out     => w_freq_div_control2pulsers,
                                    p_pattern_out          => w_p_pat_control2pulsers,
                                    clamp_pattern_out      => w_clamp_pat_control2pulsers,
                                    n_pattern_out          => w_n_pat_control2pulsers,
                                    offsets_out            => w_offsets_control2pulsers,
                                    pulsing_in             => w_pulsing_pulsers2control,
                                    test_patt_en_out       => w_test_pat_control2receiver,
                                    prefix_en_out          => w_prefix_control2receiver,
                                    receiver_allign_err_in => w_align_err_receiver2control,
                                    receiver_alligning_in  => w_aligning_receiver2control,
                                    receiver_ready         => w_ready_receiver2control,
                                    start_capture_out      => w_start_control2strmproc,
                                    mode_out               => w_mode_control2strmproc,
                                    samples_num_out        => w_samplesnum_control2strmproc,
                                    mask_out               => w_mask_control2strmproc,
                                    stream_offsets_out     => w_offsets_control2strmproc,
                                    streamer_running_in    => w_running_streamer2control,
                                    data_lost_in           => w_data_lost_axis2control,
                                    dataToAxis_busy_in     => w_busy_axis2control,
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

gen_pulsers: for i in 0 to CHANNELS-1 generate

pulsers_synchr: synchronizer 
            generic map(stages => 2)
            Port map(   clkA => S_AXI_ACLK,
                        Signal_in_clkA => w_pulse_control2pulsers(i),
                        clkB => pulser_clk,
                        Signal_out_clkB => w_pulse_control2pulsers_sync(i) );

i_puls_1ch: pulser_1ch_v2 generic map ( PATTERN_BITS     => PATTERN_BITS,
                                    OFFSET_BITS      => OFFSET_BITS,
                                    FREQ_DIV_BITS    => FREQ_DIV_BITS )
                         port map ( pulser_clk       => pulser_clk,
                                    freq_divider     => w_freq_div_control2pulsers,
                                    pulse_sync_in    => w_pulse_control2pulsers_sync(i),
                                    p_pattern_in     => w_p_pat_control2pulsers,
                                    clamp_pattern_in => w_clamp_pat_control2pulsers,
                                    n_pattern_in     => w_n_pat_control2pulsers,
                                    offset_in        => w_offsets_control2pulsers(OFFSET_BITS*(i+1)-1 downto OFFSET_BITS*i),
                                    pulse_out_en     => s_pulse_out_en(i),
                                    pulse_out_p      => pulse_out_p(i),
                                    pulse_out_clamp  => pulse_out_clamp(i),
                                    pulse_out_n      => pulse_out_n(i),
                                    pulsing_out      => w_pulsing_pulsers2control(i) );
                                    
                                       
end generate;

pulse_out_en <= s_pulse_out_en(0) or
                s_pulse_out_en(1) or
                s_pulse_out_en(2) or
                s_pulse_out_en(3) or
                s_pulse_out_en(4) or
                s_pulse_out_en(5) or
                s_pulse_out_en(6) or
                s_pulse_out_en(7);

choose_receiver: if use_frame = FALSE generate
i_receiver: receiver generic map ( CHANNELS         => CHANNELS)
--                              USE_FRAME        => FALSE )
                   port map ( adc_clk_in_p     => adc_clk_in_p,
                              adc_clk_in_n     => adc_clk_in_n,
                              frame_in_p       => frame_in_p,
                              frame_in_n       => frame_in_n,
                              din_p            => din_p,
                              din_n            => din_n,
                              rst_in           => w_rst_from_cotrol,
                              test_patt_en     => w_test_pat_control2receiver,
                              prefix_en_in     => w_prefix_control2receiver,
                              dout             => w_data_receiver2strmproc,
                              adc_clk_out      => w_adc_clk_from_receiver,
                              adc_sel_out      => w_adc_sel_receiver2strmproc,
                              allign_error_out => w_align_err_receiver2control,
                              alligning_out    => w_aligning_receiver2control,
                              receiver_ready   => w_ready_receiver2control );
end generate;

choose_receiver_frame: if use_frame = TRUE generate
i_receiver_frame: receiver_frame generic map ( CHANNELS         => CHANNELS)
--                              USE_FRAME        => FALSE )
                   port map ( adc_clk_in_p     => adc_clk_in_p,
                              adc_clk_in_n     => adc_clk_in_n,
                              frame_in_p       => frame_in_p,
                              frame_in_n       => frame_in_n,
                              din_p            => din_p,
                              din_n            => din_n,
                              rst_in           => w_rst_from_cotrol,
                              test_patt_en     => w_test_pat_control2receiver,
                              prefix_en_in     => w_prefix_control2receiver,
                              dout             => w_data_receiver2strmproc,
                              adc_clk_out      => w_adc_clk_from_receiver,
                              adc_sel_out      => w_adc_sel_receiver2strmproc,
                              allign_error_out => w_align_err_receiver2control,
                              alligning_out    => w_aligning_receiver2control,
                              receiver_ready   => w_ready_receiver2control );
end generate;
                              
    adc_clk_out <= w_adc_clk_from_receiver;
    
streamer_synchr: synchronizer 
            generic map(stages => 2)
            Port map(   clkA => S_AXI_ACLK,
                        Signal_in_clkA => w_start_control2strmproc,
                        clkB => w_adc_clk_from_receiver,
                        Signal_out_clkB => w_start_control2strmproc_synchr );

i_stream_proc: stream_proc generic map ( CHANNELS          => CHANNELS,
                                 OFFSET_BITS       => OFFSET_BITS,
                                 SAMPLES_NUM_BITS  => DATA_NUM_BITS )
                      port map ( adc_clk_in        => w_adc_clk_from_receiver,
                                 adc_data_in       => w_data_receiver2strmproc,
                                 adc_data_valid_in => w_adc_sel_receiver2strmproc,
                                 start_in          => w_start_control2strmproc_synchr,
                                 running_out       => w_running_streamer2control,
                                 mode_in           => w_mode_control2strmproc,
                                 samples_num       => w_samplesnum_control2strmproc,
                                 mask_in           => w_mask_control2strmproc,
                                 offsets_in        => w_offsets_control2strmproc,
                                 rst_in            => w_rst_from_cotrol,
                                 data_out          => w_data_strmproc2axis,
                                 data_out_valid    => w_datavalid_strmproc2axis,
                                 data_out_last     => w_datalast_strmproc2axis,
                                 stream_mode_out   => w_strmmode_strmproc2axis );
                                 

i_dataToAxis: dataToAxis generic map ( CHANNELS   => CHANNELS )
                     port map ( data_in           => w_data_strmproc2axis,
                                data_in_valid     => w_datavalid_strmproc2axis,
                                data_in_last      => w_datalast_strmproc2axis,
                                stream_mode       => w_strmmode_strmproc2axis,
                                streamer_busy_out => w_busy_axis2control,
                                data_lost         => w_data_lost_axis2control,
                                M_AXIS_ACLK       => M_AXIS_ACLK,
                                M_AXIS_ARESETN    => M_AXIS_ARESETN,
                                M_AXIS_TVALID     => M_AXIS_TVALID,
                                M_AXIS_TDATA      => M_AXIS_TDATA,
                                M_AXIS_TLAST      => M_AXIS_TLAST,
                                M_AXIS_TREADY     => M_AXIS_TREADY,
                                M_AXIS_TKEEP      => M_AXIS_TKEEP );
                                 


i_MAXI_read_data: M_AXI_read_data generic map ( CHANNELS                   => CHANNELS,
                                     OFFSET_BITS                => OFFSET_BITS,
                                     C_M_AXI_ID_WIDTH           => C_M_AXI_ID_WIDTH,
                                     C_M_AXI_ADDR_WIDTH         => C_M_AXI_ADDR_WIDTH,
                                     C_M_AXI_DATA_WIDTH         => C_M_AXI_DATA_WIDTH,
                                     C_M_AXI_AWUSER_WIDTH       => C_M_AXI_AWUSER_WIDTH,
                                     C_M_AXI_ARUSER_WIDTH       => C_M_AXI_ARUSER_WIDTH,
                                     C_M_AXI_WUSER_WIDTH        => C_M_AXI_WUSER_WIDTH,
                                     C_M_AXI_RUSER_WIDTH        => C_M_AXI_RUSER_WIDTH,
                                     C_M_AXI_BUSER_WIDTH        => C_M_AXI_BUSER_WIDTH )
                          port map ( rdata_addr_in              => w_raddr_control2rdata,
                                     rdata_valid_in             => w_rd_valid_control2rdata,
                                     mask_out                   => w_mask_rdata2control,
                                     offsets_out                => w_offsets_rdata2control,
                                     data_out_valid             => w_data_valid_rdata2control,
                                     M_AXI_ACLK                 => M_AXI_ACLK,
                                     M_AXI_ARESETN              => M_AXI_ARESETN,
                                     M_AXI_AWID                 => M_AXI_AWID,
                                     M_AXI_AWADDR               => M_AXI_AWADDR,
                                     M_AXI_AWLEN                => M_AXI_AWLEN,
                                     M_AXI_AWSIZE               => M_AXI_AWSIZE,
                                     M_AXI_AWBURST              => M_AXI_AWBURST,
                                     M_AXI_AWLOCK               => M_AXI_AWLOCK,
                                     M_AXI_AWCACHE              => M_AXI_AWCACHE,
                                     M_AXI_AWPROT               => M_AXI_AWPROT,
                                     M_AXI_AWQOS                => M_AXI_AWQOS,
                                     M_AXI_AWUSER               => M_AXI_AWUSER,
                                     M_AXI_AWVALID              => M_AXI_AWVALID,
                                     M_AXI_AWREADY              => M_AXI_AWREADY,
                                     M_AXI_WDATA                => M_AXI_WDATA,
                                     M_AXI_WSTRB                => M_AXI_WSTRB,
                                     M_AXI_WLAST                => M_AXI_WLAST,
                                     M_AXI_WUSER                => M_AXI_WUSER,
                                     M_AXI_WVALID               => M_AXI_WVALID,
                                     M_AXI_WREADY               => M_AXI_WREADY,
                                     M_AXI_BID                  => M_AXI_BID,
                                     M_AXI_BRESP                => M_AXI_BRESP,
                                     M_AXI_BUSER                => M_AXI_BUSER,
                                     M_AXI_BVALID               => M_AXI_BVALID,
                                     M_AXI_BREADY               => M_AXI_BREADY,
                                     M_AXI_ARID                 => M_AXI_ARID,
                                     M_AXI_ARADDR               => M_AXI_ARADDR,
                                     M_AXI_ARLEN                => M_AXI_ARLEN,
                                     M_AXI_ARSIZE               => M_AXI_ARSIZE,
                                     M_AXI_ARBURST              => M_AXI_ARBURST,
                                     M_AXI_ARLOCK               => M_AXI_ARLOCK,
                                     M_AXI_ARCACHE              => M_AXI_ARCACHE,
                                     M_AXI_ARPROT               => M_AXI_ARPROT,
                                     M_AXI_ARQOS                => M_AXI_ARQOS,
                                     M_AXI_ARUSER               => M_AXI_ARUSER,
                                     M_AXI_ARVALID              => M_AXI_ARVALID,
                                     M_AXI_ARREADY              => M_AXI_ARREADY,
                                     M_AXI_RID                  => M_AXI_RID,
                                     M_AXI_RDATA                => M_AXI_RDATA,
                                     M_AXI_RRESP                => M_AXI_RRESP,
                                     M_AXI_RLAST                => M_AXI_RLAST,
                                     M_AXI_RUSER                => M_AXI_RUSER,
                                     M_AXI_RVALID               => M_AXI_RVALID,
                                     M_AXI_RREADY               => M_AXI_RREADY );

end Behavioral;
