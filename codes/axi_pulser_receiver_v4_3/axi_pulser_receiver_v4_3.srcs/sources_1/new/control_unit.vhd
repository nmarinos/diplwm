library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity control_unit_s_axi is
	generic (
		-- Users to add parameters here
        CHANNELS      : integer range 0 to 32   := 8;
        PATTERN_BITS        : integer range 0 to 32   := 32;
        OFFSET_BITS         : integer range 0 to 32   := 8;
        DATA_NUM_BITS       : integer range 0 to 32   := 16;
--        PERIOD_BITS         : integer range 0 to 32   := 16;
        FREQ_DIV_BITS       : integer range 0 to 32   := 3;
        maxis_raddr_width   : integer := 32;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
        rst_out        : out std_logic;
        intr_out       : out std_logic;
	   	
	   	-------------------------------------------------------------------------------
	   	--To/From M_AXI_read_data
        rdata_addr_out : out std_logic_vector(maxis_raddr_width-1 downto 0);
        --the rdata is valid. When high a read transaction starts
        rdata_valid_out : out std_logic;
        --Data read from the memory. The offset for the fIrst channels is at the LSB of the 
        --offsets_out signal. The data is valid when Data_out_valid is high
        mask_in : in std_logic_vector(CHANNELS-1 downto 0);
        offsets_in : in std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
        data_valid_in : in std_logic;
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
        dataToAxis_busy_in    : in std_logic;
	   	-------------------------------------------------------------------------------
        -- SLAVE AXI INTERFACE
        -- Global Clock Signal
        S_AXI_ACLK	: in std_logic;
        -- Global Reset Signal. This Signal is Active LOW
        S_AXI_ARESETN	: in std_logic;
        -- Write address (issued by master, acceped by Slave)
        S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        -- Write channel Protection type. This signal indicates the
        -- privilege and security level of the transaction, and whether
        -- the transaction is a data access or an instruction access.
        S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
        -- Write address valid. This signal indicates that the master signaling
        -- valid write address and control information.
        S_AXI_AWVALID	: in std_logic;
        -- Write address ready. This signal indicates that the slave is ready
        -- to accept an address and associated control signals.
        S_AXI_AWREADY	: out std_logic;
        -- Write data (issued by master, acceped by Slave) 
        S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        -- Write strobes. This signal indicates which byte lanes hold
        -- valid data. There is one write strobe bit for each eight
        -- bits of the write data bus.    
        S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        -- Write valid. This signal indicates that valid write
        -- data and strobes are available.
        S_AXI_WVALID	: in std_logic;
        -- Write ready. This signal indicates that the slave
        -- can accept the write data.
        S_AXI_WREADY	: out std_logic;
        -- Write response. This signal indicates the status
        -- of the write transaction.
        S_AXI_BRESP	: out std_logic_vector(1 downto 0);
        -- Write response valid. This signal indicates that the channel
        -- is signaling a valid write response.
        S_AXI_BVALID	: out std_logic;
        -- Response ready. This signal indicates that the master
        -- can accept a write response.
        S_AXI_BREADY	: in std_logic;
        -- Read address (issued by master, acceped by Slave)
        S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        -- Protection type. This signal indicates the privilege
        -- and security level of the transaction, and whether the
        -- transaction is a data access or an instruction access.
        S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
        -- Read address valid. This signal indicates that the channel
        -- is signaling valid read address and control information.
        S_AXI_ARVALID	: in std_logic;
        -- Read address ready. This signal indicates that the slave is
        -- ready to accept an address and associated control signals.
        S_AXI_ARREADY	: out std_logic;
        -- Read data (issued by slave)
        S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        -- Read response. This signal indicates the status of the
        -- read transfer.
        S_AXI_RRESP	: out std_logic_vector(1 downto 0);
        -- Read valid. This signal indicates that the channel is
        -- signaling the required read data.
        S_AXI_RVALID	: out std_logic;
        -- Read ready. This signal indicates that the master can
        -- accept the read data and response information.
        S_AXI_RREADY	: in std_logic
        );
        end control_unit_s_axi;
        
        architecture arch_imp of control_unit_s_axi is
        
        	-- AXI4LITE signals
        	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        	signal axi_awready	: std_logic;
        	signal axi_wready	: std_logic;
        	signal axi_bresp	: std_logic_vector(1 downto 0);
        	signal axi_bvalid	: std_logic;
        	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        	signal axi_arready	: std_logic;
        	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        	signal axi_rresp	: std_logic_vector(1 downto 0);
        	signal axi_rvalid	: std_logic:= '0';
        
