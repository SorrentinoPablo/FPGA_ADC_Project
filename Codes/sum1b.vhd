-- Sumador de 1 bit
-- Sorrentino Pablo


library IEEE;
use IEEE.std_logic_1164.all;

entity sum1b is
	port(
		a_i	: in std_logic; -- std_logic -> '0'/'1'/X/U
		b_i	: in std_logic;
		ci_i: in std_logic;
		s_o	: out std_logic;
		co_o: out std_logic
	);
end;
architecture sum1b_arq of sum1b is
	-- Declaraciones / Inclusion de componentes
begin
	-- Funcionalidad
	s_o  <=  a_i xor b_i xor ci_i;
	co_o <= (a_i and b_i) or (a_i and ci_i) or (b_i and ci_i);
end;