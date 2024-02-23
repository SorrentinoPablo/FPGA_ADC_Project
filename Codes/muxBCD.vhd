-- Multiplexor de entradas de 4 bits para registro BCD
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;

entity muxBCD is
	port(
		BCD0	: in std_logic_vector(3 downto 0);
		punto_i	: in std_logic_vector(3 downto 0);
		BCD1	: in std_logic_vector(3 downto 0);
		BCD2	: in std_logic_vector(3 downto 0);
		volt_i	: in std_logic_vector(3 downto 0);
		sel		: in std_logic_vector(2 downto 0);
		f_o		: out std_logic_vector(3 downto 0)
	);
end;

architecture muxBCD_arq of muxBCD is
	signal ubi		: std_logic_vector(4 downto 0);

	signal inoutA	: std_logic_vector(3 downto 0); -- conectar la entrada con salida
	signal inoutB	: std_logic_vector(3 downto 0);
	signal inoutC	: std_logic_vector(3 downto 0);
	signal inoutD	: std_logic_vector(3 downto 0);
	signal inoutE	: std_logic_vector(3 downto 0);

	signal inmuxA	: std_logic_vector(3 downto 0); -- comparar entrada con la pos del mux
	signal inmuxB	: std_logic_vector(3 downto 0);
	signal inmuxC	: std_logic_vector(3 downto 0);
	signal inmuxD	: std_logic_vector(3 downto 0);
	signal inmuxE	: std_logic_vector(3 downto 0);

begin
	--	000 para BCD0, 001 para el punto, 010 para el BCD1
	--	011 para el BCD2, 100 para la tension, 1xx es 0 para la salida
	ubi(3)	<= not (sel(2) or sel(1) or sel(0));
	ubi(1)	<= (not sel(2)) and (not sel(1)) and sel(0);
	ubi(2)	<= (not sel(2)) and sel(1) and (not sel(0));
	ubi(0)	<= (not sel(2)) and sel(1) and sel(0);
	ubi(4)	<= sel(2) and (not sel(1)) and (not sel(0));
	
	inoutA	<= (inmuxA(3) and ubi(0)) & (inmuxA(2) and ubi(0)) & (inmuxA(1) and ubi(0)) & (inmuxA(0) and ubi(0));
	inoutB	<= (inmuxB(3) and ubi(1)) & (inmuxB(2) and ubi(1)) & (inmuxB(1) and ubi(1)) & (inmuxB(0) and ubi(1));
	inoutC	<= (inmuxC(3) and ubi(2)) & (inmuxC(2) and ubi(2)) & (inmuxC(1) and ubi(2)) & (inmuxC(0) and ubi(2));
	inoutD	<= (inmuxD(3) and ubi(3)) & (inmuxD(2) and ubi(3)) & (inmuxD(1) and ubi(3)) & (inmuxD(0) and ubi(3));
	inoutE	<= (inmuxE(3) and ubi(4)) & (inmuxE(2) and ubi(4)) & (inmuxE(1) and ubi(4)) & (inmuxE(0) and ubi(4));
	
	-- Conexiones para pasar los datos correspondientes
	inmuxA	<= BCD0;
	inmuxB	<= punto_i;
	inmuxC	<= BCD1;
	inmuxD	<= BCD2;
	inmuxE	<= volt_i;
	
	-- Conexiones a la salida
	f_o		<= inoutE or inoutD or inoutC or inoutB or inoutA;
end;