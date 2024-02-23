-- Contador de 3300000 bits
-- Sorrentino Pablo
-- 525 en binario: 10 0000 1101

library IEEE;
use IEEE.std_logic_1164.all;

entity contVer is
	generic(
		N: natural := 10			-- Bits del contador o extension del registro
	);
	port(
		clk_i	: in std_logic;  	-- clock
		rst_i	: in std_logic;  	-- reset
		ena_i	: in std_logic;  	-- enable
		max		: out std_logic; 	-- cuenta maxima, 525-1
		count	: out std_logic_vector(N-1 downto 0)	-- Cuenta: de 0 a 524
	);
end;

architecture contVer_arq of contVer is	
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
	component regN_rst is
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
	end component;

	signal d_aux	: std_logic_vector(9 downto 0);	-- cables vectoriales para indexación del contador
	signal q_i		: std_logic_vector(9 downto 0);
	signal c_i		: std_logic_vector(9 downto 0);
	signal rst_end	: std_logic;					-- cable auxiliar para la lógica del reset de fin de cuenta
	signal rst_aux	: std_logic;					-- cable auxiliar de reset

begin

	--Inclusion del registro
	reg_inst: regN_rst
    generic map(
		N => N		--se cambia segun el primer N del archivo
	)
	port map(
		clk_i	=> clk_i,			-- Clock
		rst_i	=> rst_aux,			-- Reset
		ena_i	=> ena_i,			-- Enable
		d_i		=> q_i,				-- Entrada reg
		q_o		=> count			-- Salida reg
	);
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
  
	Bloque_contBin: for i in 1 to 9 generate
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
-- 525 en binario: 10 0000 1101
-- 524 en binario: 10 0000 1100

-- 525   
	rst_end	<= q_i(9) and (not q_i(8)) and (not q_i(7)) and (not q_i(6)) and (not q_i(5)) and (not q_i(4)) and q_i(3) and q_i(2) and (not q_i(1)) and q_i(0);
	
-- 524
	max		<= q_i(9) and (not q_i(8)) and (not q_i(7)) and (not q_i(6)) and (not q_i(5)) and (not q_i(4)) and q_i(3) and q_i(2) and (not q_i(1)) and (not q_i(0));
end;