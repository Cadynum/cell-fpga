library ieee;
use ieee.std_logic_1164.all;

entity onepulse is
	port (	clk, reset, pulse : in std_logic;
		q : out std_logic
	);
end entity;

architecture a of onepulse is
	signal state : std_logic := '0';
begin
	state <= '0' when reset = '1' else pulse when rising_edge(clk);
	q <= '1' when state = '0' and pulse = '1' else '0';
end architecture;