--        	-- Example-specific design signals
--        	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
--        	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
--        	-- ADDR_LSB = 2 for 32 bits (n downto 2)
--        	-- ADDR_LSB = 3 for 64 bits (n downto 3)
        	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
        	constant OPT_MEM_ADDR_BITS : integer := C_S_AXI_ADDR_WIDTH-ADDR_LSB-1;
--        	------------------------------------------------
--        	---- Signals for user logic register space example
--        	--------------------------------------------------
--        	---- Number of Slave Registers 4
        	constant c_regs_num : integer := 2 ** (C_S_AXI_ADDR_WIDTH - 2);
--        	constant c_regs_num : integer := 11;
            constant C_CONTROL_REG      : integer := 0;
                constant C_CONTROL_RUN_BIT          : integer   := 0;                     
                constant C_CONTROL_RST_BIT          : integer   := 1;                     
                constant C_TEST_PATTERN_EN_BIT      : integer   := 2;                     
                constant C_CHANNEL_PREFIX_EN_BIT    : integer   := 3;                     
--                constant C_TEST_PATTERN_EN_BIT0     : integer   := 4;                     
--                constant C_TEST_PATTERN_EN_BIT1     : integer   := 5;  
                subtype  MODE_BITS_RANGE is  natural range 5 downto 4;                   
            constant C_STATUS_REG       : integer := 1;
                constant C_SYS_READY_BIT            : integer   := 0;
                constant C_RUNNING_BIT              : integer   := 1;
                constant C_CAPTURE_BUSY_BIT         : integer   := 2;
                constant C_ALLIGN_ERR_BIT           : integer   := 3;
                constant C_SAMPLE_LOST_BIT          : integer   := 3;
                constant C_PERIOD_ERR_BIT           : integer   := 3;
           constant C_P_FREQ_DIV_REG    : integer := 2;
           constant C_P_PATT_REG        : integer := 3;
           constant C_CLAMP_PATT_REG    : integer := 4;
           constant C_N_PATT_REG        : integer := 5;
           constant C_CAPT_DELAY_REG    : integer := 6;
           constant C_CAPT_LENGTH_REG   : integer := 7;
           constant C_PULSE_PERIOD_REG  : integer := 8;
           constant C_MO_BASE_ADDR_REG  : integer := 9;
           constant C_MO_BASE_STEPS_REG : integer := 10;
        	
            type register_array is array (0 to c_regs_num-1) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);	
            signal slv_reg : register_array := (others => (others => '0'));
        --    signal slv_reg0	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        --	signal slv_reg1	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        --	signal slv_reg2	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        --	signal slv_reg3	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        	signal slv_reg_rden	: std_logic;
        	signal slv_reg_wren	: std_logic;
        	signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        	signal byte_index	: integer;
        	
        	--control unit signals
        	type state_type is (   st0_INITIALIZING, 
        	                       st1_READY, --ready to run
        	                       st2_INIT_ASCAN,
        	                       st2a_RADDR,  -- send read address to M_AXI_read_data
        	                       st2b_RDATA,   --
        	                       st3_PERIOD_WAIT, --wait for the period counter to become equal to period 
        	                       st4_PULSE,
        	                       st5_CAPT_DELAY, -- wait for the capture delay counter
        	                       st6_CAPTURE,
        	                       st6b_CAPTURE_WAIT_0,
        	                       st6b_CAPTURE_WAIT_1,
        	                       st6b_CAPTURE_WAIT_2,
        	                       st6c_CAPTURE_WAIT_END,
        	                       st7a_NEXT_PULSE_ASCAN,
        	                       st7b_SETUP_NEXT_RADDR
        	                       );
        	signal state                : state_type;
        	signal s_capture_delay      : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        	signal delay_counter        : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        	signal period_counter       : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
--        	signal s_status_reg         : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            signal s_mode               : std_logic_vector(1 downto 0);
            signal s_mask               : std_logic_vector(CHANNELS-1 downto 0);
            signal s_period             : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            signal s_offsets            : std_logic_vector(CHANNELS*OFFSET_BITS-1 downto 0);
