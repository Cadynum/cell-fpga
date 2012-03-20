library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;


entity cell1d is
	port (
		clk_in, reset, btnr, btnl : in std_logic;
		sw : in std_logic_vector(7 downto 0);
		an : out std_logic_vector(3 downto 0);
		seg : out std_logic_vector(7 downto 0);
		vgaRed, vgaGreen : out std_logic_vector(2 downto 0);
		vgaBlue : out std_logic_vector(1 downto 0);
		hSync, vSync : out std_logic
	);
end entity;


architecture a of cell1d is
	constant width : integer := 1024;
	constant height : integer := 768;
	signal clk, visible : std_logic;

	signal rule : std_logic_vector(7 downto 0);
	signal x: integer range 0 to width-1;
	signal y : integer range 0 to height-1;

	signal hPulse, vPulse : std_logic;
	signal animate : std_logic := '0';
	signal cc : std_logic;

	signal trigCell: Source := OneSet;
	signal saveGeneration : std_logic;

	component clockgen is
	port
	 (-- Clock in ports
	  clk_in           : in     std_logic;
	  -- Clock out ports
	  clk_out        : out    std_logic
	 );
	end component;
begin

C_CLOCKGEN: component clockgen port map (clk_in, clk);

CELL:	entity work.cell generic map (width)
		port map (clk, reset, trigCell, saveGeneration, rule, cc, open);


	trigCell <= 	OneSet		when vPulse = '1' and animate = '0' else
			FromSeed	when vPulse = '1' and animate = '1' else
			NextGeneration	when x = 0 and hPulse = '1' else
			Idle;


	saveGeneration <= '1' when y = 1 and x = 0 and hPulse = '1' else '0';


	process (reset, clk) is begin
		if reset = '1' then
			animate <= '0';
		elsif rising_edge(clk) then
			if vPulse = '1' then
				rule <= sw;
			end if;
			if btnr = '1' and btnl = '0' then
				animate <= '1';
			elsif btnr = '0' and btnl = '1' then
				animate <= '0';
			end if;
		end if;
	end process;

Seg7Disp: entity work.decimal7seg port map (clk, hPulse, rule, an, seg);

VGACTL:	entity work.vgaController
			-- 1280x1024x60hz
			--generic map	( 1280, 48, 112, 248, '1'
			--		, 1024, 1, 3, 38, '1')

			--1024x768x60hz
			generic map	( 1024, 24, 136, 160, '0'
					, 768, 3, 6, 29, '0')
			port map (clk, reset, x, y, visible, hPulse, vPulse, hSync, vSync);

	vgaRed <= (others => visible and not cc);
	vgaGreen <= (others => visible and not cc);
	vgaBlue <= (others => visible and not cc);

end architecture;
