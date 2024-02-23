-- Contador de 3300000 bits
-- Sorrentino Pablo
-- 3 300 000, en binario 0011 0010 0101 1010 1010 0000

library IEEE;
use IEEE.std_logic_1164.all;

entity cont33 is
	port(
		clk_i	: in std_logic;  -- clock
		rst_i	: in std_logic;  -- reset
		ena_i	: in std_logic;  -- enable
		rstUno	: out std_logic; -- reset para contador de unos Q_BCD
		enaReg	: out std_logic  -- enable para registro Q_reg
	);
end;

architecture cont33_arq of cont33 is	
	component ffd
		port(
			clk_i	: in std_logic;
			rst_i	: in std_logic;
			ena_i	: in std_logic;
			d_i		: in std_logic;
			q_o		: out std_logic
		);	
	end component;
	component contBin is
		port(
			clk_i	: in std_logic;		-- clock del sistema 
			rst_i	: in std_logic;		-- reset
			ena_i	: in std_logic;		-- enable
			d_i		: in std_logic;		-- entrada del carry anterior
			q_o		: out std_logic;	-- salida
			c_o		: out std_logic		-- carry de salida
		);
	end component;

signal d_aux	: std_logic_vector(23 downto 0);	-- cables vectoriales para indexación del contador
signal q_i		: std_logic_vector(23 downto 0);
signal c_i		: std_logic_vector(23 downto 0);
signal rst_end	: std_logic;						-- cable auxiliar para la lógica del reset de fin de cuenta
signal rst_aux	: std_logic;						-- cable auxiliar de reset
signal q_aux	: std_logic_vector(5 downto 0);

begin   
	rst_aux <= rst_i or rst_end;	-- reset al final de la cuenta o del sistema
	ffd0: ffd
		port map(
			clk_i	=> clk_i,		-- clock
			rst_i	=> rst_aux,		-- reset
			ena_i	=> ena_i,		-- enable del sistema
			d_i		=> d_aux(0),	  
			q_o		=> q_i(0)
		);
	d_aux(0)<= not q_i(0);
	c_i(0)	<= q_i(0);
  
	Bloque_contBin: for i in 1 to 23 generate
		inst_contBin: contBin
		port map(
				clk_i	=> clk_i,
				rst_i	=> rst_aux,
				ena_i	=> ena_i,
				d_i		=> d_aux(i),
				q_o		=> q_i(i),
				c_o		=> c_i(i)
			);
			d_aux(i) <= c_i(i-1);
	end generate;
-- 3300000, en binario 0011 0010 0101 1010 1010 0000
-- 3300001, en binario 0011 0010 0101 1010 1010 0001
-- 0011	 
	q_aux(5)	<= (not q_i(23)) and (not q_i(22)) and q_i(21) and q_i(20);
	
-- 0010	 
	q_aux(4)	<= (not q_i(19)) and (not q_i(18)) and q_i(17) and (not q_i(16));

-- 0101
	q_aux(3)	<= (not q_i(15)) and q_i(14) and (not q_i(13)) and q_i(12);

-- 1010
	q_aux(2)	<= q_i(11) and (not q_i(10)) and q_i(9) and (not q_i(8));
	
-- 1010
	q_aux(1)	<= q_i(7) and (not q_i(6)) and q_i(5) and (not q_i(4));

-- 11111
	q_aux(0)	<= q_aux(5) and q_aux(4) and q_aux(3) and q_aux(2) and q_aux(1);

-- 1 0001    
	rst_end		<= (q_aux(0)) and (not q_i(3)) and (not q_i(2)) and (not q_i(1)) and q_i(0);
	
	rstUno		<= rst_end;

-- 1 0000
	enaReg		<= (q_aux(0)) and (not q_i(3)) and (not q_i(2)) and (not q_i(1)) and (not q_i(0));
end;