--        	signal s_pulse_mask         : std_logic_vector(CHANNELS-1 downto 0);
        	signal s_pulse_freq_div_out : std_logic_vector(FREQ_DIV_BITS-1 downto 0);  
            signal s_p_pattern_out      : std_logic_vector(PATTERN_BITS-1 downto 0);
            signal s_clamp_pattern_out  : std_logic_vector(PATTERN_BITS-1 downto 0);
            signal s_n_pattern_out      : std_logic_vector(PATTERN_BITS-1 downto 0);
            signal s_samples_num        : std_logic_vector(DATA_NUM_BITS-1 downto 0);
            signal s_base_raddr         : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            signal s_raddr              : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            signal s_rsteps             : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            signal s_steps_counter      : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            signal s_rst_out            : std_logic;
            signal s_rst_out_d          : std_logic;
            signal s_rst_out_dd         : std_logic;
 
        
        begin
        	-- I/O Connections assignments
        
        	S_AXI_AWREADY	<= axi_awready;
        	S_AXI_WREADY	<= axi_wready;
        	S_AXI_BRESP	<= axi_bresp;
        	S_AXI_BVALID	<= axi_bvalid;
        	S_AXI_ARREADY	<= axi_arready;
        	S_AXI_RDATA	<= axi_rdata;
        	S_AXI_RRESP	<= axi_rresp;
        	S_AXI_RVALID	<= axi_rvalid;
        	-- Implement axi_awready generation
        	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
        	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
        	-- de-asserted when reset is low.
        
        	process (S_AXI_ACLK)
        	begin
        	  if rising_edge(S_AXI_ACLK) then 
        	    if S_AXI_ARESETN = '0' then
        	      axi_awready <= '0';
        	    else
        	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
        	        -- slave is ready to accept write address when
        	        -- there is a valid write address and write data
        	        -- on the write address and data bus. This design 
        	        -- expects no outstanding transactions. 
        	        axi_awready <= '1';
        	      else
        	        axi_awready <= '0';
        	      end if;
        	    end if;
        	  end if;
        	end process;
        
        	-- Implement axi_awaddr latching
        	-- This process is used to latch the address when both 
        	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 
        
        	process (S_AXI_ACLK)
        	begin
        	  if rising_edge(S_AXI_ACLK) then 
        	    if S_AXI_ARESETN = '0' then
        	      axi_awaddr <= (others => '0');
        	    else
        	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
        	        -- Write Address latching
        	        axi_awaddr <= S_AXI_AWADDR;
        	      end if;
        	    end if;
        	  end if;                   
        	end process; 
        
        	-- Implement axi_wready generation
        	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
        	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
        	-- de-asserted when reset is low. 
        
        	process (S_AXI_ACLK)
        	begin
        	  if rising_edge(S_AXI_ACLK) then 
        	    if S_AXI_ARESETN = '0' then
        	      axi_wready <= '0';
        	    else
        	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
        	          -- slave is ready to accept write data when 
        	          -- there is a valid write address and write data
        	          -- on the write address and data bus. This design 
        	          -- expects no outstanding transactions.           
        	          axi_wready <= '1';
        	      else
        	        axi_wready <= '0';
        	      end if;
        	    end if;
        	  end if;
        	end process; 
        
        	-- Implement memory mapped register select and write logic generation
        	-- The write data is accepted and written to memory mapped registers when
        	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
        	-- select byte enables of slave registers while writing.
        	-- These registers are cleared when reset (active low) is applied.
        	-- Slave register write enable is asserted when valid address and data are available
        	-- and the slave is ready to accept the write address and write data.
        	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;
        
        	process (S_AXI_ACLK)
        	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
        	begin
        	  if rising_edge(S_AXI_ACLK) then 
        	    if S_AXI_ARESETN = '0' then
        	      slv_reg <= (others => (others =>'0'));
        --	      slv_reg1 <= (others => '0');
        --	      slv_reg2 <= (others => '0');
        --	      slv_reg3 <= (others => '0');
        	    else
        	      loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        	      slv_reg <= slv_reg;
--        	      slv_reg <= s_status_reg;
        	      
                  
--                  --set the busy bit
--                  slv_reg(C_STATUS_REG)(C_CAPTURE_BUSY_BIT) <= streamer_running_in;
                  
