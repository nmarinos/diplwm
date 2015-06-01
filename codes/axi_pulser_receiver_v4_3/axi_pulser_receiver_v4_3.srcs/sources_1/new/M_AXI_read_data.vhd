----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.08.2014 10:16:05
-- Design Name: 
-- Module Name: M_AXI_read_data - Behavioral
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

entity M_AXI_read_data is
    generic (
		-- Users to add parameters here
        CHANNELS : integer := 8;
        OFFSET_BITS : integer := 16;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

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
        --the base addr of the mask/offsets buffer
        rdata_addr_in : in std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        --the rdata is valid. When high a read transaction starts
        rdata_valid_in : in std_logic;
        
        --Data read from the memory. The offset for the forst channels is at the LSB of the 
        --offsets_out signal. The data is valid when Data_out_valid is high
        mask_out : out std_logic_vector(CHANNELS-1 downto 0);
        offsets_out : out std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
        data_out_valid : out std_logic;
        
    
        ----------------------
        --MASTER AXI INTERFACE
        ----------------------
        M_AXI_ACLK	: in std_logic;
        -- Global Reset Singal. This Signal is Active Low
        M_AXI_ARESETN	: in std_logic;
        -- Master Interface Write Address ID
        M_AXI_AWID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
        -- Master Interface Write Address
        M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        -- Burst length. The burst length gives the exact number of transfers in a burst
        M_AXI_AWLEN	: out std_logic_vector(7 downto 0);
        -- Burst size. This signal indicates the size of each transfer in the burst
        M_AXI_AWSIZE	: out std_logic_vector(2 downto 0);
        -- Burst type. The burst type and the size information, 
        -- determine how the address for each transfer within the burst is calculated.
        M_AXI_AWBURST	: out std_logic_vector(1 downto 0);
        -- Lock type. Provides additional information about the
        -- atomic characteristics of the transfer.
        M_AXI_AWLOCK	: out std_logic;
        -- Memory type. This signal indicates how transactions
        -- are required to progress through a system.
        M_AXI_AWCACHE	: out std_logic_vector(3 downto 0);
        -- Protection type. This signal indicates the privilege
        -- and security level of the transaction, and whether
        -- the transaction is a data access or an instruction access.
        M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
        -- Quality of Service, QoS identifier sent for each write transaction.
        M_AXI_AWQOS	: out std_logic_vector(3 downto 0);
        -- Optional User-defined signal in the write address channel.
        M_AXI_AWUSER	: out std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
        -- Write address valid. This signal indicates that
        -- the channel is signaling valid write address and control information.
        M_AXI_AWVALID	: out std_logic;
        -- Write address ready. This signal indicates that
        -- the slave is ready to accept an address and associated control signals
        M_AXI_AWREADY	: in std_logic;
        -- Master Interface Write Data.
        M_AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        -- Write strobes. This signal indicates which byte
        -- lanes hold valid data. There is one write strobe
        -- bit for each eight bits of the write data bus.
        M_AXI_WSTRB	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
        -- Write last. This signal indicates the last transfer in a write burst.
        M_AXI_WLAST	: out std_logic;
        -- Optional User-defined signal in the write data channel.
        M_AXI_WUSER	: out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
        -- Write valid. This signal indicates that valid write
        -- data and strobes are available
        M_AXI_WVALID	: out std_logic;
        -- Write ready. This signal indicates that the slave
        -- can accept the write data.
        M_AXI_WREADY	: in std_logic;
        -- Master Interface Write Response.
        M_AXI_BID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
        -- Write response. This signal indicates the status of the write transaction.
        M_AXI_BRESP	: in std_logic_vector(1 downto 0);
        -- Optional User-defined signal in the write response channel
        M_AXI_BUSER	: in std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
        -- Write response valid. This signal indicates that the
        -- channel is signaling a valid write response.
        M_AXI_BVALID	: in std_logic;
        -- Response ready. This signal indicates that the master
        -- can accept a write response.
        M_AXI_BREADY	: out std_logic;
        -- Master Interface Read Address.
        M_AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
        -- Read address. This signal indicates the initial
        -- address of a read burst transaction.
        M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        -- Burst length. The burst length gives the exact number of transfers in a burst
        M_AXI_ARLEN	: out std_logic_vector(7 downto 0);
        -- Burst size. This signal indicates the size of each transfer in the burst
        M_AXI_ARSIZE	: out std_logic_vector(2 downto 0);
        -- Burst type. The burst type and the size information, 
        -- determine how the address for each transfer within the burst is calculated.
        M_AXI_ARBURST	: out std_logic_vector(1 downto 0);
        -- Lock type. Provides additional information about the
        -- atomic characteristics of the transfer.
        M_AXI_ARLOCK	: out std_logic;
        -- Memory type. This signal indicates how transactions
        -- are required to progress through a system.
        M_AXI_ARCACHE	: out std_logic_vector(3 downto 0);
        -- Protection type. This signal indicates the privilege
        -- and security level of the transaction, and whether
        -- the transaction is a data access or an instruction access.
        M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
        -- Quality of Service, QoS identifier sent for each read transaction
        M_AXI_ARQOS	: out std_logic_vector(3 downto 0);
        -- Optional User-defined signal in the read address channel.
        M_AXI_ARUSER	: out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
        -- Write address valid. This signal indicates that
        -- the channel is signaling valid read address and control information
        M_AXI_ARVALID	: out std_logic;
        -- Read address ready. This signal indicates that
        -- the slave is ready to accept an address and associated control signals
        M_AXI_ARREADY	: in std_logic;
        -- Read ID tag. This signal is the identification tag
        -- for the read data group of signals generated by the slave.
        M_AXI_RID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
        -- Master Read Data
        M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        -- Read response. This signal indicates the status of the read transfer
        M_AXI_RRESP	: in std_logic_vector(1 downto 0);
        -- Read last. This signal indicates the last transfer in a read burst
        M_AXI_RLAST	: in std_logic;
        -- Optional User-defined signal in the read address channel.
        M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
        -- Read valid. This signal indicates that the channel
        -- is signaling the required read data.
        M_AXI_RVALID	: in std_logic;
        -- Read ready. This signal indicates that the master can
        -- accept the read data and response information.
        M_AXI_RREADY	: out std_logic
    		
    		 );
