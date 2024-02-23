-- Generador de sincronismo (VGA)
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VGA is
	generic(
		N: natural := 10 -- Bits de contadores y otros
	);
	port(
		clk_i	: in std_logic; 	-- Clock
		rst_i	: in std_logic; 	-- Reset
		red_i	: in std_logic; 	-- Entrada para rojo
		grn_i	: in std_logic; 	-- Entrada para verde
		blu_i	: in std_logic; 	-- Entrada para azul
		hsync	: out std_logic; 	-- Sincronismo horizontal
		vsync	: out std_logic; 	-- Sincronismo vertical
		red_o	: out std_logic; 	-- Salida para rojo
		grn_o	: out std_logic; 	-- Salida para verde
		blu_o	: out std_logic; 	-- Salida para azul
		pixel_x	: out std_logic_vector(9 downto 0);	-- Posicion horizontal
		pixel_y	: out std_logic_vector(9 downto 0) 	-- Posicion vertical
	);
end;

architecture VGA_arq of VGA is
	signal maxEna	: std_logic; 						-- Enable para vertical
	signal cHori	: std_logic_vector(N-1 downto 0);	-- Entrada comparadores / Salida pixel_x
	signal cVert	: std_logic_vector(N-1 downto 0);	-- Entrada comparadores / Salida pixel_y
	signal rstH_aux, rstV_aux: std_logic;				-- Salidas de OR para reset de ffd
	signal compEnaH, compRstH: std_logic;				-- Salidas de comparadores para horizontal
	signal compEnaV, compRstV: std_logic;				-- Salidas de comparadores para vertical
	signal vidH, vidV	: std_logic;					-- Vidon de horizontal y vertical
	signal vidon_aux	: std_logic;					-- Vidon auxiliar
	
-- Declaraciones / Inclusion de componentes
	component contHor is
		generic(
			N: natural := 10		-- Bits del contador o extension del registro
		);
		port(
			clk_i: in std_logic;	-- Clock
			rst_i: in std_logic;	-- Reset
			ena_i: in std_logic;	-- Enable
			max	 : out std_logic;	-- Cuenta máxima, 800-1
			count: out std_logic_vector(N-1 downto 0)	-- Cuenta: de 0 a 799
		);
	end component;
	component contVer is
		generic(
			N: natural := 10	-- Bits del contador o extension del registro
		);
		port(
			clk_i: in std_logic;	-- Clock
			rst_i: in std_logic;	-- Reset
			ena_i: in std_logic;	-- Enable
			max: out std_logic;		-- Cuenta máxima, 525-1
			count: out std_logic_vector(N-1 downto 0)	-- Cuenta: de 0 a 524
		);
	end component;
	component ffd is
		port(
			clk_i	: in std_logic; -- bit puede tomar valores 0 o 1, std logic, 0, 1, U (undefined), 
			rst_i	: in std_logic; -- X colision, Z alta impedancia, etc.
			ena_i	: in std_logic;
			d_i		: in std_logic;
			q_o		: out std_logic
		);
	end component;
	component comp_Nb is
		generic(
			N: natural := 10
		);
		port(
			a: in std_logic_vector(N-1 downto 0);
			b: in std_logic_vector(N-1 downto 0);
			s: out std_logic
		);
	end component;
begin
	-- Para el horizontal, ascendente a 656 px y descendente a 751 px
	pixel_x		<= cHori;
	rstH_aux	<= rst_i or compRstH;
	
	-- Contador (Hasta 800)
	contH: contHor
	generic map (
		N => N
	)
	port map(
		clk_i => clk_i,		-- Clock del sistema
		rst_i => rst_i,		-- Reset del sistema
		ena_i => '1',		-- Enable siempre activo
		max   => maxEna,	-- Enable para vertical
		count => cHori		-- Entrada comparadores / Salida pixel_x
	);
	
	-- Flip Flop D
	ffdH: ffd
	port map(
		clk_i =>  clk_i,
		rst_i =>  rstH_aux,	-- Salida de OR
		ena_i =>  compEnaH,	-- Salida de comparador
		d_i   =>  '1',		-- D siempre en 1
		q_o   =>  hsync		-- Sincronismo horizontal
	);
	
	-- Comparadores de pulsos ascendentes y descendentes de hsync
	compNb0: comp_Nb
	generic map(N => N)
	port map(
		a => cHori,
		b => "1010010000", -- Se compara con 656
		s => compEnaH
	);
	
	compNb1: comp_Nb
	generic map(N => N)
	port map(
		a => cHori,
		b => "1011101111", -- Se compara con 752-1
		s => compRstH
	);
	
	-- Para el vertical, ascendente a 490 lineas y descendente a 492 lineas
	pixel_y		<= cVert;
	rstV_aux	<= rst_i or compRstV;
	
	-- Contador (Hasta 522)
	contV: contVer
	generic map (N => N)
	port map(
		clk_i => clk_i,
		rst_i => rst_i,
		ena_i => maxEna,
		max   => open,
		count => cVert 		-- Entrada a los comparadores y Salida para el pixel y
	);
	-- Flip Flop D
	ffdV: ffd
	port map(
		clk_i =>  clk_i,
		rst_i =>  rstV_aux, -- Salida de OR
		ena_i =>  compEnaV, -- Salida de comparador
		d_i   =>  '1',		-- D siempre en 1
		q_o   =>  vsync		-- Sincronismo vertical
	);
	-- Comparadores de pulsos ascendentes y descendentes de vsync
	compNb2: comp_Nb
	generic map(N => N)
	port map(
		a => cVert,
		b => "0111101010",	-- Se compara con 490
		s => compEnaV
	);
	compNb3: comp_Nb
	generic map(N => N)
	port map(
		a => cVert,
		b => "0111101011",	-- Se compara con 492-1
		s => compRstV
	);
	
	-- Vidon Horizontal: Se muestra en pantalla si los bits son 000, 001, 010, 011 y 100
	vidH <= not cHori(9) or (not cHori(8) and not cHori(7));
	
	-- Vidon Vertical: Se muestra en pantalla si los bits son X01
	vidV <= not cVert(8) and cVert(7);
	
	-- VIDON
	vidon_aux <= vidH and vidV;	-- Si vidH y vidV son '1' entonces se activa el vidon
	
	-- RGB OUT, cada color se encuentra controlado por el vidon
	red_o <= red_i and vidon_aux;
	blu_o <= blu_i and vidon_aux;
	grn_o <= grn_i and vidon_aux;
end;