--                  --set the data lost bit
--                  slv_reg(C_STATUS_REG)(C_SAMPLE_LOST_BIT) <= data_lost_in;
                  
--                  --set receiver alligned bit
--                  if receiver_allign_err_in = '1' then
--                      slv_reg(C_STATUS_REG)(C_ALLIGN_ERR_BIT) <= '1';
--                  else
--                      slv_reg(C_STATUS_REG)(C_ALLIGN_ERR_BIT) <= '0';
--                  end if;
        	      if (slv_reg_wren = '1') then
                        --check if we try to write in the status reg
                        if (to_integer(unsigned(loc_addr)) /= C_STATUS_REG) then
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                              if ( S_AXI_WSTRB(byte_index) = '1' ) then
                                -- Respective byte enables are asserted as per write strobes                   
                                slv_reg(to_integer(unsigned(loc_addr)))(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                              end if;
                            end loop;
                        end if;
        	      end if;

                if state = st1_READY then
                    slv_reg(C_STATUS_REG)(C_SYS_READY_BIT) <= '1';
                else
                    slv_reg(C_STATUS_REG)(C_SYS_READY_BIT) <= '0';
                end if;
                
                if state = st1_READY or state = st0_INITIALIZING then
                    slv_reg(C_STATUS_REG)(C_RUNNING_BIT) <= '0';
                else
                    slv_reg(C_STATUS_REG)(C_RUNNING_BIT) <= '1';
                end if;
                
                if streamer_running_in = '1' or dataToAxis_busy_in = '1' then
                    slv_reg(C_STATUS_REG)(C_CAPTURE_BUSY_BIT) <= '1';
                else
                    slv_reg(C_STATUS_REG)(C_CAPTURE_BUSY_BIT) <= '0';
                end if;
                    
                if receiver_allign_err_in = '1' then
                    slv_reg(C_STATUS_REG)(C_ALLIGN_ERR_BIT) <= '1';
                else
                    slv_reg(C_STATUS_REG)(C_ALLIGN_ERR_BIT) <= '0';
                end if;
                
                
                if data_lost_in = '1' then
                    slv_reg(C_STATUS_REG)(C_SAMPLE_LOST_BIT) <= '1';
                else
                    slv_reg(C_STATUS_REG)(C_SAMPLE_LOST_BIT) <= '0';
                end if;

--                slv_reg(C_STATUS_REG)(C_CAPTURE_BUSY_BIT) <= streamer_running_in or dataToAxis_busy_in;
--                slv_reg(C_STATUS_REG)(C_ALLIGN_ERR_BIT) <= receiver_allign_err_in;
--                slv_reg(C_STATUS_REG)(C_SAMPLE_LOST_BIT) <= data_lost_in;
                  
        	      --write to register logic
        	    end if;
        	  end if;                   
        	end process; 
        
        	-- Implement write response logic generation
        	-- The write response and response valid signals are asserted by the slave 
        	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
        	-- This marks the acceptance of address and indicates the status of 
        	-- write transaction.
        
        	process (S_AXI_ACLK)
        	begin
        	  if rising_edge(S_AXI_ACLK) then 
        	    if S_AXI_ARESETN = '0' then
        	      axi_bvalid  <= '0';
        	      axi_bresp   <= "00"; --need to work more on the responses
        	    else
        	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
        	        axi_bvalid <= '1';
        	        axi_bresp  <= "00"; 
        	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
        	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
        	      end if;
        	    end if;
        	  end if;                   
        	end process; 
        
        	-- Implement axi_arready generation
        	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
        	-- S_AXI_ARVALID is asserted. axi_awready is 
        	-- de-asserted when reset (active low) is asserted. 
        	-- The read address is also latched when S_AXI_ARVALID is 
        	-- asserted. axi_araddr is reset to zero on reset assertion.
        
        	process (S_AXI_ACLK)
        	begin
        	  if rising_edge(S_AXI_ACLK) then 
        	    if S_AXI_ARESETN = '0' then
        	      axi_arready <= '0';
        	      axi_araddr  <= (others => '1');
        	    else
        	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
        	        -- indicates that the slave has acceped the valid read address
        	        axi_arready <= '1';
        	        -- Read Address latching 
        	        axi_araddr  <= S_AXI_ARADDR;           
        	      else
        	        axi_arready <= '0';
        	      end if;
        	    end if;
        	  end if;                   
        	end process; 
        
        	-- Implement axi_arvalid generation
        	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
        	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
        	-- data are available on the axi_rdata bus at this instance. The 
        	-- assertion of axi_rvalid marks the validity of read data on the 
        	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
        	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
        	-- cleared to zero on reset (active low).  
        	process (S_AXI_ACLK)
        	begin
        	  if rising_edge(S_AXI_ACLK) then
        	    if S_AXI_ARESETN = '0' then
        	      axi_rvalid <= '0';
        	      axi_rresp  <= "00";
        	    else
        	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
        	        -- Valid read data is available at the read data bus
        	        axi_rvalid <= '1';
        	        axi_rresp  <= "00"; -- 'OKAY' response
        	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
        	        -- Read data is accepted by the master
        	        axi_rvalid <= '0';
        	      end if;            
        	    end if;
        	  end if;
        	end process;
        
        	-- Implement memory mapped register select and read logic generation
        	-- Slave register read enable is asserted when valid address is available
        	-- and the slave is ready to accept the read address.
        	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;
        
        	process (slv_reg, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
        	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
        	begin
        	  if S_AXI_ARESETN = '0' then
        	    reg_data_out  <= (others => '1');
        	  else
        	    -- Address decoding for reading registers
        	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
                reg_data_out <= slv_reg(to_integer(unsigned(loc_addr)));
        	  end if;
        	end process; 
        
        	-- Output register or memory read data
        	process( S_AXI_ACLK ) is
        	begin
        	  if (rising_edge (S_AXI_ACLK)) then
        	    if ( S_AXI_ARESETN = '0' ) then
        	      axi_rdata  <= (others => '0');
        	    else
        	      if (slv_reg_rden = '1') then
        	        -- When there is a valid read address (S_AXI_ARVALID) with 
        	        -- acceptance of read address by the slave (axi_arready), 
        	        -- output the read dada 
        	        -- Read address mux
        	          axi_rdata <= reg_data_out;     -- register read data
        	      end if;   
        	    end if;
        	  end if;
        	end process;
       
       
        	
        	
            -- Add user logic here
            test_patt_en_out <= slv_reg(C_CONTROL_REG)(C_TEST_PATTERN_EN_BIT);
            prefix_en_out <= slv_reg(C_CONTROL_REG)(C_CHANNEL_PREFIX_EN_BIT);
            
            rst_out <= s_rst_out or s_rst_out_d or s_rst_out_dd;
            process( S_AXI_ACLK )
            begin
                if rising_edge(S_AXI_ACLK) then
                    s_rst_out_d <= s_rst_out;
                    s_rst_out_dd <= s_rst_out_d;
                    
                    if ( S_AXI_ARESETN = '0' or slv_reg(C_CONTROL_REG)(C_CONTROL_RST_BIT) = '1') then
                        state <= st0_INITIALIZING;
                        s_rst_out <= '1';
                        intr_out <= '0';
                    else
                        s_rst_out <= '0';
                        intr_out <= '0';
                        period_counter <= std_logic_vector(unsigned(period_counter) + 1);
                        delay_counter <= (others => '0');
                        
                        pulse_out <= (others => '0');
                        pulse_freq_div_out <= (others => '0');
                        p_pattern_out <= (others => '0');
                        clamp_pattern_out <= (others => '0');
                        n_pattern_out <= (others => '0');
                        offsets_out <= (others => '0');
                        
                        start_capture_out <= '0';
                        mode_out <= (others => '0');
                        samples_num_out <= (others => '0');
                        mask_out <= (others => '0');
                        stream_offsets_out <= (others => '0');
                        
                        rdata_addr_out <= (others => '0');
                        rdata_valid_out <= '0';
--                        slv_reg(C_STATUS_REG)(C_SYS_READY_BIT) <= '0';
--                        slv_reg(C_STATUS_REG)(C_RUNNING_BIT) <= '1';
--                        slv_reg(C_STATUS_REG)(C_CAPTURE_BUSY_BIT) <= streamer_running_in or dataToAxis_busy_in;
--                        slv_reg(C_STATUS_REG)(C_ALLIGN_ERR_BIT) <= receiver_allign_err_in;
--                        slv_reg(C_STATUS_REG)(C_SAMPLE_LOST_BIT) <= data_lost_in;
                        
                        --to streamer
                        mode_out <= s_mode;
                        samples_num_out <= s_samples_num;
                        mask_out <= s_mask;
                        stream_offsets_out <= s_offsets;
                        
                        --to pulsers
                        pulse_freq_div_out <= s_pulse_freq_div_out;
                        p_pattern_out <= s_p_pattern_out;
                        clamp_pattern_out <= s_clamp_pattern_out;
                        n_pattern_out <= s_n_pattern_out;
                        offsets_out <= s_offsets;
                        
                        case (state) is
                            -- Initializing. When the module is reseted, it restarts from this state and waits for the receiver to 
                            -- allign. When the receiver is ready, the module goes to ready state.
                            when st0_INITIALIZING =>
                                period_counter <= (others => '0');
                                if receiver_ready = '1' then
                                    state <= st1_READY;
                                else
                                    state <= st0_INITIALIZING;                                
                                end if;
                            
                            ---------------------------------------------------------
                            -- In this state the core is ready to pulse.
                            when st1_READY =>
                                period_counter <= (others => '0'); --initialize the counter
                                
                                
                                --buffer the data in the slave registers. This way, writing to reg while running, will not affect the run.
                                s_mode <= slv_reg(C_CONTROL_REG)(MODE_BITS_RANGE); --store mode. This way, writing to reg while running, will not affect the run.
                                s_period <= slv_reg(C_PULSE_PERIOD_REG); --keep the pulse period
                                s_pulse_freq_div_out <= slv_reg(C_P_FREQ_DIV_REG)(FREQ_DIV_BITS-1 downto 0);
                                s_p_pattern_out <= slv_reg(C_P_PATT_REG)(PATTERN_BITS-1 downto 0);
                                s_clamp_pattern_out <= slv_reg(C_CLAMP_PATT_REG)(PATTERN_BITS-1 downto 0);
                                s_n_pattern_out <= slv_reg(C_N_PATT_REG)(PATTERN_BITS-1 downto 0);
                                s_capture_delay <= slv_reg(C_CAPT_DELAY_REG);
                                s_samples_num <= slv_reg(C_CAPT_LENGTH_REG)(DATA_NUM_BITS-1 downto 0);
                                s_base_raddr <= slv_reg(C_MO_BASE_ADDR_REG);
                                s_raddr <= slv_reg(C_MO_BASE_ADDR_REG);
                                s_rsteps <= slv_reg(C_MO_BASE_STEPS_REG);
                                s_steps_counter <= (others => '0');
                                
                                --status reg bits bit
--                                slv_reg(C_STATUS_REG)(C_SYS_READY_BIT) <= '1';
--                                slv_reg(C_STATUS_REG)(C_RUNNING_BIT) <= '0';
                                
                                
                                
                                
                                if slv_reg(C_CONTROL_REG)(C_CONTROL_RUN_BIT) = '1' then 
                                    case slv_reg(C_CONTROL_REG)(MODE_BITS_RANGE) is
                                        when "00" => state <= st2_INIT_ASCAN;
                                        when "01" => state <= st2a_RADDR;
                                        when "10" => state <= st2a_RADDR;
                                        when others => state <= st1_READY;
                                    end case;
                                    
                                else
                                    state <= st1_READY;
                                end if;

                            ---------------------------------------------------------
                            -- Initialize A scan. Create the mask ("00000001"). This mask will rotate for each pulse
                            when  st2_INIT_ASCAN =>
                                s_mask <= std_logic_vector(to_unsigned(1, CHANNELS));
                                s_offsets <= (others => '0');
                                state <= st3_PERIOD_WAIT;
                            
                            ---------------------------------------------------------
                            -- send read address to M_AXI_read_data
                            when st2a_RADDR =>
                                rdata_addr_out <= s_raddr;
                                rdata_valid_out <= '1';
                                state <= st2b_RDATA;
                            
                            ---------------------------------------------------------
                            --receive data from M_AXI_read_data
                            when st2b_RDATA =>
                                s_mask <= mask_in;
                                s_offsets <= offsets_in;
                                state <= st2b_rdata;
                                if data_valid_in = '1' then
                                    state <= st3_PERIOD_WAIT;
                                else
                                    state <= st2b_RDATA;
                                end if;
                            
                            
                            
                            
                            ---------------------------------------------------------
                            -- Wait period to finish
                            when st3_PERIOD_WAIT =>
                                if period_counter = s_period then
                                    state <= st4_PULSE;
                                else
                                    state <= st3_PERIOD_WAIT;
                                end if;
                            ---------------------------------------------------------
                            -- PULSe
                            when st4_PULSE =>
                                --reinitialize period counter
                                period_counter <= (others => '0');
                                pulse_out <= s_mask;
--                                pulse_freq_div_out <= s_pulse_freq_div_out;
--                                p_pattern_out <= s_p_pattern_out;
--                                clamp_pattern_out <= s_clamp_pattern_out;
--                                n_pattern_out <= s_n_pattern_out;
--                                offsets_out <= s_offsets;
--                                if pulsing_in = s_mask then
                                    if s_capture_delay = std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)) then
                                        state <= st6_CAPTURE;
                                    else
                                        state <= st5_CAPT_DELAY;
                                    end if;
