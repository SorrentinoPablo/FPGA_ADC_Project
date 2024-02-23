-- Logica adc sigma delta
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;

entity logica is
	port(
		clk_i	: in std_logic;  -- Clock
		rst_i	: in std_logic;  -- Reset
		ena_i	: in std_logic;  -- Enable
		d_vi	: in std_logic;  -- Señal de entrada
		q_fb	: out std_logic; -- Feedback
		q_proc	: out std_logic	 -- Bloque de procesamiento
	);
end;

architecture logica_arq of logica is
component ffd
	port(
		clk_i	: in std_logic; -- Clock
		rst_i	: in std_logic; -- Reset
		ena_i	: in std_logic; -- Enable
		d_i		: in std_logic; 
		q_o		: out std_logic -- Salida
	);
end component;

signal q_aux	: std_logic; 	-- Cable auxiliar para el q del ffd

begin
	ffd0: ffd
	port map(
		clk_i =>  clk_i,
		rst_i =>  rst_i,
		ena_i =>  ena_i,
		d_i   =>  d_vi,
		q_o   =>  q_aux
	);
	q_fb	<= not q_aux;
	q_proc	<= q_aux;
end;