-- FFD 
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;

entity ffd is --Nueva forma
	port(		--puerto, modo y tipo
		clk_i	: in std_logic; --bit puede tomar valores 0 o 1, std logic, 0, 1, U (undefined), 
		rst_i	: in std_logic; --X colision, Z alta impedancia, etc.
		ena_i	: in std_logic;
		d_i		: in std_logic;
		q_o	: out std_logic
	);
end;	--declaracion de los puertos de entrada y salida
architecture ffd_arq of ffd is --conjunto de declaraciones e instrucciones
	-- Declaraciones / Inclusion de componentes
begin
	--concurrentes, fuera de las estructurales
	--process como caja negra, toma y saca señales
	--comportamiento de bloques
	--dentro de process, actuan los estructurales
	--describir el funcionamiento
	process(clk_i) --se define la lista de sensibilidad
					--process solo para el registro y el flip flop d
	begin			--cambian q cuando cambia la lista
		if rising_edge(clk_i) then 	--se verifica el flanco ascendente
			if rst_i = '1' then		--es un reset sincronico, comandado por el reloj
				q_o <= '0';
			elsif ena_i = '1' then
				q_o <= d_i; --event es subida o bajada
			end if; --rst_i, si el clr es cero, q es cero
		end if;	--rising_edge
	end process;--se evalua renglon a renglon
end; --construir mucho hardware con poco codigo, mejor que very log
--es mas rapido que el asincronico