--                                else
--                                    state <= st4_PULSE;
--                                end if;
                            ---------------------------------------------------------
                            -- Capture delay. Wait for the capture delay counter. 
                            when st5_CAPT_DELAY =>
                                delay_counter <= std_logic_vector(unsigned(delay_counter) + 1);
                                if delay_counter = s_capture_delay then
                                    state <= st6_CAPTURE;
                                else
                                    state <= st5_CAPT_DELAY;
                                end if;


                            ---------------------------------------------------------
                            -- Start capture. Send "start capture" signal and wait 
                            -- for response (streamer_running_in)
                            when st6_CAPTURE => 
                                start_capture_out <= '1';
--                                mode_out <= s_mode;
--                                samples_num_out <= s_samples_num;
--                                mask_out <= s_mask;
--                                stream_offsets_out <= s_offsets;
--                                if streamer_running_in = '1' then
                                state <= st6b_CAPTURE_WAIT_0;
                           
                            when st6b_CAPTURE_WAIT_0 => 
                                state <= st6b_CAPTURE_WAIT_1;
                           
                            when st6b_CAPTURE_WAIT_1 => 
                                state <= st6b_CAPTURE_WAIT_2;
                           
                            when st6b_CAPTURE_WAIT_2 => 
                                state <= st6c_CAPTURE_WAIT_END;
                           
                           
                            when st6c_CAPTURE_WAIT_END =>
                                    if slv_reg(C_CONTROL_REG)(C_CONTROL_RUN_BIT) = '1' then
                                        case s_mode is
                                            when "00" => state <= st7a_NEXT_PULSE_ASCAN;
                                            when "01" => state <= st7b_SETUP_NEXT_RADDR;
                                            when "10" => state <= st7b_SETUP_NEXT_RADDR;
                                            when others => state <= st1_READY;
                                        end case;
                                    else
                                        state <= st1_READY;
                                    end if;
