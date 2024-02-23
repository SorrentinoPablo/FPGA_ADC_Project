-- Contador de binario simple
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;

entity contBin is
	port(
		clk_i	: in std_logic;		-- clock 
		rst_i	: in std_logic;		-- reset
		ena_i	: in std_logic;		-- enable
		d_i		: in std_logic;		-- entrada del carry anterior
		q_o		: out std_logic;	-- salida del módulo
		c_o		: out std_logic		-- carry de salida
	);
end;

architecture contBin_arq of contBin is
	component ffd is
		port(	-- puerto, modo y tipo
			clk_i	: in std_logic;	-- bit puede tomar valores 0 o 1, std logic, 0, 1, U (undefined), 
			rst_i	: in std_logic; -- X colision, Z alta impedancia, etc.
			ena_i	: in std_logic;
			d_i		: in std_logic;
			q_o		: out std_logic
		);
	end component;

signal d_aux	: std_logic;	-- cable auxiliar para conectar la entrada
signal ffd_aux	: std_logic;	-- cable auxiliar para conectar la entrada al flip-flop
signal q_aux	: std_logic;	-- cable auxiliar para conectar la salida

begin
    inst_ffd: ffd
       port map(
          clk_i	=> clk_i,		-- clock del sistema
          rst_i	=> rst_i,		-- reset
          ena_i	=> ena_i,		-- enable
          d_i	=> ffd_aux,
          q_o	=> q_aux
	  );
    c_o		<= d_aux and q_aux;
    ffd_aux	<= d_aux xor q_aux;
    d_aux	<= d_i;
    q_o		<= q_aux;
end;