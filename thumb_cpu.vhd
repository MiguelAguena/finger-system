library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity thumb_cpu is
	generic (
		word_size : natural := 8;
		address_size : natural := 16;
		ctrl_size : natural := 2
	)
	port (
		interruption: in std_logic;
		controller_1: in std_logic_vector(ctrl_size-1 downto 0);
		controller_2: in std_logic_vector(ctrl_size-1 downto 0);
		data_in : in std_logic_vector(word_size-1 downto 0);
		data_out : out std_logic_vector(word_size-1 downto 0);
		mem_address : out std_logic_vector(address_size-1 downto 0)
	)