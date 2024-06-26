library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    generic (
        size : natural := 32
    );

    port (
        A, B : in  std_logic_vector(size-1 downto 0);
        F    : out std_logic_vector(size-1 downto 0);
        S    : in  std_logic_vector(2 downto 0);
        Z    : out std_logic;
        Ov   : out std_logic;
        Co   : out std_logic
    );
end alu;

architecture alu_1 of alu is
    component alu_1_bit is
        port (
            A, B       : in  std_logic;
            F          : out std_logic;
            Ci         : in  std_logic;
            Ov         : out std_logic;
            Co         : out std_logic;
            Op         : in  std_logic_vector(1 downto 0)
        );
    end component alu_1_bit;
    signal not_b_aux : std_logic;
    signal slt_aux : std_logic;
    signal result_aux : std_logic_vector(size-1 downto 0);
    signal op_aux : std_logic_vector(1 downto 0);
    signal ov_aux : std_logic;
    signal co_aux : std_logic_vector(size-1 downto 0);
    signal zero_aux : std_logic_vector(size-1 downto 0) := (others => '0');
    signal slt_out : std_logic_vector(size-1 downto 0) := (others => '0');
begin
    op_aux <= S(1 downto 0);     

    not_b_aux <= '1' when op_aux = "01" else
                 '0';

    ALUS: for i in size-1 downto 0 generate
        LAST: if i = size-1 generate
            ALU_LAST: alu_1_bit port map (
                A => A(i),
                B => B(i),
                F => result_aux(i),
                Ci => co_aux(i - 1),
                Co => co_aux(i),
                Op => op_aux,
                Ov => ov_aux
            );
        end generate;

        MID: if (i /= size-1) AND (i /= 0) generate
            ALU_I: alu_1_bit port map (
                A => A(i),
                B => B(i),
                F => result_aux(i),
                Ci => co_aux(i - 1),
                Co => co_aux(i),
                Op => op_aux
            );
        end generate;

        FIRST: if i = 0 generate
            ALU_FIRST: alu_1_bit port map (
                A => A(i),
                B => B(i),
                F => result_aux(i),
                Ci => not_b_aux,
                Co => co_aux(i),
                Op => op_aux
            );
        end generate;
    end generate;

    Ov <= ov_aux;

    slt_aux <= (NOT(A(size-1) XOR B(size-1)) AND (result_aux(size-1))) OR (A(size-1) AND NOT(B(size-1)));
    slt_out(0) <= slt_aux;

    Z <= '1' when result_aux = zero_aux else
         '0';
    Co <= co_aux(size-1);   
    
    F <= slt_out when S(2) = '1' else
         result_aux;
end architecture;