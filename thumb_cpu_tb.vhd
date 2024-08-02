library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity thumb_cpu_tb is
	port (
		counter: out natural
	);
end thumb_cpu_tb;

architecture arch of thumb_cpu_tb is

	component thumb_cpu is
		generic (
			reg_n: natural := 8;
			word_size : natural := 16;
			irq_size : natural := 2;
			PC_reset: std_logic_vector(15 downto 0) := "0000000000100000"
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
	end component thumb_cpu;
	
	component mem_ctrl is
		generic (
			addr_s : natural := 16;
			word_s : natural := 16
		);
		port (
			ck : in  std_logic;
			wr : in  std_logic;
			data_addr : in  std_logic_vector(addr_s-1 downto 0);
			data_i : in  std_logic_vector(word_s-1 downto 0);
			data_o : out std_logic_vector(word_s-1 downto 0);
			inst_addr : in  std_logic_vector(addr_s-1 downto 0);
			inst_o : out std_logic_vector(word_s-1 downto 0)
		);
	end component mem_ctrl;
  
	signal clock_in : std_logic := '0';
	constant clockPeriod : time := 20 ns; -- clock de 50MHz
	 
	signal s_data_in : std_logic_vector(15 downto 0);
	signal s_data_write : std_logic;
	signal s_data_out : std_logic_vector(15 downto 0);
	signal s_inst_in : std_logic_vector(15 downto 0);
	signal s_inst_address : std_logic_vector(15 downto 0);
	signal s_data_address : std_logic_vector(15 downto 0);
	signal s_zero : std_logic := '0';
	signal s_interrupt : std_logic := '0';
	signal s_irq : std_logic_vector(1 downto 0) := "00";
	
	signal s_counter : natural := 0;
begin
    clock_in <= (not clock_in) after clockPeriod/2;

		DUT: thumb_cpu
		port map (
			clock => clock_in,
			reset => s_zero,
			interrupt => s_interrupt,
			irq => s_irq,
			data_in => s_data_in,
			data_write => s_data_write,
			data_out => s_data_out,
			inst_in => s_inst_in,
			inst_address => s_inst_address,
			data_address => s_data_address
		);

	  MEM: mem_ctrl
	  port map (
			ck => clock_in,
			wr => s_data_write,
			data_addr => s_data_address,
			data_i => s_data_out,
			data_o => s_data_in,
			inst_addr => s_inst_address,
			inst_o => s_inst_in
   	  );
	  
	  p0: process(clock_in, s_counter) is
	  begin
		if rising_edge(clock_in) then 
			s_counter <= s_counter + 1;
		end if;
	  end process p0;
	  
	  counter <= s_counter;
end arch; -- arch