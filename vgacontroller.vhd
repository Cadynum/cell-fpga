library ieee;
use ieee.std_logic_1164.all;


entity vgacontroller is
	generic (
		constant hSize : natural := 640;
		constant hFrontPorch : natural := 16;
		constant hSyncPulse : natural := 96;
		constant hBackPorch : natural := 48;
		constant hPolarity : std_logic := '0';

		constant vSize : natural := 480;
		constant vFrontPorch : natural := 10;
		constant vSyncPulse : natural := 2;
		constant vBackPorch : natural := 33;
		constant vPolarity : std_logic := '0'
	);
	port (
		pixClk, reset : in std_logic;
		x : out natural range 0 to hSize - 1;
		y : out natural range 0 to vSize - 1;
		visible, hPulse, vPulse, hSync, vSync : out std_logic
	);
end entity;


architecture a of vgacontroller is
	constant hMax : natural := hFrontPorch + hSyncPulse + hBackPorch + hSize - 1;
	constant vMax : natural := vFrontPorch + vSyncPulse + vBackPorch + vSize - 1;
	constant hBeginArea : natural := hFrontPorch + hSyncPulse + hBackPorch;
	constant vBeginArea : natural := vFrontPorch + vSyncPulse + vBackPorch;
	signal pixCnt : natural range 0 to hMax := 0;
	signal lineCnt : natural range 0 to vMax := 0;
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

	x <= pixCnt - hBeginArea when pixCnt >= hBeginArea else 0;
	y <= lineCnt - vBeginArea when lineCnt >= vBeginArea else 0;

	vSync <= vPolarity when lineCnt >= vFrontPorch and lineCnt < vFrontPorch+vSyncPulse else not vPolarity;
	hSync <= hPolarity when pixCnt >= hFrontPorch and pixCnt < hFrontPorch+hSyncPulse else not hPolarity;

	visible <= '1' when lineCnt >= vBeginArea and pixCnt >= hBeginArea else '0';

	hPulse <= '1' when pixCnt = hBeginArea-1
			and lineCnt >= vBeginArea else '0';
	vPulse <= '1' when lineCnt = 0 and pixCnt = 0 else '0';

end architecture;
