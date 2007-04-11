------------------------------------------------------------------------------
-- isuperdma.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Filename:          isuperdma.vhd
-- Author:            Matthieu GUILLEMOT <g@npng.org>
-- Version:           1.00.a
-- Description:       Top level design
-- Date:              2006/03/16
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

entity isuperdma is
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
	 Isuperdma_Debug					  : out std_logic_vector(127 downto 0);
	 Isuperdma_Interrupt            : out std_logic;

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

end entity isuperdma;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of isuperdma is

	-- constants
	constant transparent_color       : std_logic_vector(15 downto 0) := "1111100000011111"; -- Pink
	constant line_width              : std_logic_vector(31 downto 0) := X"00000280"; -- 320 * 2

	-- slave local address
	signal slave_slice               : std_logic_vector(31 downto 0) := X"00000000";
	signal slave_slice_we            : std_logic := '0';

	-- isuperdma registers
	signal control_skip              : std_logic_vector(31 downto 0) := X"00000000";
	signal control_skip_we           : std_logic := '0';
	signal control_skip_rst_control  : std_logic := '0';
	signal source                    : std_logic_vector(31 downto 0) := X"00000000";
	signal source_we                 : std_logic := '0';
	signal destination               : std_logic_vector(31 downto 0) := X"00000000";
	signal destination_we            : std_logic := '0';
	signal size                      : std_logic_vector(31 downto 0) := X"00000000";
	signal size_we                   : std_logic := '0';

	-- register alias
	signal section_width             : std_logic_vector(15 downto 0) := X"0000";
	signal section_height            : std_logic_vector(15 downto 0) := X"0000";
	signal sprite_width              : std_logic_vector(15 downto 0) := X"0000";
	signal control                   : std_logic_vector(15 downto 0) := X"0000";
	
	-- RAM pointers
	signal destination_ptr           : std_logic_vector(31 downto 0) := X"00000000";
	signal destination_ptr_rst       : std_logic := '0';
	signal destination_ptr_next_line : std_logic := '0';
	signal source_ptr                : std_logic_vector(31 downto 0) := X"00000000";
	signal source_ptr_rst            : std_logic := '0';
	signal source_ptr_next_line      : std_logic := '0';
	
	-- operation length registers
	signal op_length                 : std_logic_vector(15 downto 0) := X"0000";
	signal op_length_rst             : std_logic := '0';
	signal op_length_dec             : std_logic := '0';	
	signal lines_left                : std_logic_vector(15 downto 0) := X"0000";
	signal lines_left_rst            : std_logic := '0';
	signal lines_left_dec            : std_logic := '0';	

	-- state machines
	type Master_State_Machine is (Master_Idle,
											Master_StartLine,
											Master_Read_Addr,
											Master_Read_Data,
											Master_Write_Addr,
											Master_Write_Data,										
											Master_LineEnded);

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
	
	-- debug
	signal debug_master_state       : std_logic_vector(3 downto 0) := "0000";
	signal debug_slave_state        : std_logic_vector(3 downto 0) := "0000";

	-- fifo signals
	signal fifo_rst                 : std_logic := '0';
	signal fifo_re                  : std_logic := '0';
	signal fifo_we                  : std_logic := '0';
	signal fifo_empty               : std_logic := '0';

	-- fifo
	component superdma_fifo port (
		clk: IN std_logic;
		din: IN std_logic_VECTOR(63 downto 0);
		rd_en: IN std_logic;
		rst: IN std_logic;
		wr_en: IN std_logic;
		dout: OUT std_logic_VECTOR(63 downto 0);
		empty: OUT std_logic;
		full: OUT std_logic
	);
	end component;
	
begin

	FIFO_INSTANCE : superdma_fifo	port map (
		clk          => PLB_Clk,
		din          => PLB_MRdDBus,
		rd_en        => fifo_re,
		rst          => fifo_rst,
		wr_en        => fifo_we,
		dout         => M_wrDBus,
		empty        => fifo_empty,
		full         => open
	);
	
	CONTROL_SKIP_FF : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if PLB_Rst = '1' then
				control_skip <= X"00000000";
			elsif control_skip_rst_control = '1' then
				control_skip(15 downto 0) <= X"0000";
			elsif control_skip_we = '1' then
				control_skip <= PLB_wrDBus(32 to 63);
			end if;
		end if;
	end process CONTROL_SKIP_FF;

	SOURCE_FF : for i in 0 to 31 generate
		FF_I : FDRE port map (
			D  => PLB_wrDBus(63 - i),
			Q  => source(i),
			C  => PLB_Clk,
			CE => source_we,
			R  => PLB_Rst
		);
	end generate SOURCE_FF;

	DESTINATION_FF : for i in 0 to 31 generate
		FF_I : FDRE port map (
			D  => PLB_wrDBus(63 - i),
			Q  => destination(i),
			C  => PLB_Clk,
			CE => destination_we,
			R  => PLB_Rst
		);
	end generate DESTINATION_FF;

	SIZE_FF : for i in 0 to 31 generate
		FF_I : FDRE port map (
			D  => PLB_wrDBus(63 - i),
			Q  => size(i),
			C  => PLB_Clk,
			CE => size_we,
			R  => PLB_Rst
		);
	end generate SIZE_FF;

