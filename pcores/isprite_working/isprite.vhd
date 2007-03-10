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
	 Isprite_Debug						  : out std_logic_vector(127 downto 0);
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

	constant line_width              : std_logic_vector(31 downto 0) := X"00000280"; -- 320 * 2
	constant transparent_color       : std_logic_vector(15 downto 0) := "1111100000011111"; -- Pink

	signal slave_slice               : std_logic_vector(0 to 31) := (others => '0');
	signal slave_slice_we            : std_logic := '0';

	signal control                   : std_logic_vector(31 downto 0) := (others => '0');
	signal control_we                : std_logic := '0';
	signal control_rst               : std_logic := '0';
	signal source                    : std_logic_vector(31 downto 0) := (others => '0');
	signal source_we                 : std_logic := '0';
	signal destination               : std_logic_vector(31 downto 0) := (others => '0');
	signal destination_we            : std_logic := '0';
	signal sprite_size               : std_logic_vector(31 downto 0) := (others => '0');
	signal sprite_size_we            : std_logic := '0';
	
	signal sprite_width              : std_logic_vector(15 downto 0) := (others => '0');
	signal sprite_height             : std_logic_vector(15 downto 0) := (others => '0');

	signal sprite_ram_addr           : std_logic_vector(9 downto 0) := (others => '0');
	signal sprite_ram_addr_col       : std_logic_vector(4 downto 0) := (others => '0');
	signal sprite_ram_addr_row       : std_logic_vector(5 downto 0) := (others => '0');
	signal sprite_ram_addr_rst       : std_logic := '0';
	signal sprite_ram_addr_inc       : std_logic := '0';
	signal sprite_ram_addr_next_line : std_logic := '0';
	signal sprite_ram_we             : std_logic_vector(0 downto 0) := (others => '0');
	signal sprite_ram_out            : std_logic_vector(63 downto 0) := (others => '0'); -- raw sprite_ram busa+busb output
	
	signal source_ptr                : std_logic_vector(31 downto 0) := (others => '0');
	signal source_ptr_rst            : std_logic := '0';
	signal source_ptr_next_line      : std_logic := '0';

	type Master_State_Machine is (Master_Idle,
										   Master_StartBlit,
											Master_Sprite_Radd,
											Master_Sprite_Read1,
											Master_Sprite_ReadEnded,
											Master_Bg_Radd,
											Master_Bg_ReadBurst,
											Master_Bg_ReadSingle,
											Master_Ended,
											Master_Wadd,
											Master_Write_SkipLine,
											Master_WriteBurst,
											Master_WriteSingle,
											Master_Write2);

	type Slave_State_Machine is (Slave_Idle,
										  Slave_AddAck,
										  Slave_Read,
										  Slave_Read2,
										  Slave_Write,
										  Slave_Write2);
	
	
	signal master_state_current : Master_State_Machine := Master_Idle;
	signal master_state_next : Master_State_Machine := Master_Idle;
	signal slave_state_current : Slave_State_Machine := Slave_Idle;
	signal slave_state_next : Slave_State_Machine := Slave_Idle;
	
	signal start_read_sprite : std_logic := '0';
	signal start_write_sprite : std_logic := '0';
	signal master_started_operation : std_logic := '0';
	
	signal debug_master_state : std_logic_vector(3 downto 0) := (others => '0');

	component sprite_ram
	port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(63 downto 0);
		addra: IN std_logic_VECTOR(9 downto 0);
		wea: IN std_logic_VECTOR(0 downto 0);
		douta: OUT std_logic_VECTOR(63 downto 0));
	end component;
	
