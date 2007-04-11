------------------------------------------------------------------------------
-- ivga.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Filename:          ivga.vhd
-- Author:            Matthieu GUILLEMOT <g@npng.org>
-- Version:           1.00.a
-- Description:       Top level design
-- Date:              2006/03/26
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity ivga is
  generic
  (
    C_BASEADDR                     : std_logic_vector     := X"FFFFFFFF";
    C_HIGHADDR                     : std_logic_vector     := X"00000000";
    C_PLB_AWIDTH                   : integer              := 32;
    C_PLB_DWIDTH                   : integer              := 64;
    C_PLB_NUM_MASTERS              : integer              := 8;
    C_PLB_MID_WIDTH                : integer              := 3;
    C_FAMILY                       : string               := "virtex2p"
	);
  port
  (
    -- User ports
	 VGA_HSYNCH                     : out std_logic;
	 VGA_VSYNCH                     : out std_logic;
	 VGA_OUT_BLANK_Z                : out std_logic;
	 VGA_OUT_RED                    : out std_logic_vector(0 to 7);
	 VGA_OUT_GREEN                  : out std_logic_vector(0 to 7);
	 VGA_OUT_BLUE                   : out std_logic_vector(0 to 7);
	 VGA_OUT_PIXEL_CLOCK            : out std_logic;
	 VGA_INTERRUPT						  : out std_logic;
	 VGA_DEBUG						     : out std_logic_vector(127 downto 0);

    -- PBL bus protocol ports
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
  );

end entity ivga;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of ivga is

	-- constants
	constant H_front_porch : std_logic_vector(9 downto 0) := "0000001000"; -- 8
	constant H_sync        : std_logic_vector(9 downto 0) := "0000011000"; -- 24
	constant H_back_porch  : std_logic_vector(9 downto 0) := "0000100000"; -- 32
	constant H_video       : std_logic_vector(9 downto 0) := "0101000000"; -- 320
	constant V_front_porch : std_logic_vector(9 downto 0) := "0000000101"; -- 5
	constant V_sync        : std_logic_vector(9 downto 0) := "0000000011"; -- 3
	constant V_back_porch  : std_logic_vector(9 downto 0) := "0000001110"; -- 14
	constant V_video       : std_logic_vector(9 downto 0) := "0011110000"; -- 240
	constant Clock_Divider : integer := 3; -- divided by 16
	
