library ieee;
use ieee.std_logic_1164.all;
use work.types.all;


entity celltest is
end entity;


architecture a of celltest is
	constant size : natural := 16;
	signal clk, reset: std_logic := '0';
	signal view, ready : std_logic;
	signal cellS : Source;
begin
	clk <= not clk after 5 ns;
	reset <= '1' after 10 ns, '0' after 20 ns;

	cellS <=	OneSet after 200 ns,
			NextGeneration after 500 ns,
			OneSet after 2000 ns;

	C1 : entity work.cell generic map (size) port map (clk, reset, cellS, '0', "00000010", view, ready);



	process begin
		wait;
	end process;


end architecture;