begin

	the_sprite_ram : sprite_ram
		port map (
			clka => PLB_Clk,
			dina => PLB_MRdDBus,
			addra => sprite_ram_addr,
			wea => sprite_ram_we,
			douta => sprite_ram_out);

	Isprite_Debug(127 downto 64) <= sprite_ram_out;

	sprite_width <= sprite_size(31 downto 16);
	sprite_height <= sprite_size(15 downto 0);
	
	sprite_ram_addr <= sprite_ram_addr_row & sprite_ram_addr_col(3 downto 0);
	
	sprite_transparency_ram_din <= transp_tf & transp_th & transp_it;
	
	sprite_ram_we_vec(0) <= sprite_ram_we;
	bg_ram_we_vec(0) <= bg_ram_we;
	sprite_transparency_ram_we_vec(0) <= sprite_transparency_ram_we;

	transparency_info_it <= transparency_info(0);
	transparency_info_th <= transparency_info(6 downto 1);
	transparency_info_tf <= transparency_info(12 downto 7);
	
	-- combinatorial
	GENERATE_SKIP_ENDPREM : process(transparency_info_th, transparency_info_tf, shift) is
		variable total_th : std_logic_vector(6 downto 0);
		variable total_tf : std_logic_vector(6 downto 0);
	begin
		case shift is
			when "00" =>
				skip <= "0" & transparency_info_th(5 downto 2);
				endprem <= "0" & transparency_info_tf(5 downto 2);	
			when "01" =>
				total_th := ("0" & transparency_info_th) + 1;
				total_tf := ("0" & transparency_info_tf) + 3;
				skip <= total_th(6 downto 2);
				endprem <= total_tf(6 downto 2);
			when "10" =>
				total_th := ("0" & transparency_info_th) + 2;
				total_tf := ("0" & transparency_info_tf) + 2;
				skip <= total_th(6 downto 2);
				endprem <= total_tf(6 downto 2);
			when "11" =>
				total_th := ("0" & transparency_info_th) + 3;
				total_tf := ("0" & transparency_info_tf) + 1;
				skip <= total_th(6 downto 2);
				endprem <= total_tf(6 downto 2);
			when others =>
				null;
		end case;
	end process GENERATE_SKIP_ENDPREM;
	
	-- combinatorial
	GENERATE_OP_LENGTH : process(sprite_width, skip, endprem, shift) is
	begin
		if shift = "00" then
			op_length <= sprite_width(6 downto 2) - skip - endprem;
		else
			op_length <= sprite_width(6 downto 2) - skip - endprem + 1;
		end if;
	end process GENERATE_OP_LENGTH;
	
	-- combinatorial
	GENERATE_SHIFT : process(destination) is
	begin
		case destination(2 downto 1) is
			when "00" =>
				shift <= "00";
			when "01" =>
				shift <= "11";
			when "10" =>
				shift <= "10";
			when "11" =>
				shift <= "01";
			when others =>
				null;
		end case;
	end process GENERATE_SHIFT;
	
	-- sequential
	MANAGE_SPRITE_SKIP_BUFFER : process(PLB_Clk, sprite_ram_addr_col, sprite_ram_out) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if sprite_ram_addr_col = "00000" then
				sprite_skip_buffer <= transparent_color & transparent_color & transparent_color;
			else
				case shift is
					when "01" =>
						sprite_skip_buffer <= sprite_ram_out(47 downto 0);
					when "10" =>
						sprite_skip_buffer(47 downto 32) <= (others => '0');
						sprite_skip_buffer(31 downto 0) <= sprite_ram_out(31 downto 0);
					when "11" =>
						sprite_skip_buffer(47 downto 16) <= (others => '0');
						sprite_skip_buffer(15 downto 0) <= sprite_ram_out(15 downto 0);
					when others =>
						sprite_skip_buffer <= (others => '0');
				end case;
			end if;			
		end if;
	end process MANAGE_SPRITE_SKIP_BUFFER;
	
	-- combinatorial
	GENERARE_SPRITE_DATA : process(sprite_ram_out, shift, sprite_skip_buffer, sprite_ram_addr_col, op_length) is
	begin
		if sprite_ram_addr_col = op_length then
			case shift is
				when "00" =>
					sprite_data <= sprite_ram_out;
				when "01" =>
					sprite_data <= sprite_skip_buffer(47 downto 0) & transparent_color;
				when "10" =>
					sprite_data <= sprite_skip_buffer(31 downto 0) & transparent_color & transparent_color;
				when "11" =>
					sprite_data <= sprite_skip_buffer(15 downto 0) & transparent_color & transparent_color & transparent_color;
				when others =>
					null;
			end case;
		else
			case shift is
				when "00" =>
					sprite_data <= sprite_ram_out;
				when "01" =>
					sprite_data <= sprite_skip_buffer(47 downto 0) & sprite_ram_out(63 downto 48);
				when "10" =>
					sprite_data <= sprite_skip_buffer(31 downto 0) & sprite_ram_out(63 downto 32);
				when "11" =>
					sprite_data <= sprite_skip_buffer(15 downto 0) & sprite_ram_out(63 downto 16);
				when others =>
					null;
			end case;
		end if;
	end process GENERARE_SPRITE_DATA;
	
	-- combinatorial
	GENERATE_SPRITE_TRANSPARENCY_RAM_ADDR : process(master_state_current, sprite_ram_addr) is
	begin
		if master_state_current = Master_Sprite_Read1 then
			sprite_transparency_ram_addr <= sprite_ram_addr(9 downto 4) - 1;
		else
			sprite_transparency_ram_addr <= sprite_ram_addr(9 downto 4);
		end if;
	end process GENERATE_SPRITE_TRANSPARENCY_RAM_ADDR;
	
	-- combinatorial
	GENERATE_WRITE_DATA : process(sprite_data, bg_ram_out) is
				--transparency_info_it, transparency_info_th, transparency_info_tf) is
	begin
		--if transparency_info_it = '1' or transparency_info_th /= "000000" or transparency_info_tf /= "000000" then
			if sprite_data(63 downto 48) = transparent_color then
				M_wrDBus(0 to 15) <= bg_ram_out(63 downto 48);
			else
				M_wrDBus(0 to 15) <= sprite_data(63 downto 48);
			end if;
			if sprite_data(47 downto 32) = transparent_color then
				M_wrDBus(16 to 31) <= bg_ram_out(47 downto 32);
			else
				M_wrDBus(16 to 31) <= sprite_data(47 downto 32);
			end if;
			if sprite_data(31 downto 16) = transparent_color then
				M_wrDBus(32 to 47) <= bg_ram_out(31 downto 16);
			else
				M_wrDBus(32 to 47) <= sprite_data(31 downto 16);
			end if;
			if sprite_data(15 downto 0) = transparent_color then
				M_wrDBus(48 to 63) <= bg_ram_out(15 downto 0);
			else
				M_wrDBus(48 to 63) <= sprite_data(15 downto 0);
			end if;
		--else
		--	M_wrDBus <= sprite_data;
		--end if;
	end process GENERATE_WRITE_DATA;

	-- sequential
	UPDATE_SLAVE_SLICE : process(PLB_Clk, slave_slice_we, PLB_ABus) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if slave_slice_we = '1' then
				slave_slice <= PLB_ABus - C_BASEADDR;
			end if;
		end if;	
	end process UPDATE_SLAVE_SLICE;

	-- sequential
	UPDATE_SOURCE : process(PLB_Clk, source_we, PLB_wrDBus) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if source_we = '1' then
				source <= PLB_wrDBus(32 to 63);
			end if;
		end if;	
	end process UPDATE_SOURCE;

	-- sequential
	UPDATE_DESTINATION : process(PLB_Clk, destination_we, PLB_wrDBus) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if destination_we = '1' then
				destination <= PLB_wrDBus(32 to 63);
			end if;
		end if;	
	end process UPDATE_DESTINATION;

	-- sequential
	UPDATE_SPRITE_SIZE : process(PLB_Clk, sprite_size_we, PLB_wrDBus) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if sprite_size_we = '1' then
				sprite_size <= PLB_wrDBus(32 to 63);
			end if;
		end if;	
	end process UPDATE_SPRITE_SIZE;

	-- sequential
	UPDATE_CONTROL : process(PLB_Clk, control_rst, control_we, PLB_wrDBus) is
	begin
		if control_rst = '1' then
			control <= X"00000000";
		elsif PLB_Clk'event and PLB_Clk = '1' then
			if control_we = '1' then
				control <= PLB_wrDBus(32 to 63);
			end if;
		end if;	
	end process UPDATE_CONTROL;

	-- sequential
	UPDATE_SPRITE_RAM_ADDR : process(PLB_Clk, sprite_ram_addr_rst, sprite_ram_addr_next_line, sprite_ram_addr_skip, 
												sprite_ram_addr_inc, sprite_ram_addr_col, sprite_ram_addr_row, skip) is
	begin
		if sprite_ram_addr_rst = '1' then
			sprite_ram_addr_row <= (others => '0');
			sprite_ram_addr_col <= (others => '0');
		elsif PLB_Clk'Event and PLB_Clk = '1' then
			if sprite_ram_addr_next_line = '1' then
				sprite_ram_addr_row <= sprite_ram_addr_row + 1;
				sprite_ram_addr_col <= (others => '0');
			elsif sprite_ram_addr_skip = '1' then
				sprite_ram_addr_col <= skip;
			elsif sprite_ram_addr_inc = '1' then
				sprite_ram_addr_col <= sprite_ram_addr_col + 1;
			end if;
		end if;
	end process UPDATE_SPRITE_RAM_ADDR;

	-- sequential
	UPDATE_BG_RAM_ADDR : process(PLB_Clk, bg_ram_addr_rst, bg_ram_addr_inc, bg_ram_addr, skip) is
	begin
		if bg_ram_addr_rst = '1' then
			bg_ram_addr <= "0" & skip;
		elsif PLB_Clk'Event and PLB_Clk = '1' then
			if bg_ram_addr_inc = '1' then
				bg_ram_addr <= bg_ram_addr + 1;
			end if;
		end if;
	end process UPDATE_BG_RAM_ADDR;

	-- sequential
	UPDATE_SOURCE_PTR : process(PLB_Clk, source_ptr_rst, source_ptr_next_line, source_ptr, source) is
	begin
		if source_ptr_rst = '1' then
			source_ptr <= source;
		elsif PLB_Clk'Event and PLB_Clk = '1' then
			if source_ptr_next_line = '1' then
				source_ptr <= source_ptr + sprite_width;
			end if;
		end if;
	end process UPDATE_SOURCE_PTR;
	
	-- sequential
	UPDATE_DESTINATION_PTR : process(PLB_Clk, destination_ptr_rst, destination_ptr_next_line, destination_ptr, destination) is
	begin
		if destination_ptr_rst = '1' then
			destination_ptr <= destination;
		elsif PLB_Clk'Event and PLB_Clk = '1' then
			if destination_ptr_next_line = '1' then
				destination_ptr <= destination_ptr + line_width;
			end if;
		end if;
	end process UPDATE_DESTINATION_PTR;

	-- sequential
	CHANGE_STATE : process(PLB_Clk, PLB_Rst, slave_state_next, master_state_next) is
	begin
		if PLB_Rst = '1'  then
			slave_state_current <= Slave_Idle;
			master_state_current <= Master_Idle;
		elsif PLB_Clk'Event and PLB_Clk = '1' then
			slave_state_current <= slave_state_next;
			master_state_current <= master_state_next;    
		end if;
	end process CHANGE_STATE;
	
	-- sequential
	GENERATE_START_SIGNALS : process(PLB_Clk, master_started_operation, control) is
	begin
		if PLB_Clk'Event and PLB_Clk = '1' then
			control_rst <= '0';
			if master_started_operation = '1' then
				start_read_sprite <= '0';
				start_write_sprite <= '0';				
			elsif control(0) = '1' then
				control_rst <= '1';
				start_read_sprite <= '1';
			elsif control(1) = '1' then
				control_rst <= '1';
				start_write_sprite <= '1';
			end if;
		end if;
	end process GENERATE_START_SIGNALS;
	
	-- sequential
