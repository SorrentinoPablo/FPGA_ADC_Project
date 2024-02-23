-- Contador BCD de 7 digitos
-- Sorretino Pablo

library IEEE;
use IEEE.std_logic_1164.all;

entity contBCD_7 is
	port(
		clk_i		: in std_logic;
		rst_i		: in std_logic;
		ena_i		: in std_logic;
		bcd0_o		: out std_logic_vector(3 downto 0);
		bcd1_o		: out std_logic_vector(3 downto 0);
		bcd2_o		: out std_logic_vector(3 downto 0);
		bcd3_o		: out std_logic_vector(3 downto 0);
		bcd4_o		: out std_logic_vector(3 downto 0);
		bcd5_o		: out std_logic_vector(3 downto 0);
		bcd6_o		: out std_logic_vector(3 downto 0)
	);
end;
architecture contBCD_7_arq of contBCD_7 is
	-- Declaraciones de los componentes
	component contBCD is
		port(
			clk_i	: in std_logic;
			rst_i	: in std_logic;
			ena_i	: in std_logic;
			q_o		: out std_logic_vector(3 downto 0);
			max_o	: out std_logic
		);
	end component;
	signal flag_out	: std_logic_vector(6 downto 0);
	signal ena_aux	: std_logic_vector(6 downto 0);

begin
	ena_aux(0) <= ena_i;
	--Inclusion del contador BCD 0
	bcd0_inst: contBCD
		port map(
			clk_i 	=> clk_i,
			rst_i 	=> rst_i,
			ena_i 	=> ena_aux(0),
			q_o 	=> bcd0_o,
			max_o 	=> flag_out(0)
		);
	ena_aux(1) <= ena_aux(0) and flag_out(0);
	bcd1_inst: contBCD
		port map(
			clk_i 	=> clk_i,
			rst_i 	=> rst_i,
			ena_i 	=> ena_aux(1),
			q_o 	=> bcd1_o,
			max_o 	=> flag_out(1)
		);
	ena_aux(2) <= ena_aux(1) and flag_out(1);
	bcd2_inst: contBCD
		port map(
			clk_i 	=> clk_i,
			rst_i 	=> rst_i,
			ena_i 	=> ena_aux(2),
			q_o 	=> bcd2_o,
			max_o 	=> flag_out(2)
		);
	ena_aux(3) <= ena_aux(2) and flag_out(2);
	bcd3_inst: contBCD
		port map(
			clk_i 	=> clk_i,
			rst_i 	=> rst_i,
			ena_i 	=> ena_aux(3),
			q_o 	=> bcd3_o,
			max_o 	=> flag_out(3)
		);
	ena_aux(4) <= ena_aux(3) and flag_out(3);
	bcd4_inst: contBCD
		port map(
			clk_i 	=> clk_i,
			rst_i 	=> rst_i,
			ena_i 	=> ena_aux(4),
			q_o 	=> bcd4_o,
			max_o 	=> flag_out(4)
		);
	ena_aux(5) <= ena_aux(4) and flag_out(4);
	bcd5_inst: contBCD
		port map(
			clk_i 	=> clk_i,
			rst_i 	=> rst_i,
			ena_i 	=> ena_aux(5),
			q_o 	=> bcd5_o,
			max_o 	=> flag_out(5)
		);
	ena_aux(6) <= ena_aux(5) and flag_out(5);
	bcd6_inst: contBCD
		port map(
			clk_i 	=> clk_i,
			rst_i 	=> rst_i,
			ena_i 	=> ena_aux(6),
			q_o 	=> bcd6_o,
			max_o 	=> flag_out(6) --open
		);
end;