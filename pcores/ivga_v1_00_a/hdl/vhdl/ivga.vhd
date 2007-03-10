------------------------------------------------------------------------------
-- ivga.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Filename:          ivga.vhd
-- Author:            Matthieu GUILLEMOT <g@npng.org>
-- Version:           1.00.a
-- Description:       Top level design, instantiates IPIF and user logic.
-- Date:              Fri Feb 02 14:49:58 2007 (by Create and Import Peripheral Wizard)
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library ;
--use ivga_v1_00_a.all;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_BASEADDR                   -- User logic base address
--   C_HIGHADDR                   -- User logic high address
--   C_PLB_AWIDTH                 -- PLB address bus width
--   C_PLB_DWIDTH                 -- PLB address data width
--   C_PLB_NUM_MASTERS            -- Number of PLB masters
--   C_PLB_MID_WIDTH              -- log2(C_PLB_NUM_MASTERS)
--   C_FAMILY                     -- Target FPGA architecture
--
-- Definition of Ports:
--   PLB_Clk                      -- PLB Clock
--   PLB_Rst                      -- PLB Reset
--   Sl_addrAck                   -- Slave address acknowledge
--   Sl_MBusy                     -- Slave busy indicator
--   Sl_MErr                      -- Slave error indicator
--   Sl_rdBTerm                   -- Slave terminate read burst transfer
--   Sl_rdComp                    -- Slave read transfer complete indicator
--   Sl_rdDAck                    -- Slave read data acknowledge
--   Sl_rdDBus                    -- Slave read data bus
--   Sl_rdWdAddr                  -- Slave read word address
--   Sl_rearbitrate               -- Slave re-arbitrate bus indicator
--   Sl_SSize                     -- Slave data bus size
--   Sl_wait                      -- Slave wait indicator
--   Sl_wrBTerm                   -- Slave terminate write burst transfer
--   Sl_wrComp                    -- Slave write transfer complete indicator
--   Sl_wrDAck                    -- Slave write data acknowledge
--   PLB_abort                    -- PLB abort request indicator
--   PLB_ABus                     -- PLB address bus
--   PLB_BE                       -- PLB byte enables
--   PLB_busLock                  -- PLB bus lock
--   PLB_compress                 -- PLB compressed data transfer indicator
--   PLB_guarded                  -- PLB guarded transfer indicator
--   PLB_lockErr                  -- PLB lock error indicator
--   PLB_masterID                 -- PLB current master identifier
--   PLB_MSize                    -- PLB master data bus size
--   PLB_ordered                  -- PLB synchronize transfer indicator
--   PLB_PAValid                  -- PLB primary address valid indicator
--   PLB_pendPri                  -- PLB pending request priority
--   PLB_pendReq                  -- PLB pending bus request indicator
--   PLB_rdBurst                  -- PLB burst read transfer indicator
--   PLB_rdPrim                   -- PLB secondary to primary read request indicator
--   PLB_reqPri                   -- PLB current request priority
--   PLB_RNW                      -- PLB read/not write
--   PLB_SAValid                  -- PLB secondary address valid indicator
--   PLB_size                     -- PLB transfer size
--   PLB_type                     -- PLB transfer type
--   PLB_wrBurst                  -- PLB burst write transfer indicator
--   PLB_wrDBus                   -- PLB write data bus
--   PLB_wrPrim                   -- PLB secondary to primary write request indicator
--   M_abort                      -- Master abort bus request indicator
--   M_ABus                       -- Master address bus
--   M_BE                         -- Master byte enables
--   M_busLock                    -- Master buslock
--   M_compress                   -- Master compressed data transfer indicator
--   M_guarded                    -- Master guarded transfer indicator
--   M_lockErr                    -- Master lock error indicator
--   M_MSize                      -- Master data bus size
--   M_ordered                    -- Master synchronize transfer indicator
--   M_priority                   -- Master request priority
--   M_rdBurst                    -- Master burst read transfer indicator
--   M_request                    -- Master request
--   M_RNW                        -- Master read/nor write
--   M_size                       -- Master transfer size
--   M_type                       -- Master transfer type
--   M_wrBurst                    -- Master burst write transfer indicator
--   M_wrDBus                     -- Master write data bus
--   PLB_MBusy                    -- PLB master slave busy indicator
--   PLB_MErr                     -- PLB master slave error indicator
--   PLB_MWrBTerm                 -- PLB master terminate write burst indicator
--   PLB_MWrDAck                  -- PLB master write data acknowledge
--   PLB_MAddrAck                 -- PLB master address acknowledge
--   PLB_MRdBTerm                 -- PLB master terminate read burst indicator
--   PLB_MRdDAck                  -- PLB master read data acknowledge
--   PLB_MRdDBus                  -- PLB master read data bus
--   PLB_MRdWdAddr                -- PLB master read word address
--   PLB_MRearbitrate             -- PLB master bus re-arbitrate indicator
--   PLB_MSSize                   -- PLB slave data bus size
------------------------------------------------------------------------------

