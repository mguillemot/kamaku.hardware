------------------------------------------------------------------------------
-- isprite.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Filename:          isprite.vhd
-- Author:            Matthieu GUILLEMOT <g@npng.org>
-- Version:           1.00.a
-- Description:       Top level design, instantiates IPIF and user logic.
-- Date:              2006/02/26
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------

entity isprite is
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
	 Isprite_Debug						  : out std_logic_vector(255 downto 0);
	 Isprite_Interrupt              : out std_logic;

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

end entity isprite;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of isprite is

	-- constants
	constant transparent_color       : std_logic_vector(15 downto 0) := "1111100000011111"; -- Pink
	constant line_width              : std_logic_vector(31 downto 0) := X"00000280"; -- 320 * 2

	-- slave local address
	signal slave_slice               : std_logic_vector(0 to 31) := X"00000000";
	signal slave_slice_we            : std_logic := '0';

	-- isprite registers
	signal control                   : std_logic_vector(31 downto 0) := X"00000000";
	signal control_we                : std_logic := '0';
	signal control_rst               : std_logic := '0';
	signal source                    : std_logic_vector(31 downto 0) := X"00000000";
	signal source_we                 : std_logic := '0';
	signal framebuffer               : std_logic_vector(31 downto 0) := X"00000000";
	signal framebuffer_we            : std_logic := '0';
	signal sprite_size               : std_logic_vector(31 downto 0) := X"00000000";
	signal sprite_size_we            : std_logic := '0';
	signal sprite_coord              : std_logic_vector(31 downto 0) := X"00000000";
	signal sprite_coord_we           : std_logic := '0';
	
	-- alias
	signal sprite_width              : std_logic_vector(15 downto 0) := X"0000";
	signal sprite_height             : std_logic_vector(15 downto 0) := X"0000";
	signal sprite_x                  : std_logic_vector(15 downto 0) := X"0000";
	signal sprite_y                  : std_logic_vector(15 downto 0) := X"0000";	

	-- sprite_ram I/O
	signal sprite_ram_addr_A         : std_logic_vector(9 downto 0) := "0000000000";
	signal sprite_ram_addr_B         : std_logic_vector(9 downto 0) := "0000000000";
	signal sprite_ram_addr_C         : std_logic_vector(9 downto 0) := "0000000000";
	signal sprite_ram_addr_D         : std_logic_vector(9 downto 0) := "0000000000";
	signal sprite_ram_addr_col       : std_logic_vector(4 downto 0) := "00000";
	signal sprite_ram_addr_col_latched : std_logic_vector(4 downto 0) := "00000";
	signal sprite_ram_addr_row       : std_logic_vector(5 downto 0) := "000000";
	signal sprite_ram_addr_rst       : std_logic := '0';
	signal sprite_ram_addr_inc       : std_logic := '0';
	signal sprite_ram_addr_next_line : std_logic := '0';
	signal sprite_ram_addr_skip      : std_logic := '0';
	signal sprite_ram_we             : std_logic_vector(0 downto 0) := "0";
	signal sprite_ram_out            : std_logic_vector(63 downto 0) := X"0000000000000000";
	signal sprite_ram_out_A          : std_logic_vector(15 downto 0) := X"0000";
	signal sprite_ram_out_B          : std_logic_vector(15 downto 0) := X"0000";
	signal sprite_ram_out_C          : std_logic_vector(15 downto 0) := X"0000";
	signal sprite_ram_out_D          : std_logic_vector(15 downto 0) := X"0000";

	-- bg_ram I/O
	signal bg_ram_addr               : std_logic_vector(5 downto 0) := "000000";
	signal bg_ram_addr_rst           : std_logic := '0';
	signal bg_ram_addr_inc           : std_logic := '0';
	signal bg_ram_we                 : std_logic_vector(0 downto 0) := "0";
	signal bg_ram_out                : std_logic_vector(63 downto 0) := X"0000000000000000";
	
	-- DDR adress pointers
	signal source_ptr                : std_logic_vector(31 downto 0) := X"00000000";
	signal source_ptr_rst            : std_logic := '0';
	signal source_ptr_next_line      : std_logic := '0';
	signal destination_ptr           : std_logic_vector(31 downto 0) := X"00000000";
	signal destination_ptr_rst       : std_logic := '0';
	signal destination_ptr_next_line : std_logic := '0';

	-- Master & slave state machines
	type Master_State_Machine is (Master_Idle,
											Master_Sprite_Radd,
											Master_Sprite_Read1,
											Master_Sprite_ReadEnded,
										   Master_StartBlitLine,
											Master_StartBlitLine_Delayed,
											Master_StartBlitLine_Delayed2,
											Master_StartBlitLine_Delayed3,
											Master_Bg_Skip,
											Master_Bg_Radd,
											Master_Bg_ReadBurst,
											Master_Bg_ReadSingle,
											Master_Ended,
											Master_Wadd,
											Master_WriteBurst,
											Master_WriteSingle);

	type Slave_State_Machine is (Slave_Idle,
										  Slave_AddAck,
										  Slave_Read,
										  Slave_Read2,
										  Slave_Write,
										  Slave_Write2);
	
	signal master_state_current     : Master_State_Machine := Master_Idle;
	signal master_state_next        : Master_State_Machine := Master_Idle;
	signal slave_state_current      : Slave_State_Machine  := Slave_Idle;
	signal slave_state_next         : Slave_State_Machine  := Slave_Idle;
	
	-- sprite_transparency_ram I/O
	signal sprite_transparency_ram_we   : std_logic_vector(0 downto 0)  := "0";
	signal sprite_transparency_ram_din  : std_logic_vector(12 downto 0) := "0000000000000";
	signal sprite_transparency_ram_addr : std_logic_vector(5 downto 0)  := "000000";

	-- write operation transparency info
	signal transparency_info            : std_logic_vector(12 downto 0) := "0000000000000";
	signal transparency_info_it         : std_logic := '0'; -- inner transparency?
	signal transparency_info_th         : std_logic_vector(5 downto 0) := "000000"; -- pixel-sized transparent header
	signal transparency_info_tf         : std_logic_vector(5 downto 0) := "000000"; -- pixel-sized transparent footer
	signal transparency_info_ct         : std_logic := '0'; -- completely transparency?
	
	-- read operation transparency computing
	signal transp_rst               : std_logic := '0';
	signal transp_update            : std_logic := '0';
	signal transp_it                : std_logic := '0';
	signal transp_tf                : std_logic_vector(5 downto 0) := "000000";
	signal transp_th                : std_logic_vector(5 downto 0) := "000000";
	signal transp_header_complete   : std_logic := '0';
	signal transp_computing         : std_logic := '0';

	-- write operation state flags
	signal write_operation           : std_logic := '0';
	
	-- write operation control flags
	signal bg_skip                   : std_logic := '0';
	signal trailing_transparency     : std_logic := '0';
	signal shift                     : std_logic_vector(1 downto 0) := "00";
	signal skip                      : std_logic_vector(4 downto 0) := "00000";
	signal op_length                 : std_logic_vector(5 downto 0) := "000000";
	signal endprem                   : std_logic_vector(4 downto 0) := "00000";
	signal total_th                  : std_logic_vector(6 downto 0) := "0000000";
	signal total_tf                  : std_logic_vector(6 downto 0) := "0000000";
	
	-- write operation skip & op_length computing
	signal rogne2                    : std_logic_vector(15 downto 0);
	signal rogne                     : signed(15 downto 0);
	signal last_pixel                : signed(15 downto 0);
	signal skip_beginning            : std_logic;
	signal skip_end                  : std_logic;
	signal start_line                : std_logic_vector(5 downto 0);
	signal end_line                  : std_logic_vector(5 downto 0);

	-- single-beat write operation qualifiers
	signal transparency_mask        : std_logic_vector(7 downto 0) := "00000000";
	signal transparency_mask_size   : std_logic_vector(1 downto 0) := "00";
	
	-- components
	component isprite_partial_sprite_ram
	port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(15 downto 0);
		addra: IN std_logic_VECTOR(9 downto 0);
		wea: IN std_logic_VECTOR(0 downto 0);
		douta: OUT std_logic_VECTOR(15 downto 0));
	end component;
	
	component sprite_transparency_ram
	port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(12 downto 0);
		addra: IN std_logic_VECTOR(5 downto 0);
		wea: IN std_logic_VECTOR(0 downto 0);
		douta: OUT std_logic_VECTOR(12 downto 0));
	end component;
	
	component bg_ram
	port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(63 downto 0);
		addra: IN std_logic_VECTOR(5 downto 0);
		wea: IN std_logic_VECTOR(0 downto 0);
		douta: OUT std_logic_VECTOR(63 downto 0));
	end component;

	-- debug
	signal debug_master_state : std_logic_vector(3 downto 0) := "0000";
	