--	GENERATE_INTERRUPT : process(PLB_Clk, master_state_current) is
--	begin
--		if PLB_Clk'Event and PLB_Clk = '1' then
--			if master_state_current = Master_Ended then
--				Isprite_Interrupt <= '1';
--			else
--				Isprite_Interrupt <= '0';
--			end if;
--		end if;
--	end process GENERATE_INTERRUPT;
	
	-- sequential
	COMPUTE_LINE_TRANSPARENCY : process(PLB_Clk, PLB_MRdDBus, transp_rst, transp_it, transp_tf, transp_th, transp_header_complete, sprite_width) is
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
		end if;
	end process COMPUTE_LINE_TRANSPARENCY;

	-- combinatorial
	MASTER_STATE : process(PLB_MAddrAck, PLB_MRdDAck, PLB_MWrDAck, master_state_current, 
								  start_read_sprite, start_write_sprite, sprite_ram_addr_row, sprite_ram_addr_col, sprite_width,
								  transparency_info_it, transparency_info_tf, transparency_info_th, skip, 
								  source_ptr, sprite_height, destination_ptr, bg_ram_addr, endprem, op_length) is

		variable sub_width : std_logic_vector(4 downto 0);
		variable sub_height : std_logic_vector(6 downto 0);
		
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
		master_started_operation <= '0';
		sprite_ram_we <= '0';
		sprite_ram_addr_rst <= '0';
		sprite_ram_addr_inc <= '0';
		sprite_ram_addr_next_line <= '0';
		sprite_ram_addr_skip <= '0';
		bg_ram_we <= '0';
		bg_ram_addr_rst <= '0';
		bg_ram_addr_inc <= '0';
		source_ptr_rst <= '0';
		source_ptr_next_line <= '0';
		destination_ptr_rst <= '0';
		destination_ptr_next_line <= '0';
		sprite_transparency_ram_we <= '0';
		master_state_next <= master_state_current;
		transp_rst <= '0';
		transp_update <= '0';
		debug_master_state <= "0000";
		
		case master_state_current is
		
			when Master_Idle =>
				sprite_ram_addr_rst <= '1';
				destination_ptr_rst <= '1';
				source_ptr_rst <= '1';
				bg_ram_addr_rst <= '1';
				if start_read_sprite = '1' then
					master_state_next <= Master_Sprite_Radd;
					master_started_operation <= '1';
				elsif start_write_sprite = '1' then
					master_state_next <= Master_StartBlit;
					master_started_operation <= '1';
				end if;
				debug_master_state <= "0000";
			
			when Master_Sprite_Radd =>
				transp_rst <= '1';
				M_request <= '1';
				M_priority <= "00";
				M_RNW <= '1';
				M_size <= "1011"; -- burst transfert, double words, terminated by master
				M_ABus <= source_ptr;
				if PLB_MAddrAck = '1' then
					master_state_next <= Master_Sprite_Read1;
					transp_update <= '1';
				end if;
				debug_master_state <= "0001";
			
			when Master_Sprite_Read1 =>
				sub_width := sprite_width(6 downto 2) - 1;
				sub_height := sprite_height(6 downto 0) - 1;
				if PLB_MRdDAck = '1' then
					if sprite_ram_addr_col(3 downto 0) = sub_width(3 downto 0) then -- end of sprite line
						if sprite_ram_addr_row = sub_height(5 downto 0) then -- end of whole sprite
							sprite_ram_addr_inc <= '1';
							master_state_next <= Master_Sprite_ReadEnded;
							M_rdBurst <= '0';
						else
							sprite_ram_addr_next_line <= '1';
							M_rdBurst <= '1';
						end if;
					else
						M_rdBurst <= '1';
						sprite_ram_addr_inc <= '1';
					end if;
					if sprite_ram_addr_col = "00000" then -- beginning of a new line
						transp_rst <= '1';
						sprite_transparency_ram_we <= '1';						
					end if;
					sprite_ram_we <= '1';
					transp_update <= '1';
				else
					M_rdBurst <= '1';
				end if;
				debug_master_state <= "0010";
				
			when Master_Sprite_ReadEnded =>
				sprite_transparency_ram_we <= '1';						
				master_state_next <= Master_Ended;
				debug_master_state <= "0011";	

			when Master_StartBlit =>