entity ivga is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_BASEADDR                     : std_logic_vector     := X"FFFFFFFF";
    C_HIGHADDR                     : std_logic_vector     := X"00000000";
    C_PLB_AWIDTH                   : integer              := 32;
    C_PLB_DWIDTH                   : integer              := 64;
    C_PLB_NUM_MASTERS              : integer              := 8;
    C_PLB_MID_WIDTH                : integer              := 3;
    C_FAMILY                       : string               := "virtex2p"
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
	 VGA_HSYNCH                     : out std_logic;
	 VGA_VSYNCH                     : out std_logic;
	 VGA_OUT_BLANK_Z                : out std_logic;
	 VGA_OUT_RED                    : out std_logic_vector(0 to 7);
	 VGA_OUT_GREEN                  : out std_logic_vector(0 to 7);
	 VGA_OUT_BLUE                   : out std_logic_vector(0 to 7);
	 VGA_OUT_PIXEL_CLOCK            : out std_logic;
	 VGA_INTERRUPT						  : out std_logic;
	 VGA_DEBUG						     : out std_logic_vector(127 downto 0);
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    PLB_Clk                        : in  std_logic;
    PLB_Rst                        : in  std_logic;
    Sl_addrAck                     : out std_logic;
    Sl_MBusy                       : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
    Sl_MErr                        : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
    Sl_rdBTerm                     : out std_logic;
    Sl_rdComp                      : out std_logic;
    Sl_rdDAck                      : out std_logic;
    Sl_rdDBus                      : out std_logic_vector(0 to C_PLB_DWIDTH-1);
    Sl_rdWdAddr                    : out std_logic_vector(0 to 3);
    Sl_rearbitrate                 : out std_logic;
    Sl_SSize                       : out std_logic_vector(0 to 1);
    Sl_wait                        : out std_logic;
    Sl_wrBTerm                     : out std_logic;
    Sl_wrComp                      : out std_logic;
    Sl_wrDAck                      : out std_logic;
    PLB_abort                      : in  std_logic;
    PLB_ABus                       : in  std_logic_vector(0 to C_PLB_AWIDTH-1);
    PLB_BE                         : in  std_logic_vector(0 to C_PLB_DWIDTH/8-1);
    PLB_busLock                    : in  std_logic;
    PLB_compress                   : in  std_logic;
    PLB_guarded                    : in  std_logic;
    PLB_lockErr                    : in  std_logic;
    PLB_masterID                   : in  std_logic_vector(0 to C_PLB_MID_WIDTH-1);
    PLB_MSize                      : in  std_logic_vector(0 to 1);
    PLB_ordered                    : in  std_logic;
    PLB_PAValid                    : in  std_logic;
    PLB_pendPri                    : in  std_logic_vector(0 to 1);
    PLB_pendReq                    : in  std_logic;
    PLB_rdBurst                    : in  std_logic;
    PLB_rdPrim                     : in  std_logic;
    PLB_reqPri                     : in  std_logic_vector(0 to 1);
    PLB_RNW                        : in  std_logic;
    PLB_SAValid                    : in  std_logic;
    PLB_size                       : in  std_logic_vector(0 to 3);
    PLB_type                       : in  std_logic_vector(0 to 2);
    PLB_wrBurst                    : in  std_logic;
    PLB_wrDBus                     : in  std_logic_vector(0 to C_PLB_DWIDTH-1);
    PLB_wrPrim                     : in  std_logic;
    M_abort                        : out std_logic;
    M_ABus                         : out std_logic_vector(0 to C_PLB_AWIDTH-1);
    M_BE                           : out std_logic_vector(0 to C_PLB_DWIDTH/8-1);
    M_busLock                      : out std_logic;
    M_compress                     : out std_logic;
    M_guarded                      : out std_logic;
    M_lockErr                      : out std_logic;
    M_MSize                        : out std_logic_vector(0 to 1);
    M_ordered                      : out std_logic;
    M_priority                     : out std_logic_vector(0 to 1);
    M_rdBurst                      : out std_logic;
    M_request                      : out std_logic;
    M_RNW                          : out std_logic;
    M_size                         : out std_logic_vector(0 to 3);
    M_type                         : out std_logic_vector(0 to 2);
    M_wrBurst                      : out std_logic;
    M_wrDBus                       : out std_logic_vector(0 to C_PLB_DWIDTH-1);
    PLB_MBusy                      : in  std_logic;
    PLB_MErr                       : in  std_logic;
    PLB_MWrBTerm                   : in  std_logic;
    PLB_MWrDAck                    : in  std_logic;
    PLB_MAddrAck                   : in  std_logic;
    PLB_MRdBTerm                   : in  std_logic;
    PLB_MRdDAck                    : in  std_logic;
    PLB_MRdDBus                    : in  std_logic_vector(0 to (C_PLB_DWIDTH-1));
    PLB_MRdWdAddr                  : in  std_logic_vector(0 to 3);
    PLB_MRearbitrate               : in  std_logic;
    PLB_MSSize                     : in  std_logic_vector(0 to 1)
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