begin
	 
	SPRITE_RAM_PART_A : isprite_partial_sprite_ram port map (
		clka  => PLB_Clk,
		dina  => PLB_MRdDBus(0 to 15),
		addra => sprite_ram_addr_A,
		wea   => sprite_ram_we,
		douta => sprite_ram_out_A
	);
	
	SPRITE_RAM_PART_B : isprite_partial_sprite_ram port map (
		clka  => PLB_Clk,
		dina  => PLB_MRdDBus(16 to 31),
		addra => sprite_ram_addr_B,
		wea   => sprite_ram_we,
		douta => sprite_ram_out_B
	);

	SPRITE_RAM_PART_C : isprite_partial_sprite_ram port map (
		clka  => PLB_Clk,
		dina  => PLB_MRdDBus(32 to 47),
		addra => sprite_ram_addr_C,
		wea   => sprite_ram_we,
		douta => sprite_ram_out_C
	);

	SPRITE_RAM_PART_D : isprite_partial_sprite_ram port map (
		clka  => PLB_Clk,
		dina  => PLB_MRdDBus(48 to 63),
		addra => sprite_ram_addr_D,
		wea   => sprite_ram_we,
		douta => sprite_ram_out_D
	);

	SPRITE_TRANSPARENCY_RAM_INSTANCE : sprite_transparency_ram port map (
		clka => PLB_Clk,
		dina => sprite_transparency_ram_din,
		addra => sprite_transparency_ram_addr,
		wea => sprite_transparency_ram_we,
		douta => transparency_info
	);
			
	BG_RAM_INSTANCE : bg_ram port map (
		clka => PLB_Clk,
		dina => PLB_MRdDBus,
		addra => bg_ram_addr,
		wea => bg_ram_we,
		douta => bg_ram_out
	);

	-- sequential
	CONTROL_FF : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if control_rst = '1' or PLB_Rst = '1' then
				control <= X"00000000";
			elsif control_we = '1' then
				control <= PLB_wrDBus(32 to 63);
			end if;
		end if;
	end process CONTROL_FF;

	SOURCE_FF : for i in 0 to 31 generate
		FF : FDRE port map (
			D  => PLB_wrDBus(63 - i),
			Q  => source(i),
			C  => PLB_Clk,
			CE => source_we,
			R  => PLB_Rst
		);
	end generate SOURCE_FF;

	FRAMEBUFFER_FF : for i in 0 to 31 generate
		FF : FDRE port map (
			D  => PLB_wrDBus(63 - i),
			Q  => framebuffer(i),
			C  => PLB_Clk,
			CE => framebuffer_we,
			R  => PLB_Rst
		);
	end generate FRAMEBUFFER_FF;

	SPRITE_SIZE_FF : for i in 0 to 31 generate
		FF : FDRE port map (
			D  => PLB_wrDBus(63 - i),
			Q  => sprite_size(i),
			C  => PLB_Clk,
			CE => sprite_size_we,
			R  => PLB_Rst
		);
	end generate SPRITE_SIZE_FF;

	SPRITE_COORD_FF : for i in 0 to 31 generate
		FF : FDRE port map (
			D  => PLB_wrDBus(63 - i),
			Q  => sprite_coord(i),
			C  => PLB_Clk,
			CE => sprite_coord_we,
			R  => PLB_Rst
		);
	end generate SPRITE_COORD_FF;

	Isprite_Debug(3 downto 0) <= debug_master_state;
	Isprite_Debug(5 downto 4) <= control(1 downto 0);	
