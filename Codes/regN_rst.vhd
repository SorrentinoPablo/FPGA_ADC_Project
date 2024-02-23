-- Registro de N bits con reset
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;

entity regN_rst is
	generic(
		N: natural := 4
	);
	port(
		clk_i	: in std_logic;
		rst_i	: in std_logic;		
		ena_i	: in std_logic;
		d_i		: in std_logic_vector(N-1 downto 0);
		q_o		: out std_logic_vector(N-1 downto 0)
	);
end;
architecture regN_rst_arq of regN_rst is
	-- Declaraciones / Inclusion de componentes
begin
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				q_o <= (N-1 downto 0 => '0'); --others 
			elsif ena_i = '1' then
				q_o <= d_i;
			end if; 
		end if;
	end process;
end;