end entity ivga;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of ivga is
	
	constant H320_front_porch : std_logic_vector(9 downto 0) := "0000001000"; -- 8
	constant H320_sync        : std_logic_vector(9 downto 0) := "0000011000"; -- 24
	constant H320_back_porch  : std_logic_vector(9 downto 0) := "0000100000"; -- 32
	constant H320_video       : std_logic_vector(9 downto 0) := "0101000000"; -- 320
	constant H320_total_wait  : std_logic_vector(9 downto 0) := H320_front_porch + H320_sync + H320_back_porch;
	constant H320_total       : std_logic_vector(9 downto 0) := H320_total_wait + H320_video;	
	constant H640_front_porch : std_logic_vector(9 downto 0) := "0000010000"; -- 16
	constant H640_sync        : std_logic_vector(9 downto 0) := "0001100000"; -- 96
	constant H640_back_porch  : std_logic_vector(9 downto 0) := "0000110000"; -- 48
	constant H640_video       : std_logic_vector(9 downto 0) := "1010000000"; -- 640
	constant H640_total_wait  : std_logic_vector(9 downto 0) := H640_front_porch + H640_sync + H640_back_porch;
	constant H640_total       : std_logic_vector(9 downto 0) := H640_total_wait + H640_video;	

	constant V320_front_porch : std_logic_vector(9 downto 0) := "0000000101"; -- 5
	constant V320_sync        : std_logic_vector(9 downto 0) := "0000000011"; -- 3
	constant V320_back_porch  : std_logic_vector(9 downto 0) := "0000001110"; -- 14
	constant V320_video       : std_logic_vector(9 downto 0) := "0011110000"; -- 240
	constant V320_total_wait  : std_logic_vector(9 downto 0) := V320_front_porch + V320_sync + V320_back_porch;
	constant V320_total       : std_logic_vector(9 downto 0) := V320_total_wait + V320_video;	
	constant V640_front_porch : std_logic_vector(9 downto 0) := "0000001001"; -- 9
	constant V640_sync        : std_logic_vector(9 downto 0) := "0000000010"; -- 2
	constant V640_back_porch  : std_logic_vector(9 downto 0) := "0000011101"; -- 29
	constant V640_video       : std_logic_vector(9 downto 0) := "0111100000"; -- 480
	constant V640_total_wait  : std_logic_vector(9 downto 0) := V640_front_porch + V640_sync + V640_back_porch;
	constant V640_total       : std_logic_vector(9 downto 0) := V640_total_wait + V640_video;	
	
	constant line_width : std_logic_vector(31 downto 0) := X"00000280"; -- 320 * 2
	constant screen_width : std_logic_vector(9 downto 0) := "0101000000"; -- 320
	constant screen_height : std_logic_vector(9 downto 0) := "0011110000"; -- 240

	signal ClkCpt : std_logic_vector(4 downto 0);
	
	signal HDisp : std_logic;
	signal VDisp : std_logic;
	signal Hsync : std_logic;
	signal Vsync : std_logic;
	signal PixelClock320 : std_logic;
	signal PixelClock640 : std_logic;
	signal PixelClock : std_logic;
	signal HDisp320 : std_logic;
	signal VDisp320 : std_logic;
	signal Hsync320 : std_logic;
	signal Vsync320 : std_logic;
	signal HDisp640 : std_logic;
	signal VDisp640 : std_logic;
	signal Hsync640 : std_logic;
	signal Vsync640 : std_logic;
	signal Red : std_logic_vector(7 downto 0);
	signal Green : std_logic_vector(7 downto 0);
	signal Blue : std_logic_vector(7 downto 0);
	
	signal cmptVsync : std_logic_vector(9 downto 0);
	signal cmptHsync : std_logic_vector(9 downto 0);	
	signal cmptVsync320 : std_logic_vector(9 downto 0);
	signal cmptHsync320 : std_logic_vector(9 downto 0);	
	signal cmptVsync640 : std_logic_vector(9 downto 0);
	signal cmptHsync640 : std_logic_vector(9 downto 0);	
	
	type VGA_Slave_State_Machine is (Slave_Idle,
												Slave_AddAck,
												Slave_Read,
												Slave_Read2,
												Slave_Write,
												Slave_Write2);
	
	type VGA_Master_State_Machine is (Master_Idle,
										   Master_Radd,
											Master_Read1,
											Master_Read2,
											Master_Wait);
	
	
	signal vga_slave_state_current : VGA_Slave_State_Machine := Slave_Idle;
	signal vga_slave_state_next : VGA_Slave_State_Machine := Slave_Idle;
	signal vga_master_state_current : VGA_Master_State_Machine := Master_Idle;
	signal vga_master_state_next : VGA_Master_State_Machine := Master_Idle;

	signal slave_slice : std_logic_vector(0 to 31);
	signal slave_slice_we : std_logic;
	
	signal vga_base_address : std_logic_vector(31 downto 0) := X"00000000";
	signal vga_base_address_we : std_logic;
	
	signal vga_control_reg : std_logic_vector(31 downto 0) := X"00000000";
	signal vga_control_reg_we : std_logic;

	component pixel_fifo
	port (
		din: IN std_logic_VECTOR(63 downto 0);
		rd_clk: IN std_logic;
		rd_en: IN std_logic;
		rst: IN std_logic;
		wr_clk: IN std_logic;
		wr_en: IN std_logic;
		dout: OUT std_logic_VECTOR(15 downto 0);
		empty: OUT std_logic;
		full: OUT std_logic
	);
	end component;
	
	signal pixel_fifo_re : std_logic;
	signal pixel_fifo_rst : std_logic;
	signal pixel_fifo_we : std_logic ;
	signal pixel_fifo_out : std_logic_vector(15 downto 0);
	
	signal start_read_line : std_logic; -- when to launch the pixel line read burst
	signal current_line : std_logic_vector(31 downto 0); -- address of current line in framebuffer
	signal start_read_line320 : std_logic; 
	signal current_line320 : std_logic_vector(31 downto 0); 
	signal start_read_line640 : std_logic; 
	signal current_line640 : std_logic_vector(31 downto 0); 
	
	signal pixel_count : std_logic_vector(9 downto 0);
	signal pixel_count_inc : std_logic;
	signal pixel_count_rst : std_logic;
	
	signal x320 : std_logic_vector(9 downto 0); -- for debug
	signal y320 : std_logic_vector(9 downto 0); -- for debug
	signal x640 : std_logic_vector(9 downto 0); -- for debug
	signal y640 : std_logic_vector(9 downto 0); -- for debug

	type VGA_Mode is (Mode320, Mode640);
	
	signal Mode : VGA_Mode := Mode320;
	
	signal vga_on : std_logic;
	
