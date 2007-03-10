------------------------------------------------------------------------------
-- Filename:          idma.vhd
-- Version:           1.00.a
-- Description:       Top level design, instantiates IPIF and user logic.
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- library Proc_Common_v1_00_b;
-- use Proc_Common_v1_00_b.pselect;

-- library idma_v1_00_a;
-- use idma_v1_00_a.all;

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
--   C_USER_ID_CODE               -- User ID to place in MIR/Reset register
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

entity idma is
  generic
    (
      -- ADD USER GENERICS BELOW THIS LINE ---------------
      --USER generics added here
      -- ADD USER GENERICS ABOVE THIS LINE ---------------

      -- DO NOT EDIT BELOW THIS LINE ---------------------
      -- Bus protocol parameters, do not add to or delete
      C_BASEADDR                     : std_logic_vector     := X"20000000";
      C_HIGHADDR                     : std_logic_vector     := X"2001FFFF";
      C_PLB_AWIDTH                   : integer              := 32;
      C_PLB_DWIDTH                   : integer              := 64;
      C_PLB_NUM_MASTERS              : integer              := 8;
      C_PLB_MID_WIDTH                : integer              := 3;
      C_USER_ID_CODE                 : integer              := 3;
      C_FAMILY                       : string               := "virtex2p"
      -- DO NOT EDIT ABOVE THIS LINE ---------------------
      );
  port
    (
      -- ADD USER PORTS BELOW THIS LINE ------------------
      --USER ports added here
      -- ADD USER PORTS ABOVE THIS LINE ------------------

      -- DO NOT EDIT BELOW THIS LINE ---------------------
      -- Bus protocol ports, do not add to or delete
      PLB_Clk                        : in  std_logic;
      PLB_Rst                        : in  std_logic;

      -- PLB signals (Slave Side)
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


      -- PLB signals (Master Side)
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
      PLB_MSSize                     : in  std_logic_vector(0 to 1);
      -- DO NOT EDIT ABOVE THIS LINE ---------------------


      -- DMA Signals
      DMA_Interrupt                  : out std_logic;
      DMA_Debug                      : out std_logic_vector(0 to 3)
      );

  attribute SIGIS : string;
  attribute SIGIS of PLB_Clk       : signal is "Clk";
  attribute SIGIS of PLB_Rst       : signal is "Rst";

end entity idma;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of idma is

  
--  type burst_reg_type is
--    array (natural range 0 to 15) of std_logic_vector(0 to 63);

  

-- Registers

  signal dma_control_reg : std_logic_vector(0 to 31);
  signal dma_control_reg_we  : std_logic;
  signal dma_control_reg_rst : std_logic;
  --adresse de la source des donnees
  signal sa_reg : std_logic_vector(0 to 31);
  signal sa_reg_we : std_logic;
  signal sa_reg_inc : std_logic;
  signal sa_reg_rst : std_logic;
  --adresse de la destination des donnees
  signal da_reg : std_logic_vector(0 to 31);
  signal da_reg_we : std_logic;
  signal da_reg_inc : std_logic;
  signal da_reg_rst : std_logic;
  --taille des donnees
  signal length_reg : std_logic_vector(0 to 31);
  signal length_reg_we : std_logic;
  signal length_reg_dec : std_logic;
  signal length_reg_rst : std_logic;


  --signal burst_cpt : std_logic_vector(0 to 3);
  --signal burst_cpt_rst : std_logic;
  --signal burst_cpt_inc : std_logic;
  
  --registres temporaires (stockage des donnees)
  --signal burst_reg : burst_reg_type;
  --signal burst_reg_we : bit_vector(0 to 15);
  --signal burst_reg_we_rst : std_logic;
  --signal burst_reg_we_shift : std_logic;
  --signal burst_reg_we_init : std_logic;

  signal burst_fifo_re : std_logic;
  signal burst_fifo_rst : std_logic;
  signal burst_fifo_we : std_logic ;
  signal burst_fifo_ae : std_logic;
  signal burst_fifo_af : std_logic;
  signal burst_fifo_empty : std_logic;
  signal burst_fifo_full : std_logic;
  
  signal slave_slice : std_logic_vector(0 to 31);
  signal slave_slice_we : std_logic;

  
  type DMA_Slave_State_Machine is (Slave_Idle,
                                   Slave_AddAck,
                                   Slave_Read,
                                   Slave_Read2,
                                   Slave_Write,
                                   Slave_Write2);
  
  type DMA_Master_State_Machine is (Master_Idle,
                                    Master_Radd,
                                    Master_Read1,
                                    Master_Read2,
                                    Master_Read3,
--                                    Master_Read_Error,
                                    Master_Wait,
                                    Master_Wait2,
                                   -- Master_Wait3,
                                    Master_Wadd,
                                    Master_Write1,
                                    Master_Write2,
                                    Master_Write3,
--                                    Master_Write_Error,
                                    Master_Next,
                                    Master_Reset);

  
  signal dma_slave_state_current : DMA_Slave_State_Machine := Slave_Idle;
  signal dma_slave_state_next : DMA_Slave_State_Machine := Slave_Idle;
  signal dma_master_state_current : DMA_Master_State_Machine := Master_Idle;
  signal dma_master_state_next : DMA_Master_State_Machine := Master_Idle;


  component fifo_generator_v2_3
    port (
      clk: IN std_logic;
      din: IN std_logic_VECTOR(63 downto 0);
      rd_en: IN std_logic;
      rst: IN std_logic;
      wr_en: IN std_logic;
      almost_empty: OUT std_logic;
      almost_full: OUT std_logic;
      dout: OUT std_logic_VECTOR(63 downto 0);
      empty: OUT std_logic;
      full: OUT std_logic);
  end component;  

