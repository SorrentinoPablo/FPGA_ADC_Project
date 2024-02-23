-- Voltimetro implementado con un modulador sigma-delta
-- Voltimetro_toplevel
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;

entity Voltimetro_toplevel is
	port(
		clk_i			: in std_logic;		-- Clock
		rst_i			: in std_logic;		-- Reset
		swrst_o1		: in std_logic;
		swrst_o2		: in std_logic;
		ledsinV_o		: out std_logic;
		datav_in_i		: in std_logic;		-- Señal de entrada
		datav_out_o		: out std_logic;	-- Señal de realimentación
		hs_o 			: out std_logic;	-- Sincronismo horizontal
		vs_o 			: out std_logic;	-- Sincronismo vertical
		red_o 			: out std_logic;	-- Rojo
		grn_o 			: out std_logic;	-- Verde
		blu_o 			: out std_logic;	-- Azul
		ledsinH_o		: out std_logic
	);

	-- Mapeo de pines, kit Arty A7-35, restricciones de ubicaciones
	attribute loc		: string;
	attribute iostandard: string;

	attribute loc 			of clk_i : signal is "E3";			-- reloj del sistema (100 MHz)
	attribute iostandard 	of clk_i : signal is "LVCMOS33";
	attribute loc 			of rst_i : signal is "D9";			-- senal de reset (boton 0, rst_i)
	attribute iostandard 	of rst_i : signal is "LVCMOS33";

	-- Entradas simple
	attribute loc 			of datav_in_i: signal is "D4";		-- entrada, datav_in_i
	attribute iostandard 	of datav_in_i: signal is "LVCMOS33";

	-- Salida realimentada
	attribute loc 			of datav_out_o: signal is "F3";		-- realimentacion, datav_out_o
	attribute iostandard 	of datav_out_o: signal is "LVCMOS33";

	-- VGA
	attribute loc 			of hs_o  : signal is "D12";			-- sincronismo horizontal, hs_o
	attribute iostandard 	of hs_o  : signal is "LVCMOS33";
	attribute loc 			of vs_o  : signal is "K16";			-- sincronismo vertical, vs_o
	attribute iostandard 	of vs_o  : signal is "LVCMOS33";
	attribute loc 			of red_o : signal is "G13";			-- salida color rojo, red_o
	attribute iostandard 	of red_o : signal is "LVCMOS33";
	attribute loc 			of grn_o : signal is "B11";			-- salida color verde, grn_o
	attribute iostandard 	of grn_o : signal is "LVCMOS33";
	attribute loc 			of blu_o : signal is "A11";			-- salida color azul, blu_o
	attribute iostandard 	of blu_o : signal is "LVCMOS33";
	
	attribute loc 			of ledsinH_o: signal is "E1";		
	attribute loc 			of ledsinV_o: signal is "J5";
	attribute loc 			of swrst_o1	: signal is "A8";
	attribute loc 			of swrst_o2	: signal is "C11";
	attribute iostandard 	of ledsinH_o: signal is "LVCMOS33";
	attribute iostandard 	of ledsinV_o: signal is "LVCMOS33";
	attribute iostandard 	of swrst_o1	: signal is "LVCMOS33";
	attribute iostandard 	of swrst_o2	: signal is "LVCMOS33";


end Voltimetro_toplevel;

architecture Voltimetro_toplevel_arq of Voltimetro_toplevel is
	-- Declaracion del componente voltimetro
	component voltimetro is
		port(
			clk_i		: in std_logic;		-- Clock
			rst_i		: in std_logic;		-- Reset
			datav_in_i	: in std_logic;		-- Senal de entrada
			hs_o		: out std_logic;	-- Sincronismo horizontal
			vs_o		: out std_logic;	-- Sincronismo vertical
			datav_out_o	: out std_logic;	-- Senal de realimentación
			red_o		: out std_logic;	-- Rojo
			grn_o		: out std_logic;	-- Verde
			blu_o		: out std_logic;		-- Azul
			ledsinH_o	: out std_logic
		);
	end component;
	-- Declaracion del componente generador de reloj (MMCM - Mixed Mode Clock Manager)
	-- Se necesita agregar en Vivado el Clocking Wizard desde IP Catalog
	component clk_wiz_0
		port (
			clk_in1: in std_logic;			-- Clock de entrada (100 MHz)
	  		clk_out1: out std_logic			-- Clock de salida (25 MHz)
	 );
	end component;

	signal clk25MHz	: std_logic;
	signal rstaux	: std_logic;
	signal ledVaux	: std_logic;
	signal ledHaux	: std_logic;

begin
	-- Instancia del bloque voltimetro
	inst_voltimetro: voltimetro
		port map(
			clk_i		=> clk25MHz,		-- Clock generado
			rst_i		=> rst_i,			-- Reset
			datav_in_i	=> datav_in_i,		-- Senal de entrada
			hs_o		=> hs_o,			-- Sincronismo horizontal
			vs_o		=> ledVaux,			-- Sincronismo vertical
			datav_out_o	=> datav_out_o,		-- Senal de realimentación
			red_o		=> red_o,			-- Rojo
			grn_o		=> grn_o,			-- Verde
			blu_o		=> blu_o,			-- Azul
			ledsinH_o	=> ledHaux
        );
	-- Generador del reloj lento
	clk25MHz_gen : clk_wiz_0
   		port map (
   			clk_in1		=> clk_i,			-- Clock del sistema (100 MHz)
   			clk_out1	=> clk25MHz			-- Clock generado (25 MHz)
		);

	vs_o		<= ledVaux;
	ledsinH_o	<= ledHaux or swrst_o2;
	ledsinV_o	<= ledVaux or swrst_o1;
end;