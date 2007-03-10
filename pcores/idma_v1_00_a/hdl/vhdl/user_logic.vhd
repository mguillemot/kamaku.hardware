------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2006 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Mon May 29 16:11:16 2006 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v1_00_b;
use proc_common_v1_00_b.proc_common_pkg.all;
-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_AWIDTH                     -- User logic address bus width
--   C_DWIDTH                     -- User logic data bus width
--   C_NUM_CE                     -- User logic chip enable bus width
--   C_RDFIFO_DWIDTH              -- Data width of Read FIFO
--   C_RDFIFO_DEPTH               -- Depth of Read FIFO
--   C_WRFIFO_DWIDTH              -- Data width of Write FIFO
--   C_WRFIFO_DEPTH               -- Depth of Write FIFO
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus for user logic
--   Bus2IP_BE                    -- Bus to IP byte enables for user logic
--   Bus2IP_Burst                 -- Bus to IP burst-mode qualifier
--   Bus2IP_RdCE                  -- Bus to IP read chip enable for user logic
--   Bus2IP_WrCE                  -- Bus to IP write chip enable for user logic
--   Bus2IP_RdReq                 -- Bus to IP read request
--   Bus2IP_WrReq                 -- Bus to IP write request
--   IP2Bus_Data                  -- IP to Bus data bus for user logic
--   IP2Bus_Retry                 -- IP to Bus retry response
--   IP2Bus_Error                 -- IP to Bus error response
--   IP2Bus_ToutSup               -- IP to Bus timeout suppress
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   Bus2IP_MstError              -- Bus to IP master error
--   Bus2IP_MstLastAck            -- Bus to IP master last acknowledge
--   Bus2IP_MstRdAck              -- Bus to IP master read acknowledge
--   Bus2IP_MstWrAck              -- Bus to IP master write acknowledge
--   Bus2IP_MstRetry              -- Bus to IP master retry
--   Bus2IP_MstTimeOut            -- Bus to IP mster timeout
--   IP2Bus_Addr                  -- IP to Bus address for the master transaction
--   IP2Bus_MstBE                 -- IP to Bus byte-enables qualifiers
--   IP2Bus_MstBurst              -- IP to Bus burst qualifier
--   IP2Bus_MstBusLock            -- IP to Bus bus-lock qualifier
--   IP2Bus_MstNum                -- IP to Bus burst size indicator
--   IP2Bus_MstRdReq              -- IP to Bus master read request
--   IP2Bus_MstWrReq              -- IP to Bus master write request
--   IP2IP_Addr                   -- IP to IP local device address for the master transaction
--   IP2RFIFO_WrReq               -- IP to RFIFO : IP write request
--   IP2RFIFO_Data                -- IP to RFIFO : IP write data
--   IP2RFIFO_WrMark              -- IP to RFIFO : mark beginning of packet being written
--   IP2RFIFO_WrRelease           -- IP to RFIFO : return RFIFO to normal FIFO operation
--   IP2RFIFO_WrRestore           -- IP to RFIFO : restore the RFIFO to the last packet mark
--   RFIFO2IP_WrAck               -- RFIFO to IP : RFIFO write acknowledge
--   RFIFO2IP_AlmostFull          -- RFIFO to IP : RFIFO almost full
--   RFIFO2IP_Full                -- RFIFO to IP : RFIFO full
--   RFIFO2IP_Vacancy             -- RFIFO to IP : RFIFO vacancy
--   IP2WFIFO_RdReq               -- IP to WFIFO : IP read request
--   IP2WFIFO_RdMark              -- IP to WFIFO : mark beginning of packet being read
--   IP2WFIFO_RdRelease           -- IP to WFIFO : Return WFIFO to normal FIFO operation
--   IP2WFIFO_RdRestore           -- IP to WFIFO : restore the WFIFO to the last packet mark
--   WFIFO2IP_Data                -- WFIFO to IP : WFIFO read data
--   WFIFO2IP_RdAck               -- WFIFO to IP : WFIFO read acknowledge
--   WFIFO2IP_AlmostEmpty         -- WFIFO to IP : WFIFO almost empty
--   WFIFO2IP_Empty               -- WFIFO to IP : WFIFO empty
--   WFIFO2IP_Occupancy           -- WFIFO to IP : WFIFO occupancy
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_AWIDTH                       : integer              := 32;
    C_DWIDTH                       : integer              := 64;
    C_NUM_CE                       : integer              := 2;
    C_RDFIFO_DWIDTH                : integer              := 64;
    C_RDFIFO_DEPTH                 : integer              := 512;
    C_WRFIFO_DWIDTH                : integer              := 64;
    C_WRFIFO_DEPTH                 : integer              := 512
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    --USER ports added here
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(0 to C_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_DWIDTH/8-1);
    Bus2IP_Burst                   : in  std_logic;
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
    Bus2IP_RdReq                   : in  std_logic;
    Bus2IP_WrReq                   : in  std_logic;
    IP2Bus_Data                    : out std_logic_vector(0 to C_DWIDTH-1);
    IP2Bus_Retry                   : out std_logic;
    IP2Bus_Error                   : out std_logic;
    IP2Bus_ToutSup                 : out std_logic;
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    Bus2IP_MstError                : in  std_logic;
    Bus2IP_MstLastAck              : in  std_logic;
    Bus2IP_MstRdAck                : in  std_logic;
    Bus2IP_MstWrAck                : in  std_logic;
    Bus2IP_MstRetry                : in  std_logic;
    Bus2IP_MstTimeOut              : in  std_logic;
    IP2Bus_Addr                    : out std_logic_vector(0 to C_AWIDTH-1);
    IP2Bus_MstBE                   : out std_logic_vector(0 to C_DWIDTH/8-1);
    IP2Bus_MstBurst                : out std_logic;
    IP2Bus_MstBusLock              : out std_logic;
    IP2Bus_MstNum                  : out std_logic_vector(0 to 4);
    IP2Bus_MstRdReq                : out std_logic;
    IP2Bus_MstWrReq                : out std_logic;
    IP2IP_Addr                     : out std_logic_vector(0 to C_AWIDTH-1);
    IP2RFIFO_WrReq                 : out std_logic;
    IP2RFIFO_Data                  : out std_logic_vector(0 to C_RDFIFO_DWIDTH-1);
    IP2RFIFO_WrMark                : out std_logic;
    IP2RFIFO_WrRelease             : out std_logic;
    IP2RFIFO_WrRestore             : out std_logic;
    RFIFO2IP_WrAck                 : in  std_logic;
    RFIFO2IP_AlmostFull            : in  std_logic;
    RFIFO2IP_Full                  : in  std_logic;
    RFIFO2IP_Vacancy               : in  std_logic_vector(0 to log2(C_RDFIFO_DEPTH));
    IP2WFIFO_RdReq                 : out std_logic;
    IP2WFIFO_RdMark                : out std_logic;
    IP2WFIFO_RdRelease             : out std_logic;
    IP2WFIFO_RdRestore             : out std_logic;
    WFIFO2IP_Data                  : in  std_logic_vector(0 to C_WRFIFO_DWIDTH-1);
    WFIFO2IP_RdAck                 : in  std_logic;
    WFIFO2IP_AlmostEmpty           : in  std_logic;
    WFIFO2IP_Empty                 : in  std_logic;
    WFIFO2IP_Occupancy             : in  std_logic_vector(0 to log2(C_WRFIFO_DEPTH))
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic

  ------------------------------------------
  -- Signals for user logic master model example
  ------------------------------------------
  -- signals for write/read data
  signal mst_ip2bus_data                : std_logic_vector(0 to C_DWIDTH-1);
  signal mst_reg_read_request           : std_logic;
  signal mst_reg_write_select           : std_logic_vector(0 to 1);
  signal mst_reg_read_select            : std_logic_vector(0 to 1);
  signal mst_write_ack                  : std_logic;
  signal mst_read_ack                   : std_logic;
  -- signals for master control/status registers
  type BYTE_REG_TYPE is array(0 to 15) of std_logic_vector(0 to 7);
  signal mst_reg                        : BYTE_REG_TYPE;
  signal mst_byte_we                    : std_logic_vector(0 to 15);
  signal mst_cntl_rd_req                : std_logic;
  signal mst_cntl_wr_req                : std_logic;
  signal mst_cntl_bus_lock              : std_logic;
  signal mst_cntl_burst                 : std_logic;
  signal mst_ip2bus_addr                : std_logic_vector(0 to C_AWIDTH-1);
  signal mst_ip2ip_addr                 : std_logic_vector(0 to C_AWIDTH-1);
  signal mst_ip2bus_be                  : std_logic_vector(0 to C_DWIDTH/8-1);
  signal mst_go                         : std_logic;
  -- signals for master control state machine
  type MASTER_CNTL_SM_TYPE is (IDLE, SINGLE, BURST_16, LAST_BURST, CHK_BURST_DONE);
  signal mst_cntl_state                 : MASTER_CNTL_SM_TYPE;
  signal mst_sm_set_done                : std_logic;
  signal mst_sm_busy                    : std_logic;
  signal mst_sm_clr_go                  : std_logic;
  signal mst_sm_rd_req                  : std_logic;
  signal mst_sm_wr_req                  : std_logic;
  signal mst_sm_burst                   : std_logic;
  signal mst_sm_bus_lock                : std_logic;
  signal mst_sm_ip2bus_addr             : std_logic_vector(0 to C_AWIDTH-1);
  signal mst_sm_ip2ip_addr              : std_logic_vector(0 to C_AWIDTH-1);
  signal mst_sm_ip2bus_be               : std_logic_vector(0 to C_DWIDTH/8-1);
  signal mst_sm_ip2bus_mstnum           : std_logic_vector(0 to 4);
  signal mst_xfer_length                : integer;
  signal mst_xfer_count                 : integer;
  signal mst_ip_addr_count              : integer;
  signal mst_bus_addr_count             : integer;

  ------------------------------------------
  -- Signals for read/write fifo example
  ------------------------------------------
  type FIFO_CNTL_SM_TYPE is (IDLE, RD_REQ, WR_REQ);
  signal fifo_cntl_ns                   : FIFO_CNTL_SM_TYPE;
  signal fifo_cntl_cs                   : FIFO_CNTL_SM_TYPE;
  signal ip2wfifo_rdreq_cmb             : std_logic;
  signal ip2rfifo_wrreq_cmb             : std_logic;