begin


  burst_fifo : fifo_generator_v2_3
		port map (
			clk => PLB_Clk,
			din => PLB_MRdDBus,
			rd_en => burst_fifo_re,
			rst => burst_fifo_rst,
			wr_en => burst_fifo_we,
			almost_empty => burst_fifo_ae,
			almost_full => burst_fifo_af,
			dout => M_wrDBus,
			empty => burst_fifo_empty,
			full => burst_fifo_full);


  
  -----------------------------------------------------------------------------
  -- DMA_CHANGE_STATE : change to the next state of the slave and master
  -- fsm (finit state machine)
  -----------------------------------------------------------------------------

  DMA_CHANGE_STATE: process(PLB_Clk,PLB_Rst) is
  begin
    if PLB_Clk'Event and PLB_Clk = '1' then
      if PLB_Rst = '1'  then
        dma_slave_state_current <= Slave_Idle;
        dma_master_state_current <= Master_Idle;
      else
        dma_slave_state_current <= dma_slave_state_next;
        dma_master_state_current <= dma_master_state_next;    
      end if;
    end if;
  end process DMA_CHANGE_STATE;



  -----------------------------------------------------------------------------
  -- REG_WRITE : write data into registers
  -----------------------------------------------------------------------------
  REG_WRITE: process(PLB_Clk, PLB_Rst, dma_control_reg_we, sa_reg_we,
                     da_reg_we , length_reg_we ,slave_slice_we,
                     length_reg_dec,sa_reg_inc,da_reg_inc,
                     --burst_cpt_inc,
                     sa_reg_rst, da_reg_rst,dma_control_reg_rst, length_reg_rst
                     --burst_cpt_rst, burst_reg_we_init,
                     --burst_reg_we_shift, burst_reg_we_rst
                     ) is
  begin
    if PLB_Rst = '1'  then
      dma_control_reg <= X"ABCDEF00";   --debug tools
      sa_reg <= X"00000000";
      da_reg <= X"00000000";
      length_reg <= X"00000000";
      --burst_cpt <= X"0";
    elsif PLB_Clk'Event and PLB_Clk = '1' then

      -- Slave registers, receive data from PLB.
      if dma_control_reg_rst = '1'  then
        dma_control_reg <= X"ABCDEF00";
      elsif dma_control_reg_we = '1' then
        dma_control_reg <=  PLB_wrDBus(32 to 63); 
      end if;
      
      if sa_reg_rst = '1' then
        sa_reg <= X"00000000";
      elsif sa_reg_we = '1' then
        sa_reg(0 to 29) <=  PLB_wrDBus(32 to 61);
        sa_reg(30 to 31) <= "00";
      elsif sa_reg_inc = '1' then 
        sa_reg <= sa_reg + 128;
      end if;

      if da_reg_rst = '1' then
        da_reg <= X"00000000";
      elsif da_reg_we = '1' then
        da_reg(0 to 29) <=  PLB_wrDBus(32 to 61);
        da_reg(30 to 31) <= "00";
      elsif da_reg_inc = '1' then
        da_reg <= da_reg + 128;
      end if;

      if length_reg_rst = '1' then
        length_reg <= X"00000000";
      elsif length_reg_we = '1' then
        length_reg <=  PLB_wrDBus(32 to 63);
      elsif length_reg_dec = '1' then 
        length_reg <= length_reg - 8;
      end if;
      
      if slave_slice_we = '1' then
        slave_slice <=  PLB_ABus - C_BASEADDR;
      end if;

    --  if burst_cpt_rst = '1' then
    --    burst_cpt <= X"0";
    --  elsif burst_cpt_inc = '1' then
    --    burst_cpt <= burst_cpt + 1;
    --  end if;
      
      -- Master registers, reveive data from PLB.

     -- if burst_reg_we_rst = '1' then
     --   burst_reg_we <= X"0000";
     -- elsif burst_reg_we_init = '1' then
     --   burst_reg_we <= X"0001";
     -- elsif burst_reg_we_shift = '1' then
     --   burst_reg_we <= burst_reg_we sll 1;
     -- end if;
      
    end if;
  end process REG_WRITE;

