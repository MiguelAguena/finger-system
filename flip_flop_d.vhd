library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_d is
    port (
        clock : in std_logic;
        clear : in std_logic;
        enable : in std_logic;
        D : in std_logic;
        Q : out std_logic
    );
end entity flip_flop_d;

architecture comportamental of flip_flop_d is
    signal IQ : std_logic := '0';
begin

    process (clock, clear, enable, IQ, D)
    begin
        if (clock'event and clock = '1') then
            if (clear = '1') then
                IQ <= '0';
            elsif (enable = '1') then
                IQ <= D;
            else
                IQ <= IQ;
            end if;
        end if;
    end process;
    Q <= IQ;

end architecture comportamental;