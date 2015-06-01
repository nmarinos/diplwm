----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.08.2014 11:00:33
-- Design Name: 
-- Module Name: tb_MAXI_rd - Behavioral
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

entity tb_MAXI_rd is
end tb_MAXI_rd;

architecture Behavioral of tb_MAXI_rd is

    constant CHANNELS : integer := 8;
    constant OFFSET_BITS : integer := 16;
    constant C_M_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"40000000";
    constant C_M_AXI_BURST_LEN	: integer	:= 16;
    constant C_M_AXI_ID_WIDTH	: integer	:= 1;
    constant C_M_AXI_ADDR_WIDTH	: integer	:= 32;
    constant C_M_AXI_DATA_WIDTH	: integer	:= 32;
    constant C_M_AXI_AWUSER_WIDTH	: integer	:= 1;
    constant C_M_AXI_ARUSER_WIDTH	: integer	:= 1;
    constant C_M_AXI_WUSER_WIDTH	: integer	:= 1;
    constant C_M_AXI_RUSER_WIDTH	: integer	:= 1;
    constant C_M_AXI_BUSER_WIDTH	: integer	:= 1;

            
                
    component M_AXI_read_data
        generic (
            CHANNELS : integer := 8;
            OFFSET_BITS : integer := 16;
            C_M_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"40000000";
            C_M_AXI_BURST_LEN	: integer	:= 16;
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
            M_AXI_ARESETN	: in std_logic := '1';
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

    signal rdata_addr_in: std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal rdata_valid_in: std_logic;
    signal mask_out: std_logic_vector(CHANNELS-1 downto 0);
    signal offsets_out: std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
    signal data_out_valid: std_logic;
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
    signal M_AXI_ARREADY: std_logic;
    signal M_AXI_RID: std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    signal M_AXI_RDATA: std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal M_AXI_RRESP: std_logic_vector(1 downto 0);
    signal M_AXI_RLAST: std_logic;
    signal M_AXI_RUSER: std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
    signal M_AXI_RVALID: std_logic;
    signal M_AXI_RREADY: std_logic ;
    
    constant M_AXI_ACLK_period : time := 10 ns;

begin

uut: M_AXI_read_data generic map ( CHANNELS                   => CHANNELS,
                                     OFFSET_BITS                => OFFSET_BITS,
                                     C_M_TARGET_SLAVE_BASE_ADDR => C_M_TARGET_SLAVE_BASE_ADDR,
                                     C_M_AXI_BURST_LEN          => C_M_AXI_BURST_LEN,
                                     C_M_AXI_ID_WIDTH           => C_M_AXI_ID_WIDTH,
                                     C_M_AXI_ADDR_WIDTH         => C_M_AXI_ADDR_WIDTH,
                                     C_M_AXI_DATA_WIDTH         => C_M_AXI_DATA_WIDTH,
                                     C_M_AXI_AWUSER_WIDTH       => C_M_AXI_AWUSER_WIDTH,
                                     C_M_AXI_ARUSER_WIDTH       => C_M_AXI_ARUSER_WIDTH,
                                     C_M_AXI_WUSER_WIDTH        => C_M_AXI_WUSER_WIDTH,
                                     C_M_AXI_RUSER_WIDTH        => C_M_AXI_RUSER_WIDTH,
                                     C_M_AXI_BUSER_WIDTH        => C_M_AXI_BUSER_WIDTH )
                          port map ( rdata_addr_in              => rdata_addr_in,
                                     rdata_valid_in             => rdata_valid_in,
                                     mask_out                   => mask_out,
                                     offsets_out                => offsets_out,
                                     data_out_valid             => data_out_valid,
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

  

clk_process: process
    begin
        M_AXI_ACLK <= '0';
        wait for M_AXI_ACLK_period/2;
        M_AXI_ACLK <= '1';
        wait for M_AXI_ACLK_period/2;
    end process;
    
    
stimuli: process
    begin
        wait for 100 ns;
        rdata_valid_in <= '1';
        rdata_addr_in <= x"00001005";
        wait for M_AXI_ACLK_period;
        rdata_valid_in <= '0';
        rdata_addr_in <= (others => '0');


        wait;      
    end process; 
    
slave_axi_read_answer: process
    begin
        wait until M_AXI_ARVALID = '1';
        wait for M_AXI_ACLK_period;
        M_AXI_ARREADY <= '1';
        wait for M_AXI_ACLK_period;
        M_AXI_ARREADY <= '0';
        M_AXI_RVALID <= '1';
        wait for M_AXI_ACLK_period*8;
        M_AXI_RLAST <= '1';
        wait for M_AXI_ACLK_period;
        M_AXI_RLAST <= '0';
        M_AXI_RVALID <= '0';
        
    end process;    
    
    
rdata_proc: process
    begin
        wait for M_AXI_ACLK_period;
        M_AXI_RDATA <= std_logic_vector(unsigned(M_AXI_RDATA) + 1);
    end process;           
end Behavioral;
