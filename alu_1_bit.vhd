library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_1_bit is
    port (
        A, B       : in  std_logic;
        F          : out std_logic;
        Ci         : in  std_logic;
        Ov         : out std_logic;
        Co         : out std_logic;
        Op         : in  std_logic_vector(1 downto 0)
    );
end alu_1_bit;

architecture alu_1_bit_1 of alu_1_bit is
    signal a_aux, b_aux : std_logic;
    signal and_aux : std_logic;
    signal or_aux : std_logic;
    signal adder_aux : std_logic;
    signal result_aux : std_logic;
begin
    a_aux <= A;

    b_aux <= (NOT B) when OP = "01" else
             B;

    and_aux <= a_aux AND b_aux;
    or_aux <= a_aux OR b_aux;

    adder_aux <= ((a_aux XOR b_aux) XOR Ci);
    Co <= (a_aux AND b_aux) OR (a_aux AND Ci) OR (b_aux AND Ci);

    result_aux <= and_aux when Op = "10" else
                  or_aux when Op = "11" else
                  adder_aux;
  

    Ov <= (NOT(adder_aux) AND a_aux AND b_aux) OR (adder_aux AND NOT(a_aux) AND NOT(b_aux));
    
    F <= result_aux;
end architecture;