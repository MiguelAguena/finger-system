library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interrupt_generator is
    port (
        ck : in std_logic;
        reset : in std_logic;
		interrupt: out std_logic;
		irq: out std_logic_vector(2 downto 0);
        finished_frame : in std_logic;
        input_1_up : in std_logic;
        input_1_down : in std_logic;
        input_2_up : in std_logic;
        input_2_down : in std_logic;
        wr : in  std_logic;
        ctrl_state_addr : in std_logic_vector(2 downto 0);
        ctrl_state_i : in std_logic;
        ctrl_state_o : out std_logic
    );
end interrupt_generator;

architecture ig_1 of interrupt_generator is
    component flip_flop_d is
        port (
            clock : in std_logic;
            clear : in std_logic;
            enable : in std_logic;
            D : in std_logic;
            Q : out std_logic
        );
    end component flip_flop_d;

    component edge_detector is
        port (  
            clock : in std_logic;
            signal_in : in std_logic;
            signal_out : out std_logic
        );
    end component edge_detector;

    signal s_input_1_up, s_input_1_up_edge : std_logic;
    signal s_input_1_down, s_input_1_down_edge : std_logic;
    signal s_input_2_up, s_input_2_up_edge : std_logic;
    signal s_input_2_down, s_input_2_down_edge : std_logic;
    signal s_finished_frame, s_finished_frame_edge : std_logic;

    signal s_input_1_up_reg_out : std_logic;
    signal s_input_1_down_reg_out : std_logic;
    signal s_input_2_up_reg_out : std_logic;
    signal s_input_2_down_reg_out : std_logic;
    signal s_finished_frame_reg_out : std_logic;

    signal s_interrupt : std_logic;

    signal s_wr_1_up, s_wr_1_down, s_wr_2_up, s_wr_2_down, s_wr_finished_frame: std_logic;
begin
    s_input_1_up <= (not input_1_up);
    s_input_1_down <= (not input_1_down);
    s_input_2_up <= (not input_2_up);
    s_input_2_down <= (not input_2_down);

    s_finished_frame <= finished_frame;

    s_wr_1_up <= '1' when (wr = '1' and ctrl_state_addr = "000") else
                 '0';
    
    s_wr_1_down <= '1' when (wr = '1' and ctrl_state_addr = "001") else
                   '0';

    s_wr_2_up <= '1' when (wr = '1' and ctrl_state_addr = "010") else
                 '0';

    s_wr_2_down <= '1' when (wr = '1' and ctrl_state_addr = "011") else
                   '0';

    s_wr_finished_frame <= '1' when (wr = '1' and ctrl_state_addr = "100") else
                           '0';

    ctrl_state_o <= s_input_1_up_reg_out when (ctrl_state_addr = "000") else
                    s_input_1_down_reg_out when (ctrl_state_addr = "001") else
                    s_input_2_up_reg_out when (ctrl_state_addr = "010") else
                    s_input_2_down_reg_out when (ctrl_state_addr = "011") else
                    s_finished_frame_reg_out when (ctrl_state_addr = "100") else
                    '0';

    interrupt <= (s_input_1_up_edge and not(s_input_1_up_reg_out)) or (s_input_1_down_edge and not(s_input_1_down_reg_out)) or (s_input_2_up_edge and not(s_input_2_up_reg_out)) or (s_input_2_down_edge and not(s_input_2_down_reg_out)) or (s_finished_frame_edge and not(s_finished_frame_reg_out));

    irq <= "000" when (s_input_1_up_edge = '1') else
           "001" when (s_input_1_down_edge = '1') else
           "010" when (s_input_2_up_edge = '1') else
           "011" when (s_input_2_down_edge = '1') else
           "100" when (s_finished_frame_edge = '1') else
           "000";

    FF_000: flip_flop_d
    port map (
        clock => ck,
        clear => reset,
        enable => s_wr_1_up,
        D => ctrl_state_i,
        Q => s_input_1_up_reg_out
    );

    FF_001: flip_flop_d
    port map (
        clock => ck,
        clear => reset,
        enable => s_wr_1_down,
        D => ctrl_state_i,
        Q => s_input_1_down_reg_out
    );

    FF_010: flip_flop_d
    port map (
        clock => ck,
        clear => reset,
        enable => s_wr_2_up,
        D => ctrl_state_i,
        Q => s_input_2_up_reg_out
    );

    FF_011: flip_flop_d
    port map (
        clock => ck,
        clear => reset,
        enable => s_wr_2_down,
        D => ctrl_state_i,
        Q => s_input_2_down_reg_out
    );

    FF_100: flip_flop_d
    port map (
        clock => ck,
        clear => reset,
        enable => s_wr_finished_frame,
        D => ctrl_state_i,
        Q => s_finished_frame_reg_out
    );

    INPUT_1_UP_INTERRUPT: edge_detector
    port map (
        clock => ck,
        signal_in => s_input_1_up,
        signal_out => s_input_1_up_edge
    );

    INPUT_1_DOWN_INTERRUPT: edge_detector
    port map (
        clock => ck,
        signal_in => s_input_1_down,
        signal_out => s_input_1_down_edge
    );

    INPUT_2_UP_INTERRUPT: edge_detector
    port map (
        clock => ck,
        signal_in => s_input_2_up,
        signal_out => s_input_2_up_edge
    );

    INPUT_2_DOWN_INTERRUPT: edge_detector
    port map (
        clock => ck,
        signal_in => s_input_2_down,
        signal_out => s_input_2_down_edge
    );

    FINISHED_FRAME_INTERRUPT: edge_detector
    port map (
        clock => ck,
        signal_in => s_finished_frame,
        signal_out => s_finished_frame_edge
    );
end architecture;