--	constant H_front_porch    : std_logic_vector(9 downto 0) := "0000010000"; -- 16
--	constant H_sync           : std_logic_vector(9 downto 0) := "0001100000"; -- 96
--	constant H_back_porch     : std_logic_vector(9 downto 0) := "0000110000"; -- 48
--	constant H_video          : std_logic_vector(9 downto 0) := "1010000000"; -- 640
--	constant V_front_porch    : std_logic_vector(9 downto 0) := "0000001001"; -- 9
--	constant V_sync           : std_logic_vector(9 downto 0) := "0000000010"; -- 2
--	constant V_back_porch     : std_logic_vector(9 downto 0) := "0000011101"; -- 29
--	constant V_video          : std_logic_vector(9 downto 0) := "0111100000"; -- 480
--	constant Clock_Divider    : integer := 1; -- divided by 4

	constant H_total_wait     : std_logic_vector(9 downto 0) := H_front_porch + H_sync + H_back_porch;
	constant H_total          : std_logic_vector(9 downto 0) := H_total_wait + H_video;	
	constant V_total_wait     : std_logic_vector(9 downto 0) := V_front_porch + V_sync + V_back_porch;
	constant V_total          : std_logic_vector(9 downto 0) := V_total_wait + V_video;	
	constant line_width       : std_logic_vector(31 downto 0):= X"00000280"; -- 320 * 2 (in bytes)
	constant screen_width     : std_logic_vector(9 downto 0) := "0101000000"; -- 320 (in pixels)
	constant screen_height    : std_logic_vector(9 downto 0) := "0011110000"; -- 240 (in pixels)
	constant max_op_length    : std_logic_vector(6 downto 0) := "1001111"; -- 79 (in double-words)
	constant transparent_color: std_logic_vector(15 downto 0) := "1111100000011111"; -- Pink

	-- PixelClock generation
	signal ClkCpt             : std_logic_vector(4 downto 0) := "00000";
	signal PixelClock         : std_logic := '0';

	-- output signals
	signal HDisp              : std_logic := '0';
	signal VDisp              : std_logic := '0';
	signal Hsync              : std_logic := '0';
	signal Vsync              : std_logic := '0';
	signal Red                : std_logic_vector(7 downto 0) := "00000000";
	signal Green              : std_logic_vector(7 downto 0) := "00000000";
	signal Blue               : std_logic_vector(7 downto 0) := "00000000";
	
	-- synchronization generation
	signal cmptVsync          : std_logic_vector(9 downto 0) := "0000000000";
	signal cmptHsync          : std_logic_vector(9 downto 0) := "0000000000";	
	
	-- master & slave state machines
	type VGA_Slave_State_Machine is (Slave_Idle,
												Slave_AddAck,
												Slave_Read,
												Slave_Read2,
												Slave_Write,
												Slave_Write2);
	
	type VGA_Master_State_Machine is (Master_Idle,
												 Master_ReadBg_Addr,
												 Master_ReadBg_Data,
											    Master_Ended,
												 Master_Compute_StartInstance,
												 Master_Compute_CheckInstance,
												 Master_Compute_ProcessInstance);
	
	signal vga_slave_state_current  : VGA_Slave_State_Machine  := Slave_Idle;
	signal vga_slave_state_next     : VGA_Slave_State_Machine  := Slave_Idle;
	signal vga_master_state_current : VGA_Master_State_Machine := Master_Idle;
	signal vga_master_state_next    : VGA_Master_State_Machine := Master_Idle;

	-- slave local address
	signal slave_slice         : std_logic_vector(0 to 31) := X"00000000";
	signal slave_slice_we      : std_logic := '0';
	
	-- control registers
	signal vga_base_address         : std_logic_vector(31 downto 0) := X"00000000";
	signal vga_base_address_we      : std_logic := '0';
	signal vga_control_reg          : std_logic_vector(31 downto 0) := X"00000000";
	signal vga_control_reg_we       : std_logic := '0';
	signal instances_switch         : std_logic := '0';
	signal vga_last_instance_reg1   : std_logic_vector(31 downto 0) := X"00000000";
	signal vga_last_instance_reg2   : std_logic_vector(31 downto 0) := X"00000000";
	signal vga_last_instance_reg_we : std_logic := '0';
	
	-- control signals
	signal start_read_line     : std_logic := '0'; -- when to launch the pixel line read burst
	signal vga_on              : std_logic := '0';
	
	-- background reading module signals
	signal op_length           : std_logic_vector(6 downto 0) := "0000000";
	signal op_length_dec       : std_logic := '0';
	signal op_length_rst       : std_logic := '0';
	signal current_line        : std_logic_vector(31 downto 0) := X"00000000"; -- address of current line in framebuffer
	
	-- line calculation module signals
	signal computing                : std_logic := '0';
	signal instances_enabled        : std_logic := '0';
	signal computing_line           : unsigned(9 downto 0) := "0000000000";
	signal last_instance            : std_logic_vector(11 downto 0) := "000000000000";
	signal current_instance         : std_logic_vector(31 downto 0) := X"00000000";
	signal current_instance_x       : signed(9 downto 0) := "0000000000";
	signal current_instance_y       : signed(9 downto 0) := "0000000000";
	signal current_instance_sprite  : std_logic_vector(5 downto 0) := "000000";
	signal instance_number          : unsigned(11 downto 0) := "000000000000";
	signal instance_number_rst      : std_logic := '0';
	signal instance_number_inc      : std_logic := '0';
	signal sprite_x                 : unsigned(3 downto 0) := "0000";
	signal sprite_y                 : unsigned(3 downto 0) := "0000";

	-- components
	component supervga_line_ram
		port (
			clka: IN std_logic;
			dina: IN std_logic_VECTOR(15 downto 0);
			addra: IN std_logic_VECTOR(6 downto 0);
			wea: IN std_logic_VECTOR(0 downto 0);
			douta: OUT std_logic_VECTOR(15 downto 0)
		);
	end component;
	
	component supervga_instance_ram
		port (
			clka: IN std_logic;
			dina: IN std_logic_VECTOR(31 downto 0);
			addra: IN std_logic_VECTOR(11 downto 0);
			wea: IN std_logic_VECTOR(0 downto 0);
			douta: OUT std_logic_VECTOR(31 downto 0)
		);
	end component;
	
	component supervga_sprite_ram
		port (
			clka: IN std_logic;
			dina: IN std_logic_VECTOR(15 downto 0);
			addra: IN std_logic_VECTOR(13 downto 0);
			wea: IN std_logic_VECTOR(0 downto 0);
			douta: OUT std_logic_VECTOR(15 downto 0)
		);
	end component;
	
	-- line_ram I/O and address registers
	--
	-- Note: which line_ram is which doesn't really matter...
	--       (indeed, when line_ram_switch = '0', line_ram_1 is written and line_ram_2 is read)
	signal line_ram_addr1           : std_logic_vector(6 downto 0)  := "0000000";
	signal line_ram_addr2           : std_logic_vector(6 downto 0)  := "0000000";
	signal line_ram_waddr           : std_logic_vector(8 downto 0)  := "000000000";
	signal line_ram_waddr_latched   : std_logic_vector(8 downto 0)  := "000000000";
	signal line_ram_waddr_last      : std_logic_vector(8 downto 0)  := "000000000";
	signal line_ram_waddr_set_beginning : std_logic := '0';
	signal line_ram_waddr_rst       : std_logic := '0';
	signal line_ram_waddr_next_pixel: std_logic := '0';
	signal line_ram_waddr_next_dw   : std_logic := '0';
	signal line_ram_raddr           : std_logic_vector(8 downto 0)  := "000000000";
	signal line_ram_raddr_rst       : std_logic := '0';
	signal line_ram_raddr_inc       : std_logic := '0';
	signal line_ram_we_bg           : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_we_pixel        : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_we1A            : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_we1B            : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_we1C            : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_we1D            : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_we2A            : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_we2B            : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_we2C            : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_we2D            : std_logic_vector(0 downto 0)  := "0";
	signal line_ram_out1A           : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_out1B           : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_out1C           : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_out1D           : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_out2A           : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_out2B           : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_out2C           : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_out2D           : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_out             : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_switch          : std_logic := '0';
	signal line_ram_process         : std_logic := '0';
	signal line_ram_din             : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_dinA            : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_dinB            : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_dinC            : std_logic_vector(15 downto 0) := X"0000";
	signal line_ram_dinD            : std_logic_vector(15 downto 0) := X"0000";
	
	-- instances_ram I/O and address registers
	--
	-- Note: locked = "hidden" instance_ram used by the internal VGA circuit
	--       open = "visible" instance_ram accessed by the processor
	--
	-- Note: when instance_ram_switch = '0', instance_ram_1 is locked and instance_ram_2 is open
	signal instance_ram_locked_addr : std_logic_vector(11 downto 0) := "000000000000";
	signal instance_ram_open_addr   : std_logic_vector(11 downto 0) := "000000000000";
	signal instance_ram_addr1       : std_logic_vector(11 downto 0) := "000000000000";
	signal instance_ram_addr2       : std_logic_vector(11 downto 0) := "000000000000";
	signal instance_ram_locked_we   : std_logic_vector(0 downto 0) := "0";
	signal instance_ram_open_we     : std_logic_vector(0 downto 0) := "0";
	signal instance_ram_we1         : std_logic_vector(0 downto 0) := "0";
	signal instance_ram_we2         : std_logic_vector(0 downto 0) := "0";
	signal instance_ram_locked_out  : std_logic_vector(31 downto 0) := X"00000000";
	signal instance_ram_open_out    : std_logic_vector(31 downto 0) := X"00000000";
	signal instance_ram_out1        : std_logic_vector(31 downto 0) := X"00000000";
	signal instance_ram_out2        : std_logic_vector(31 downto 0) := X"00000000";
	signal instance_ram_switch      : std_logic := '0';
	
	-- sprite_ram I/O and adress registers
	signal sprite_ram_addr          : std_logic_vector(13 downto 0) := "00000000000000";
	signal sprite_ram_raddr         : std_logic_vector(13 downto 0) := "00000000000000";
	signal sprite_ram_waddr         : std_logic_vector(13 downto 0) := "00000000000000";
	signal sprite_ram_we            : std_logic_vector(0 downto 0) := "0";
	signal sprite_ram_out           : std_logic_vector(15 downto 0) := X"0000";

	-- debug
	signal debug_master_state       : std_logic_vector(3 downto 0) := "0000";
	signal debug_slave_state        : std_logic_vector(3 downto 0) := "0000";	
	
