library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity finger_cpu is
	generic (
	   reg_n: natural := 8;
		word_size : natural := 16;
		irq_size : natural := 3;
		PC_reset: std_logic_vector(15 downto 0) := "1111111111111110"
	);
	
	port (
		clock: in std_logic;
		reset: in std_logic;
		interrupt: in std_logic;
		irq: in std_logic_vector(irq_size-1 downto 0);
		data_in : in std_logic_vector(word_size-1 downto 0);
		data_write : out std_logic;
		data_out : out std_logic_vector(word_size-1 downto 0);
		inst_in : in std_logic_vector(word_size-1 downto 0);
		inst_address : out std_logic_vector(word_size-1 downto 0);
		data_address : out std_logic_vector(word_size-1 downto 0)
	);
end finger_cpu;

architecture fingerv1 of finger_cpu is
	component alu is
		 generic (
			  size : natural := 16
		 );

		 port (
			  A, B : in  std_logic_vector(size-1 downto 0);
			  F    : out std_logic_vector(size-1 downto 0);
			  S    : in  std_logic_vector(1 downto 0);
			  N	 : out std_logic;
			  Z    : out std_logic;
			  Ov   : out std_logic;
			  Co   : out std_logic
		 );
	end component alu;

	component regfile is
		 generic (
			  reg_n: natural := 8;
			  word_s: natural := 16;
			  PC_reset: std_logic_vector(15 downto 0) := "0000000000100000"
		 );

		 port (
			  clock:                     in  std_logic;
			  reset:                     in  std_logic;
			  regWrite:                  in  std_logic;
			  regWritePC:                in  std_logic;
			  rr1, rr2:                  in  std_logic_vector(natural(ceil(log2(real(reg_n)))) -1 downto 0);
			  wr:                        in  std_logic_vector(natural(ceil(log2(real(reg_n)))) -1 downto 0);
			  d:                         in  std_logic_vector(word_s-1 downto 0);
			  dPC:                       in  std_logic_vector(word_s-1 downto 0);
			  qPC:							  out std_logic_vector(word_s-1 downto 0);
			  q1,  q2:                   out std_logic_vector(word_s-1 downto 0)
		 );
	end component regfile;
	
	component register_d is
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
	end component register_d;
	
	signal s_interrupt_counter : integer := 0;
	signal s_interrupt_stalling : std_logic := '0';
	signal s_interrupt_load_pc : std_logic := '0';

	signal s_inst_address : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_pc_plus_2 : std_logic_vector(word_size-1 downto 0);
	signal s_number_2 : std_logic_vector(word_size-1 downto 0) := (1 => '1', others => '0');
	signal s_op_sum : std_logic_vector(1 downto 0) := (others => '0');
	
	signal s_inst_in : std_logic_vector(word_size-1 downto 0);
	signal s_sel_if : std_logic_vector(2 downto 0);
	
	signal s_processor_stall : std_logic := '0';
	signal s_regWrite : std_logic;
	signal s_regWritePC : std_logic;
	signal s_rr1 : std_logic_vector(natural(ceil(log2(real(reg_n)))) -1 downto 0) := (others => '0');
	signal s_rr2 : std_logic_vector(natural(ceil(log2(real(reg_n)))) -1 downto 0) := (others => '0');
	signal s_wr : std_logic_vector(natural(ceil(log2(real(reg_n)))) -1 downto 0) := (others => '0');
	signal s_lp_reg : std_logic_vector(natural(ceil(log2(real(reg_n)))) -1 downto 0) := std_logic_vector(to_unsigned(reg_n - 2, natural(ceil(log2(real(reg_n))))));	
	signal s_d : std_logic_vector(word_size-1 downto 0);
	
	signal s_imm_if : std_logic_vector(word_size-1 downto 0);
	signal s_q1_if : std_logic_vector(word_size-1 downto 0);
	signal s_q2_if : std_logic_vector(word_size-1 downto 0);
	signal s_q1_before_fwd : std_logic_vector(word_size-1 downto 0);
	signal s_q2_before_fwd : std_logic_vector(word_size-1 downto 0);
	signal s_alu_op_if : std_logic_vector(1 downto 0);
	
	signal s_signal_1 : std_logic := '1';
	signal s_signal_0 : std_logic := '0';
	
	signal s_if_ex_in : std_logic_vector(78 downto 0) := (others => '0');
	signal s_if_ex_out : std_logic_vector(78 downto 0) := (others => '0');
	signal s_if_ex_clear : std_logic := '0';
	
	signal s_ex_wb_in : std_logic_vector(60 downto 0) := (others => '0');
	signal s_ex_wb_out : std_logic_vector(60 downto 0) := (others => '0');
	signal s_ex_wb_clear : std_logic := '0';
	
	signal s_inst_address_ex : std_logic_vector(word_size-1 downto 0) := (others => '0');

	signal s_sel_ex : std_logic_vector(2 downto 0);
	signal s_imm_ex : std_logic_vector(word_size-1 downto 0);
	signal s_q1_ex : std_logic_vector(word_size-1 downto 0);
	signal s_rr1_ex : std_logic_vector(2 downto 0);
	signal s_q2_ex : std_logic_vector(word_size-1 downto 0);
	signal s_rr2_ex : std_logic_vector(2 downto 0);
	signal s_alu_op_ex : std_logic_vector(1 downto 0);
	signal s_regWrite_ex : std_logic;
	signal s_regWrite_ex_after_branch : std_logic;
	signal s_wr_ex : std_logic_vector(natural(ceil(log2(real(reg_n)))) -1 downto 0) := (others => '0');
	
	signal s_alu_a : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_alu_b : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_alu_a_before_fwd : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_alu_b_before_fwd : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_alu_a_after_fwd : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_alu_b_after_fwd : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_alu_res_ex : std_logic_vector(word_size-1 downto 0);
	signal s_zero_ex : std_logic;
	signal s_negative_ex : std_logic;
	signal s_overflow_ex : std_logic;
	signal s_jump_ex : std_logic := '0';
	
	signal s_inst_address_wb : std_logic_vector(word_size-1 downto 0) := (others => '0');

	signal s_sel_wb : std_logic_vector(2 downto 0);
	signal s_alu_res_wb : std_logic_vector(word_size-1 downto 0);
	signal s_rr1_wb : std_logic_vector(2 downto 0);
	signal s_alu_b_after_fwd_wb : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_rr2_wb : std_logic_vector(2 downto 0);
	signal s_regWrite_wb : std_logic;
	signal s_wr_wb : std_logic_vector(natural(ceil(log2(real(reg_n)))) -1 downto 0) := (others => '0');
	
	signal s_data_address : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_data_in : std_logic_vector(word_size-1 downto 0);
	signal s_data_out : std_logic_vector(word_size-1 downto 0);
	
	
	signal s_pc_input : std_logic_vector(word_size-1 downto 0) := (others => '0');
	signal s_res_to_write : std_logic_vector(word_size-1 downto 0);