end M_AXI_read_data;



architecture Behavioral of M_AXI_read_data is
	
	signal axi_arvalid	: std_logic;
	signal axi_rready	: std_logic;
	signal data_reg : std_logic_vector(C_M_AXI_DATA_WIDTH*CHANNELS-1 downto 0);

begin



    --------------------------------
    -- MASTER AXI INTERFACE
    --------------------------------        		
    -- This interface implements only the READ channel. The read is always in burst mode and the burst 
    -- length is CHANNELS + 1. The first read data is the mask and the rest are the offset data. The read data width is 
    -- 32 bits. The module assumes that the control unit will not initiate any more transactions before the end of the 
    --last transaction, so no checks are implemented.  
    ------------------------------
    --Read Address Channel
    ------------------------------
    
    --The Read Address Channel (AW) provides only a burst read transaction
    --of CHANNELS+1 length
      
    process(M_AXI_ACLK)										  
    begin                                                              
        if (rising_edge (M_AXI_ACLK)) then                               
            if (M_AXI_ARESETN = '0') then                                 
                axi_arvalid <= '0'; 
                M_AXI_ARLEN <= (others => '0');                                         
            else                                                           
                if (rdata_valid_in = '1') then
                    axi_arvalid <= '1';   --set arvalid to high  
                    M_AXI_ARADDR <= rdata_addr_in;
                    --set burst length to channels+1
                    M_AXI_ARLEN <=  std_logic_vector(to_unsigned(CHANNELS, 8));                              
                elsif (M_AXI_ARREADY = '1' and axi_arvalid = '1') then       
                    axi_arvalid <= '0';  --deassert axi_arvalid after M_AXI_ARREADY goes high    
                    M_AXI_ARADDR <= (others => '0');                                  
                    M_AXI_ARLEN <= (others => '0');                                         
                end if;                                                      
            end if;                                                        
        end if;                                                          
    end process;                                                       
                                         
     M_AXI_ARVALID <= axi_arvalid;     
    
    ------------------------------
    --Read Data Channel
    ------------------------------
    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then                               
            if (M_AXI_ARESETN = '0') then  
                axi_rready <= '0';
            else
                if (rdata_valid_in = '1') then
                    axi_rready <= '1';
                elsif (axi_rready = '1' and M_AXI_RLAST = '1' and M_AXI_RVALID = '1') then
                    axi_rready <= '0';
                end if;
            end if;
        end if;
    end process;
    M_AXI_RREADY <= axi_rready;
    
    process(M_AXI_ACLK)
    begin
        if (rising_edge (M_AXI_ACLK)) then                               
            if (M_AXI_ARESETN = '0') then  
                data_out_valid <= '0';
                mask_out <= (others => '0');
                offsets_out <= (others => '0');
            else
                data_out_valid <= '0';
                mask_out <= (others => '0');
                offsets_out <= (others => '0');
                
                if (M_AXI_RVALID = '1' and axi_rready = '1') then
                    -- when we have valid read data, shift the data_reg and store the new data to the MSB position
                    data_reg <= M_AXI_RDATA & data_reg(C_M_AXI_DATA_WIDTH*CHANNELS-1 downto C_M_AXI_DATA_WIDTH);
                    if (M_AXI_RLAST = '1') then
                        -- output the data
                        data_out_valid <= '1';
                        mask_out <= data_reg(CHANNELS-1 downto 0);
                        for i in 0 to CHANNELS-2 loop
                            offsets_out(OFFSET_BITS*(i+1)-1 downto OFFSET_BITS*i) <= data_reg(((i+1)*C_M_AXI_DATA_WIDTH)+OFFSET_BITS-1 downto (i+1)*C_M_AXI_DATA_WIDTH);
                         end loop;
                         offsets_out(OFFSET_BITS*CHANNELS-1 downto OFFSET_BITS*(CHANNELS-1)) <= M_AXI_RDATA(OFFSET_BITS-1 downto 0);
                    end if;
                end if;
            end if;
        end if;
       end process;
	   
	   M_AXI_ARBURST <= "01";
	   M_AXI_ARSIZE <= "010";
end Behavioral;
