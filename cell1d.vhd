library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
use work.modeline.all;


entity cell1d is
	port (
		clk_in, reset, btnr, btnl, btnu, btnd : in std_logic;
		sw : in std_logic_vector(7 downto 0);
		an : out std_logic_vector(3 downto 0);
		seg : out std_logic_vector(7 downto 0);
		vgaRed, vgaGreen : out std_logic_vector(2 downto 0);
		vgaBlue : out std_logic_vector(1 downto 0);
		hSync, vSync : out std_logic
	);
end entity;


architecture a of cell1d is
	constant r : Sync := r1280x1024x60;

	constant width : integer := 1280;
	constant height : integer := 1024;
	signal clk, visible : std_logic;

	signal rule : std_logic_vector(7 downto 0);
	signal x: integer range 0 to width-1;
	signal y : integer range 0 to height-1;

	signal hPulse, vPulse : std_logic;
	signal animate : std_logic := '0';
	signal cc, output : std_logic;

	signal trigCell: Source := OneSet;
	signal saveGeneration : std_logic;

	signal btnuDB, btndDB : std_logic;
	signal incSpeed, decSpeed : std_logic;
	signal speed : unsigned(5 downto 0) := (others => '0');

begin

C_CLOCKGEN: entity work.clockgen port map (clk_in, clk);

CELL:	entity work.cell generic map (width)
		port map (clk, reset, trigCell, saveGeneration, rule, cc);


	trigCell <= 	OneSet		when vPulse = '1' and animate = '0' else
			FromSeed	when vPulse = '1' and animate = '1' else
			NextGeneration	when x = 0 and hPulse = '1' else
			Idle;


	saveGeneration <= '1' when y = speed and x = 0 and hPulse = '1' else '0';

	INCD : entity work.debounce generic map (15) port map (clk, reset, btnu, btnuDB);
	DECD : entity work.debounce generic map (15) port map (clk, reset, btnd, btndDB);
	INC: entity work.onepulse port map (clk, reset, btnuDB, incSpeed);
	DEC: entity work.onepulse port map (clk, reset, btndDB, decSpeed);

	process (reset, clk) is begin
		if reset = '1' then
			speed <= (others => '0');
		elsif rising_edge(clk) then
			if incSpeed = '1' and decSpeed = '0' then
				speed <= speed + 1;
			elsif incSpeed = '0' and decSpeed = '1' then
				speed <= speed - 1;
			end if;
		end if;
	end process;


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

VGACTL:	entity work.vgaController generic map (r)
			port map (clk, reset, x, y, visible, hPulse, vPulse, hSync, vSync);
	
	output <= visible and not cc;
	vgaRed <= (others => output);
	vgaGreen <= (others => output);
	vgaBlue <= (others => output);

end architecture;
