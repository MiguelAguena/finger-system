library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity regfile is
    generic (
        reg_n: natural := 10;
        word_s: natural := 32
    );

    port (
        clock:        in  std_logic;
        reset:        in  std_logic;
        regWrite:     in  std_logic;
        rr1, rr2, wr: in  std_logic_vector(natural(ceil(log2(real(reg_n)))) -1 downto 0);
        d:            in  std_logic_vector(word_s-1 downto 0);
        q1, q2:       out std_logic_vector(word_s-1 downto 0)
    );
end regfile;

architecture regfile_1 of regfile is
    type std_logic_matrix is array (1 to reg_n-1) of std_logic_vector(word_s-1 downto 0);
    
    -- signal q_aux : std_logic_matrix;
    -- signal wr_aux : std_logic_vector(reg_n-1 downto 0);
    -- signal load_aux : std_logic_vector(reg_n-1 downto 0);
    signal regbank : std_logic_matrix := (others => (others => '0'));
begin
    register_dBank: process(clock, reset) is
        begin
            if (clock'event and clock = '1') then
                if(reset = '1') then
                    zerando: for i in 1 to 31 loop
                        regbank(i) <= (others => '0');
                    end loop;
                elsif(regWrite = '1' and to_integer(unsigned(wr)) /= 0) then
                    regbank(to_integer(unsigned(wr))) <= d;
                end if;
            end if;
    end process;

    q1 <= regbank(to_integer(unsigned(rr1))) when to_integer(unsigned(rr1)) /= 0 else (others => '0');
    q2 <= regbank(to_integer(unsigned(rr2))) when to_integer(unsigned(rr2)) /= 0 else (others => '0');
end architecture;