begin

  --USER logic implementation added here

  ------------------------------------------
  -- Example code to demonstrate user logic master model functionality
  -- 
  -- Note:
  -- The example code presented here is to show you one way of stimulating
  -- the IPIF IP master interface under user control. It is provided for
  -- demonstration purposes only and allows the user to exercise the IPIF
  -- IP master interface during test and evaluation of the template.
  -- This user logic master model contains a 16-byte flattened register and
  -- the user is required to initialize the value to desire and then write to
  -- the model's 'Go' port to initiate the user logic master operation.
  -- 
  --    Control Register	(C_BASEADDR + OFFSET + 0x0):
  --       bit 0		- Rd		(Read Request Control)
  --       bit 1		- Wr		(Write Request Control)
  --       bit 2		- BL		(Bus Lock Control)
  --       bit 3		- Brst	(Burst Assertion Control)
  --       bit 4-7	- Spare	(Spare Control Bits)
  --    Status Register	(C_BASEADDR + OFFSET + 0x1):
  --       bit 0		- Done	(Transfer Done Status)
  --       bit 1		- Bsy		(User Logic Master is Busy)
  --       bit 2-7	- Spare	(Spare Status Bits)
  --    IP2IP Register		(C_BASEADDR + OFFSET + 0x4):
  --       bit 0-31	- IP2IP Address (This 32-bit value is used to populate the
  --                  IP2IP_Addr(0:31) address bus during a Read or Write user
  --                  logic master operation)
  --    IP2Bus Register	(C_BASEADDR + OFFSET + 0x8):
  --       bit 0-31	- IP2Bus Address (This 32-bit value is used to populate the
  --                  IP2Bus_Addr(0:31) address bus during a Read or Write user
  --                  logic master operation)
  --    Length Register	(C_BASEADDR + OFFSET + 0xC):
  --       bit 0-15	- Transfer Length (This 16-bit value is used to specify the
  --                  number of bytes (1 to 65,536) to transfer during user logic
  --                  master read or write operations)
  --    BE Register			(C_BASEADDR + OFFSET + 0xE):
  --       bit 0-7	- IP2Bus master BE (This 8-bit value is used to populate the
  --                  IP2Bus_MstBE byte enable bus during user logic master read or
  --                  write operations, only used in single data beat operation)
  --    Go Register			(C_BASEADDR + OFFSET + 0xF):
  --       bit 0-7	- Go Port (A write to this byte address initiates the user
  --                  logic master transfer, data key value of 0x0A must be used)
  -- 
  --    Note: OFFSET may be different depending on your address space configuration,
  --          by default it's either 0x0 or 0x100. Refer to IPIF address range array
  --          for actual value.
  -- 
  -- Here's an example procedure in your software application to initiate a 4-byte
  -- write operation (single data beat) of this master model:
  --   1. write 0x40 to the control register
  --   2. write the source data address (local) to the ip2ip register
  --   3. write the destination address (remote) to the ip2bus register
  --      - note: this address will be put on the target bus address line
  --   4. write 0x0004 to the length register
  --   5. write valid byte lane value to the be register
  --      - note: this value must be aligned with ip2bus address
  --   6. write 0x0a to the go register, this will start the write operation
  -- 
  ------------------------------------------
  mst_reg_read_request <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1);
  mst_reg_write_select <= Bus2IP_WrCE(0 to 1);
  mst_reg_read_select  <= Bus2IP_RdCE(0 to 1);
  mst_write_ack        <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1);
  mst_read_ack         <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1);

  -- user logic master request output assignments
  IP2Bus_Addr          <= mst_sm_ip2bus_addr;
  IP2Bus_MstBE         <= mst_sm_ip2bus_be;
  IP2Bus_MstBurst      <= mst_sm_burst;
  IP2Bus_MstBusLock    <= mst_sm_bus_lock;
  IP2Bus_MstNum        <= mst_sm_ip2bus_mstnum;
  IP2Bus_MstRdReq      <= mst_sm_rd_req;
  IP2Bus_MstWrReq      <= mst_sm_wr_req;
  IP2IP_Addr           <= mst_sm_ip2ip_addr;

  -- rip control bits from master model registers
  mst_cntl_rd_req      <= mst_reg(0)(0);
  mst_cntl_wr_req      <= mst_reg(0)(1);
  mst_cntl_bus_lock    <= mst_reg(0)(2);
  mst_cntl_burst       <= mst_reg(0)(3);
  mst_ip2ip_addr       <= mst_reg(4) & mst_reg(5) & mst_reg(6) & mst_reg(7);
  mst_ip2bus_addr      <= mst_reg(8) & mst_reg(9) & mst_reg(10) & mst_reg(11);
  mst_xfer_length      <= CONV_INTEGER(mst_reg(12) & mst_reg(13));
  mst_ip2bus_be        <= mst_reg(14);

  -- implement byte write enable for each byte slice of the master model registers
  MASTER_REG_BYTE_WR_EN : process( Bus2IP_BE, Bus2IP_WrReq, mst_reg_write_select ) is
  begin

    for byte_index in 0 to 15 loop
      mst_byte_we(byte_index) <= Bus2IP_WrReq and
                                 mst_reg_write_select(byte_index/(C_DWIDTH/8)) and
                                 Bus2IP_BE(byte_index-(byte_index/(C_DWIDTH/8))*(C_DWIDTH/8));
    end loop;

  end process MASTER_REG_BYTE_WR_EN;

  -- implement master model registers
  MASTER_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        mst_reg(0 to 14)  <= (others => "00000000");
      else
        -- control register (byte 0)
        if ( mst_byte_we(0) = '1' ) then
          mst_reg(0)      <= Bus2IP_Data(0 to 7);
        end if;
        -- status register (byte 1)
        mst_reg(1)(1)     <= mst_sm_busy;
        if ( mst_byte_we(1) = '1' ) then
          -- allows a clear of the 'Done'
          mst_reg(1)(0)  <= Bus2IP_Data((1-(1/(C_DWIDTH/8))*(C_DWIDTH/8))*8);
        else
          -- 'Done' from master control state machine
          mst_reg(1)(0)  <= mst_sm_set_done or mst_reg(1)(0);
        end if;
        -- ip2ip address register (byte 4 to 7)
        -- ip2bus address register (byte 8 to 11)
        -- length register (byte 12 to 13)
        -- be register (byte 14)
        for byte_index in 4 to 14 loop
          if ( mst_byte_we(byte_index) = '1' ) then
            mst_reg(byte_index) <= Bus2IP_Data(
                                     (byte_index-(byte_index/(C_DWIDTH/8))*(C_DWIDTH/8))*8 to
                                     (byte_index-(byte_index/(C_DWIDTH/8))*(C_DWIDTH/8))*8+7);
          end if;
        end loop;
      end if;
    end if;

  end process MASTER_REG_WRITE_PROC;

  -- implement master model write only 'go' port
  MASTER_WRITE_GO_PORT : process( Bus2IP_Clk ) is
    constant GO_DATA_KEY  : std_logic_vector(0 to 7) := X"0A";
    constant GO_BYTE_LANE : integer := 15;
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' or mst_sm_clr_go = '1' ) then
        mst_go   <= '0';
      elsif ( mst_byte_we(GO_BYTE_LANE) = '1' and
              Bus2IP_Data((GO_BYTE_LANE-(GO_BYTE_LANE/(C_DWIDTH/8))*(C_DWIDTH/8))*8 to
                          (GO_BYTE_LANE-(GO_BYTE_LANE/(C_DWIDTH/8))*(C_DWIDTH/8))*8+7) = GO_DATA_KEY ) then
        mst_go   <= '1';
      else
        null;
      end if;
    end if;

  end process MASTER_WRITE_GO_PORT;

  -- implement master model register read mux
  MASTER_REG_READ_PROC : process( mst_reg_read_select, mst_reg ) is
  begin

    case mst_reg_read_select is
      when "10" =>
        for byte_index in 0 to C_DWIDTH/8-1 loop
          mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= mst_reg(byte_index);
        end loop;
      when "01" =>
        for byte_index in 0 to C_DWIDTH/8-1 loop
          if ( byte_index = C_DWIDTH/8-1 ) then
            -- go port is not readable
            mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= (others => '0');
          else
            mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= mst_reg((C_DWIDTH/8)*1+byte_index);
          end if;
        end loop;
      when others =>
        mst_ip2bus_data <= (others => '0');
    end case;

  end process MASTER_REG_READ_PROC;

  --implement master model control state machine
  MASTER_CNTL_STATE_MACHINE : process( Bus2IP_Clk ) is
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then

        mst_cntl_state       <= IDLE;
        mst_sm_clr_go        <= '0';
        mst_sm_rd_req        <= '0';
        mst_sm_wr_req        <= '0';
        mst_sm_burst         <= '0';
        mst_sm_bus_lock      <= '0';
        mst_sm_ip2bus_addr   <= (others => '0');
        mst_sm_ip2bus_be     <= (others => '0');
        mst_sm_ip2ip_addr    <= (others => '0');
        mst_sm_ip2bus_mstnum <= "00000";
        mst_sm_set_done      <= '0';
        mst_sm_busy          <= '0';
        mst_xfer_count       <= 0;
        mst_bus_addr_count   <= 0;
        mst_ip_addr_count    <= 0;

      else

        -- default condition
        mst_sm_clr_go        <= '0';
        mst_sm_rd_req        <= '0';
        mst_sm_wr_req        <= '0';
        mst_sm_burst         <= '0';
        mst_sm_bus_lock      <= '0';
        mst_sm_ip2bus_addr   <= (others => '0');
        mst_sm_ip2bus_be     <= (others => '0');
        mst_sm_ip2ip_addr    <= (others => '0');
        mst_sm_ip2bus_mstnum <= "00000";
        mst_sm_set_done      <= '0';
        mst_sm_busy          <= '1';

        -- state transition
        case mst_cntl_state is

          when IDLE =>
            if ( mst_go = '1' and mst_xfer_length <= 8 ) then
              -- single beat transfer
              mst_cntl_state       <= SINGLE;
              mst_sm_clr_go        <= '1';
              mst_xfer_count       <= CONV_INTEGER(mst_xfer_length);
              mst_bus_addr_count   <= CONV_INTEGER(mst_ip2bus_addr);
              mst_ip_addr_count    <= CONV_INTEGER(mst_ip2ip_addr);
            elsif ( mst_go = '1' and mst_xfer_length < 128 ) then
              -- burst transfer less than 128 bytes
              mst_cntl_state       <= LAST_BURST;
              mst_sm_clr_go        <= '1';
              mst_xfer_count       <= CONV_INTEGER(mst_xfer_length);
              mst_bus_addr_count   <= CONV_INTEGER(mst_ip2bus_addr);
              mst_ip_addr_count    <= CONV_INTEGER(mst_ip2ip_addr);
            elsif ( mst_go = '1' ) then
              -- burst transfer greater than 128 bytes
              mst_cntl_state       <= BURST_16;
              mst_sm_clr_go        <= '1';
              mst_xfer_count       <= CONV_INTEGER(mst_xfer_length);
              mst_bus_addr_count   <= CONV_INTEGER(mst_ip2bus_addr);
              mst_ip_addr_count    <= CONV_INTEGER(mst_ip2ip_addr);
            else
              mst_cntl_state       <= IDLE;
              mst_sm_busy          <= '0';
            end if;

          when SINGLE =>
            if ( Bus2IP_MstLastAck = '1' ) then
              mst_cntl_state       <= IDLE;
              mst_sm_set_done      <= '1';
              mst_sm_busy          <= '0';
            else
              mst_cntl_state       <= SINGLE;
              mst_sm_rd_req        <= mst_cntl_rd_req;
              mst_sm_wr_req        <= mst_cntl_wr_req;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_sm_ip2bus_addr   <= CONV_STD_LOGIC_VECTOR(mst_bus_addr_count, C_AWIDTH);
              mst_sm_ip2bus_be     <= mst_ip2bus_be;
              mst_sm_ip2ip_addr    <= CONV_STD_LOGIC_VECTOR(mst_ip_addr_count, C_AWIDTH);
              mst_sm_ip2bus_mstnum <= "00001";
            end if;

          when BURST_16 =>
            if ( Bus2IP_MstLastAck = '1' ) then
              mst_cntl_state       <= CHK_BURST_DONE;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_xfer_count       <= mst_xfer_count-128;
              mst_bus_addr_count   <= mst_bus_addr_count+128;
              mst_ip_addr_count    <= mst_ip_addr_count+128;
            else
              mst_cntl_state       <= BURST_16;
              mst_sm_rd_req        <= mst_cntl_rd_req;
              mst_sm_wr_req        <= mst_cntl_wr_req;
              mst_sm_burst         <= mst_cntl_burst;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_sm_ip2bus_addr   <= CONV_STD_LOGIC_VECTOR(mst_bus_addr_count, C_AWIDTH);
              mst_sm_ip2bus_be     <= (others => '1');
              mst_sm_ip2ip_addr    <= CONV_STD_LOGIC_VECTOR(mst_ip_addr_count, C_AWIDTH);
              mst_sm_ip2bus_mstnum <= "10000"; -- 16 double words
            end if;

          when LAST_BURST =>
            if ( Bus2IP_MstLastAck = '1' ) then
              mst_cntl_state       <= CHK_BURST_DONE;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_xfer_count       <= mst_xfer_count-((mst_xfer_count/8)*8);
              mst_bus_addr_count   <= mst_bus_addr_count+(mst_xfer_count/8)*8;
              mst_ip_addr_count    <= mst_ip_addr_count+(mst_xfer_count/8)*8;
            else
              mst_cntl_state       <= LAST_BURST;
              mst_sm_rd_req        <= mst_cntl_rd_req;
              mst_sm_wr_req        <= mst_cntl_wr_req;
              mst_sm_burst         <= mst_cntl_burst;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_sm_ip2bus_addr   <= CONV_STD_LOGIC_VECTOR(mst_bus_addr_count, C_AWIDTH);
              mst_sm_ip2bus_be     <= (others => '1');
              mst_sm_ip2ip_addr    <= CONV_STD_LOGIC_VECTOR(mst_ip_addr_count, C_AWIDTH);
              mst_sm_ip2bus_mstnum <= CONV_STD_LOGIC_VECTOR((mst_xfer_count/8), 5);
            end if;

          when CHK_BURST_DONE =>
            if ( mst_xfer_count = 0 ) then
              -- transfer done
              mst_cntl_state       <= IDLE;
              mst_sm_set_done      <= '1';
              mst_sm_busy          <= '0';
            elsif ( mst_xfer_count <= 8 ) then
              -- need single beat transfer
              mst_cntl_state       <= SINGLE;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
            elsif ( mst_xfer_count < 128 ) then
              -- need burst transfer less than 128 bytes
              mst_cntl_state       <= LAST_BURST;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
            else
              -- need burst transfer greater than 128 bytes
              mst_cntl_state       <= BURST_16;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
            end if;

          when others =>
            mst_cntl_state    <= IDLE;
            mst_sm_busy       <= '0';

        end case;

      end if;
    end if;

  end process MASTER_CNTL_STATE_MACHINE;

  ------------------------------------------
  -- Example code to read/write fifo
  -- 
  -- Note:
  -- The example code presented here is to show you one way of operating on
  -- the read/write FIFOs provided by IPIF for you. There's a set of IPIC
  -- ports dedicated to FIFOs, beginning with RFIFO2IP_* or IP2RFIFO_* or
  -- WFIFO2IP_* or IP2WFIFO_*. Some FIFO ports are only available when
  -- certain FIFO services are present, s.t. vacancy calculation, etc.
  -- Typically you will need to have a state machine to read data from the
  -- write FIFO (in IPIF) or write data to the read FIFO (in IPIF). This code
  -- snippet simply transfer the data from the write FIFO to the read FIFO.
  ------------------------------------------
  IP2RFIFO_WrMark    <= '0';
  IP2RFIFO_WrRelease <= '0';
  IP2RFIFO_WrRestore <= '0';
  IP2WFIFO_RdMark    <= '0';
  IP2WFIFO_RdRelease <= '0';
  IP2WFIFO_RdRestore <= '0';

  FIFO_CNTL_SM_COMB : process( WFIFO2IP_empty, WFIFO2IP_RdAck, RFIFO2IP_full, RFIFO2IP_WrAck, fifo_cntl_cs ) is
  begin

    -- set defaults
    ip2wfifo_rdreq_cmb <= '0';
    ip2rfifo_wrreq_cmb <= '0';
    fifo_cntl_ns       <= fifo_cntl_cs;

    case fifo_cntl_cs is
      when IDLE =>
        -- data is available in the write fifo and there's space in the read fifo,
        -- so we can start transfering the data from write fifo to read fifo
        if ( WFIFO2IP_empty = '0' and RFIFO2IP_full = '0' ) then
          ip2wfifo_rdreq_cmb <= '1';
          fifo_cntl_ns       <= RD_REQ;
        end if;
      when RD_REQ =>
        -- data has been read from the write fifo,
        -- so we can write it to the read fifo
        if ( WFIFO2IP_RdAck = '1' ) then
          ip2rfifo_wrreq_cmb <= '1';
          fifo_cntl_ns       <= WR_REQ;
        end if;
      when WR_REQ =>
        -- data has been written to the read fifo,
        -- so data transfer is done
        if ( RFIFO2IP_WrAck = '1' ) then
          fifo_cntl_ns <= IDLE;
        end if;
      when others =>
        fifo_cntl_ns <= IDLE;
    end case;

  end process FIFO_CNTL_SM_COMB;

  FIFO_CNTL_SM_SEQ : process( Bus2IP_Clk ) is
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        IP2WFIFO_RdReq <= '0';
        IP2RFIFO_WrReq <= '0';
        fifo_cntl_cs   <= IDLE;
      else
        IP2WFIFO_RdReq <= ip2wfifo_rdreq_cmb;
        IP2RFIFO_WrReq <= ip2rfifo_wrreq_cmb;
        fifo_cntl_cs   <= fifo_cntl_ns;
      end if;
    end if;

  end process FIFO_CNTL_SM_SEQ;

  IP2RFIFO_Data <= WFIFO2IP_Data;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data        <= mst_ip2bus_data;

  IP2Bus_WrAck       <= mst_write_ack;
  IP2Bus_RdAck       <= mst_read_ack;
  IP2Bus_Error       <= '0';
  IP2Bus_Retry       <= '0';
  IP2Bus_ToutSup     <= '0';

end IMP;
