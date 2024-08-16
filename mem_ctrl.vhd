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
        data_addr : in std_logic_vector(addr_s-1 downto 0);
        data_i : in  std_logic_vector(word_s-1 downto 0);
        data_o : out std_logic_vector(word_s-1 downto 0);
        ctrl_state_addr : out std_logic_vector(2 downto 0);
        ctrl_state_i_ig : in std_logic;
        ctrl_state_o_ig : out std_logic;
        ctrl_state_wr : out std_logic;
        inst_addr : in  std_logic_vector(addr_s-1 downto 0);
        inst_o : out std_logic_vector(word_s-1 downto 0);
        addr_video : in std_logic_vector(addr_s-1 downto 0);
        data_video : out std_logic_vector(word_s-1 downto 0)
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

    component ram_video is
        generic (
          addr_s : natural := 16;
          word_s : natural := 16;
          size   : natural := 1024;
          init_f : string  := "ram.txt"
        );
        port (
          ck       : in  std_logic;
          wr       : in  std_logic;
          addr     : in  std_logic_vector(addr_s-1 downto 0);
          data_i   : in  std_logic_vector(word_s-1 downto 0);
          data_o   : out std_logic_vector(word_s-1 downto 0);
          addr_o_2 : in  std_logic_vector(addr_s-1 downto 0);
          data_o_2 : out std_logic_vector(word_s-1 downto 0)
        );
     end component ram_video;

    signal s_data_addr : std_logic_vector(addr_s-1 downto 0);
    signal s_data_i : std_logic_vector(word_s-1 downto 0);
    signal s_data_o : std_logic_vector(word_s-1 downto 0);
    signal s_inst_addr : std_logic_vector(addr_s-1 downto 0);
    signal s_inst_o : std_logic_vector(word_s-1 downto 0);

    signal s_rom_game_addr, s_rom_game_addr_aux : std_logic_vector(addr_s-1 downto 0);
    signal s_rom_game_o : std_logic_vector(word_s-1 downto 0);
    signal s_rom_interrupt_handlers_addr : std_logic_vector(addr_s-1 downto 0);
    signal s_rom_interrupt_handlers_o : std_logic_vector(word_s-1 downto 0);

    signal s_ctrl_state_addr_aux : std_logic_vector(addr_s-1 downto 0);
    signal s_ctrl_state_addr : std_logic_vector(2 downto 0);
    signal s_ctrl_state_i_ig : std_logic_vector(word_s-1 downto 0);

    signal s_ram_main_addr, s_ram_main_addr_aux : std_logic_vector(addr_s-1 downto 0);
    signal s_ram_main_o : std_logic_vector(word_s-1 downto 0);
    signal s_ram_main_wr : std_logic;
    signal s_ram_video_addr, s_ram_video_addr_aux : std_logic_vector(addr_s-1 downto 0);
    signal s_ram_video_o : std_logic_vector(word_s-1 downto 0);
    signal s_ram_video_wr : std_logic;
begin
    s_data_addr <= data_addr;
    s_data_i <= data_i;
    data_o <= s_data_o;
    ctrl_state_addr <= s_ctrl_state_addr;
    ctrl_state_o_ig <= data_i(0);
    s_ctrl_state_i_ig <= "000000000000000" & ctrl_state_i_ig;
    s_inst_addr <= inst_addr;
    inst_o <= s_inst_o;

    s_inst_o <= s_rom_interrupt_handlers_o when (to_integer(unsigned(s_inst_addr)) < 256) else
                s_rom_game_o when (to_integer(unsigned(s_inst_addr)) < 16640) else
                (others => '0');

    s_rom_interrupt_handlers_addr <= "00000000" & inst_addr(7 downto 0);

    s_rom_game_addr_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(s_inst_addr)) - 256, 16));
    s_rom_game_addr <= "00" & s_rom_game_addr_aux(13 downto 0);

    s_data_o <= s_ram_main_o when (to_integer(unsigned(s_data_addr)) > 49151) else
                s_ram_video_o when (to_integer(unsigned(s_data_addr)) > 32767) else
                s_ctrl_state_i_ig when (to_integer(unsigned(s_data_addr)) > 32759) else
                (others => '0');

    s_ctrl_state_addr_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(s_data_addr)) - 32760, 16));
    s_ctrl_state_addr <= s_ctrl_state_addr_aux(2 downto 0);

    ctrl_state_wr <= wr when ((to_integer(unsigned(s_data_addr)) > 32759) and (to_integer(unsigned(s_data_addr)) <= 32767)) else
    '0';

    s_ram_video_addr_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(s_data_addr)) - 32768, 16));
    s_ram_video_addr <= "00" & s_ram_video_addr_aux(13 downto 0);
    
    s_ram_video_wr <= wr when ((to_integer(unsigned(s_data_addr)) > 32767) and (to_integer(unsigned(s_data_addr)) <= 49151)) else
    '0';

    s_ram_main_addr_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(s_data_addr)) - 49152, 16));
    s_ram_main_addr <= "00" & s_ram_main_addr_aux(13 downto 0);

    s_ram_main_wr <= wr when (to_integer(unsigned(s_data_addr)) > 49151) else
    '0';

    --DEFINIR OS init_f SEM O "../" NO QUARTUS
    ROM_INTERRUPT_HANDLERS: rom
    generic map (
         addr_s => 16,
         word_s => 16,
         size   => 128, --(256 bytes / 2)
         init_f => "../rom_interrupt_handlers.txt"
    )
    port map (
         addr => s_rom_interrupt_handlers_addr,
         data => s_rom_interrupt_handlers_o
    );

    ROM_GAME: rom
    generic map (
         addr_s => 16,
         word_s => 16,
         size   => 8192, --(16384 bytes / 2)
         init_f => "../rom_game.txt"
    )
    port map (
         addr => s_rom_game_addr,
         data => s_rom_game_o
    );

    RAM_VGA: ram_video
    generic map (
         addr_s => 16,
         word_s => 16,
         size   => 8192, --(16384 bytes / 2)
         init_f => "../ram_data.txt"
    )
    port map (
         ck => ck,
         wr => s_ram_video_wr,
         addr => s_ram_video_addr,
         data_i => s_data_i,
         data_o => s_ram_video_o,
         addr_o_2 => addr_video,
         data_o_2 => data_video
    );
    
   RAM_MAIN: ram
    generic map (
         addr_s => 16,
         word_s => 16,
         size   => 8192, --(16384 bytes / 2)
         init_f => "../ram_main.txt"
    )
    port map (
         ck => ck,
         wr => s_ram_main_wr,
         addr => s_ram_main_addr,
         data_i => s_data_i,
         data_o => s_ram_main_o
    );
end architecture;