begin

	the_pixel_fifo : pixel_fifo
	port map (
		rst => pixel_fifo_rst,
		wr_clk => PLB_Clk,
		din => PLB_MRdDBus,
		wr_en => pixel_fifo_we,
		rd_clk => PixelClock,
		dout => pixel_fifo_out,
		rd_en => pixel_fifo_re,
		empty => open,
		full => open
	);

	Mode <= Mode320 when vga_control_reg(2) = '0' else Mode640;
	HDisp <= HDisp320 when Mode = Mode320 else HDisp640;
	VDisp <= VDisp320 when Mode = Mode320 else VDisp640;
	Hsync <= Hsync320 when Mode = Mode320 else Hsync640;
	Vsync <= Vsync320 when Mode = Mode320 else Vsync640;
	PixelClock <= PixelClock320 when Mode = Mode320 else PixelClock640;
	cmptVsync <= cmptVsync320 when Mode = Mode320 else cmptVsync640;
	cmptHsync <= cmptHsync320 when Mode = Mode320 else cmptHsync640;
	start_read_line <= start_read_line320 when Mode = Mode320 else start_read_line640;
	current_line <= current_line320 when Mode = Mode320 else current_line640;

	PixelClock640 <= ClkCpt(1);
	PixelClock320 <= ClkCpt(3);
	vga_on <= vga_control_reg(0);
	
	VGA_DEBUG(0) <= ClkCpt(0);
	VGA_DEBUG(1) <= PixelClock320;
	VGA_DEBUG(2) <= PixelClock640;
	VGA_DEBUG(3) <= PixelClock;

	INCR_CLKCPT : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			ClkCpt <= ClkCpt + 1;
		end if;
	end process INCR_CLKCPT;

	UPDATE_SLAVE_SLICE : process(PLB_Clk, slave_slice_we) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if slave_slice_we = '1' then
				slave_slice <= PLB_ABus - C_BASEADDR;
			end if;
		end if;	
	end process UPDATE_SLAVE_SLICE;

	UPDATE_VGA_CONTROL_REG : process(PLB_Clk, vga_control_reg_we) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if vga_control_reg_we = '1' then
				vga_control_reg <= PLB_wrDBus(32 to 63);
			end if;
		end if;	
	end process UPDATE_VGA_CONTROL_REG;
	
	UPDATE_VGA_BASE_ADDRESS : process(PLB_Clk, vga_base_address_we) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if vga_base_address_we = '1' then
				vga_base_address <= PLB_wrDBus(32 to 63);
			end if;
		end if;	
	end process UPDATE_VGA_BASE_ADDRESS;
		
	UPDATE_PIXEL_COUNT : process(PLB_Clk, pixel_count_inc, pixel_count_rst) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if pixel_count_rst = '1' then
				pixel_count <= (others => '0');
			elsif pixel_count_inc = '1' then
				pixel_count <= pixel_count + 4;
			end if;
		end if;	
	end process UPDATE_PIXEL_COUNT;
	
	-----------------------------------------------------------------------------
	-- VGA_CHANGE_STATE: change to the next state of the slave and master fsm
	-----------------------------------------------------------------------------
	VGA_CHANGE_STATE : process(PLB_Clk, PLB_Rst) is
	begin
		if PLB_Clk'Event and PLB_Clk = '1' then
			if PLB_Rst = '1'  then
				vga_slave_state_current <= Slave_Idle;
				vga_master_state_current <= Master_Idle;
			else
				vga_slave_state_current <= vga_slave_state_next;
				vga_master_state_current <= vga_master_state_next;    
			end if;
		end if;
	end process VGA_CHANGE_STATE;
	
	
	-----------------------------------------------------------------------------
	-- VGA_MASTER_STATE: master fsm
	-----------------------------------------------------------------------------
	VGA_MASTER_STATE : process(PLB_Clk, vga_master_state_current, current_line, start_read_line,
									   PLB_MAddrAck, PLB_MWrDAck, PLB_MRdDAck, pixel_count, Mode, cmptVsync640) is
	begin
	
		M_request <= '0';
		M_priority <= "00";
		M_busLock <= '0';
		M_RNW <= '0';
		M_BE <= "00000000";
		M_size <= "0000";
		M_type <= "000";
		M_abort <= '0';
		M_ABus <= X"00000000";
		M_compress    <= '0';  
		M_guarded     <= '0';
		M_lockErr     <= '0';
		M_MSize       <= (others => '0');
		M_ordered     <= '0';
		M_rdBurst     <= '0';
		M_wrBurst     <= '0';
		pixel_fifo_we <= '0';
		pixel_fifo_rst <= '0';
		pixel_count_rst <= '0';
		pixel_count_inc <= '0';
		
		case vga_master_state_current is
		
			when Master_Idle =>
				if start_read_line = '1' and vga_on = '1' then
					vga_master_state_next <= Master_Radd;
				else
					vga_master_state_next <= Master_Idle;
				end if;
			
			when Master_Radd =>
				M_request <= '1';
				M_priority <= "00";
				M_RNW <= '1';
				M_size <= "1011"; -- burst transfert, double words, terminated by master
				M_ABus <= current_line;
				pixel_fifo_rst <= '1';
				pixel_count_rst <= '1';
				if PLB_MAddrAck = '1' then
					vga_master_state_next <= Master_Read1;
				else
					vga_master_state_next <= Master_Radd;
				end if;
			
			when Master_Read1 =>
				M_rdBurst <= '1';
				pixel_fifo_we <= PLB_MRdDAck;
				pixel_count_inc <= PLB_MRdDAck;
				if PLB_MRdDAck = '1' then
					vga_master_state_next <= Master_Read2;
				else
					vga_master_state_next <= Master_Read1;
				end if;
			
			when Master_Read2 =>
				M_rdBurst <= '1';
				pixel_fifo_we <= PLB_MRdDAck;
				pixel_count_inc <= PLB_MRdDAck;
				if pixel_count = (H320_video - "0000000100") then 
					vga_master_state_next <= Master_Wait;
				else
					vga_master_state_next <= Master_Read2;
				end if;
			
			when Master_Wait =>
				vga_master_state_next <= Master_Idle;
				
		end case;
		
	end  process VGA_MASTER_STATE;
	
	-----------------------------------------------------------------------------
	-- DMA_SLAVE_STATE : implement the slave fsm.
	-----------------------------------------------------------------------------
	DMA_SLAVE_STATE : process(PLB_Clk, vga_slave_state_current, PLB_PAValid, PLB_ABus,
                           PLB_RNW, slave_slice, vga_control_reg, vga_base_address) is
	begin
	
		Sl_addrAck <= '0';
		Sl_rdComp <= '0';
		Sl_rdDAck <= '0';
		Sl_wrDAck <= '0';
		Sl_wrComp <= '0';
		Sl_wait <= '0';
		Sl_rdDBus <= (others => '0');
		slave_slice_we <= '0';
		vga_base_address_we <= '0';
		vga_control_reg_we <= '0';
		
		case vga_slave_state_current is
			
			when Slave_Idle =>
				if PLB_PAValid = '1' and PLB_ABus >= C_BASEADDR and PLB_ABus <= C_HIGHADDR	then
					vga_slave_state_next <= Slave_AddAck;
					Sl_wait <= '1';
					slave_slice_we <= '1';
				else
					Sl_wait <= '0';
					slave_slice_we <= '0';
					vga_slave_state_next <= Slave_Idle;
				end if;
				
			when Slave_AddAck => -- Read Address and record it into slave_slice.  
				Sl_wait <= '1';
				Sl_addrAck <= '1';
				if PLB_RNW = '1' then
					vga_slave_state_next <= Slave_Read;
				else
					vga_slave_state_next <= Slave_Write;
				end if; 
			
			when Slave_Read => -- Read data from plb
				Sl_rdComp <= '1';
				case slave_slice(28) is
					when '0' =>
						Sl_rdDBus(32 to 63) <= vga_base_address;
					when '1' =>
						Sl_rdDBus(32 to 63) <= vga_control_reg;
					when others =>
						null;
				end case;
				vga_slave_state_next <= Slave_Read2;
			
			
			when Slave_Read2 =>
				Sl_rdDAck <= '1';
				case slave_slice(28) is
					when '0' =>
						Sl_rdDBus(32 to 63) <= vga_base_address;
					when '1' =>
						Sl_rdDBus(32 to 63) <= vga_control_reg;
					when others =>
						null;
				end case;
				vga_slave_state_next <= Slave_Idle;
			
			
			when Slave_Write =>
				Sl_wrComp <= '1';
				case slave_slice(28) is
					when '0' =>
						vga_base_address_we <= '1';
					when '1' =>
						vga_control_reg_we <= '1';
					when others =>
						null;
				end case;
				vga_slave_state_next <= Slave_Write2;
			
			
			when Slave_Write2 =>
				Sl_wrDAck <= '1';
				case slave_slice(28) is
					when '0' =>
						vga_base_address_we <= '1';
					when '1' =>
						vga_control_reg_we <= '1';
					when others =>
						null;
				end case;
				vga_slave_state_next <= Slave_Idle;
		
		end case;
	end process DMA_SLAVE_STATE;
  
	OUTPUT_VGA_SIGNALS : process(vga_control_reg, Hsync, Vsync, PixelClock, Red, Green, Blue) is
	begin
		if vga_on = '1' then
			VGA_HSYNCH <= Hsync;
			VGA_VSYNCH <= Vsync;
			VGA_OUT_PIXEL_CLOCK <= PixelClock;
			VGA_OUT_BLANK_Z <= '1';
			VGA_OUT_RED <= Red;
			VGA_OUT_GREEN <= Green;
			VGA_OUT_BLUE <= Blue;
		else
			VGA_HSYNCH <= '0';
			VGA_VSYNCH <= '0';
			VGA_OUT_PIXEL_CLOCK <= '0';
			VGA_OUT_BLANK_Z <= '0';
			VGA_OUT_RED <= X"00";
			VGA_OUT_GREEN <= X"00";
			VGA_OUT_BLUE <= X"00";
		end if;
	end process OUTPUT_VGA_SIGNALS;

	OUTPUT_COLORS : process(pixel_fifo_out, HDisp, VDisp, Mode, cmptHsync640, cmptVsync640) is
	begin
		if HDisp = '1' and VDisp = '1' and (Mode = Mode320 or
				(Mode = Mode640 and cmptHsync640 < (H640_total_wait + screen_width) 
									 and cmptVsync640 < (V640_total_wait + screen_height))) then
			pixel_fifo_re <= '1';
			Red <= pixel_fifo_out(15 downto 11) & "000";
			Green <= pixel_fifo_out(10 downto 5) & "00";
			Blue <= pixel_fifo_out(4 downto 0) & "000";
		else
			pixel_fifo_re <= '0';
			Red <= X"00";
			Green <= X"00";
			Blue <= X"00";
		end if;
	end process OUTPUT_COLORS;
	
	GEN_INTERRUPT : process(PLB_Clk, cmptHsync, cmptVsync) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if cmptHsync = "0000000000" and cmptVsync = "0000000000" then
				VGA_INTERRUPT <= vga_control_reg(1);
			else
				VGA_INTERRUPT <= '0';
			end if;
		end if;
	end process GEN_INTERRUPT;
	
	SYNC_CMPT320 : process(PixelClock320, cmptHsync320, cmptVsync320) is
	begin
		if PixelClock320'event and PixelClock320 = '1' then
   	  start_read_line320 <= '0';
		  if cmptHsync320 < (H320_total - 1) then
			 cmptHsync320 <= cmptHsync320 + 1;
		  else
			 cmptHsync320 <= (others => '0');
		  end if;
	
		  if cmptHsync320 = 0 then
			 if cmptVsync320 < (V320_total - 1) then
				cmptVsync320 <=cmptVsync320 + 1;
			 else
				cmptVsync320 <= (others => '0');
			 end if;
			 if cmptVsync320 = (V320_total_wait - 2) then
				current_line320 <= vga_base_address;
				start_read_line320 <= '1';
			 elsif cmptVsync320 >= V320_total_wait then
			   current_line320 <= current_line320 + line_width;
				start_read_line320 <= '1';
			 end if;
		  end if;
		  
		end if;
	end process SYNC_CMPT320;
	
	SYNC_HSYNC320 : process(cmptHsync320) is
	begin
		if cmptHsync320 < H320_front_porch then
			Hsync320 <= '1';
			HDisp320 <= '0';
			x320 <= (others => '1');
		elsif cmptHsync320 < (H320_front_porch + H320_sync)  then
			Hsync320 <= '0';
			HDisp320 <= '0';
			x320 <= (others => '1');
		elsif cmptHsync320 < (H320_front_porch + H320_sync + H320_back_porch) then 
			Hsync320 <= '1';
			HDisp320 <= '0';
			x320 <= (others => '1');
		else 
			Hsync320 <= '1';
			HDisp320 <= '1';
			x320 <= cmptHsync320 - H320_total_wait;
		end if;
	end process SYNC_HSYNC320;
	
	SYNC_VSYNC320 : process(cmptVsync320) is
	begin
		if cmptVsync320 < V320_front_porch then
			Vsync320 <= '1';
			VDisp320 <= '0';
			y320 <= (others => '1');
		elsif cmptVsync320 < (V320_front_porch + V320_sync)  then
			Vsync320 <= '0';
			VDisp320 <= '0';
			y320 <= (others => '1');
		elsif cmptVsync320 < (V320_front_porch + V320_sync + V320_back_porch) then 
			Vsync320 <= '1';
			VDisp320 <= '0';
			y320 <= (others => '1');
		else
			Vsync320 <= '1';
			VDisp320 <= '1';
			y320 <= cmptVsync320 - V320_total_wait;
		end if;
	end process SYNC_VSYNC320;

	SYNC_CMPT640 : process(PixelClock640, cmptHsync640, cmptVsync640) is
	begin
		if PixelClock640'event and PixelClock640 = '1' then
   	  start_read_line640 <= '0';
		  if cmptHsync640 < (H640_total - 1) then
			 cmptHsync640 <= cmptHsync640 + 1;
		  else
			 cmptHsync640 <= (others => '0');
		  end if;
	
		  if cmptHsync640 = 0 then
			 if cmptVsync640 < (V640_total - 1) then
				cmptVsync640 <= cmptVsync640 + 1;
			 else
				cmptVsync640 <= (others => '0');
			 end if;
			 if cmptVsync640 = (V640_total_wait - 1) then
				current_line640 <= vga_base_address;
				start_read_line640 <= '1';
			 elsif cmptVsync640 >= V640_total_wait and cmptVsync640 < (V640_total_wait + screen_height) then
				current_line640 <= current_line640 + line_width;
				start_read_line640 <= '1';
			 end if;
		  end if;
		  
		end if;
	end process SYNC_CMPT640;
	
	SYNC_HSYNC640 : process(cmptHsync640) is
	begin
		if cmptHsync640 < H640_front_porch then
			Hsync640 <= '1';
			HDisp640 <= '0';
			x640 <= (others => '1');
		elsif cmptHsync640 < (H640_front_porch + H640_sync)  then
			Hsync640 <= '0';
			HDisp640 <= '0';
			x640 <= (others => '1');
		elsif cmptHsync640 < (H640_front_porch + H640_sync + H640_back_porch) then 
			Hsync640 <= '1';
			HDisp640 <= '0';
			x640 <= (others => '1');
		else 
			Hsync640 <= '1';
			HDisp640 <= '1';
			x640 <= cmptHsync640 - H640_total_wait;
		end if;
	end process SYNC_HSYNC640;
	
	SYNC_VSYNC640 : process(cmptVsync640) is
	begin
		if cmptVsync640 < V640_front_porch then
			Vsync640 <= '1';
			VDisp640 <= '0';
			y640 <= (others => '1');
		elsif cmptVsync640 < (V640_front_porch + V640_sync)  then
			Vsync640 <= '0';
			VDisp640 <= '0';
			y640 <= (others => '1');
		elsif cmptVsync640 < (V640_front_porch + V640_sync + V640_back_porch) then 
			Vsync640 <= '1';
			VDisp640 <= '0';
			y640 <= (others => '1');
		else
			Vsync640 <= '1';
			VDisp640 <= '1';
			y640 <= cmptVsync640 - V640_total_wait;
		end if;
	end process SYNC_VSYNC640;

end IMP;
