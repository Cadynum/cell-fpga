library ieee;
use ieee.std_logic_1164.all;

package Modeline is
	type Sync is 
	record
		hSize : natural;
		hFrontPorch : natural;
		hSyncPulse : natural;
		hBackPorch : natural;
		hPolarity : std_logic;

		vSize : natural;
		vFrontPorch : natural;
		vSyncPulse : natural;
		vBackPorch : natural;
		vPolarity : std_logic;
	end record;
	
	constant r1280x1024x60 : Sync :=
		( 1280, 48, 112, 248, '1'
		, 1024, 1, 3, 38, '1');
	constant r1024x768x60 : Sync :=
		( 1024, 24, 136, 160, '0'
		, 768, 3, 6, 29, '0');
end;


library ieee;
use ieee.std_logic_1164.all;
use work.Modeline.all;

entity vgacontroller is
	generic (r : Sync := r1024x768x60);
	port (
		pixClk, reset : in std_logic;
		x : out natural range 0 to r.hSize - 1;
		y : out natural range 0 to r.vSize - 1;
		visible, hPulse, vPulse, hSync, vSync : out std_logic
	);
end entity;


architecture a of vgacontroller is
	constant hMax : natural := r.hFrontPorch + r.hSyncPulse + r.hBackPorch + r.hSize - 1;
	constant vMax : natural := r.vFrontPorch + r.vSyncPulse + r.vBackPorch + r.vSize - 1;
	constant hBeginArea : natural := r.hFrontPorch + r.hSyncPulse + r.hBackPorch;
	constant vBeginArea : natural := r.vFrontPorch + r.vSyncPulse + r.vBackPorch;
	signal pixCnt : natural range 0 to hMax := 0;
	signal lineCnt : natural range 0 to vMax := 0;
	signal hVis, yVis : boolean;
begin
	process (pixClk, reset) begin
		if reset = '1' then
			pixCnt <= 0;
			lineCnt <= 0;
		elsif rising_edge(pixClk) then
			if pixCnt = hMax then
				pixCnt <= 0;
				if lineCnt = vMax then
					lineCnt <= 0;
				else
					lineCnt <= lineCnt + 1;
				end if;
			else
				pixCnt <= pixCnt + 1;
			end if;
		end if;
	end process;

	hVis <= pixCnt >= hBeginArea;
	yVis <= lineCnt >= vBeginArea;
	
	x <= pixCnt - hBeginArea when hVis else 0;
	y <= lineCnt - vBeginArea when yVis else 0;

	vSync <= r.vPolarity when lineCnt >= r.vFrontPorch and lineCnt < r.vFrontPorch+r.vSyncPulse else not r.vPolarity;
	hSync <= r.hPolarity when pixCnt >= r.hFrontPorch and pixCnt < r.hFrontPorch+r.hSyncPulse else not r.hPolarity;

	visible <= '1' when hVis and yVis else '0';
	
	hPulse <= '1' when pixCnt = hBeginArea-1 and yVis else '0';
	vPulse <= '1' when lineCnt = 0 and pixCnt = 0 else '0';

end architecture;
