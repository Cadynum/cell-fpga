package types is
	type Source is (Idle, NextGeneration, OneSet, FromSeed);
end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;


entity cell is
	generic( size : natural );

	port (
		clk, reset : in std_logic;
		cellSource : in Source;
		save : in std_logic;
		rule : in std_logic_vector(7 downto 0);
		current: out std_ulogic
	);
end;


architecture a of cell is
	constant cellMax : natural := size-1;

	signal c, cs, css : std_logic;

	signal cell, seed: std_logic_vector(cellMax downto 0);

	signal cnt, setCnt, setCntT: integer range 0 to cellMax;
	signal working, setWorking, setWorkingT : std_logic;

	signal cellMode : Source := Idle;
	signal saveMode : std_logic;

	signal store : std_logic_vector(1 downto 0);
	signal threeCells : std_logic_vector(2 downto 0);

	signal writeEnable : boolean;
	signal writeContent : std_logic;


	function active_high(b : boolean) return std_logic is begin
		if b then	return '1';
		else		return '0'; end if;
	end function;
begin
	process (clk, reset) is begin
		if reset = '1' then
			cnt <= 0;
		elsif rising_edge(clk) then
			store <= store(0) & c;
			if cnt = cellMax then
				cnt <= 0;
			elsif working = '1' then
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
	working <= '1' when cellMode /= Idle else '0';

	process (clk) is begin
		if rising_edge(clk) then
			setCntT <= cnt;
			setWorkingT <= working;
			setWorking <= setWorkingT;
			setCnt <= setCntT;

			c <= cell(cnt);
			cs <= seed(cnt);
			css <= cs;
		end if;
	end process;

	threeCells <=	'0' & store(0) & c 	when setCnt = 0		else
			store & '0'		when setCnt = cellMax	else
			store & c;


	--Writer
	writeEnable <= (cellMode /= Idle) and (setWorking = '1');
	with cellMode select
	writeContent <=	rule(to_integer(unsigned(threeCells)))	when NextGeneration,
			active_high(cnt = size/2)		when OneSet,
			css					when FromSeed,
			'0'					when others;
	process (clk) is begin
		if rising_edge(clk) then
			if writeEnable then
				cell(setCnt) <= writeContent;
			end if;
			if saveMode = '1' then
				seed(setCntT) <= c;
			end if;
		end if;
	end process;



	process (clk, reset) is
	begin
		if reset = '1' then
			cellMode <= Idle;
			saveMode <= '0';
		elsif rising_edge(clk) then
			if cellMode = Idle then
				cellMode <= cellSource;
			elsif setCnt = cellMax then
				cellMode <= cellSource;
				saveMode <= '0';
			end if;
			if save = '1' then
				saveMode <= '1';
			end if;
		end if;
	end process;

	current <= c;
end;