begin

	VGA_DEBUG(3 downto 0) <= debug_master_state;
	VGA_DEBUG(4) <= start_read_line;
	VGA_DEBUG(5) <= instance_ram_switch;
	VGA_DEBUG(17 downto 6) <= last_instance;
	VGA_DEBUG(63 downto 32) <= vga_last_instance_reg1;
	VGA_DEBUG(95 downto 64) <= vga_last_instance_reg2;
	
--	VGA_DEBUG(5) <= line_ram_process;
--	VGA_DEBUG(6) <= instances_enabled;
--	VGA_DEBUG(16 downto 8) <= std_logic_vector(computing_line(8 downto 0));
--	VGA_DEBUG(33 downto 24) <= std_logic_vector(current_instance_x);
--	VGA_DEBUG(43 downto 34) <= std_logic_vector(current_instance_y);
--	VGA_DEBUG(55 downto 44) <= std_logic_vector(instance_number);
--	--VGA_DEBUG(62 downto 54) <= line_ram_waddr;
--	VGA_DEBUG(71 downto 63) <= line_ram_waddr;
--	VGA_DEBUG(75 downto 72) <= std_logic_vector(sprite_x);	
--	VGA_DEBUG(79 downto 76) <= std_logic_vector(sprite_y);
--	VGA_DEBUG(95 downto 80) <= sprite_ram_out;
--	VGA_DEBUG(107 downto 96) <= last_instance;
--	VGA_DEBUG(112 downto 112) <= line_ram_we_pixel;
--	VGA_DEBUG(119 downto 113) <= line_ram_addr1;
--
	LINE_RAM_INSTANCE_PART_1A : supervga_line_ram port map (
		clka => PLB_Clk,
		dina => line_ram_dinA,
		addra => line_ram_addr1,
		wea => line_ram_we1A,
		douta => line_ram_out1A
	);

	LINE_RAM_INSTANCE_PART_1B : supervga_line_ram port map (
		clka => PLB_Clk,
		dina => line_ram_dinB,
		addra => line_ram_addr1,
		wea => line_ram_we1B,
		douta => line_ram_out1B
	);

	LINE_RAM_INSTANCE_PART_1C : supervga_line_ram port map (
		clka => PLB_Clk,
		dina => line_ram_dinC,
		addra => line_ram_addr1,
		wea => line_ram_we1C,
		douta => line_ram_out1C
	);

	LINE_RAM_INSTANCE_PART_1D : supervga_line_ram port map (
		clka => PLB_Clk,
		dina => line_ram_dinD,
		addra => line_ram_addr1,
		wea => line_ram_we1D,
		douta => line_ram_out1D
	);
	
	LINE_RAM_INSTANCE_PART_2A : supervga_line_ram port map (
		clka => PLB_Clk,
		dina => line_ram_dinA,
		addra => line_ram_addr2,
		wea => line_ram_we2A,
		douta => line_ram_out2A
	);

	LINE_RAM_INSTANCE_PART_2B : supervga_line_ram port map (
		clka => PLB_Clk,
		dina => line_ram_dinB,
		addra => line_ram_addr2,
		wea => line_ram_we2B,
		douta => line_ram_out2B
	);

	LINE_RAM_INSTANCE_PART_2C : supervga_line_ram port map (
		clka => PLB_Clk,
		dina => line_ram_dinC,
		addra => line_ram_addr2,
		wea => line_ram_we2C,
		douta => line_ram_out2C
	);

	LINE_RAM_INSTANCE_PART_2D : supervga_line_ram port map (
		clka => PLB_Clk,
		dina => line_ram_dinD,
		addra => line_ram_addr2,
		wea => line_ram_we2D,
		douta => line_ram_out2D
	);
	
	INSTANCE_RAM_INSTANCE1 : supervga_instance_ram port map (
		clka => PLB_Clk,
		dina => PLB_wrDBus(32 to 63),
		addra => instance_ram_addr1,
		wea => instance_ram_we1,
		douta => instance_ram_out1
	);

	INSTANCE_RAM_INSTANCE2 : supervga_instance_ram port map (
		clka => PLB_Clk,
		dina => PLB_wrDBus(32 to 63),
		addra => instance_ram_addr2,
		wea => instance_ram_we2,
		douta => instance_ram_out2
	);

	SPRITE_RAM_INSTANCE : supervga_sprite_ram port map (
		clka => PLB_Clk,
		dina => PLB_wrDBus(48 to 63),
		addra => sprite_ram_addr,
		wea => sprite_ram_we,
		douta => sprite_ram_out
	);
			
	PixelClock <= ClkCpt(Clock_Divider);
	line_ram_raddr_rst <= start_read_line;
	vga_on <= vga_control_reg(0);
	instances_enabled <= vga_control_reg(3);
	line_ram_switch <= cmptVsync(0);
	instance_ram_locked_we <= "0";
	current_instance_x <= signed(current_instance(19 downto 10));
	current_instance_y <= signed(current_instance(9 downto 0));
	current_instance_sprite <= current_instance(25 downto 20);
	instance_ram_locked_addr <= std_logic_vector(instance_number);
	current_instance <= instance_ram_locked_out;
	instance_ram_open_addr <= slave_slice(18 to 29);
	line_ram_din <= sprite_ram_out;
	sprite_ram_waddr <= slave_slice(16 to 29);
	sprite_ram_raddr <= current_instance_sprite & std_logic_vector(sprite_x) & std_logic_vector(sprite_y);
	
	-- combinatorial
	GENERATE_LAST_INSTANCE : process(vga_last_instance_reg1, vga_last_instance_reg2, instance_ram_switch) is
	begin
		if instance_ram_switch = '0' then
			last_instance <= vga_last_instance_reg1(11 downto 0);
		else
			last_instance <= vga_last_instance_reg2(11 downto 0);
		end if;
	end process GENERATE_LAST_INSTANCE;
	
	-- sequential
	LATCH_LAST_INSTANCE_REG : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if vga_last_instance_reg_we = '1' then
				if instance_ram_switch = '0' then
					vga_last_instance_reg2 <= PLB_wrDBus(32 to 63);
				else
					vga_last_instance_reg1 <= PLB_wrDBus(32 to 63);				
				end if;
			end if;
		end if;
	end process LATCH_LAST_INSTANCE_REG;
	
	-- sequential
	LATCH_LINE_RAM_WADDR : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			line_ram_waddr_latched <= line_ram_waddr;
		end if;
	end process LATCH_LINE_RAM_WADDR;
	
	-- sequential
	GENERATE_SPRITE_X : process(PLB_Clk) is
		variable minus : signed(9 downto 0);
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if line_ram_waddr_set_beginning = '1' then
				if current_instance_x < 0 then
					minus := -current_instance_x;
					sprite_x <= unsigned(minus(3 downto 0));
				else
					sprite_x <= "0000";
				end if;
			elsif line_ram_waddr_next_pixel = '1' then
				sprite_x <= sprite_x + 1;
			end if;
		end if;
	end process GENERATE_SPRITE_X;
	
	-- combinatorial
	GENERATE_SPRITE_Y : process(computing_line, current_instance_y) is
		variable diff : signed(9 downto 0);
	begin
		diff := signed(computing_line) - current_instance_y;
		sprite_y <= unsigned(diff(3 downto 0));
	end process GENERATE_SPRITE_Y;

	-- combinatorial
	GENERATE_INSTANCE_RAM_ADDR : process(instance_ram_switch, instance_ram_locked_addr, instance_ram_open_addr) is
	begin
		if instance_ram_switch = '0' then
			instance_ram_addr1 <= instance_ram_locked_addr;
			instance_ram_addr2 <= instance_ram_open_addr;
		else
			instance_ram_addr1 <= instance_ram_open_addr;
			instance_ram_addr2 <= instance_ram_locked_addr;
		end if;
	end process GENERATE_INSTANCE_RAM_ADDR;
	
	-- combinatorial
	GENERATE_INSTANCE_RAM_WE : process(instance_ram_switch, instance_ram_locked_we, instance_ram_open_we) is
	begin
		if instance_ram_switch = '0' then
			instance_ram_we1 <= instance_ram_locked_we;
			instance_ram_we2 <= instance_ram_open_we;
		else
			instance_ram_we1 <= instance_ram_open_we;
			instance_ram_we2 <= instance_ram_locked_we;
		end if;
	end process GENERATE_INSTANCE_RAM_WE;
	
	-- combinatorial
	GENERATE_INSTANCE_RAM_OUT : process(instance_ram_switch, instance_ram_out1, instance_ram_out2) is
	begin
		if instance_ram_switch = '0' then		
			instance_ram_locked_out <= instance_ram_out1;
			instance_ram_open_out <= instance_ram_out2;
		else
			instance_ram_locked_out <= instance_ram_out2;
			instance_ram_open_out <= instance_ram_out1;
		end if;
	end process GENERATE_INSTANCE_RAM_OUT;
	
	-- combinatorial
	GENERATE_LINE_RAM_ADDR : process(line_ram_switch, computing, line_ram_waddr, line_ram_waddr_latched, line_ram_raddr) is
	begin
		if line_ram_switch = '0' then
			line_ram_addr2 <= line_ram_raddr(8 downto 2);
			if computing = '1' then
				line_ram_addr1 <= line_ram_waddr_latched(8 downto 2);
			else
				line_ram_addr1 <= line_ram_waddr(8 downto 2);
			end if;
		else
			line_ram_addr1 <= line_ram_raddr(8 downto 2);
			if computing = '1' then
				line_ram_addr2 <= line_ram_waddr_latched(8 downto 2);
			else
				line_ram_addr2 <= line_ram_waddr(8 downto 2);
			end if;
		end if;
	end process GENERATE_LINE_RAM_ADDR;
	
	-- combinatorial
	GENERATE_LINE_RAM_WE_1_2 : process(line_ram_switch, line_ram_we_bg, line_ram_we_pixel, line_ram_waddr_latched, line_ram_din) is
	begin
		line_ram_we1A <= "0";
		line_ram_we1B <= "0";
		line_ram_we1C <= "0";
		line_ram_we1D <= "0";
		line_ram_we2A <= "0";
		line_ram_we2B <= "0";
		line_ram_we2C <= "0";
		line_ram_we2D <= "0";
		if line_ram_switch = '0' then
			if line_ram_we_bg = "1" then
				line_ram_we1A <= "1";
				line_ram_we1B <= "1";
				line_ram_we1C <= "1";
				line_ram_we1D <= "1";
			elsif line_ram_we_pixel = "1" and line_ram_din /= transparent_color then
				case line_ram_waddr_latched(1 downto 0) is
					when "00" =>
						line_ram_we1A <= "1";
					when "01" =>
						line_ram_we1B <= "1";
					when "10" =>
						line_ram_we1C <= "1";
					when "11" =>
						line_ram_we1D <= "1";
					when others =>
						null;
				end case;
			end if;
		else
			if line_ram_we_bg = "1" then
				line_ram_we2A <= "1";
				line_ram_we2B <= "1";
				line_ram_we2C <= "1";
				line_ram_we2D <= "1";
			elsif line_ram_we_pixel = "1" and line_ram_din /= transparent_color then
				case line_ram_waddr_latched(1 downto 0) is
					when "00" =>
						line_ram_we2A <= "1";
					when "01" =>
						line_ram_we2B <= "1";
					when "10" =>
						line_ram_we2C <= "1";
					when "11" =>
						line_ram_we2D <= "1";
					when others =>
						null;
				end case;
			end if;
		end if;
	end process GENERATE_LINE_RAM_WE_1_2;

	-- sequential
	LATCH_LINE_RAM_WE_PIXEL : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			line_ram_we_pixel(0) <= line_ram_process;
		end if;
	end process LATCH_LINE_RAM_WE_PIXEL;
	
	-- combinatorial
	GENERATE_LINE_RAM_DIN : process(line_ram_din, line_ram_we_pixel, PLB_MRdDBus) is
	begin
		if line_ram_we_pixel = "0" then
			line_ram_dinA <= PLB_MRdDBus(0 to 15);
			line_ram_dinB <= PLB_MRdDBus(16 to 31);
			line_ram_dinC <= PLB_MRdDBus(32 to 47);
			line_ram_dinD <= PLB_MRdDBus(48 to 63);
		else
			line_ram_dinA <= line_ram_din;
			line_ram_dinB <= line_ram_din;
			line_ram_dinC <= line_ram_din;
			line_ram_dinD <= line_ram_din;
		end if;
	end process GENERATE_LINE_RAM_DIN;
	
	-- combinatorial
	GENERATE_LINE_RAM_OUT : process(line_ram_raddr, line_ram_out1A, line_ram_out1B, line_ram_out1C, 
											  line_ram_out1D, line_ram_out2A, line_ram_out2B, line_ram_out2C, 
											  line_ram_out2D, line_ram_switch) is
	begin
		if line_ram_switch = '0' then		
			case line_ram_raddr(1 downto 0) is
				when "00" =>
					line_ram_out <= line_ram_out2A;
				when "01" =>
					line_ram_out <= line_ram_out2B;
				when "10" =>
					line_ram_out <= line_ram_out2C;
				when "11" =>
					line_ram_out <= line_ram_out2D;
				when others =>
					null;
			end case;
		else
			case line_ram_raddr(1 downto 0) is
				when "00" =>
					line_ram_out <= line_ram_out1A;
				when "01" =>
					line_ram_out <= line_ram_out1B;
				when "10" =>
					line_ram_out <= line_ram_out1C;
				when "11" =>
					line_ram_out <= line_ram_out1D;
				when others =>
					null;
			end case;
		end if;
	end process GENERATE_LINE_RAM_OUT;

	-- sequential
	GENERATE_LINE_RAM_WADDR : process(PLB_Clk) is
		variable last : signed(9 downto 0);
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if line_ram_waddr_rst = '1' then
				line_ram_waddr <= "000000000";
			elsif line_ram_waddr_set_beginning = '1' then
				if current_instance_x > 0 then
					line_ram_waddr <= std_logic_vector(current_instance_x(8 downto 0));
				else
					line_ram_waddr <= "000000000";
				end if;
				last := current_instance_x + 15;
				line_ram_waddr_last <= std_logic_vector(last(8 downto 0));
			elsif line_ram_waddr_next_pixel = '1' then
				line_ram_waddr <= line_ram_waddr + 1;
			elsif line_ram_waddr_next_dw = '1' then
				line_ram_waddr <= line_ram_waddr + 4;
			end if;
		end if;
	end process GENERATE_LINE_RAM_WADDR;

	-- sequential (PixelClock)
	GENERATE_LINE_RAM_RADDR : process(PixelClock) is
	begin
		if PixelClock'event and PixelClock = '1' then
			if line_ram_raddr_rst = '1' then
				line_ram_raddr <= "000000000";
			elsif line_ram_raddr_inc = '1' then
				line_ram_raddr <= line_ram_raddr + 1;
			end if;
		end if;
	end process GENERATE_LINE_RAM_RADDR;
	
		-- combinatorial
	GENERATE_SPRITE_RAM_ADDR : process(sprite_ram_waddr, sprite_ram_raddr, sprite_ram_we) is
	begin
		if sprite_ram_we = "1" then
			sprite_ram_addr <= sprite_ram_waddr;
		else
			sprite_ram_addr <= sprite_ram_raddr;
		end if;
	end process GENERATE_SPRITE_RAM_ADDR;
	
	-- sequential
	INCR_CLKCPT : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			ClkCpt <= ClkCpt + 1;
		end if;
	end process INCR_CLKCPT;
	
	-- sequential
	UPDATE_INSTANCE_NUMBER : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if instance_number_rst = '1' then
				instance_number <= (others => '0');
			elsif instance_number_inc = '1' then
				instance_number <= instance_number + 1;
			end if;
		end if;
	end process UPDATE_INSTANCE_NUMBER;
	
	-- sequential
	INSTANCE_SWITCH : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if instances_switch = '1' then
				instance_ram_switch <= not instance_ram_switch;
			end if;
		end if;
	end process INSTANCE_SWITCH;

	-- sequential
	UPDATE_SLAVE_SLICE : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if slave_slice_we = '1' then
				slave_slice <= PLB_ABus - C_BASEADDR;
			end if;
		end if;	
	end process UPDATE_SLAVE_SLICE;

	-- sequential
	UPDATE_VGA_CONTROL_REG : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if vga_control_reg_we = '1' then
				vga_control_reg <= PLB_wrDBus(32 to 63);
			end if;
		end if;	
	end process UPDATE_VGA_CONTROL_REG;
	
	-- sequential
	UPDATE_VGA_BASE_ADDRESS : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if vga_base_address_we = '1' then
				vga_base_address <= PLB_wrDBus(32 to 63);
			end if;
		end if;	
	end process UPDATE_VGA_BASE_ADDRESS;
	
	-- sequential
	UPDATE_OP_LENGTH : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if op_length_rst = '1' then
				op_length <= max_op_length;
			elsif op_length_dec = '1' then
				op_length <= op_length - 1;
			end if;
		end if;	
	end process UPDATE_OP_LENGTH;

	-- sequential
	CHANGE_STATE : process(PLB_Clk) is
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
	end process CHANGE_STATE;
	
	-- combinatorial
	MASTER_STATE : process(PLB_MAddrAck, PLB_MRdDAck, vga_master_state_current, current_line, 
										start_read_line, op_length, vga_on, instance_number, line_ram_waddr,
										line_ram_waddr_last, current_instance_y, computing_line, last_instance,
										instances_enabled) is
	begin
	
		M_request     <= '0';
		M_priority    <= "00";
		M_busLock     <= '0';
		M_RNW         <= '0';
		M_BE          <= "00000000";
		M_size        <= "0000";
		M_type        <= "000";
		M_abort       <= '0';
		M_ABus        <= X"00000000";
		M_compress    <= '0';  
		M_guarded     <= '0';
		M_lockErr     <= '0';
		M_MSize       <= (others => '0');
		M_ordered     <= '0';
		M_rdBurst     <= '0';
		M_wrBurst     <= '0';
		
		computing                 <= '0';
		line_ram_we_bg            <= "0";
		line_ram_process          <= '0';
		line_ram_waddr_rst        <= '0';
		line_ram_waddr_set_beginning <= '0';
		line_ram_waddr_next_pixel <= '0';
		line_ram_waddr_next_dw    <= '0';
		op_length_rst             <= '0';
		op_length_dec             <= '0';
		instance_number_rst       <= '0';
		instance_number_inc       <= '0';
		vga_master_state_next     <= vga_master_state_current;
		
		case vga_master_state_current is
		
			when Master_Idle =>
				line_ram_waddr_rst <= '1';
				op_length_rst <= '1';
				instance_number_rst <= '1';
				if start_read_line = '1' and vga_on = '1' then
					vga_master_state_next <= Master_ReadBg_Addr;
				end if;
				debug_master_state <= "0000";
			
			when Master_ReadBg_Addr =>
				M_request <= '1';
				M_priority <= "00";
				M_RNW <= '1';
				M_size <= "1011"; -- burst transfert, double words, terminated by master
				M_ABus <= current_line;
				if PLB_MAddrAck = '1' then
					vga_master_state_next <= Master_ReadBg_Data;
				end if;
				debug_master_state <= "0001";
			
			when Master_ReadBg_Data =>
				if PLB_MRdDAck = '1' then
					line_ram_we_bg <= "1";
					op_length_dec <= '1';
					line_ram_waddr_next_dw <= '1';
					if op_length = 0 then
						if instances_enabled = '1' then
							vga_master_state_next <= Master_Compute_StartInstance;
						else
							vga_master_state_next <= Master_Ended;
						end if;
						M_rdBurst <= '0';
					else
						M_rdBurst <= '1';
					end if;
				else
					M_rdBurst <= '1';
				end if;
				debug_master_state <= "0010";
				
			when Master_Compute_StartInstance =>
				computing <= '1';
				vga_master_state_next <= Master_Compute_CheckInstance;
				debug_master_state <= "0011";
				
			when Master_Compute_CheckInstance =>
				computing <= '1';
				if computing_line >= current_instance_y and computing_line < (current_instance_y + 16) then
					-- treat this instance
					vga_master_state_next <= Master_Compute_ProcessInstance;
					line_ram_waddr_set_beginning <= '1';
				else
					-- skip this instance
					if std_logic_vector(instance_number) = last_instance then
						vga_master_state_next <= Master_Ended;
					else
						instance_number_inc <= '1';
						vga_master_state_next <= Master_Compute_StartInstance;
					end if;
				end if;
				debug_master_state <= "0100";
			
			when Master_Compute_ProcessInstance =>
				computing <= '1';
				line_ram_waddr_next_pixel <= '1';
				line_ram_process <= '1';
				if line_ram_waddr = line_ram_waddr_last then
					if std_logic_vector(instance_number) = last_instance then
						vga_master_state_next <= Master_Ended;
					else
						instance_number_inc <= '1';
						vga_master_state_next <= Master_Compute_StartInstance;
					end if;				
				end if;
				debug_master_state <= "0101";
						
			when Master_Ended =>
				vga_master_state_next <= Master_Idle;
				debug_master_state <= "1111";
				
		end case;
		
	end  process MASTER_STATE;

	-- sequential
	SLAVE_STATE : process(PLB_Clk, vga_slave_state_current, PLB_PAValid, PLB_ABus,
                         PLB_RNW, slave_slice, vga_control_reg, vga_base_address,
								 instance_ram_open_out) is
	begin
	
		Sl_addrAck <= '0';
		Sl_rdComp  <= '0';
		Sl_rdDAck  <= '0';
		Sl_wrDAck  <= '0';
		Sl_wrComp  <= '0';
		Sl_wait    <= '0';
		Sl_rdDBus  <= (others => '0');
		
		slave_slice_we         <= '0';
		vga_base_address_we    <= '0';
		vga_control_reg_we     <= '0';
		instance_ram_open_we   <= "0";
		instances_switch       <= '0';
		sprite_ram_we          <= "0";
		vga_slave_state_next   <= vga_slave_state_current;
		
		case vga_slave_state_current is
			
			when Slave_Idle =>
				if PLB_PAValid = '1' and PLB_ABus >= C_BASEADDR and PLB_ABus <= C_HIGHADDR	then
					vga_slave_state_next <= Slave_AddAck;
					Sl_wait <= '1';
					slave_slice_we <= '1';
				end if;
				debug_slave_state <= "0000";
				
			when Slave_AddAck => -- Read Address and record it into slave_slice.  
				Sl_wait <= '1';
				Sl_addrAck <= '1';
				if PLB_RNW = '1' then
					vga_slave_state_next <= Slave_Read;
				else
					vga_slave_state_next <= Slave_Write;
				end if; 
				debug_slave_state <= "0001";
			
			when Slave_Read => -- Read data from plb
				Sl_rdComp <= '1';
				if slave_slice(15) = '0' then
					if slave_slice(16) = '0' then -- control block
						case slave_slice(28 to 29) is
							when "00" =>
								Sl_rdDBus(0 to 31) <= vga_base_address;
								Sl_rdDBus(32 to 63) <= vga_base_address;
							when "01" =>
								Sl_rdDBus(0 to 31) <= vga_control_reg;
								Sl_rdDBus(32 to 63) <= vga_control_reg;
							when others =>
								-- switch_reg and last_instance_reg cannot be read!
								null;
						end case;
					else -- instance block
						Sl_rdDBus(0 to 31) <= instance_ram_open_out;
						Sl_rdDBus(32 to 63) <= instance_ram_open_out;
					end if;
				else -- sprite block
					null; -- sprite data cannot be read!
				end if;
				vga_slave_state_next <= Slave_Read2;
				debug_slave_state <= "0010";
			
			when Slave_Read2 =>
				Sl_rdDAck <= '1';
				if slave_slice(15) = '0' then
					if slave_slice(16) = '0' then -- control block
						case slave_slice(28 to 29) is
							when "00" =>
								Sl_rdDBus(0 to 31) <= vga_base_address;
								Sl_rdDBus(32 to 63) <= vga_base_address;
							when "01" =>
								Sl_rdDBus(0 to 31) <= vga_control_reg;
								Sl_rdDBus(32 to 63) <= vga_control_reg;
							when others =>
								-- switch_reg and last_instance_reg cannot be read!
								null;
						end case;
					else -- instance block
						Sl_rdDBus(0 to 31) <= instance_ram_open_out;
						Sl_rdDBus(32 to 63) <= instance_ram_open_out;
					end if;
				else -- sprite block
					null; -- sprite data cannot be read!
				end if;
				vga_slave_state_next <= Slave_Idle;
				debug_slave_state <= "0011";
			
			when Slave_Write =>
				Sl_wrComp <= '1';
				if slave_slice(15) = '0' then
					if slave_slice(16) = '0' then -- control block
						case slave_slice(28 to 29) is
							when "00" =>
								vga_base_address_we <= '1';
							when "01" =>
								vga_control_reg_we <= '1';
							when "10" =>
								instances_switch <= '1';
							when "11" =>
								vga_last_instance_reg_we <= '1';
							when others =>
								null;
						end case;
					else
						instance_ram_open_we <= "1";
					end if;
				else -- sprite block
					sprite_ram_we <= "1";
				end if;
				vga_slave_state_next <= Slave_Write2;			
				debug_slave_state <= "0100";
			
			when Slave_Write2 =>				
				Sl_wrDAck <= '1';
				if slave_slice(15) = '0' then
					if slave_slice(16) = '0' then -- control block
						case slave_slice(28 to 29) is
							when "00" =>
								vga_base_address_we <= '1';
							when "01" =>
								vga_control_reg_we <= '1';
							when "10" =>
								null;
							when "11" =>
								vga_last_instance_reg_we <= '1';
							when others =>
								null;
						end case;
					else
						instance_ram_open_we <= "1";
					end if;
				else -- sprite block
					sprite_ram_we <= "1";
				end if;
				vga_slave_state_next <= Slave_Idle;
				debug_slave_state <= "0101";
		
		end case;
	end process SLAVE_STATE;
  
	-- combinatorial
	OUTPUT_VGA_SIGNALS : process(vga_control_reg, Hsync, Vsync, PixelClock, Red, Green, Blue, vga_on) is
	begin
		if vga_on = '1' then
			VGA_HSYNCH          <= Hsync;
			VGA_VSYNCH          <= Vsync;
			VGA_OUT_PIXEL_CLOCK <= PixelClock;
			VGA_OUT_BLANK_Z     <= '1';
			VGA_OUT_RED         <= Red;
			VGA_OUT_GREEN       <= Green;
			VGA_OUT_BLUE        <= Blue;
		else
			VGA_HSYNCH          <= '0';
			VGA_VSYNCH          <= '0';
			VGA_OUT_PIXEL_CLOCK <= '0';
			VGA_OUT_BLANK_Z     <= '0';
			VGA_OUT_RED         <= X"00";
			VGA_OUT_GREEN       <= X"00";
			VGA_OUT_BLUE        <= X"00";
		end if;
	end process OUTPUT_VGA_SIGNALS;

	-- combinatorial
	OUTPUT_COLORS : process(line_ram_out, HDisp, VDisp, cmptHsync, cmptVsync) is
	begin
		if HDisp = '1' and VDisp = '1' and cmptHsync < (H_total_wait + screen_width) 
									 and cmptVsync < (V_total_wait + screen_height) then
			line_ram_raddr_inc <= '1';
			Red <= line_ram_out(15 downto 11) & "000";
			Green <= line_ram_out(10 downto 5) & "00";
			Blue <= line_ram_out(4 downto 0) & "000";
		else
			line_ram_raddr_inc <= '0';
			Red <= X"00";
			Green <= X"00";
			Blue <= X"00";
		end if;
	end process OUTPUT_COLORS;
	
	-- sequential
	GEN_INTERRUPT : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if cmptHsync = 0 and cmptVsync = 0 then
				VGA_INTERRUPT <= vga_control_reg(1);
			else
				VGA_INTERRUPT <= '0';
			end if;
		end if;
	end process GEN_INTERRUPT;
	
	-- sequential (PixelClock)
	SYNC_CMPT640 : process(PixelClock) is
	begin
		if PixelClock'event and PixelClock = '1' then
		
		  -- default values
   	  start_read_line <= '0';
		  
		  -- cmptHsync
		  if cmptHsync < (H_total - 1) then
			 cmptHsync <= cmptHsync + 1;
		  else
			 cmptHsync <= (others => '0');
		  end if;
	
		  -- cmptVsync
		  if cmptHsync = 0 then
			 if cmptVsync < (V_total - 1) then
				cmptVsync <= cmptVsync + 1;
			 else
				cmptVsync <= (others => '0');
			 end if;
			 if cmptVsync = (V_total_wait - 2) then
				current_line <= vga_base_address;
				start_read_line <= '1';
			 elsif cmptVsync >= (V_total_wait - 1) and cmptVsync < (V_total_wait + screen_height - 1) then
				current_line <= current_line + line_width;
				start_read_line <= '1';
			 end if;
		  end if;
		  computing_line <= unsigned(cmptVsync - V_total_wait + 1);
		end if;
	end process SYNC_CMPT640;
	
	-- combinatorial
	SYNC_HSYNC640 : process(cmptHsync) is
	begin
		if cmptHsync < H_front_porch then
			Hsync <= '1';
			HDisp <= '0';
		elsif cmptHsync < (H_front_porch + H_sync)  then
			Hsync <= '0';
			HDisp <= '0';
		elsif cmptHsync < (H_front_porch + H_sync + H_back_porch) then 
			Hsync <= '1';
			HDisp <= '0';
		else 
			Hsync <= '1';
			HDisp <= '1';
		end if;
	end process SYNC_HSYNC640;
	
	-- combinatorial
	SYNC_VSYNC640 : process(cmptVsync) is
	begin
		if cmptVsync < V_front_porch then
			Vsync <= '1';
			VDisp <= '0';
		elsif cmptVsync < (V_front_porch + V_sync)  then
			Vsync <= '0';
			VDisp <= '0';
		elsif cmptVsync < (V_front_porch + V_sync + V_back_porch) then 
			Vsync <= '1';
			VDisp <= '0';
		else
			Vsync <= '1';
			VDisp <= '1';
		end if;
	end process SYNC_VSYNC640;

end IMP;
