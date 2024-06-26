library ieee;
use ieee.std_logic_1164.all;

entity register_d is
    generic (
        constant N : integer := 8
    );
    port (
        clock : in std_logic;
        clear : in std_logic;
        enable : in std_logic;
        D : in std_logic_vector (N - 1 downto 0);
        Q : out std_logic_vector (N - 1 downto 0)
    );
end entity register_d;

architecture comportamental of register_d is
    signal IQ : std_logic_vector(N - 1 downto 0) := (others => '0');
begin

    process (clock, clear, enable, IQ)
    begin
        if (clock'event and clock = '1') then
            if (clear = '1') then
                IQ <= (others => '0');
            elsif (enable = '1') then
                IQ <= D;
            else
                IQ <= IQ;
            end if;
        end if;
    end process;
    Q <= IQ;

end architecture comportamental;