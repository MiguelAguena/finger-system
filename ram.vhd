library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity ram is
    generic (
        addr_s : natural := 16;
        word_s : natural := 8;
        init_f : string  := "ram.dat"
    );
    port (
        ck     : in  bit;
        rd, wr : in  bit;
        addr   : in  bit_vector(addr_s-1 downto 0);
        data_i : in  bit_vector(word_s-1 downto 0);
        data_o : out bit_vector(word_s-1 downto 0)
    );
end ram;

architecture ram_1 of ram is
    type memory_type is array (0 to (2 ** addr_s) - 1) of bit_vector(word_s-1 downto 0);

    impure function init_mem(mif_file_name : in string) return memory_type is
        file mif_file : text open read_mode is mif_file_name;
        variable mif_line : line;
        variable temp_bv : bit_vector(word_s-1 downto 0);
        variable temp_mem : memory_type;
    begin
        for i in memory_type'range loop
            readline(mif_file, mif_line);
            read(mif_line, temp_bv);
            temp_mem(i) := temp_bv;
        end loop;
        return temp_mem;
    end function;

    signal mem : memory_type := init_mem(init_f);
begin
    p0: process (ck) is
    begin
        if(ck = '1' AND wr = '1') then
            mem(to_integer(unsigned(addr))) <= data_i;
        end if;
    end process p0;

    data_o <= mem(to_integer(unsigned(addr)));
end architecture;