begin

	INTERRUPT_COUNTER: process(clock, interrupt, s_interrupt_counter, s_interrupt_stalling, s_interrupt_load_pc) is
	begin
		if(rising_edge(clock)) then
			if(interrupt = '1') then
				s_interrupt_counter <= 2;
				s_interrupt_stalling <= '1';
			elsif(s_interrupt_counter > 0) then
				s_interrupt_counter <= s_interrupt_counter - 1;
			elsif(s_interrupt_stalling = '1' and s_interrupt_load_pc = '0') then
				s_interrupt_counter <= 0;
				s_interrupt_stalling <= '0';
				s_interrupt_load_pc <= '1';
			else
				s_interrupt_load_pc <= '0';
			end if;
		end if;
	end process;

	--FETCH
	inst_address <= s_inst_address;
	data_address <= s_data_address;
	s_sel_if <= s_inst_in(15 downto 13);
	
	ADDER2: alu
	generic map (
		size => 16
	)
	port map (
		A => s_inst_address,
		B => s_number_2,
		F => s_pc_plus_2,
		S => s_op_sum
	);

	s_inst_in <= inst_in when (s_interrupt_stalling = '0' and s_interrupt_load_pc = '0') else
				 "0011100001110000" when (s_interrupt_stalling = '0' and s_interrupt_load_pc = '1') else
				 "0000000000000000";
				 
	
	s_regWritePC <= NOT(s_processor_stall);
	s_regWrite <= '1' when (s_sel_if /= "000" and s_sel_if /= "111") else
					  '0';
	
	s_rr1 <= s_inst_in(6 downto 4) when s_sel_if = "001" else
				s_inst_in(9 downto 7) when (s_sel_if = "011" or s_sel_if(2) = '1') else
				(others => '0');
	s_rr2 <= s_inst_in(9 downto 7) when s_sel_if = "001" else
				s_inst_in(12 downto 10) when (s_sel_if = "111" or s_sel_if(2 downto 1) = "10") else
				(others => '0');	
	
	s_wr <= s_inst_in(12 downto 10) when (s_sel_if(2) = '0' or s_sel_if = "110") else
		     s_lp_reg when s_sel_if(2 downto 1) = "10" else
			  (others => '0');
	
	s_imm_if <= "000000" & s_inst_in(9 downto 0) when (s_sel_if = "010" and s_inst_in(9) = '0') else
					"00000000000" & s_inst_in(4 downto 0) when (s_sel_if = "011" and s_inst_in(4) = '0') else
					"111111" & s_inst_in(9 downto 0) when (s_sel_if = "010" and s_inst_in(9) = '1') else
					"11111111111" & s_inst_in(4 downto 0) when (s_sel_if = "011" and s_inst_in(4) = '1') else
					(others => '0');
				
	s_alu_op_if <= s_inst_in(3 downto 2) when (s_sel_if = "001") else
						s_inst_in(6 downto 5) when (s_sel_if = "011") else
						(others => '0');
	
	s_pc_input <= "00000000" & irq & "00000" when (s_interrupt_load_pc = '1') else
				  s_pc_input when (s_interrupt_stalling = '1' and s_jump_ex = '0') else
				  s_alu_b when (s_interrupt_stalling = '1' and s_jump_ex = '1') else
				  s_pc_plus_2 when (s_jump_ex = '0') else
				  s_alu_b;

	s_d <= s_res_to_write;
	
	REGS: regfile
	generic map (
		reg_n => reg_n,
		word_s => word_size,
		PC_reset => PC_reset
	)
	
	port map (
		clock => clock,
		reset => reset,
		regWrite => s_regWrite_wb,
		regWritePC => s_regWritePC,
		rr1 => s_rr1,
		rr2 => s_rr2,
		wr => s_wr_wb,
		d => s_d,
		dPC => s_pc_input,
		qPC => s_inst_address,
		q1 => s_q1_before_fwd,
		q2 => s_q2_before_fwd
	);

	s_q1_if <= s_res_to_write when (s_rr1 = s_wr_wb and s_rr1 /= "000") else
			   s_q1_before_fwd;

	s_q2_if <= s_res_to_write when (s_rr2 = s_wr_wb and s_rr2 /= "000") else
			   s_q2_before_fwd;
	
	s_if_ex_clear <= s_jump_ex OR reset;
	
	--            16			   3          16         16        3       16        3       2             1            3
	s_if_ex_in <= s_inst_address & s_sel_if & s_imm_if & s_q1_if & s_rr1 & s_q2_if & s_rr2 & s_alu_op_if & s_regWrite & s_wr;

	REG_IF_EX: register_d
	generic map (
		N => 79
	)
	port map (
      clock => clock,
      enable => s_signal_1,
      clear => s_if_ex_clear,
      D => s_if_ex_in,
      Q => s_if_ex_out
	);
	
	s_inst_address_ex <= s_if_ex_out(78 downto 63); 
	s_sel_ex <= s_if_ex_out(62 downto 60);
	s_imm_ex <= s_if_ex_out(59 downto 44);
	s_q1_ex <= s_if_ex_out(43 downto 28);
	s_rr1_ex <= s_if_ex_out(27 downto 25);
	s_q2_ex <= s_if_ex_out(24 downto 9);
	s_rr2_ex <= s_if_ex_out(8 downto 6);
	s_alu_op_ex <= s_if_ex_out(5 downto 4);
	s_regWrite_ex <= s_if_ex_out(3);
	s_wr_ex <= s_if_ex_out(2 downto 0);
	
	s_alu_a <= s_alu_a_after_fwd;
	
	s_alu_b <= (others => '0') when (s_sel_ex(2) = '1') else
			   s_alu_b_after_fwd;

	s_alu_a_after_fwd <= s_res_to_write when (s_rr1_ex = s_wr_wb and s_rr1_ex /= "000") else
						 s_alu_a_before_fwd;

	s_alu_b_after_fwd <= s_res_to_write when (s_rr2_ex = s_wr_wb and s_rr2_ex /= "000") else
						 s_alu_b_before_fwd;
	
	s_alu_a_before_fwd <= s_q1_ex;

	s_alu_b_before_fwd <= s_q2_ex when (s_sel_ex = "001" or s_sel_ex(2) = '1') else
								 s_imm_ex when (s_sel_ex(2 downto 1) = "01") else
								 (others => '0');

	GENALU: alu
	generic map (
		size => 16
	)
	port map (
		A => s_alu_a,
		B => s_alu_b,
		F => s_alu_res_ex,
		S => s_alu_op_ex,
		Z => s_zero_ex,
		N => s_negative_ex,
		Ov => s_overflow_ex
	);
	
	s_jump_ex <= '1' when ((s_sel_ex = "100" and s_zero_ex = '1') or
						   (s_sel_ex = "101" and (s_negative_ex /= s_overflow_ex))) else
	'0';

	s_regWrite_ex_after_branch <= '0' when ((s_sel_ex = "100" or s_sel_ex = "101") and s_jump_ex = '0') else
								   s_regWrite_ex;
	
	--            16				  3          16             3          16                  3          1                            3
	s_ex_wb_in <= s_inst_address_ex & s_sel_ex & s_alu_res_ex & s_rr1_ex & s_alu_b_after_fwd & s_rr2_ex & s_regWrite_ex_after_branch & s_wr_ex;
	
	s_ex_wb_clear <= reset;
	
	REG_EX_WB: register_d
	generic map (
		N => 61
	)
	port map (
      clock => clock,
      enable => s_signal_1,
		clear => s_ex_wb_clear,
      D => s_ex_wb_in,
      Q => s_ex_wb_out
	);
	
	s_inst_address_wb <= s_ex_wb_out(60 downto 45);
	s_sel_wb <= s_ex_wb_out(44 downto 42);
	s_alu_res_wb <= s_ex_wb_out(41 downto 26);
	s_rr1_wb <= s_ex_wb_out(25 downto 23);
	s_alu_b_after_fwd_wb <= s_ex_wb_out(22 downto 7);
	s_rr2_wb <= s_ex_wb_out(6 downto 4);
	s_regWrite_wb <= s_ex_wb_out(3);
	s_wr_wb <= s_ex_wb_out(2 downto 0);
	
	s_data_address <= s_alu_res_wb when (s_sel_wb(2 downto 1) = "11") else
					  (others => '0');
							
	s_data_in <= data_in;
							
	data_write <= '1' when (s_sel_wb = "111") else
					  '0';
					  
	s_data_out <= s_alu_b_after_fwd_wb;

	data_out <= s_data_out;
	
	s_res_to_write <= s_data_in when (s_sel_wb = "110") else
					  s_inst_address_wb when (s_sel_wb(2 downto 1) = "10") else
					  s_alu_res_wb;
	
end architecture;