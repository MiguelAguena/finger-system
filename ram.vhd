library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity ram is
    generic (
        addr_s : natural := 16;
        word_s : natural := 16;
        size   : natural := 1024;
        init_f : string  := "ram.txt"
    );
    port (
        ck     : in  std_logic;
        wr     : in  std_logic;
        addr   : in  std_logic_vector(addr_s-1 downto 0);
        data_i : in  std_logic_vector(word_s-1 downto 0);
        data_o : out std_logic_vector(word_s-1 downto 0)
    );
end ram;

architecture ram_1 of ram is
    type memory_type is array (0 to (size - 1)) of std_logic_vector(word_s-1 downto 0);

    impure function init_mem(mif_file_name : in string) return memory_type is
        file mif_file : text open read_mode is mif_file_name;
        variable mif_line : line;
		  variable current_char	: character;
        variable current_word	: std_logic_vector(word_s-1 downto 0);
        variable temp_mem : memory_type;
    begin
        for i in memory_type'range loop
            exit when endfile(mif_file);
            readline(mif_file, mif_line);
				
            for j in 0 to word_s-1 loop
                read(mif_line, current_char);
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

    signal mem : memory_type := init_mem(init_f);
begin
    p0: process (ck, wr, data_i, addr) is
    begin
        if(rising_edge(ck) AND wr = '1') then
            mem(to_integer(unsigned(addr(addr_s-1 downto 1)))) <= data_i;
        end if;
    end process p0;

    data_o <= mem(to_integer(unsigned(addr(addr_s-1 downto 1))));
end architecture;