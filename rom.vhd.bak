-------------------------------------------------------
--! @file rom_simples.vhdl
--! @brief My Generic File ROM.
--! @author Miguel Aguena (miguel.aguena@usp.br)
--! @date 2021-12-11
-------------------------------------------------------

--ROM

library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom is
    generic (
        addr_s : natural := 4;
        word_s : natural := 8;
        init_f : string  := "rom.dat"
    );
    port (
        addr : in  bit_vector(addr_s-1 downto 0);
        data : out bit_vector(word_s-1 downto 0)
    );
end rom;

architecture rom_1 of rom is
    type memory_type is array (0 to (2 ** addr_s) - 1) of bit_vector(word_s-1 downto 0);

    signal mem : memory_type;

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

begin
    mem <= init_mem(init_f);
    data <= mem(to_integer(unsigned(addr)));
end architecture;