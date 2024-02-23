-- Comparador de N bits
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;

entity comp_Nb is
	generic(
		N: natural := 10
	);
	port(
		a: in std_logic_vector(N-1 downto 0);	-- 1er numero a comparar
		b: in std_logic_vector(N-1 downto 0);	-- 2do numero a comparar
		s: out std_logic						-- Se obtiene un 1 si ambos son iguales
	);
end;

architecture comp_Nb_arq of comp_Nb is
    signal and_aux	: std_logic_vector(N downto 0);
    signal xnor_aux	: std_logic_vector(N-1 downto 0);
	
begin
	comp_gen: for i in 0 to N-1 generate
		xnor_aux(i)		<= a(i) xnor b(i);				-- Se obtiene un 1 para cada bit en el caso que los digitos sean identicos
		and_aux(i+1)	<= xnor_aux(i) and and_aux(i);	-- Se obtiene 0 si hay una posicion con valor distinto
	end generate;
	and_aux(0) <= '1';
	s <= and_aux(N); -- Es guardado el ultimo valor de la compuerta AND
end;