--				if transparency_info_th = "111111" and transparency_info_tf = "111111" then
--					sprite_ram_addr_next_line <= '1';
--					destination_ptr_next_line <= '1';
--					master_state_next <= Master_Write_SkipLine;
--				elsif transparency_info_it = '1' or transparency_info_th /= "000000" or transparency_info_tf /= "000000" then
					master_state_next <= Master_Bg_Radd;
--				else
--					master_state_next <= Master_Wadd;
--				end if;
				debug_master_state <= "0100";
				
			when Master_Bg_Radd =>
				if op_length = "00001" then
					-- single double-word transfer
					M_size <= "0000";
					M_BE <= "11111111";
				else
					-- burst transfert, double-words, terminated by master
					M_size <= "1011"; 
				end if;
				M_request <= '1';
				M_priority <= "00";
				M_RNW <= '1';
				M_ABus <= (destination_ptr(31 downto 3) + skip) & "000";
				sprite_ram_addr_skip <= '1';
				bg_ram_addr_rst <= '1';
				if PLB_MAddrAck = '1' then
					if op_length = "00001" then
						master_state_next <= Master_Bg_ReadSingle;
					else
						master_state_next <= Master_Bg_ReadBurst;
					end if;
				end if;
				debug_master_state <= "0110";
			
			when Master_Bg_ReadBurst =>
				sub_width := skip + op_length - 1;
				if PLB_MRdDAck = '1' then
					bg_ram_we <= '1';
					if bg_ram_addr(4 downto 0) = sub_width then -- end of sprite line
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
				debug_master_state <= "1000";

			when Master_Bg_ReadSingle =>
				if PLB_MRdDAck = '1' then
					bg_ram_we <= '1';
					bg_ram_addr_rst <= '1';
					master_state_next <= Master_Wadd;
				end if;
				debug_master_state <= "1100";

			when Master_Wadd =>