--  BURST_WRITE : process( PLB_Clk, burst_reg_we, PLB_MRdDBus ) is
 -- begin
   --    if PLB_Clk'Event and PLB_Clk = '1' then
     --    for we in 0 to 15 loop
       --    if burst_reg_we(we) = '1' then
         --    burst_reg(we) <= PLB_MRdDBus;
          -- end if;
         --end loop;  -- we
       --end if;
  --end process BURST_WRITE;



  -----------------------------------------------------------------------------
  -- DMA_SLAVE_STATE : implement the slave fsm.
  -----------------------------------------------------------------------------
  DMA_SLAVE_STATE: process(PLB_Clk,dma_slave_state_current,PLB_PAValid, PLB_ABus,
                           PLB_RNW, slave_slice, dma_control_reg,
                           sa_reg, length_reg, da_reg ) is
  begin
    Sl_addrAck <= '0';
    Sl_rdComp <= '0';
    Sl_rdDAck <= '0';
    Sl_wrDAck <= '0';
    Sl_wrComp <= '0';
    dma_control_reg_we <= '0';
    sa_reg_we <= '0';
    da_reg_we <= '0';
    length_reg_we <= '0';
    Sl_wait <= '0';
    slave_slice_we <= '0';
    Sl_rdDBus <= (others => '0');

    
    case dma_slave_state_current is
      -- Idle, waiting for address in the dma range.
      when Slave_Idle =>
        if PLB_PAValid = '1'            -- there is a request
          and PLB_ABus >= C_BASEADDR    -- In our range
          and PLB_ABus <= C_HIGHADDR
          then  -- and the master
                                                           -- mode is idle.
          dma_slave_state_next <= Slave_AddAck;
          Sl_wait <= '1';
          slave_slice_we <= '1';
        else
          Sl_wait <= '0';
          slave_slice_we <= '0';
          dma_slave_state_next <= Slave_Idle;
        end if;

      -- Read Address and record it into slave_slice.
      when Slave_AddAck =>   
        Sl_wait <= '1';
        Sl_addrAck <= '1';
        if PLB_RNW = '1' then
          dma_slave_state_next <= Slave_Read;
        else
          dma_slave_state_next <= Slave_Write;
        end if; 

      -- Read data from plb
      when Slave_Read =>
        Sl_rdComp <= '1';
        case slave_slice(27 to 28) is
          when "00" =>
            Sl_rdDBus(32 to 63) <= dma_control_reg;
          when "01" =>
            Sl_rdDBus(32 to 63) <= sa_reg;
          when "10" =>
            Sl_rdDBus(32 to 63) <= length_reg;
          when "11" =>
            Sl_rdDBus(32 to 63) <= da_reg;
          when others =>
            Sl_rdDBus(32 to 63) <= X"00010100";
        end case;
        dma_slave_state_next <= Slave_Read2;

        
      when Slave_Read2 =>
        Sl_rdDAck <= '1';
        case slave_slice(27 to 28) is
          when "00" =>
            Sl_rdDBus(32 to 63) <= dma_control_reg;
          when "01" =>
            Sl_rdDBus(32 to 63) <= sa_reg;
          when "10" =>
            Sl_rdDBus(32 to 63) <= length_reg;
          when "11" =>
            Sl_rdDBus(32 to 63) <= da_reg;
          when others =>
            Sl_rdDBus(32 to 63) <= X"00010100";
        end case;
        dma_slave_state_next <= Slave_Idle;
        
        
      when Slave_Write =>
        Sl_wrComp <= '1';
        case slave_slice(27 to 28) is
          when "00" =>
            dma_control_reg_we <= '1'; 
          when "01" =>
            sa_reg_we <= '1';
          when "10" =>
            length_reg_we <= '1'; 
          when "11" =>
            da_reg_we <= '1';   
          when others =>
            null;
        end case;
        dma_slave_state_next <= Slave_Write2;


      when Slave_Write2 =>
        Sl_wrDAck <= '1';
        case slave_slice(27 to 28) is
          when "00" =>
            dma_control_reg_we <= '1'; 
          when "01" =>
            sa_reg_we <= '1';
          when "10" =>
            length_reg_we <= '1'; 
          when "11" =>
            da_reg_we <= '1';   
          when others =>
            null;
        end case;
        dma_slave_state_next <= Slave_Idle;
        
    end case;
  end process DMA_SLAVE_STATE;


  


  Sl_rdBTerm <= '0';
  Sl_rearbitrate <= '0';
  Sl_wrBTerm <= '0';


  DMA_MASTER_STATE : process(PLB_Clk,dma_master_state_current,
                             PLB_MAddrAck,PLB_MWrDAck,PLB_MRdDAck,
                             dma_control_reg,sa_reg,da_reg,
                             --burst_reg,
                             length_reg,
                             burst_fifo_af,
                             burst_fifo_ae
                             --burst_cpt
                            ) is
   variable interupt : integer := 0;
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
    --M_wrDBus      <= (others => '0');
    dma_control_reg_rst <= '0';
    length_reg_dec <= '0';
    da_reg_inc <= '0';
    sa_reg_inc <= '0';
    da_reg_rst <= '0';
    sa_reg_rst <= '0';
    length_reg_rst <= '0';

    burst_fifo_we <= '0';
    burst_fifo_rst <= '0';
    burst_fifo_re <= '0';
    
   -- burst_cpt_rst <= '0';
   -- burst_cpt_inc <= '0';
   -- burst_reg_we_rst <= '0';
   -- burst_reg_we_init <= '0';

    DMA_Interrupt <= '0';
    
    case dma_master_state_current is
      when Master_Idle =>
        if dma_control_reg(31) = '1' then
          dma_master_state_next <= Master_Radd;
        else
          dma_master_state_next <= Master_Idle;
        end if;
        DMA_Debug <= "0000";

      when Master_Radd =>
        M_request <= '1';
        M_priority <= "00";             --au choix
        M_RNW <= '1';
        M_size <= "1011";               --Burst transfert, 2 double words
        M_ABus <= sa_reg;
        burst_fifo_rst <= '1';
        if PLB_MAddrAck = '1' then
          dma_master_state_next <= Master_Read1;
        else
          dma_master_state_next <= Master_Radd;
        end if;
        DMA_Debug <= "0001";

      when Master_Read1 =>
        M_rdBurst <= '1';
        burst_fifo_we <= PLB_MRdDAck;
        if PLB_MRdDAck = '1' then
          dma_master_state_next <= Master_Read2;
        else
          dma_master_state_next <= Master_Read1;
        end if;
        DMA_Debug <= "0010";

      when Master_Read2 =>
        M_rdBurst <= '1';
        burst_fifo_we <= PLB_MRdDAck;
        if burst_fifo_af = '1'  then
          dma_master_state_next <= Master_Read3;
        else
          dma_master_state_next <= Master_Read2;
        end if;
        DMA_Debug <= "0011";

      when Master_Read3 =>
        dma_master_state_next <= Master_Wait;
        DMA_Debug <= "0100";

      when Master_Wait =>
        dma_master_state_next <= Master_Wadd;
        DMA_Debug <= "0101";

      when Master_Wadd =>
        M_request <= '1';
        M_priority <= "00";
        M_size <= "1011";
        M_ABus <= da_reg;
        M_wrBurst <= '1';
        burst_fifo_re <= PLB_MAddrAck;
        length_reg_dec <= PLB_MWrDAck;
        if PLB_MAddrAck = '1' then
          dma_master_state_next <= Master_Write1;
        else
          dma_master_state_next <= Master_Wadd;
        end if;
        DMA_Debug <= "0110";

      when Master_Write1 =>
        M_wrBurst <= '1';
        burst_fifo_re <= PLB_MWrDAck;
        length_reg_dec <= PLB_MWrDAck;
        if length_reg <= X"00000010" then
          dma_master_state_next <= Master_Write3;
        elsif burst_fifo_ae = '1' then
          dma_master_state_next <= Master_Write2;
        else
          dma_master_state_next <= Master_Write1;
        end if;
        DMA_Debug <= "0111";

      when Master_Write2 =>
        length_reg_dec <= '1';
        dma_master_state_next <= Master_Next;
        DMA_Debug <= "1000";

      when Master_Next =>
        sa_reg_inc <= '1';
        da_reg_inc <= '1';
        burst_fifo_rst <= '1';
        dma_master_state_next <= Master_Wait2;
        DMA_Debug <= "1001";

      when Master_Wait2 =>
        dma_master_state_next <= Master_Radd;

      when Master_Write3 =>
        burst_fifo_re <= PLB_MWrDAck;
        length_reg_dec <= '1';
        dma_master_state_next <= Master_Reset;
       
      when Master_Reset =>
        DMA_Interrupt <= dma_control_reg(30);
        sa_reg_rst <= '1';
        da_reg_rst <= '1';
        length_reg_rst <= '1';
        burst_fifo_rst <= '1';
        dma_control_reg_rst <= '1';
        dma_master_state_next <= Master_Idle;
        DMA_Debug <= "1010";
        
    end case;
  end  process DMA_MASTER_STATE;

end IMP;