--	Isuperdma_Debug(3 downto 0) <= debug_master_state;
--	Isuperdma_Debug(8) <= control(0);
--	Isuperdma_Debug(47 downto 32) <= op_length;
--	Isuperdma_Debug(63 downto 48) <= lines_left;
--	Isuperdma_Debug(95 downto 64) <= source_ptr;
--	Isuperdma_Debug(127 downto 96) <= destination_ptr;

	section_width <= size(31 downto 16);
	section_height <= size(15 downto 0);
	sprite_width <= control_skip(31 downto 16);
	control <= control_skip(15 downto 0);
	
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
	UPDATE_DESTINATION_PTR : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if destination_ptr_rst = '1' then
				destination_ptr <= destination;
			elsif destination_ptr_next_line = '1' then
				destination_ptr <= destination_ptr + line_width;
			end if;
		end if;
	end process UPDATE_DESTINATION_PTR;

	-- sequential
	UPDATE_SOURCE_PTR : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if source_ptr_rst = '1' then
				source_ptr <= source;
			elsif source_ptr_next_line = '1' then
				source_ptr <= source_ptr + (sprite_width(14 downto 0) & "0");
			end if;
		end if;
	end process UPDATE_SOURCE_PTR;
	
	-- sequential
	UPDATE_OP_LENGTH : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if op_length_rst = '1' then
				op_length <= ("00" & section_width(15 downto 2)) - 1;
			elsif op_length_dec = '1' then
				op_length <= op_length - 1;
			end if;
		end if;
	end process UPDATE_OP_LENGTH;

	-- sequential
	UPDATE_LINES_LEFT : process(PLB_Clk) is
	begin
		if PLB_Clk'event and PLB_Clk = '1' then
			if lines_left_rst = '1' then
				lines_left <= section_height;
			elsif lines_left_dec = '1' then
				lines_left <= lines_left - 1;
			end if;
		end if;
	end process UPDATE_LINES_LEFT;
	
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
	
	-- combinatorial
	MASTER_STATE : process(PLB_MAddrAck, PLB_MRdDAck, PLB_MWrDAck, master_state_current, fifo_empty,
								  source_ptr, destination_ptr, op_length, lines_left, control) is
	begin
	
		M_request                 <= '0';
		M_priority                <= "00";
		M_busLock                 <= '0';
		M_RNW                     <= '0';
		M_BE                      <= "00000000";
		M_size                    <= "0000";
		M_type                    <= "000";
		M_abort                   <= '0';
		M_ABus                    <= X"00000000";
		M_compress                <= '0';  
		M_guarded                 <= '0';
		M_lockErr                 <= '0';
		M_MSize                   <= "00";
		M_ordered                 <= '0';
		M_rdBurst                 <= '0';
		M_wrBurst                 <= '0';
		
		fifo_rst                  <= '0';
		fifo_we                   <= '0';
		fifo_re                   <= '0';
		source_ptr_rst            <= '0';
		source_ptr_next_line      <= '0';
		destination_ptr_rst       <= '0';
		destination_ptr_next_line <= '0';
		op_length_rst             <= '0';
		op_length_dec             <= '0';
		lines_left_rst            <= '0';
		lines_left_dec            <= '0';
		control_skip_rst_control  <= '0';
		master_state_next         <= master_state_current;
		debug_master_state        <= "0000";

		Isuperdma_Interrupt       <= '0';
				
		case master_state_current is
		
			when Master_Idle =>
				fifo_rst <= '1';
				source_ptr_rst <= '1';
				destination_ptr_rst <= '1';
				lines_left_rst <= '1';
				if control(0) = '1' then
					master_state_next <= Master_StartLine;
					control_skip_rst_control <= '1';
				end if;
				debug_master_state <= "0000";
			
			when Master_StartLine =>
				op_length_rst <= '1';
				lines_left_dec <= '1';
				master_state_next <= Master_Read_Addr;
				debug_master_state <= "0001";
			
			when Master_Read_Addr =>
				M_request <= '1';
				M_priority <= "00";
				M_RNW <= '1';
				M_size <= "1011"; -- burst transfert, double words, terminated by master
				M_ABus <= source_ptr;
				if PLB_MAddrAck = '1' then
					master_state_next <= Master_Read_Data;
				end if;
				debug_master_state <= "0010";
			
			when Master_Read_Data =>
				if PLB_MRdDAck = '1' then
					if op_length = 0 then -- end of section line
						master_state_next <= Master_Write_Addr;
						M_rdBurst <= '0';
					else
						M_rdBurst <= '1';
						op_length_dec <= '1';
					end if;
					fifo_we <= '1';
				else
					M_rdBurst <= '1';
				end if;
				debug_master_state <= "0011";
				
			when Master_Write_Addr =>
				if PLB_MAddrAck = '1' then
					fifo_re <= '1';
					master_state_next <= Master_Write_Data;
				end if;
				M_size <= "1011"; -- burst transfer, double-words, terminated by master
				M_ABus <= destination_ptr;
				M_request <= '1';
				M_priority <= "00";
				M_wrBurst <= '1';
				debug_master_state <= "0100";
				
			when Master_Write_Data =>
				if PLB_MWrDAck = '1' then
					if fifo_empty = '1' then
						master_state_next <= Master_LineEnded;
						M_wrBurst <= '0';
					else
						M_wrBurst <= '1';
					end if;	
					fifo_re <= '1';
				else
					M_wrBurst <= '1';
				end if;
				debug_master_state <= "0101";

			when Master_LineEnded =>
				source_ptr_next_line <= '1';
				destination_ptr_next_line <= '1';
				if lines_left = 0 then
					master_state_next <= Master_Idle;
					Isuperdma_Interrupt <= '1';
				else
					master_state_next <= Master_StartLine;
				end if;
				debug_master_state <= "0110";
							
			when others =>
				null;

		end case;
	end process MASTER_STATE;

	-- combinatorial
	SLAVE_STATE : process(slave_state_current, slave_slice, PLB_PAValid, PLB_ABus, PLB_RNW,
								 control_skip, source, destination, size) is
	begin
	
		Sl_addrAck       <= '0';
		Sl_rdComp        <= '0';
		Sl_rdDAck        <= '0';
		Sl_wrDAck        <= '0';
		Sl_wrComp        <= '0';
		Sl_wait          <= '0';
		Sl_rdDBus        <= X"0000000000000000";
		
		slave_slice_we   <= '0';
		control_skip_we  <= '0';		
		source_we        <= '0';
		destination_we   <= '0';
		size_we          <= '0';
		slave_state_next <= slave_state_current;
		
		case slave_state_current is
			
			when Slave_Idle =>
				if PLB_PAValid = '1' and PLB_ABus >= C_BASEADDR and PLB_ABus <= C_HIGHADDR	then
					slave_state_next <= Slave_AddAck;
					Sl_wait <= '1';
					slave_slice_we <= '1';
				end if;
				debug_slave_state <= "0000";
				
			when Slave_AddAck => -- Read address and record it into slave_slice
				Sl_wait <= '1';
				Sl_addrAck <= '1';
				if PLB_RNW = '1' then
					slave_state_next <= Slave_Read;
				else
					slave_state_next <= Slave_Write;
				end if;
				debug_slave_state <= "0001";
			
			when Slave_Read =>
				Sl_rdComp <= '1';
				case slave_slice(4 downto 3) is
					when "00" =>
						Sl_rdDBus(32 to 63) <= control_skip;
					when "01" =>
						Sl_rdDBus(32 to 63) <= source;
					when "10" =>
						Sl_rdDBus(32 to 63) <= destination;
					when "11" =>
						Sl_rdDBus(32 to 63) <= size;
					when others =>
						Sl_rdDBus(32 to 63) <= X"00000000";
				end case;
				slave_state_next <= Slave_Read2;
				debug_slave_state <= "0010";
			
			when Slave_Read2 =>
				Sl_rdDAck <= '1';
				case slave_slice(4 downto 3) is
					when "00" =>
						Sl_rdDBus(32 to 63) <= control_skip;
					when "01" =>
						Sl_rdDBus(32 to 63) <= source;
					when "10" =>
						Sl_rdDBus(32 to 63) <= destination;
					when "11" =>
						Sl_rdDBus(32 to 63) <= size;
					when others =>
						Sl_rdDBus(32 to 63) <= X"00000000";
				end case;
				slave_state_next <= Slave_Idle;
				debug_slave_state <= "0011";
			
			when Slave_Write =>
				Sl_wrComp <= '1';
				case slave_slice(4 downto 3) is
					when "00" =>
						control_skip_we <= '1';
					when "01" =>
						source_we <= '1';
					when "10" =>
						destination_we <= '1';
					when "11" =>
						size_we <= '1';
					when others =>
						null;
				end case;
				slave_state_next <= Slave_Write2;
				debug_slave_state <= "0100";
			
			when Slave_Write2 =>
				Sl_wrDAck <= '1';
				slave_state_next <= Slave_Idle;
				debug_slave_state <= "0101";
		
			when others =>
				null;
		
		end case;
	end process SLAVE_STATE;
	
end IMP;
