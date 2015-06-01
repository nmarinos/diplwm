----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2014 15:31:37
-- Design Name: 
-- Module Name: tb_dataToAxis - Behavioral
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

entity tb_dataToAxis is

end tb_dataToAxis;

architecture Behavioral of tb_dataToAxis is

constant CHANNELS : integer := 16;
constant DATA_COUNTER_BITS   : integer := 16;  


    component dataToAxis is
        generic (
            CHANNELS : integer := 8
--            DATA_COUNTER_BITS   : integer range 1 to 32 := 16   
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
    signal M_AXIS_ARESETN    : std_logic;
    signal M_AXIS_TVALID     : std_logic;
    signal M_AXIS_TDATA      : std_logic_vector (channels*16-1 downto 0);
    signal M_AXIS_TKEEP      : std_logic_vector ((channels*16/8)-1 downto 0);
    signal M_AXIS_TLAST      : std_logic;
    signal M_AXIS_TREADY     : std_logic := '1';
    
    constant M_AXIS_ACLK_period : time := 3.125 ns;
    
    signal counter            : std_logic_vector(11 downto 0) := (others => '0');
    signal data_counter            : std_logic_vector(11 downto 0) := (others => '0');
    
    

begin


clk_process: process
    begin
        M_AXIS_ACLK <= '1';
        wait for M_AXIS_ACLK_period/2;
        M_AXIS_ACLK <= '0';
        wait for M_AXIS_ACLK_period/2;
    end process;

dut: dataToAxis
    generic map(CHANNELS => CHANNELS)
    port map (data_in           => data_in,
              data_in_valid     => data_in_valid,
              data_in_last       => data_in_last,
              stream_mode       => stream_mode,
              streamer_busy_out => streamer_busy_out,
              data_lost         => data_lost,
              M_AXIS_ACLK       => M_AXIS_ACLK,
              M_AXIS_ARESETN    => M_AXIS_ARESETN,
              M_AXIS_TVALID     => M_AXIS_TVALID,
              M_AXIS_TDATA      => M_AXIS_TDATA,
--              M_AXIS_TSTRB      => M_AXIS_TSTRB,
              M_AXIS_TLAST      => M_AXIS_TLAST,
              M_AXIS_TKEEP      => M_AXIS_TKEEP,
              M_AXIS_TREADY     => M_AXIS_TREADY);
              
              
data_proc: process
    begin
        data_in_valid <= '0';
        wait for M_AXIS_ACLK_period;
        if data_counter = std_logic_vector(to_unsigned(0,12)) then
            data_in_valid <= '0';
            data_in_last <= '0';
            wait for M_AXIS_ACLK_period*10;
        end if;
        
        data_in_valid <= '1';
        if data_counter = std_logic_vector(to_unsigned(10,12)) then
            data_in_last <= '1';
            data_counter <= (others => '0');
        else
            data_in_last <= '0';
            data_counter <= std_logic_vector(unsigned(data_counter) + 1);
        end if;
        counter <= std_logic_vector(unsigned(counter) + 1);
        wait for M_AXIS_ACLK_period;
    end process;              

    
data_gen: for i in 0 to CHANNELS-1 generate
        data_in(16*(i+1)-1 downto 16*i) <= std_logic_vector(to_unsigned(i,4)) & counter;
    end generate;
    
    
--    x"8" & counter &
--               x"7" & counter &    
--               x"6" & counter &   
--               x"5" & counter &   
--               x"4" & counter &   
--               x"3" & counter &   
--               x"2" & counter &   
--               x"1" & counter; 
               
               
stimuli: process
    begin
        wait for 100 ns;
        wait for M_AXIS_ACLK_period;
--        data_in_valid <= '1';
--        wait for 9*M_AXIS_ACLK_period;
--        data_in_last <= '1';
--        wait for M_AXIS_ACLK_period;
--        data_in_last <= '0';
--        data_in_valid <= '0';
                
        
        wait;
    end process;               
end Behavioral;
