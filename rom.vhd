library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity rom is
    generic (
        addr_s : natural := 16;
        word_s : natural := 16;
        init_f : string  := "rom.dat"
    );
    port (
        addr : in  std_logic_vector(addr_s-1 downto 0);
        data : out std_logic_vector(word_s-1 downto 0)
    );
end rom;

architecture rom_1 of rom is
    type memory_type is array (0 to (2 ** addr_s) - 1) of std_logic_vector(word_s-1 downto 0);

    signal mem : memory_type;

    impure function init_mem(mif_file_name : in string) return memory_type is
        file mif_file : text open read_mode is mif_file_name;
        variable mif_line : line;
		  variable current_char	: character;
        variable current_word	: std_logic_vector(word_s-1 downto 0);
        variable temp_mem : memory_type;
    begin
        for i in memory_type'range loop
            readline(mif_file, mif_line);
            read(mif_line, current_char);
				
				for j in 0 to word_s-1 loop
					if current_char = '1' then
						current_word(word_s - 1 - j) := '1';
					else
						current_word(word_s - 1 - j) := '0';
					end if;
				end loop;
				
				temp_mem(i) := current_word;
        end loop;
        return temp_mem;
    end function;

begin
    mem <= init_mem(init_f);
    data <= mem(to_integer(unsigned(addr(addr_s-1 downto 1))));
end architecture;

architecture rom_modelsim of rom is
    type memory_type is array (0 to (2 ** addr_s) - 1) of std_logic_vector(word_s-1 downto 0);

    signal mem : memory_type;

begin
    mem( 0) <= "0000000000000000";
    mem( 1) <= "0000000000000000";
    mem( 2) <= "0100010000000011";
    mem( 3) <= "0000000000000000";
    mem( 4) <= "0000000000000000";
    mem( 5) <= "0110100010000101";
    mem( 6) <= "0000000000000000";
    mem( 7) <= "0000000000000000";
    mem( 8) <= "0010110100010000";
    mem( 9) <= "0000000000000000";
    mem(10) <= "0000000000000000";
    mem(11) <= "0010110110000100";
    mem(12) <= "0000000000000000";
    mem(13) <= "0000000000000000";
    mem(14) <= "0101000000001111";
    mem(15) <= "0000000000000000";
    mem(16) <= "0000000000000000";
    mem(17) <= "0110110110000001";
    mem(18) <= "0000000000000000";
    mem(19) <= "0000000000000000";
    mem(20) <= "1001000110000000";
    mem(21) <= "0000000000000000";
    mem(22) <= "0000000000000000";
    mem(23) <= "1001110000000000";
    mem(24 to (2 ** addr_s) - 1) <= (others => (others => '0'));

    data <= mem(to_integer(unsigned(addr(addr_s-1 downto 1))));
end architecture;