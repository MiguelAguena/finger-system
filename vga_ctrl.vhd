library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_ctrl is
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
end vga_ctrl;

architecture vga_ctrl_1 of vga_ctrl is
	component vga_sync is
		 port (
			clock : in std_logic;
			reset : in std_logic;
			blank : out std_logic;
			hsync : out std_logic;
			vsync : out std_logic;
			vblank : out std_logic
		 );
	end component;

	component vga_pll is
		port (
			refclk   : in  std_logic := '0'; --  refclk.clk
			rst      : in  std_logic := '0'; --   reset.reset
			outclk_0 : out std_logic         -- outclk0.clk
		);
	end component vga_pll;
	
	signal s_vga_clock : std_logic := '0';
	
	signal s_video_width : integer := 320;
	signal s_video_height : integer := 240;
	
	signal s_addr : std_logic_vector(addr_s-1 downto 0) := (others => '0');
	signal s_bit_counter : integer := 0;
	signal s_pixel : std_logic;
	signal s_addr_counter_divide : std_logic := '0';
	
	signal s_vga_r, s_vga_g, s_vga_b : std_logic_vector(3 downto 0) := (others => '0');
	
	signal s_blank, s_vblank, s_hsync, s_vsync, s_vblank_aux, s_hsync_aux, s_vsync_aux : std_logic := '0';

begin
	addr <= s_addr;
	
	vga_r <= s_vga_r;
	vga_g <= s_vga_g;
	vga_b <= s_vga_b;
	
	
	PLL: vga_pll
	port map (
		refclk => clock,
		rst => reset,
		outclk_0 => s_vga_clock
	);

	s_pixel <= data(s_bit_counter);
	ADDR_COUNTER: process(s_vga_clock, s_blank, s_addr_counter_divide, s_bit_counter, s_vblank) is
	begin
		if(rising_edge(s_vga_clock)) then
			if(reset = '1') then
				s_addr <= (others => '0');
				s_addr_counter_divide <= '0';
				s_bit_counter <= 0;
			else
				if(s_vblank = '1') then				
					s_addr <= (others => '0');
				end if;
				if(s_blank = '1') then
					if(s_addr_counter_divide = '0') then
						s_addr_counter_divide <= '1';
					else
						s_addr_counter_divide <= '0';
						if(s_bit_counter < word_s-1) then
							s_bit_counter <= s_bit_counter + 1;
						else
							s_bit_counter <= 0;
							if(s_vblank = '0') then
								s_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(s_addr)) + 1, addr_s));
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	s_vga_r <= "1111" when (s_pixel = '1') else
				  "0000";
				  
	s_vga_g <= "1111" when (s_pixel = '1') else
				  "0000";
				  
	s_vga_b <= "1111" when (s_pixel = '1') else
				  "0000";

	UPDATE: process(s_vga_clock) is
	begin
		if(rising_edge(s_vga_clock)) then
			s_vblank_aux <= s_vblank;
			s_hsync_aux <= s_hsync;
			s_vsync_aux <= s_vsync;
			
			vblank <= s_vblank_aux;
			hsync <= s_hsync_aux;
			vsync <= s_vsync_aux;
		end if;
	end process;
	
	SYNC: vga_sync
	port map(
		clock => s_vga_clock,
		reset => reset,
		blank => s_blank,
		hsync => s_hsync,
		vsync => s_vsync,
		vblank => s_vblank
	);	
end architecture;