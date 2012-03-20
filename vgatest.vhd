library ieee;
use ieee.std_logic_1164.all;

entity vgatest is
end entity;


architecture a of vgatest is
	signal clk, reset: std_logic := '0';
	signal hsync, vsync : std_logic;
	signal vis : std_logic;

begin
	clk <= not clk after 5 ns;
	reset <= '1' after 10 ns, '0' after 20 ns;

	C1 : entity work.vgacontroller port map (clk, reset, open, open, vis, hsync, vsync);


	process begin
		wait;
	end process;


end architecture;
