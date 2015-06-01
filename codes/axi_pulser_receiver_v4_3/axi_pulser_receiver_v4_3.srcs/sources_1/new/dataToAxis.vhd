----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.07.2014 13:28:26
-- Design Name: 
-- Module Name: dataToAxis - Behavioral
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

entity dataToAxis is
    generic (
        CHANNELS : integer := 8
--        DATA_COUNTER_BITS   : integer range 1 to 32 := 16   
        );
    Port (
        --signals coming from the stream processor
        data_in : in std_logic_vector(CHANNELS*16-1 downto 0);
        data_in_valid : in std_logic;
        data_in_last : in std_logic;
        stream_mode : in std_logic; --0: keep all channels, 1: keep 1st channels
        
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
--        M_AXIS_TSTRB	: out std_logic_vector((CHANNELS*16/8)-1 downto 0);
        -- TLAST indicates the boundary of a packet.
        M_AXIS_TLAST	: out std_logic;
        -- TREADY indicates that the slave can accept a transfer in the current cycle.
        M_AXIS_TREADY	: in std_logic;
        --tkeep signal indicates which is the last byte of the stream at the last beat of it
        M_AXIS_TKEEP    : out std_logic_vector((CHANNELS*16/8)-1 downto 0)
         );
end dataToAxis;

architecture Behavioral of dataToAxis is

    
--    signal data_num_counter     : std_logic_vector(DATA_COUNTER_BITS-1 downto 0) := (others => '0');
    signal data_lost_s          : std_logic;
    signal m_axis_tdata_s : std_logic_vector(CHANNELS*16-1 downto 0);
    signal ch_position : std_logic_vector(5 downto 0) := (others => '0');
begin

    process(M_AXIS_ACLK)
        variable v_pos : integer range 0 to 7 :=0;
    begin
        if rising_edge(M_AXIS_ACLK) then
            if M_AXIS_ARESETN = '0' then
                data_lost_s <= '0';
                M_AXIS_TVALID <= '0';
                M_AXIS_TLAST <= '0';
                m_axis_tdata_s <= (others => '0');
            
            else
                
                data_lost_s <= data_lost_s;
                M_AXIS_TVALID <= '0';
                M_AXIS_TLAST <= '0';
                m_axis_tdata_s <= (others => '0');
                M_AXIS_TKEEP <= (others => '0');
--                m_axis_tdata_s <= m_axis_tdata_s;
                
                case stream_mode is
                    when '0' =>   -- stream all channels
                        if data_in_valid = '1' then
                            M_AXIS_TVALID <= '1';
                            M_AXIS_TKEEP <= (others => '1');
                            if data_in_last = '1' then
                                M_AXIS_TLAST <= '1';
                            else
                                M_AXIS_TLAST <= '0';
                            end if;
                            m_axis_tdata_s <= data_in;
                        end if;
                    when '1' =>   --stream first channel
                        m_axis_tdata_s <= m_axis_tdata_s;
                        if data_in_valid = '1' then
                            v_pos := to_integer(unsigned(ch_position));
                            ch_position <= std_logic_vector(unsigned(ch_position) + 1);
                            m_axis_tdata_s((v_pos+1)*16-1 downto v_pos*16)   <= data_in(15 downto 0);
                            if v_pos = CHANNELS-1 then
                                M_AXIS_TVALID <= '1';
--                                M_AXIS_TDATA <= m_axis_tdata_s;
                                M_AXIS_TKEEP <= (others => '1');
                                ch_position <= (others => '0');
                            end if;
                            
                            --the last beat of the stream. TKEEP indicates which is the last valid byte of the stream 
                            if data_in_last = '1' then
                                M_AXIS_TLAST <= '1';
                                M_AXIS_TVALID <= '1';
                                M_AXIS_TKEEP <= (others => '0');
                                M_AXIS_TKEEP(v_pos*2+1 downto 0) <= (others => '1');
                                ch_position <= (others => '0');
                                
                            end if;
                            
                               
                        end if;
                    when others => 
                end case;
            
            
            end if; --reset if
        
        
        
        
        
        end if; --rising edge
    end process;
    
    data_lost <= data_lost_s;
    M_AXIS_TDATA <= m_axis_tdata_s;
    
end Behavioral;
