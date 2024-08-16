library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync is
    port (
		clock : in std_logic;
		reset : in std_logic;
		blank : out std_logic;
		hsync : out std_logic;
		vsync : out std_logic;
		vblank : out std_logic
    );
end vga_sync;
	 
architecture vga_sync_1 of vga_sync is
	signal s_h_line : integer := 800;                           
	signal s_h_back : integer := 144;
	signal s_h_front : integer := 16;
	signal s_v_line : integer := 525;
	signal s_v_back : integer := 34;
	signal s_v_front : integer := 11;
	signal s_h_sync_cycle : integer := 96;
	signal s_v_sync_cycle : integer := 2;
	
	signal s_h_counter : integer := 0;
	signal s_v_counter : integer := 0;
	
	signal s_hsync, s_vsync, s_blank, s_vblank, s_h_valid, s_v_valid : std_logic := '0';
begin

	COUNT: process(clock, reset, s_h_counter, s_v_counter) is
	begin
		if(falling_edge(clock)) then
			if(reset = '1') then
				s_h_counter <= 0;
				s_v_counter <= 0;
			else
				if(s_h_counter >= s_h_line - 1) then
					s_h_counter <= 0;
					if(s_v_counter >= s_v_line - 1) then
						s_v_counter <= 0;
					else
						s_v_counter <= s_v_counter + 1;
					end if;
				else
					s_h_counter <= s_h_counter + 1;
				end if;
			end if;
		end if;
	end process;
	
	s_hsync <= '0' when (s_h_counter < s_h_sync_cycle) else
				  '1';
	s_vsync <= '0' when (s_v_counter < s_v_sync_cycle) else
				  '1';
				  
	s_h_valid <= '1' when (s_h_counter < (s_h_line - s_h_front) and s_h_counter >= s_h_back) else
					 '0';
					 
	s_v_valid <= '1' when (s_v_counter < (s_v_line - s_v_front) and s_v_counter >= s_v_back) else
					 '0';

	s_blank <= s_h_valid and s_v_valid;
	
	s_vblank <= not(s_v_valid);
	
	UPDATE: process(clock) is
	begin
		if(falling_edge(clock)) then
			blank <= s_blank;
			hsync <= s_hsync;
			vsync <= s_vsync;
			vblank <= s_vblank;
		end if;
	end process;
end architecture;