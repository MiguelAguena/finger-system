library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_ctrl is
    generic (
        addr_s : natural := 16;
        word_s : natural := 16
    );
    port (
        ck : in  std_logic;
        wr : in  std_logic;
        data_addr : in  std_logic_vector(addr_s-1 downto 0);
        data_i : in  std_logic_vector(word_s-1 downto 0);
        data_o : out std_logic_vector(word_s-1 downto 0);
        inst_addr : in  std_logic_vector(addr_s-1 downto 0);
        inst_o : out std_logic_vector(word_s-1 downto 0)
    );
end mem_ctrl;

architecture ctrl_1 of mem_ctrl is
	component rom is
        generic (
             addr_s : natural := 16;
             word_s : natural := 16;
             size   : natural := 1024;
             init_f : string  := "../rom.txt"
        );
        port (
             addr : in  std_logic_vector(addr_s-1 downto 0);
             data : out std_logic_vector(word_s-1 downto 0)
        );
    end component rom;

    component ram is
        generic (
             addr_s : natural := 16;
             word_s : natural := 16;
             size   : natural := 1024;
             init_f : string  := "../ram.txt"
        );
        port (
             ck     : in  std_logic;
             wr     : in  std_logic;
             addr   : in  std_logic_vector(addr_s-1 downto 0);
             data_i : in  std_logic_vector(word_s-1 downto 0);
             data_o : out std_logic_vector(word_s-1 downto 0)
        );
    end component ram;

    signal s_data_addr : std_logic_vector(addr_s-1 downto 0);
    signal s_data_i : std_logic_vector(word_s-1 downto 0);
    signal s_data_o : std_logic_vector(word_s-1 downto 0);
    signal s_inst_addr : std_logic_vector(addr_s-1 downto 0);
    signal s_inst_o : std_logic_vector(word_s-1 downto 0);

    signal s_game_addr, s_game_addr_aux : std_logic_vector(addr_s-1 downto 0);
    signal s_game_o : std_logic_vector(word_s-1 downto 0);
    signal s_interrupt_handlers_addr : std_logic_vector(addr_s-1 downto 0);
    signal s_interrupt_handlers_o : std_logic_vector(word_s-1 downto 0);
begin
    s_data_addr <= data_addr;
    s_data_i <= data_i;
    data_o <= s_data_o;
    s_inst_addr <= inst_addr;
    inst_o <= s_inst_o;

    s_inst_o <= s_interrupt_handlers_o when (to_integer(unsigned(s_inst_addr)) < 256) else
    --corrigir o resto
                s_game_o when (to_integer(unsigned(s_inst_addr)) < 4224) else
                (others => '0');

    --corrigir o resto
    s_game_addr_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(s_inst_addr)) - 32, 16));

    s_interrupt_handlers_addr <= "00000000" & inst_addr(7 downto 0);
    s_game_addr <= "0000" & s_game_addr_aux(11 downto 0);

    --DEFINIR OS init_f SEM O "../" NO QUARTUS
    MEM_INTERRUPT_HANDLERS: rom
    generic map (
         addr_s => 16,
         word_s => 16,
         size   => 128 --(256 / 2),
         init_f => "../rom_interrupt_handlers.txt"
    )
    port map (
         addr => s_interrupt_handlers_addr,
         data => s_interrupt_handlers_o
    );

    MEM_GAME: rom
    generic map (
         addr_s => 16,
         word_s => 16,
         size   => 4096 --(8192 / 2),
         init_f => "../rom_game.txt"
    )
    port map (
         addr => s_game_addr,
         data => s_game_o
    );

   --MEM_VIDEO: 8192 --(16384 / 2) palavras
    
   MEM_DATA: ram
    generic map (
         addr_s => 16,
         word_s => 16,
         size   => 8192 --(16384 / 2),
         init_f => "../ram_data.txt"
    )
    port map (
         ck => ck,
         wr => wr,
         addr => s_data_addr,
         data_i => s_data_i,
         data_o => s_data_o
    );
end architecture;