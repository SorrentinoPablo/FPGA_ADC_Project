-- Registros de estabilizacion
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity regEst is
	generic(
		N: natural := 4
	);
	port(
		clk_i		: in std_logic;
		rst_i		: in std_logic;		
		pixel_x_reg		: in std_logic_vector(9 downto 0);
		pixel_y_reg		: in std_logic_vector(9 downto 0);
		d_i			: in std_logic_vector(N-1 downto 0);
		q_o			: out std_logic_vector(N-1 downto 0)
	);
end;
architecture regEst_arq of regEst is
	-- Declaraciones / Inclusion de componentes
	signal ena_aux: std_logic;
	signal ena_H: std_logic;
	signal ena_V: std_logic;
	
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
	-- Comparadores de pulsos ascendentes y descendentes de hsync
	compNb_H: comp_Nb
	generic map(N => 10)
	port map(
		a => pixel_x_reg,
		b => "1010010000", -- Se compara con 656
		s => ena_H
	);
	compNb_v: comp_Nb
	generic map(N => 10)
	port map(
		a => pixel_y_reg,
		b => "0111101010",	-- Se compara con 490
		s => ena_V
	);
	ena_aux <= ena_H and ena_V;
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				q_o <= (N-1 downto 0 => '0'); --others 
			elsif ena_aux = '1' then
				q_o <= d_i;
			end if; 
		end if;
	end process;
end;