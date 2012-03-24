library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
	generic ( size : natural := 16);
	port (	clk, reset, d : in std_logic;
		q : out std_logic
	);
end entity;


architecture a of debounce is
	signal cnt : unsigned(size-1 downto 0) := (others => '0');
	signal val : std_logic;
begin
	process (clk, reset) begin
		if reset = '1' then
			cnt <= (others => '0');
			val <= '0';
		elsif rising_edge(clk) then
			if d /= val then
				if cnt = (cnt'range => '1') then
					val <= not val;
				end if;
				cnt <= cnt + 1;
			else
				cnt <= (others => '0');
			end if;
		end if;
	end process;
	q <= val;
end;