--				if transparency_info_th = "111111" and transparency_info_tf = "111111" then -- completely transparent line
--					sprite_ram_addr_next_line <= '1';
--					destination_ptr_next_line <= '1';
--					master_state_next <= Master_Write_SkipLine;
--				else
					if op_length = "00001" then
						-- single double-word transfer
						M_size <= "0000";
						M_BE <= "11111111";
					else
						-- burst transfert, double-words, terminated by master
						M_size <= "1011"; 
					end if;				
					M_request <= '1';
					M_priority <= "00";
					M_ABus <= (destination_ptr(31 downto 3) + skip) & "000";
					M_wrBurst <= '1';
					if PLB_MAddrAck = '1' then
						sprite_ram_addr_inc <= '1'; -- PLB_MWrDAck not working: why?
						bg_ram_addr_inc <= '1'; -- PLB_MWrDAck not working: why?
						if op_length = "00001" then
							master_state_next <= Master_WriteSingle;
						else
							master_state_next <= Master_WriteBurst;
						end if;
					end if;
--				end if;
				debug_master_state <= "1001";
				
			when Master_Write_SkipLine =>
				-- Just to give time to read the new transparency info
				master_state_next <= Master_Wadd;
				debug_master_state <= "1100";
			
			when Master_WriteBurst =>
				M_wrBurst <= '1';
				sub_width := skip + op_length - 1;
				sub_height := sprite_height(6 downto 0) - 1;
				if PLB_MWrDAck = '1' then
					sprite_ram_addr_inc <= '1';
					if sprite_ram_addr_col = sub_width then -- end of sprite line
						if sprite_ram_addr_row = sub_height(5 downto 0) then -- end of whole sprite
							master_state_next <= Master_Ended;
						else
							master_state_next <= Master_Write2;
							destination_ptr_next_line <= '1';
						end if;
					else
						bg_ram_addr_inc <= '1';
					end if;
				end if;
				debug_master_state <= "1010";

			when Master_WriteSingle =>
				sub_height := sprite_height(6 downto 0) - 1;
				if PLB_MWrDAck = '1' then
					if sprite_ram_addr_row = sub_height(5 downto 0) then -- end of whole sprite
						master_state_next <= Master_Ended;
					else
						master_state_next <= Master_Write2;
						destination_ptr_next_line <= '1';
					end if;
				end if;
				debug_master_state <= "1101";
				
			when Master_Write2 =>
				sprite_ram_addr_next_line <= '1';
				master_state_next <= Master_Bg_Radd;
				debug_master_state <= "1011";
				
			when Master_Ended =>
				sprite_ram_addr_rst <= '1';
				destination_ptr_rst <= '1';
				source_ptr_rst <= '1';
				master_state_next <= Master_Idle;
				debug_master_state <= "1111";

		end case;
	end process MASTER_STATE;

	-- combinatorial
	SLAVE_STATE : process(PLB_PAValid, PLB_ABus, PLB_RNW, slave_state_current, 
                         slave_slice, control, source, destination, sprite_size) is
	begin
	
		Sl_addrAck <= '0';
		Sl_rdComp <= '0';
		Sl_rdDAck <= '0';
		Sl_wrDAck <= '0';
		Sl_wrComp <= '0';
		Sl_wait <= '0';
		Sl_rdDBus <= (others => '0');
