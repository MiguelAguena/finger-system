library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity finger_system is
	port (
		clock : in std_logic;
		reset : in std_logic;
		hsync : out std_logic;
		vsync : out std_logic;
		vga_r : out std_logic_vector(3 downto 0);
		vga_g : out std_logic_vector(3 downto 0);
		vga_b : out std_logic_vector(3 downto 0);
		input_1_up : in std_logic;
		input_1_down : in std_logic;
		input_2_up : in std_logic;
		input_2_down : in std_logic
	);
end finger_system;

architecture arch of finger_system is

	component finger_cpu is
		generic (
			reg_n: natural := 8;
			word_size : natural := 16;
			irq_size : natural := 3;
			PC_reset: std_logic_vector(15 downto 0) := "0000000010000000"
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
	end component finger_cpu;
	
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
			ctrl_state_addr : out std_logic_vector(2 downto 0);
			ctrl_state_i_ig : in std_logic;
			ctrl_state_o_ig : out std_logic;
			ctrl_state_wr : out std_logic;
			inst_addr : in  std_logic_vector(addr_s-1 downto 0);
			inst_o : out std_logic_vector(word_s-1 downto 0);
			addr_video : in std_logic_vector(addr_s-1 downto 0);
			data_video : out std_logic_vector(word_s-1 downto 0)
		);
	end component mem_ctrl;

	component vga_ctrl is
		generic (
		   addr_s : natural := 16;
		   word_s : natural := 16
		);
		
	   port (
		   clock : in std_logic;
		   reset : in std_logic;
		   addr : out std_logic_vector(addr_s-1 downto 0);
		   data : in std_logic_vector(word_s-1 downto 0);
		   vblank : out std_logic;
		   hsync : out std_logic;
		   vsync : out std_logic;
		   vga_r : out std_logic_vector(3 downto 0);
		   vga_g : out std_logic_vector(3 downto 0);
		   vga_b : out std_logic_vector(3 downto 0)
	   );
   end component vga_ctrl;

	component interrupt_generator is
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
	end component interrupt_generator;	
	
	signal s_data_in : std_logic_vector(15 downto 0);
	signal s_data_write : std_logic;
	signal s_data_out : std_logic_vector(15 downto 0);
	signal s_inst_in : std_logic_vector(15 downto 0);
	signal s_inst_address : std_logic_vector(15 downto 0);
	signal s_data_address : std_logic_vector(15 downto 0);
	signal s_interrupt : std_logic;
	signal s_irq : std_logic_vector(2 downto 0);
	signal s_ctrl_state_addr : std_logic_vector(2 downto 0);
	signal s_ctrl_state_i_ig : std_logic;
	signal s_ctrl_state_o_ig : std_logic;
	signal s_ctrl_state_wr : std_logic;
	signal s_addr_video : std_logic_vector(15 downto 0);
	signal s_data_video : std_logic_vector(15 downto 0);
	signal s_vblank : std_logic;
begin

		CPU: finger_cpu
		port map (
			clock => clock,
			reset => reset,
			interrupt => s_interrupt,
			irq => s_irq,
			data_in => s_data_in,
			data_write => s_data_write,
			data_out => s_data_out,
			inst_in => s_inst_in,
			inst_address => s_inst_address,
			data_address => s_data_address
		);

	  MEM_CONTROLLER: mem_ctrl
	  port map (
			ck => clock,
			wr => s_data_write,
			data_addr => s_data_address,
			data_i => s_data_out,
			data_o => s_data_in,
			ctrl_state_addr => s_ctrl_state_addr,
			ctrl_state_i_ig => s_ctrl_state_i_ig,
			ctrl_state_o_ig => s_ctrl_state_o_ig,
			ctrl_state_wr => s_ctrl_state_wr,
			inst_addr => s_inst_address,
			inst_o => s_inst_in,
			addr_video => s_addr_video,
			data_video => s_data_video
   	  );

	  INTERRUPT_GEN: interrupt_generator
	  port map (
			ck => clock,
			reset => reset,
			interrupt => s_interrupt,
			irq => s_irq,
			finished_frame => s_vblank,
			input_1_up => input_1_up,
			input_1_down => input_1_down,
			input_2_up => input_2_up,
			input_2_down => input_2_down,
			wr => s_ctrl_state_wr,
			ctrl_state_addr => s_ctrl_state_addr,
			ctrl_state_i => s_ctrl_state_o_ig,
			ctrl_state_o => s_ctrl_state_i_ig
	  );

	  VGA_CONTROLLER: vga_ctrl
	  generic map (
			addr_s => 16,
			word_s => 16
	  )	
	  port map (
			clock => clock,
			reset => reset,
			addr => s_addr_video,
			data => s_data_video,
			vblank => s_vblank,
			hsync => hsync,
			vsync => vsync,
			vga_r => vga_r,
			vga_g => vga_g,
			vga_b => vga_b
		);
end arch; -- arch