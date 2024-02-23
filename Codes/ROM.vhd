-- ROM con caracteres almacenados
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ROM is
	port(
		font_col: in std_logic_vector(2 downto 0);		-- Bits 9 a 7 del pixel x
		font_row: in std_logic_vector(2 downto 0);		-- Bits 9 a 7 del pixel y
		char_adress: in std_logic_vector(3 downto 0);	-- Bus de datos del multiplexor
		rom_out: out std_logic							-- Salida serie de la ROM
	);
end;

architecture ROM_arq of ROM is
	signal AddrVer: std_logic_vector(6 downto 0);
	type matriz is array (0 to 95) of std_logic_vector(0 to 7);
	
	-- El indice del char es el addres unido al fVer, transformado a entero
	constant Char: matriz :=	(
							"00000000",
							"00111100",
							"01000010",
							"01000010",
							"01000010",
							"01000010",
							"00111100",
							"00000000",-- 0: 0000
							
							"00000000",
							"00001000",
							"00011000",
							"00101000",
							"00001000",
							"00001000",
							"00111100",
							"00000000",-- 1: 0001
							
							"00000000",
							"00111100",
							"01000010",
							"00000100",
							"00001000",
							"00110000",
							"01111110",
							"00000000",-- 2: 0010
							
							"00000000",
							"01111100",
							"00000010",
							"00111110",
							"00000010",
							"00000010",
							"01111100",
							"00000000",-- 3: 0011
							
							"00000000",
							"00001100",
							"00010100",
							"00100100",
							"01111110",
							"00000100",
							"00000100",
							"00000000",-- 4: 0100
							
							"00000000",
							"01111100",
							"01000000",
							"01111100",
							"00000010",
							"00000010",
							"01111100",
							"00000000",-- 5: 0101
							
							"00000000",
							"00111100",
							"01000000",
							"01111100",
							"01000010",
							"01000010",
							"00111100",
							"00000000",-- 6: 0110
							
							"00000000",
							"01111110",
							"00000110",
							"00001000",
							"00010000",
							"00100000",
							"00100000",
							"00000000",-- 7: 0111
							
							"00000000",
							"00111100",
							"01000010",
							"01111110",
							"01000010",
							"01000010",
							"00111100",
							"00000000",-- 8: 1000
							
							"00000000",
							"00111100",
							"01000010",
							"01000010",
							"00111110",
							"00000010",
							"01111100",
							"00000000",-- 9: 1001
							
							"00000000",
							"00000000",
							"00000000",
							"00000000",
							"00000000",
							"00011000",
							"00011000",
							"00000000",-- .: 1010
							
							"00000000",
							"01000010",
							"01000010",
							"01100110",
							"00100100",
							"00100100",
							"00011000",
							"00000000" -- V: 1011
						); 
begin
	AddrVer 	<= char_adress & font_row;	-- Se unen los datos de Addr y fVer y se toma 1 bit o pixel del char
	rom_out 	<= Char(to_integer(unsigned(AddrVer)))(to_integer(unsigned(font_col)));
end;
