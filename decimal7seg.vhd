library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decimal7seg is
	port (
		clk, onPulse : in std_logic;
		binary : in std_logic_vector(7 downto 0);
		an : out std_logic_vector(3 downto 0);
		segment : out std_logic_vector(7 downto 0)
	);
end entity;


architecture a of decimal7seg is
	signal cnt : unsigned(1 downto 0) := "00";
	signal bcd : integer range 0 to 9;
	signal tmp : integer range 0 to 255;

	type seg_t is array (natural range <>) of std_logic_vector(6 downto 0);
	constant segarray : seg_t := ("1000000", "1111001", "0100100", "0110000", "0011001", "0010010"
					, "0000010", "1111000", "0000000", "0011000");

	type sel_t is array (natural range <>) of std_logic_vector(3 downto 0);
	constant sel : sel_t := ("1110", "1101", "1011", "0111");
begin
	process (clk) begin
		if rising_edge(clk) then
			if onPulse = '1' then
				if cnt = "11" then
					tmp <= to_integer(unsigned(binary));
				else
					tmp <= tmp / 10;
				end if;
				cnt <= cnt + 1;
			end if;
		end if;
	end process;

	bcd <= tmp mod 10;
	segment <= '1' & segarray(bcd);
	an <= sel(to_integer(cnt));
end architecture;
