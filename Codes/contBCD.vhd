library IEEE;
use IEEE.std_logic_1164.all;

entity contBCD is
	port(
		clk_i	: in std_logic;
		rst_i	: in std_logic;
		ena_i	: in std_logic;
		q_o		: out std_logic_vector(3 downto 0);
		max_o	: out std_logic
	);
end;
architecture contBCD_arq of contBCD is
	--Inclusion de los componentes
	signal salOr	: std_logic;
	signal salAnd	: std_logic;
	signal salComp	: std_logic;
	signal salSum	: std_logic_vector(3 downto 0);
	signal salReg	: std_logic_vector(3 downto 0);
	
	component regN_rst is
		generic(
			N: natural := 4
		);
		port(
			clk_i	: in std_logic; 
			ena_i	: in std_logic;
			rst_i	: in std_logic;
			d_i		: in std_logic_vector(N-1 downto 0);
			q_o		: out std_logic_vector(N-1 downto 0)
		);
	end component;
	component sumNb is
		generic(
			N: natural := 4
		);
		port(
			a_i		: in std_logic_vector(N-1 downto 0);
			b_i		: in std_logic_vector(N-1 downto 0);
			ci_i	: in std_logic;
			s_o		: out std_logic_vector(N-1 downto 0);
			co_o	: out std_logic
		);
	end component;
	
begin
--registro
	reg_inst: regN_rst
		generic map(
			N => 4
		)
		port map(
			clk_i 	=> clk_i,
			rst_i 	=> salOr,
			ena_i 	=> ena_i,
			d_i 	=> salSum, --entrada al registro
			q_o 	=> salReg
		);
--sumador
	sum_inst: sumNb
		generic map(
			N => 4
		)
		port map(
			a_i 	=> salReg,
			b_i 	=> "0001",
			ci_i 	=> '0',		--carry
			s_o 	=> salSum,
			co_o 	=> open		--carry, flag de la max cuenta
		);
		
	--salComp <= salReg and "1001"; y comparacion bit a bit, conversion
	salComp <= salReg(0) and (not salReg(1)) and (not salReg(2)) and salReg(3);
	salAnd  <= ena_i and salComp;
	salOr   <= rst_i or salAnd;
	q_o 	<= salReg; --la cuenta final
	max_o	<= salComp;
end;