--	Isprite_Debug(6) <= transparency_info_it;
--	Isprite_Debug(12 downto 7) <= transparency_info_th;	
--	Isprite_Debug(18 downto 13) <= transparency_info_tf;
--	Isprite_Debug(23 downto 19) <= sprite_ram_addr_col;
--	Isprite_Debug(28 downto 24) <= sprite_ram_addr_col_latched;
--	Isprite_Debug(34 downto 29) <= bg_ram_addr;
--	Isprite_Debug(40 downto 35) <= op_length;
--	Isprite_Debug(50 downto 49) <= shift;
--	Isprite_Debug(56 downto 51) <= sprite_transparency_ram_addr;
--	Isprite_Debug(58) <= skip_beginning;
--	Isprite_Debug(64 downto 59) <= start_line;
--	Isprite_Debug(71 downto 66) <= end_line;
--	Isprite_Debug(80 downto 73) <= transparency_mask;
--	Isprite_Debug(81) <= skip_end;
--	Isprite_Debug(82) <= trailing_transparency;
--	Isprite_Debug(83) <= write_operation;
--	Isprite_Debug(84) <= bg_skip;
--	Isprite_Debug(89 downto 85) <= skip;
--	Isprite_Debug(103 downto 99) <= endprem;
--	Isprite_Debug(118 downto 113) <= sprite_ram_addr_row;
--	Isprite_Debug(191 downto 128) <= sprite_ram_out;
	--Isprite_Debug(207 downto 192) <= std_logic_vector(rogne);
	--Isprite_Debug(223 downto 208) <= std_logic_vector(rogne2);
	--Isprite_Debug(239 downto 224) <= std_logic_vector(last_pixel);
	

	sprite_width <= sprite_size(31 downto 16);
	sprite_height <= sprite_size(15 downto 0);
	sprite_x <= sprite_coord(31 downto 16);
	sprite_y <= sprite_coord(15 downto 0);
	
	transparency_info_it <= transparency_info(0);
	transparency_info_th <= transparency_info(6 downto 1);
	transparency_info_tf <= transparency_info(12 downto 7);
	transparency_info_ct <= '1' when (transparency_info_th = "111111" and transparency_info_tf = "111111") else '0';

	shift <= sprite_x(1 downto 0) when (write_operation = '1') else "00";

	-- sequential
	GENERATE_START_AND_END_LINE : process(PLB_Clk) is
		variable minus_sprite_y   : signed(15 downto 0);
		variable last_line        : std_logic_vector(15 downto 0);
		variable new_height       : std_logic_vector(15 downto 0);
		variable height_minus_one : std_logic_vector(15 downto 0);
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
		
			-- start_line
			minus_sprite_y := - signed(sprite_y);
			if signed(sprite_y) < 0 then
				start_line <= std_logic_vector(minus_sprite_y(5 downto 0));
			else
				start_line <= "000000";
			end if;
			
			-- end_line
			last_line := sprite_y + sprite_height - 1;
			new_height := sprite_height - last_line + 238;
			height_minus_one := sprite_height - 1;
			if last_line > 239 then
				end_line <= new_height(5 downto 0);
			else
				end_line <= height_minus_one(5 downto 0);
			end if;
			
		end if;
	end process GENERATE_START_AND_END_LINE;	

	-- sequential
	LATCH_SPRITE_RAM_ADDR_COL : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			sprite_ram_addr_col_latched <= sprite_ram_addr_col;
		end if;
	end process LATCH_SPRITE_RAM_ADDR_COL;
	
	-- combinatorial
	GENERATE_SPRITE_RAM_OUT : process(sprite_ram_addr_col_latched, shift, sprite_ram_out_A, sprite_ram_out_B,
												 sprite_ram_out_C, sprite_ram_out_D, sprite_width) is
	begin
		case shift is
			when "01" =>
				if sprite_ram_addr_col_latched = 0 then
					sprite_ram_out <= transparent_color & sprite_ram_out_A & sprite_ram_out_B & sprite_ram_out_C;
				elsif sprite_ram_addr_col_latched = sprite_width(6 downto 2) then
					sprite_ram_out <= sprite_ram_out_D & transparent_color & transparent_color & transparent_color;
				else
					sprite_ram_out <= sprite_ram_out_D & sprite_ram_out_A & sprite_ram_out_B & sprite_ram_out_C;
				end if;
			when "10" =>
				if sprite_ram_addr_col_latched = 0 then
					sprite_ram_out <= transparent_color & transparent_color & sprite_ram_out_A & sprite_ram_out_B;
				elsif sprite_ram_addr_col_latched = sprite_width(6 downto 2) then
					sprite_ram_out <= sprite_ram_out_C & sprite_ram_out_D & transparent_color & transparent_color;
				else
					sprite_ram_out <= sprite_ram_out_C & sprite_ram_out_D & sprite_ram_out_A & sprite_ram_out_B;
				end if;
			when "11" =>
				if sprite_ram_addr_col_latched = 0 then
					sprite_ram_out <= transparent_color & transparent_color & transparent_color & sprite_ram_out_A;
				elsif sprite_ram_addr_col_latched = sprite_width(6 downto 2) then
					sprite_ram_out <= sprite_ram_out_B & sprite_ram_out_C & sprite_ram_out_D & transparent_color;
				else
					sprite_ram_out <= sprite_ram_out_B & sprite_ram_out_C & sprite_ram_out_D & sprite_ram_out_A;
				end if;
			when others =>
				sprite_ram_out <= sprite_ram_out_A & sprite_ram_out_B & sprite_ram_out_C & sprite_ram_out_D;
		end case;
	end process GENERATE_SPRITE_RAM_OUT;

	-- sequential
	COMPUTE_PRE_TRANSPARENCY_DATA : process(PLB_Clk) is
		variable rogne_temp     : signed(15 downto 0);
		variable rogne2_temp    : std_logic_vector(15 downto 0);
		variable last_pixel_var : signed(15 downto 0);
	begin
		if PLB_Clk'event and PLB_Clk = '1' then

			-- total_th & total_tf
			case shift is
				when "01" =>
					total_th <= ("0" & transparency_info_th) + 1;
					total_tf <= ("0" & transparency_info_tf) + 3;
				when "10" =>
					total_th <= ("0" & transparency_info_th) + 2;
					total_tf <= ("0" & transparency_info_tf) + 2;
				when "11" =>
					total_th <= ("0" & transparency_info_th) + 3;
					total_tf <= ("0" & transparency_info_tf) + 1;
				when others =>
					total_th <= "0" & transparency_info_th;
					total_tf <= "0" & transparency_info_tf;
			end case;
			
			-- skip_beginning
			if signed(sprite_x) < 0 then
				skip_beginning <= '1';
			else
				skip_beginning <= '0';
			end if;
			
			-- rogne
			rogne_temp := - signed(sprite_x);
			if rogne_temp(1 downto 0) /= 0 then
				rogne <= rogne_temp + 4;
			else
				rogne <= rogne_temp;
			end if;
		
			-- last_pixel
			last_pixel_var := signed(sprite_x(15 downto 2) & "00") + signed(sprite_width - transparency_info_tf + shift);
			last_pixel <= last_pixel_var;
		
			-- rogne2
			rogne2_temp := last_pixel_var - 320;
			if rogne2_temp(1 downto 0) /= 0 then
				rogne2 <= rogne2_temp + 4;
			else
				rogne2 <= rogne2_temp;
			end if;
			
		end if;
	end process COMPUTE_PRE_TRANSPARENCY_DATA;

	-- sequential
	COMPUTE_POST_TRANSPARENCY_DATA : process(PLB_Clk) is
		variable skip_var                       : unsigned(4 downto 0);
		variable endprem_var                    : unsigned(4 downto 0);
		variable op_length_var                  : signed(5 downto 0);
		variable skip_beginning_was_transparent : std_logic;
	begin
		if PLB_Clk'event and PLB_Clk = '1' then

			-- skip
			if skip_beginning = '1' and unsigned(rogne(6 downto 2)) > unsigned(total_th(6 downto 2)) then
				skip_var := unsigned(rogne(6 downto 2));
				skip_beginning_was_transparent := '1';
			else
				skip_var := unsigned(total_th(6 downto 2));
				skip_beginning_was_transparent := '0';
			end if;
			skip <= std_logic_vector(skip_var);

			-- endprem
			if last_pixel > 320 then
				endprem_var := unsigned(total_tf(6 downto 2) + rogne2(6 downto 2));
				skip_end <= '1';
			else
				endprem_var := unsigned(total_tf(6 downto 2));
				skip_end <= '0';
			end if;
			endprem <= std_logic_vector(endprem_var);

			-- op_length
			op_length_var := signed(sprite_width(7 downto 2)) - skip_var - endprem_var;
			if op_length_var < 0 then
				op_length_var := "000000"; -- op_length_var++ not needed if < 0
			elsif shift /= "00" then
				op_length_var := op_length_var + 1;
			end if;
			op_length <= std_logic_vector(op_length_var);

			-- trailing_transparency
			if (total_th(1 downto 0) /= "00" and skip_beginning_was_transparent = '0') or (total_tf(1 downto 0) /= "00" and skip_end = '0') then
				trailing_transparency <= '1';
			else
				trailing_transparency <= '0';
			end if;
			
		end if;
	end process COMPUTE_POST_TRANSPARENCY_DATA;
	
	-- combinatorial
	COMPUTE_BG_SKIP : process(op_length, transparency_info_it, trailing_transparency) is
	begin
		if op_length = 1  then
			bg_skip <= '1';
		elsif transparency_info_it = '1' or trailing_transparency = '1' then
			bg_skip <= '0';
		else
			bg_skip <= '1';
		end if;
	end process COMPUTE_BG_SKIP;
	
	-- combinatorial
	GENERATE_TRANSPARENCY_MASK_AND_SIZE : process(sprite_ram_out) is
		variable mask : std_logic_vector(7 downto 0);
	begin
		mask := "11111111";
		if sprite_ram_out(15 downto 0) = transparent_color then
			mask(1 downto 0) := "00";
		end if;
		if sprite_ram_out(31 downto 16) = transparent_color then
			mask(3 downto 2) := "00";
		end if;
		if sprite_ram_out(47 downto 32) = transparent_color then
			mask(5 downto 4) := "00";
		end if;
		if sprite_ram_out(63 downto 48) = transparent_color then
			mask(7 downto 6) := "00";
		end if;
		if mask(7 downto 2) = "000000" then
			transparency_mask_size <= "01";
		elsif mask(7 downto 4) = "0000" then
			transparency_mask_size <= "10";
		elsif mask(7 downto 6) = "00" then
			transparency_mask_size <= "11";
		else
			transparency_mask_size <= "11";
		end if;
		transparency_mask <= mask;
	end process GENERATE_TRANSPARENCY_MASK_AND_SIZE;
		
	-- combinatorial
	GENERATE_WRITE_DATA : process(sprite_ram_out, bg_ram_out) is
	begin
		if sprite_ram_out(63 downto 48) = transparent_color then
			M_wrDBus(0 to 15) <= bg_ram_out(63 downto 48);
		else
			M_wrDBus(0 to 15) <= sprite_ram_out(63 downto 48);
		end if;
		if sprite_ram_out(47 downto 32) = transparent_color then
			M_wrDBus(16 to 31) <= bg_ram_out(47 downto 32);
		else
			M_wrDBus(16 to 31) <= sprite_ram_out(47 downto 32);
		end if;
		if sprite_ram_out(31 downto 16) = transparent_color then
			M_wrDBus(32 to 47) <= bg_ram_out(31 downto 16);
		else
			M_wrDBus(32 to 47) <= sprite_ram_out(31 downto 16);
		end if;
		if sprite_ram_out(15 downto 0) = transparent_color then
			M_wrDBus(48 to 63) <= bg_ram_out(15 downto 0);
		else
			M_wrDBus(48 to 63) <= sprite_ram_out(15 downto 0);
		end if;
	end process GENERATE_WRITE_DATA;
	
	-- sequential
	UPDATE_SLAVE_SLICE : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if PLB_Rst = '1' then
				slave_slice <= X"00000000";
			elsif slave_slice_we = '1' then
				slave_slice <= PLB_ABus - C_BASEADDR;
			end if;
		end if;	
	end process UPDATE_SLAVE_SLICE;

	-- sequential
	UPDATE_RAM_ADDR : process(PLB_Clk) is
		variable sprite_ram_addr_col_var           : std_logic_vector(4 downto 0);
		variable sprite_ram_addr_row_var           : std_logic_vector(5 downto 0);
		variable sprite_ram_addr_col_minus_one_var : std_logic_vector(4 downto 0);
		variable sprite_ram_addr_var               : std_logic_vector(9 downto 0);
		variable sprite_ram_addr_minus_one_var     : std_logic_vector(9 downto 0);
	begin
		if PLB_Clk'Event and PLB_Clk = '1' then
		
			--sprite_ram_addr_row & sprite_ram_addr_col
			sprite_ram_addr_row_var := sprite_ram_addr_row;
			sprite_ram_addr_col_var := sprite_ram_addr_col;
			if sprite_ram_addr_rst = '1' then
				sprite_ram_addr_row_var := start_line;
				sprite_ram_addr_col_var := (others => '0');
			elsif sprite_ram_addr_next_line = '1' then
				sprite_ram_addr_row_var := sprite_ram_addr_row + 1;
				sprite_ram_addr_col_var := (others => '0');
			elsif sprite_ram_addr_skip = '1' then
				sprite_ram_addr_col_var := skip;
			elsif sprite_ram_addr_inc = '1' then
				sprite_ram_addr_col_var := sprite_ram_addr_col + 1;
			end if;
			sprite_ram_addr_row <= sprite_ram_addr_row_var;
			sprite_ram_addr_col <= sprite_ram_addr_col_var;
			
			-- sprite_ram_addr
			sprite_ram_addr_col_minus_one_var := sprite_ram_addr_col_var - 1;
			sprite_ram_addr_var := sprite_ram_addr_row_var & sprite_ram_addr_col_var(3 downto 0);
			sprite_ram_addr_minus_one_var := sprite_ram_addr_row_var & sprite_ram_addr_col_minus_one_var(3 downto 0);
			case shift is
				when "01" =>
					sprite_ram_addr_A <= sprite_ram_addr_var;
					sprite_ram_addr_B <= sprite_ram_addr_var;
					sprite_ram_addr_C <= sprite_ram_addr_var;
					sprite_ram_addr_D <= sprite_ram_addr_minus_one_var;
				when "10" =>
					sprite_ram_addr_A <= sprite_ram_addr_var;
					sprite_ram_addr_B <= sprite_ram_addr_var;
					sprite_ram_addr_C <= sprite_ram_addr_minus_one_var;
					sprite_ram_addr_D <= sprite_ram_addr_minus_one_var;
				when "11" =>
					sprite_ram_addr_A <= sprite_ram_addr_var;
					sprite_ram_addr_B <= sprite_ram_addr_minus_one_var;
					sprite_ram_addr_C <= sprite_ram_addr_minus_one_var;
					sprite_ram_addr_D <= sprite_ram_addr_minus_one_var;
				when others =>
					sprite_ram_addr_A <= sprite_ram_addr_var;
					sprite_ram_addr_B <= sprite_ram_addr_var;
					sprite_ram_addr_C <= sprite_ram_addr_var;
					sprite_ram_addr_D <= sprite_ram_addr_var;
			end case;

			-- sprite_transparency_ram_addr
			if transp_computing = '1' then
				sprite_transparency_ram_addr <= sprite_ram_addr_row_var - 1;
			else
				sprite_transparency_ram_addr <= sprite_ram_addr_row_var;
			end if;

		end if;
	end process UPDATE_RAM_ADDR;

	-- sequential
	UPDATE_BG_RAM_ADDR : process(PLB_Clk) is
	begin
		if PLB_Clk'Event and PLB_Clk = '1' then
			if bg_ram_addr_rst = '1' then
				bg_ram_addr <= "000000";
			elsif bg_ram_addr_inc = '1' then
				bg_ram_addr <= bg_ram_addr + 1;
			end if;
		end if;
	end process UPDATE_BG_RAM_ADDR;

	-- sequential
	UPDATE_SOURCE_PTR : process(PLB_Clk) is
	begin
		if PLB_Clk'Event and PLB_Clk = '1' then
			if source_ptr_rst = '1' then
				source_ptr <= source;
			elsif source_ptr_next_line = '1' then
				source_ptr <= source_ptr + sprite_width;
			end if;
		end if;
	end process UPDATE_SOURCE_PTR;
	
	-- sequential
	UPDATE_DESTINATION_PTR : process(PLB_Clk) is
		variable add_x : std_logic_vector(31 downto 0);
		variable add_y : unsigned(31 downto 0);
	begin
		if PLB_Clk'Event and PLB_Clk = '1' then
			if destination_ptr_rst = '1' then
				if signed(sprite_x) < 0 then
					add_x := "111111111111111" & sprite_x(15 downto 0) & "0";
				else
					add_x := "000000000000000" & sprite_x(15 downto 0) & "0";
				end if;
				if signed(sprite_y) < 0 then
					add_y := X"00000000";
				else
					add_y := unsigned(line_width(15 downto 0)) * unsigned(sprite_y);
				end if;
				destination_ptr <= framebuffer + add_x + std_logic_vector(add_y);
			elsif destination_ptr_next_line = '1' then
				destination_ptr <= destination_ptr + line_width;
			end if;
		end if;
	end process UPDATE_DESTINATION_PTR;

	-- sequential
	CHANGE_STATE : process(PLB_Clk, PLB_Rst) is
	begin
		if PLB_Clk'Event and PLB_Clk = '1' then
			if PLB_Rst = '1' then
				slave_state_current <= Slave_Idle;
				master_state_current <= Master_Idle;
			else
				slave_state_current <= slave_state_next;
				master_state_current <= master_state_next;
			end if;
		end if;
	end process CHANGE_STATE;
	
	-- sequential
	COMPUTE_LINE_TRANSPARENCY : process(PLB_Clk) is
		variable it              : std_logic;
		variable header_complete : std_logic;
		variable tf              : std_logic_vector(5 downto 0);
		variable th              : std_logic_vector(5 downto 0);
		variable transp          : std_logic_vector(3 downto 0);
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			-- current bus transparency
			transp := "0000";
			if PLB_MRdDBus(0 to 15) = transparent_color then
				transp(3) := '1';
			end if;
			if PLB_MRdDBus(16 to 31) = transparent_color then
				transp(2) := '1';
			end if;
			if PLB_MRdDBus(32 to 47) = transparent_color then
				transp(1) := '1';
			end if;
			if PLB_MRdDBus(48 to 63) = transparent_color then
				transp(0) := '1';
			end if;
			-- reset effect
			if transp_rst = '1' then
				it := '0';
				tf := "000000";
				th := "000000";
				header_complete := '0';
			else
				it := transp_it;
				tf := transp_tf;
				th := transp_th;
				header_complete := transp_header_complete;
			end if;
			-- update effect
			if transp_update = '1' then
				if header_complete = '0' then
					if transp = "1111" then
						if th = sprite_width(5 downto 0) - 4 then
							th := "111111";
							tf := "111111";
						else
							th := th + 4;
						end if;
					elsif transp(3 downto 1) = "111" then
						th := th + 3;
					elsif transp(3 downto 2) = "11" then
						th := th + 2;
					elsif transp(3 downto 3) = "1" then
						th := th + 1;
					end if;				
				end if;
				if transp = "1111" then
					if header_complete = '1' then
						tf := tf + 4;
					end if;
				elsif transp(2 downto 0) = "111" then
					if tf /= "000000" then
						it := '1';
					end if;
					tf := "000011";
				elsif transp(1 downto 0) = "11" then
					if tf /= "000000" then
						it := '1';
					end if;
					tf := "000010";
				elsif transp(0 downto 0) = "1" then
					if tf /= "000000" then
						it := '1';
					end if;
					tf := "000001";
				else
					if tf /= "000000" then
						it := '1';
					end if;
					tf := "000000";
				end if;
				if header_complete = '1' and transp(3 downto 3) = "1" and transp(2 downto 0) /= "111" then
					it := '1';
				end if;
				if transp = "0101" or transp = "1010" then
					it := '1';
				end if;
				if transp /= "1111" then
					header_complete := '1';
				end if;
			end if;
			-- final values
			transp_it <= it;
			transp_tf <= tf;
			transp_th <= th;
			transp_header_complete <= header_complete;
			sprite_transparency_ram_din <= tf & th & it;
		end if;
	end process COMPUTE_LINE_TRANSPARENCY;
	
	-- combinatorial
	MASTER_STATE : process(PLB_MAddrAck, PLB_MRdDAck, PLB_MWrDAck, master_state_current, end_line,
								  sprite_ram_addr_row, sprite_ram_addr_col, sprite_width, sprite_height, control, 
								  transparency_info_ct, skip, transparency_mask, transparency_mask_size, bg_skip,
								  source_ptr, destination_ptr, bg_ram_addr, op_length) is
	
		variable sub_width  : std_logic_vector(5 downto 0);
		variable sub_height : std_logic_vector(6 downto 0);
		
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
		M_MSize       <= "00";
		M_ordered     <= '0';
		M_rdBurst     <= '0';
		M_wrBurst     <= '0';
		
		sprite_ram_we              <= "0";
		sprite_ram_addr_rst        <= '0';
		sprite_ram_addr_inc        <= '0';
		sprite_ram_addr_next_line  <= '0';
		sprite_ram_addr_skip       <= '0';
		bg_ram_we                  <= "0";
		bg_ram_addr_rst            <= '0';
		bg_ram_addr_inc            <= '0';
		control_rst                <= '0';
		source_ptr_rst             <= '0';
		source_ptr_next_line       <= '0';
		destination_ptr_rst        <= '0';
		destination_ptr_next_line  <= '0';
		sprite_transparency_ram_we <= "0";
		master_state_next          <= master_state_current;
		transp_rst                 <= '0';
		transp_update              <= '0';
		transp_computing           <= '0';
		write_operation            <= '0';
		debug_master_state         <= "0000";

		Isprite_Interrupt          <= '0';
				
		case master_state_current is
		
			when Master_Idle =>
				sprite_ram_addr_rst <= '1';
				destination_ptr_rst <= '1';
				source_ptr_rst <= '1';
				bg_ram_addr_rst <= '1';
				if control(0) = '1' then
					master_state_next <= Master_Sprite_Radd;
					control_rst <= '1';
				elsif control(1) = '1' then
					master_state_next <= Master_StartBlitLine_Delayed;
					control_rst <= '1';
				end if;
				debug_master_state <= "0000";
			
			when Master_Sprite_Radd =>
				transp_rst <= '1';
				M_request <= '1';
				M_priority <= "00";
				M_RNW <= '1';
				M_size <= "1011"; -- burst transfert, double words, terminated by master
				M_ABus <= source_ptr;
				transp_computing <= '1';
				if PLB_MAddrAck = '1' then
					master_state_next <= Master_Sprite_Read1;
					transp_update <= '1';
				end if;
				debug_master_state <= "0001";
			
			when Master_Sprite_Read1 =>
				sub_width := sprite_width(7 downto 2) - 1;
				sub_height := sprite_height(6 downto 0) - 1;
				if PLB_MRdDAck = '1' then
					if sprite_ram_addr_col(3 downto 0) = sub_width(3 downto 0) then -- end of sprite line
						if sprite_ram_addr_row = sub_height(5 downto 0) then -- end of whole sprite
							sprite_ram_addr_inc <= '1';
							master_state_next <= Master_Sprite_ReadEnded;
							M_rdBurst <= '0';
							transp_computing <= '0';
						else
							sprite_ram_addr_next_line <= '1';
							M_rdBurst <= '1';
							transp_computing <= '1';
						end if;
					else
						M_rdBurst <= '1';
						sprite_ram_addr_inc <= '1';
						transp_computing <= '1';
					end if;
					if sprite_ram_addr_col = "00000" then -- beginning of a new line
						transp_rst <= '1';
						sprite_transparency_ram_we <= "1";
					end if;
					sprite_ram_we <= "1";
					transp_update <= '1';
				else
					M_rdBurst <= '1';
					transp_computing <= '1';
				end if;
				debug_master_state <= "0010";
				
			when Master_Sprite_ReadEnded =>
				sprite_transparency_ram_we <= "1";
				master_state_next <= Master_Ended;
				debug_master_state <= "0011";

			when Master_StartBlitLine_Delayed =>
				-- to get new transparency_info
				write_operation <= '1';
				master_state_next <= Master_StartBlitLine_Delayed2;
				debug_master_state <= "0100";

			when Master_StartBlitLine_Delayed2 =>
				-- to compute PRE_TRANSPARENCY
				write_operation <= '1';
				master_state_next <= Master_StartBlitLine_Delayed3;
				debug_master_state <= "0100";

			when Master_StartBlitLine_Delayed3 =>
				-- to compute POST_TRANSPARENCY
				write_operation <= '1';
				master_state_next <= Master_StartBlitLine;
				debug_master_state <= "0100";

			when Master_StartBlitLine =>
				write_operation <= '1';
				if transparency_info_ct = '1' or op_length = 0 then -- skipline
					sprite_ram_addr_next_line <= '1';
					destination_ptr_next_line <= '1';
					if sprite_ram_addr_row = end_line then -- end of whole sprite
						master_state_next <= Master_Ended;
					else
						master_state_next <= Master_StartBlitLine_Delayed;
					end if;
				else
					sprite_ram_addr_skip <= '1';
					if bg_skip = '1' then
						master_state_next <= Master_Bg_Skip;
					else
						master_state_next <= Master_Bg_Radd;
					end if;
				end if;
				debug_master_state <= "0101";
			
			when Master_Bg_Skip =>
				write_operation <= '1';
				master_state_next <= Master_Wadd;
				debug_master_state <= "0111";
			
			when Master_Bg_Radd =>
				write_operation <= '1';
				if PLB_MAddrAck = '1' then
					if op_length = 1 then
						master_state_next <= Master_Bg_ReadSingle;
					else
						master_state_next <= Master_Bg_ReadBurst;
					end if;
				end if;
				if op_length = 1 then
					-- single double-word read
					M_size <= "0000";
					M_BE <= "11111111";
				else
					-- burst read, double-words, terminated by master
					M_size <= "1011"; 
				end if;
				M_request <= '1';
				M_priority <= "00";
				M_RNW <= '1';
				M_ABus <= (destination_ptr(31 downto 3) + skip) & "000";
				bg_ram_addr_rst <= '1';
				debug_master_state <= "1000";
			
			when Master_Bg_ReadBurst =>
				write_operation <= '1';
				sub_width := op_length - 1;
				if PLB_MRdDAck = '1' then
					bg_ram_we <= "1";
					if bg_ram_addr(4 downto 0) = sub_width(4 downto 0) then -- end of sprite line
						M_rdBurst <= '0';
						bg_ram_addr_rst <= '1';
						master_state_next <= Master_Wadd;
					else
						M_rdBurst <= '1';
						bg_ram_addr_inc <= '1';
					end if;
				else
					M_rdBurst <= '1';
				end if;
				debug_master_state <= "1001";

			when Master_Bg_ReadSingle =>
				write_operation <= '1';
				if PLB_MRdDAck = '1' then
					bg_ram_we <= "1";
					bg_ram_addr_rst <= '1';
					master_state_next <= Master_Wadd;
				end if;
				debug_master_state <= "1010";

			when Master_Wadd =>
				if PLB_MAddrAck = '1' then
					if op_length = 1 then
						master_state_next <= Master_WriteSingle;
					else
						sprite_ram_addr_inc <= '1'; -- WARNING: PLB_MWrDAck is not working here
						bg_ram_addr_inc <= '1'; -- WARNING: PLB_MWrDAck is not working here
						master_state_next <= Master_WriteBurst;
					end if;
				end if;
				if op_length = 1 then
					-- single double-word write
					M_size <= "0000";
					M_BE <= transparency_mask;
					M_ABus <= (destination_ptr(31 downto 3) + skip) & transparency_mask_size & "0";
				else
					-- burst write, double-words, terminated by master
					M_size <= "1011";
					M_ABus <= (destination_ptr(31 downto 3) + skip) & "000";
				end if;				
				M_request <= '1';
				M_priority <= "00";
				M_wrBurst <= '1';
				write_operation <= '1';
				debug_master_state <= "1011";
				
			when Master_WriteBurst =>
				M_wrBurst <= '1';
				write_operation <= '1';
				sub_width := skip + op_length - 1;
				if PLB_MWrDAck = '1' then
					if sprite_ram_addr_col = sub_width(4 downto 0) then -- end of sprite line
						if sprite_ram_addr_row = end_line then -- end of whole sprite
							master_state_next <= Master_Ended;
						else
							master_state_next <= Master_StartBlitLine_Delayed;
							sprite_ram_addr_next_line <= '1';
							destination_ptr_next_line <= '1';
						end if;
					else
						sprite_ram_addr_inc <= '1';
						bg_ram_addr_inc <= '1';
					end if;
				end if;
				debug_master_state <= "1100";

			when Master_WriteSingle =>
				write_operation <= '1';
				if PLB_MWrDAck = '1' then
					if sprite_ram_addr_row = end_line then -- end of whole sprite
						master_state_next <= Master_Ended;
					else
						master_state_next <= Master_StartBlitLine_Delayed;
						destination_ptr_next_line <= '1';
						sprite_ram_addr_next_line <= '1';
					end if;
				end if;
				debug_master_state <= "1101";
							
			when Master_Ended =>
				write_operation <= '1';
				Isprite_Interrupt <= '1';
				master_state_next <= Master_Idle;
				debug_master_state <= "1111";
				
			when others =>
				null;

		end case;
	end process MASTER_STATE;

	-- combinatorial
	SLAVE_STATE : process(slave_state_current, slave_slice, PLB_PAValid, PLB_ABus, PLB_RNW,
								 control, source, framebuffer, sprite_size, sprite_coord) is
	begin
		Sl_addrAck <= '0';
		Sl_rdComp  <= '0';
		Sl_rdDAck  <= '0';
		Sl_wrDAck  <= '0';
		Sl_wrComp  <= '0';
		Sl_wait    <= '0';
		Sl_rdDBus  <= X"0000000000000000";
		
		slave_slice_we   <= '0';
		control_we       <= '0';		
		source_we        <= '0';
		framebuffer_we   <= '0';
		sprite_size_we   <= '0';
		sprite_coord_we  <= '0';
		slave_state_next <= slave_state_current;
		
		case slave_state_current is
			
			when Slave_Idle =>
				if PLB_PAValid = '1' and PLB_ABus >= C_BASEADDR and PLB_ABus <= C_HIGHADDR	then
					slave_state_next <= Slave_AddAck;
					Sl_wait <= '1';
					slave_slice_we <= '1';
				end if;
				
			when Slave_AddAck => -- Read address and record it into slave_slice.  
				Sl_wait <= '1';
				Sl_addrAck <= '1';
				if PLB_RNW = '1' then
					slave_state_next <= Slave_Read;
				else
					slave_state_next <= Slave_Write;
				end if;
			
			when Slave_Read =>
				Sl_rdComp <= '1';
				case slave_slice(26 to 28) is
					when "000" =>
						Sl_rdDBus(32 to 63) <= control;
					when "001" =>
						Sl_rdDBus(32 to 63) <= source;
					when "010" =>
						Sl_rdDBus(32 to 63) <= framebuffer;
					when "011" =>
						Sl_rdDBus(32 to 63) <= sprite_size;
					when "100" =>
						Sl_rdDBus(32 to 63) <= sprite_coord;
					when others =>
						null;
				end case;
				Sl_rdDBus(0 to 31) <= X"00000000";
				slave_state_next <= Slave_Read2;
			
			when Slave_Read2 =>
				Sl_rdDAck <= '1';
								case slave_slice(26 to 28) is
					when "000" =>
						Sl_rdDBus(32 to 63) <= control;
					when "001" =>
						Sl_rdDBus(32 to 63) <= source;
					when "010" =>
						Sl_rdDBus(32 to 63) <= framebuffer;
					when "011" =>
						Sl_rdDBus(32 to 63) <= sprite_size;
					when "100" =>
						Sl_rdDBus(32 to 63) <= sprite_coord;
					when others =>
						null;
				end case;
				Sl_rdDBus(0 to 31) <= X"00000000";
				slave_state_next <= Slave_Idle;
			
			when Slave_Write =>
				Sl_wrComp <= '1';
				case slave_slice(26 to 28) is
					when "000" =>
						control_we <= '1';
					when "001" =>
						source_we <= '1';
					when "010" =>
						framebuffer_we <= '1';
					when "011" =>
						sprite_size_we <= '1';
					when "100" =>
						sprite_coord_we <= '1';
					when others =>
						null;
				end case;
				slave_state_next <= Slave_Write2;
			
			when Slave_Write2 =>
				Sl_wrDAck <= '1';
				slave_state_next <= Slave_Idle;
		
			when others =>
				null;
		
		end case;
	end process SLAVE_STATE;
	
end IMP;
