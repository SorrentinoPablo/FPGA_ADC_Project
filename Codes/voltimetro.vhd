-- Conexion de bloque del voltimetro
-- Sorrentino Pablo

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity voltimetro is
	port(
		clk_i			: in std_logic;		-- Clock
		rst_i			: in std_logic;		-- Reset
		datav_in_i		: in std_logic;		-- Entrada de unos y ceros del ffd inicial, habilita al contador BCD
		hs_o			: out std_logic;	-- Sicronismo horizontal
		vs_o			: out std_logic;	-- Sincronismo vertical
		datav_out_o		: out std_logic;	-- Realimentacion
		red_o			: out std_logic;	-- Salida del color rojo
		grn_o			: out std_logic;	-- Salida del color verde
		blu_o			: out std_logic;		-- Salida del color azul
		ledsinH_o		: out std_logic
	);
	--attribute loc 			of ledsinH_o: signal is "E1";
	--attribute iostandard 	of ledsinH_o: signal is "LVCMOS33";
end;

architecture voltimetro_arq of voltimetro is
	signal enchufe1	: std_logic;                   	-- ADC/contBCD_7
	signal enchufe2	: std_logic;                   	-- cont33/Reg
	signal enchufe3	: std_logic;                   	-- cont33/contBCD_7
	
	signal enchufe4a: std_logic_vector(3 downto 0);	-- contBCD_7/Regs
	signal enchufe4b: std_logic_vector(3 downto 0);
	signal enchufe4c: std_logic_vector(3 downto 0);
	signal enchufe4d: std_logic_vector(3 downto 0);
	signal enchufe4e: std_logic_vector(3 downto 0);
	signal enchufe4f: std_logic_vector(3 downto 0);
	signal enchufe4g: std_logic_vector(3 downto 0);
	
	signal enchufe5a: std_logic_vector(3 downto 0);	-- Regs/Muxs
	signal enchufe5b: std_logic_vector(3 downto 0);
	signal enchufe5c: std_logic_vector(3 downto 0);
	signal enchufe5d: std_logic_vector(3 downto 0);
	signal enchufe5e: std_logic_vector(3 downto 0);
	signal enchufe5f: std_logic_vector(3 downto 0);
	signal enchufe5g: std_logic_vector(3 downto 0);
	
	signal aux_enchufe5d: std_logic_vector(3 downto 0);
	signal aux_enchufe5f: std_logic_vector(3 downto 0);
	signal aux_enchufe5g: std_logic_vector(3 downto 0);
   	
	signal enchufe6	: std_logic_vector(3 downto 0);	-- MuxBCD/ROM
	signal enchufe7	: std_logic_vector(9 downto 0);	-- VGA/MUX (pixel x)
	signal enchufe8	: std_logic_vector(9 downto 0);	-- VGA/MUX (pixel y)
	signal enchufe9	: std_logic;                   	-- ROM/VGA
	signal ena_i	: std_logic := '1';				-- Enable seteado en 1
	
	component cont33 is
		port(
			clk_i	: in std_logic;  -- Clock
			rst_i	: in std_logic;  -- Reset
			ena_i	: in std_logic;  -- Enable
			rstUno	: out std_logic; -- Reset para contador de unos
			enaReg	: out std_logic  -- Enable para registro
		);
	end component;
	component contBCD_7 is
		port(
			clk_i	: in std_logic;
			rst_i	: in std_logic;
			ena_i	: in std_logic;
			bcd0_o	: out std_logic_vector(3 downto 0);
			bcd1_o	: out std_logic_vector(3 downto 0);
			bcd2_o	: out std_logic_vector(3 downto 0);
			bcd3_o	: out std_logic_vector(3 downto 0);
			bcd4_o	: out std_logic_vector(3 downto 0);
			bcd5_o	: out std_logic_vector(3 downto 0);
			bcd6_o	: out std_logic_vector(3 downto 0)
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
	component muxBCD is
		port(
			BCD0	: in std_logic_vector(3 downto 0);
			punto_i	: in std_logic_vector(3 downto 0);
			BCD1	: in std_logic_vector(3 downto 0);
			BCD2	: in std_logic_vector(3 downto 0);
			volt_i	: in std_logic_vector(3 downto 0);
			sel		: in std_logic_vector(2 downto 0);
			f_o		: out std_logic_vector(3 downto 0)
		);
	end component;
	component ROM is
		port(
			font_col	: in std_logic_vector(2 downto 0);
			font_row	: in std_logic_vector(2 downto 0);
			char_adress	: in std_logic_vector(3 downto 0);
			rom_out		: out std_logic
		);
	end component;
	component logica is
		port(
			clk_i	: in std_logic;  -- Clock
			rst_i	: in std_logic;  -- Reset
			ena_i	: in std_logic;  -- Enable
			d_vi	: in std_logic;  -- Senal de entrada
			q_fb	: out std_logic; -- Feedback
			q_proc	: out std_logic	 -- Bloque de procesamiento
		);
	end component;
	component VGA is
		port(
			clk_i	: in std_logic; 	-- Clock
			rst_i	: in std_logic;		-- Reset
			red_i	: in std_logic; 	-- Entrada para rojo
			grn_i	: in std_logic; 	-- Entrada para verde
			blu_i	: in std_logic; 	-- Entrada para azul
			hsync	: out std_logic; 	-- Sincronismo horizontal
			vsync	: out std_logic; 	-- Sincronismo vertical
			red_o	: out std_logic; 	-- Salida para rojo
			grn_o	: out std_logic; 	-- Salida para verde
			blu_o	: out std_logic; 	-- Salida para azul
			pixel_x	: out std_logic_vector(9 downto 0);	-- Posicion horizontal
			pixel_y	: out std_logic_vector(9 downto 0) 	-- Posicion vertical
		);
	end component;
	component regEst is
		generic(
			N: natural := 4
		);
		port(
			clk_i			: in std_logic;
			rst_i			: in std_logic;		
			pixel_x_reg		: in std_logic_vector(9 downto 0);
			pixel_y_reg		: in std_logic_vector(9 downto 0);
			d_i				: in std_logic_vector(N-1 downto 0);
			q_o				: out std_logic_vector(N-1 downto 0)
		);
	end component;
begin
	-- Contador binario hasta el maximo
	contBinario: cont33
		port map(
			clk_i	=> clk_i,		-- Clock
			rst_i	=> rst_i, 		-- Reset
			ena_i	=> ena_i, 		-- Enable
			rstUno	=> enchufe3, 	-- Reset del contador de unos
			enaReg	=> enchufe2 	-- Enable de Registro
		);
	ledsinH_o <= enchufe3;
	
	-- Contador de unos
	contUnos: contBCD_7
		port map(
			clk_i  => clk_i, 		-- Clock
			rst_i  => enchufe3, 	-- Reset controlado por contador binario
			ena_i  => enchufe1, 	-- Entrada del bloque de procesamiento y control
			bcd0_o => enchufe4a, 	-- Salida (entrada de registro)
			bcd1_o => enchufe4b,
			bcd2_o => enchufe4c,
			bcd3_o => enchufe4d,
			bcd4_o => enchufe4e,
			bcd5_o => enchufe4f,
			bcd6_o => enchufe4g
		);

	-- Registros de la tension
	regN0: regN_rst
		generic map(
			N => 4 -- Bits de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,		-- Clock
			rst_i	 => rst_i,		-- Reset
			ena_i	 => enchufe2,	-- Enable
			d_i		 => enchufe4a,	-- Entradas del registro
			q_o		 => enchufe5a	-- Salida hacia Mux
		);
	regN1: regN_rst
		generic map(
			N => 4 -- Bits de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,		-- Clock
			rst_i	 => rst_i,		-- Reset
			ena_i	 => enchufe2,	-- Enable
			d_i		 => enchufe4b,	-- Entradas del registro
			q_o		 => enchufe5b	-- Salida hacia Mux
		);
	regN2: regN_rst
		generic map(
			N => 4 -- Bits de de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,		-- Clock
			rst_i	 => rst_i,		-- Reset
			ena_i	 => enchufe2,	-- Enable
			d_i		 => enchufe4c,	-- Entradas del registro
			q_o		 => enchufe5c	-- Salida hacia Mux
		);
	regN3: regN_rst
		generic map(
			N => 4 -- Bits de de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,		-- Clock
			rst_i	 => rst_i,		-- Reset
			ena_i	 => enchufe2,	-- Enable
			d_i		 => enchufe4d,	-- Entradas del registro
			q_o		 => aux_enchufe5d	-- Salida hacia Mux
		);
	regN4: regN_rst
		generic map(
			N => 4 -- Bits de de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,		-- Clock
			rst_i	 => rst_i,		-- Reset
			ena_i	 => enchufe2,	-- Enable
			d_i		 => enchufe4e,	-- Entradas del registro
			q_o		 => enchufe5e	-- Salida hacia Mux
		);
	regN5: regN_rst
		generic map(
			N => 4 -- Bits de de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,		-- Clock
			rst_i	 => rst_i,		-- Reset
			ena_i	 => enchufe2,	-- Enable
			d_i		 => enchufe4f,	-- Entradas del registro
			q_o		 => aux_enchufe5f	-- Salida hacia Mux
		);
	regN6: regN_rst
		generic map(
			N => 4 -- Bits de de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,		-- Clock
			rst_i	 => rst_i,		-- Reset
			ena_i	 => enchufe2,	-- Enable
			d_i		 => enchufe4g,	-- Entradas del registro
			q_o		 => aux_enchufe5g	-- Salida hacia Mux
		);
		
		
	--Registros estabilidad
	regE_1: regEst
		generic map(
			N => 4 -- Bits de de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,
			rst_i	 => rst_i,
			pixel_x_reg	=>	enchufe7,
			pixel_y_reg	=>	enchufe8,
			d_i		 => aux_enchufe5g,
			q_o		 => enchufe5g
		);
	regE_2: regEst
		generic map(
			N => 4 -- Bits de de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,
			rst_i	 => rst_i,
			pixel_x_reg	=>	enchufe7,
			pixel_y_reg	=>	enchufe8,
			d_i		 => aux_enchufe5f,
			q_o		 => enchufe5f
		);
	regE_3: regEst
		generic map(
			N => 4 -- Bits de de cada entrada del registro
		)
		port map(
			clk_i	 => clk_i,
			rst_i	 => rst_i,
			pixel_x_reg	=>	enchufe7,
			pixel_y_reg	=>	enchufe8,
			d_i		 => aux_enchufe5d,
			q_o		 => enchufe5d
		);

	-- Multiplexor
	muxBCDconex: muxBCD
		port map(
			BCD0	=> enchufe5d,
			punto_i	=> "1010",
			BCD1	=> enchufe5f,
			BCD2	=> enchufe5g,
			volt_i	=> "1011",					-- Datos entrantes del registro de tension
			sel		=> enchufe7(9 downto 7),	-- Pixel x de VGA
			f_o		=> enchufe6					-- Salida hacia ROM
		);

	-- ROM
	ROMconex: ROM
		port map(
			font_col	=> enchufe7(6 downto 4),	-- Posicion X controlada por VGA
			font_row	=> enchufe8(6 downto 4),	-- Posicion Y controlada por VGA
			char_adress	=> enchufe6,				-- Datos entrantes de MUX
			rom_out		=> enchufe9					-- Salida hacia VGA
		);
		
	-- Logica ADC sigma-delta
	logicADC: logica
		port map(
			clk_i  => clk_i,		-- Clock
			rst_i  => rst_i,		-- Reset
			ena_i  => ena_i,		-- Enable
			d_vi   => datav_in_i,	-- Entrada de señales
			q_fb   => datav_out_o,	-- Realimentación
			q_proc => enchufe1		-- Bloque de procesamiento
		);

	-- VGA
	Pantalla: VGA
		port map(
			clk_i   => clk_i,		-- Clock
			rst_i	=> rst_i,		-- Reset
			red_i   => enchufe9,	-- Entrada rojo
			grn_i   => enchufe9,	-- Entrada verde
			blu_i   => '1',			-- Entrada azul
			hsync   => hs_o,		-- Sincronismo horizontal
			vsync   => vs_o,		-- Sincronismo vertical
			red_o   => red_o,		-- Salida rojo
			grn_o   => grn_o,		-- Salida verde
			blu_o   => blu_o,		-- Salida azul
			pixel_x => enchufe7,	-- Pixel x
			pixel_y => enchufe8		-- Pixel y
		);
end;