--		Sl_MErr <= (others => '0');
--		Sl_rearbitrate <= '0';
--		Sl_wrBTerm <= '0';
--		Sl_SSize <= (others => '0');
--		Sl_MBusy <= (others => '0');
--		Sl_rdWdAddr <= (others => '0');
--		Sl_rdBTerm <= '0';
		slave_slice_we <= '0';
		control_we <= '0';
		source_we <= '0';
		destination_we <= '0';
		sprite_size_we <= '0';
		slave_state_next <= slave_state_current;
		
		case slave_state_current is
			
			when Slave_Idle =>
				if PLB_PAValid = '1' and PLB_ABus >= C_BASEADDR and PLB_ABus <= C_HIGHADDR	then
					slave_state_next <= Slave_AddAck;
					Sl_wait <= '1';
					slave_slice_we <= '1';
				end if;
				
			when Slave_AddAck => -- Read Address and record it into slave_slice.  
				Sl_wait <= '1';
				Sl_addrAck <= '1';
				if PLB_RNW = '1' then
					slave_state_next <= Slave_Read;
				else
					slave_state_next <= Slave_Write;
				end if; 
			
			when Slave_Read => -- Read data to plb
				Sl_rdComp <= '1';
				case slave_slice(27 to 28) is
					when "00" =>
						Sl_rdDBus(32 to 63) <= control;
					when "01" =>
						Sl_rdDBus(32 to 63) <= source;
					when "10" =>
						Sl_rdDBus(32 to 63) <= destination;
					when "11" =>
						Sl_rdDBus(32 to 63) <= sprite_size;
					when others =>
						null;
				end case;
				slave_state_next <= Slave_Read2;
			
			when Slave_Read2 =>
				Sl_rdDAck <= '1';
				case slave_slice(27 to 28) is
					when "00" =>
						Sl_rdDBus(32 to 63) <= control;
					when "01" =>
						Sl_rdDBus(32 to 63) <= source;
					when "10" =>
						Sl_rdDBus(32 to 63) <= destination;
					when "11" =>
						Sl_rdDBus(32 to 63) <= sprite_size;
					when others =>
						null;
				end case;
				slave_state_next <= Slave_Idle;
			
			when Slave_Write =>
				Sl_wrComp <= '1';
				case slave_slice(27 to 28) is
					when "00" =>
						control_we <= '1';
					when "01" =>
						source_we <= '1';
					when "10" =>
						destination_we <= '1';
					when "11" =>
						sprite_size_we <= '1';
					when others =>
						null;
				end case;
				slave_state_next <= Slave_Write2;
			
			when Slave_Write2 =>
				Sl_wrDAck <= '1';
				case slave_slice(27 to 28) is
					when "00" =>
						control_we <= '1';
					when "01" =>
						source_we <= '1';
					when "10" =>
						destination_we <= '1';
					when "11" =>
						sprite_size_we <= '1';
					when others =>
						null;
				end case;
				slave_state_next <= Slave_Idle;
		
		end case;
	end process SLAVE_STATE;
	
end IMP;