--                                else
--                                    state <= st6_CAPTURE;
--                                end if;
                            
                            ---------------------------------------------------------
                            -- NEXT_PULSE_ASCAN. Rotate the mask one position to the left
                            -- to have it ready for the next pulse
                            when st7a_NEXT_PULSE_ASCAN =>
                                s_mask <= s_mask(CHANNELS-2 downto 0) & s_mask(CHANNELS-1);
                                intr_out <= '1';
                                state <= st3_PERIOD_WAIT;
                            
                            
                            ---------------------------------------------------------
                            -- Setup next step raddr
                            when st7b_SETUP_NEXT_RADDR => 
                                if s_steps_counter = s_rsteps then
									s_steps_counter <= (others => '0');
									s_raddr <= s_base_raddr;
								else
									s_steps_counter <= std_logic_vector(unsigned(s_steps_counter) + 1);
									s_raddr <= std_logic_vector(unsigned(s_raddr) + 4*(CHANNELS+1));
								end if;
                                state <= st2a_RADDR;
                                intr_out <= '1';
                            
                            
                            ---------------------------------------------------------
                            -- fail safe recovery to initializing
                            when others =>
                                state <= st0_INITIALIZING;
                        end case;
                    end if;
                end if; 
            end process;
        	
                   	        	
        
        end arch_imp;

	
