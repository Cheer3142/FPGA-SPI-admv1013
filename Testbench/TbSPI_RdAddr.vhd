library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
USE STD.TEXTIO.ALL;

----------------------------------------------------------------------------------
-- Testbench for SPI 
--
-- The ADMV1013 protocol consists of a write/read bit followed
-- by six register address bits, 16 data bits, and a parity bit. Both
-- the address and data fields are organized MSB first and end with
-- the LSB. For a write, set the first bit to 0. For a read, set the first bit to 1
-- R(1)/W(0) + A( 5 to 0 ) + Data ( 15 to 0 )
----------------------------------------------------------------------------------

entity TbSPI is
end entity TbSPI;


architecture Testbench of TbSPI is
----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
	constant	tClk			: time := 10 ns;
	
-------------------------------------------------------------------------
-- Component Declaration
-------------------------------------------------------------------------
	Component SPICom Is
	Port(
		Clk      : in  std_logic;
        RstB     : in  std_logic;
		Address	 : in  std_logic_vector( 5 downto 0 );	-- Register Address
		
		RdWr	 : in  std_logic;						-- R/W
		WrData	 : in  std_logic_vector( 15 downto 0 );	
		RdData	 : out std_logic_vector( 15 downto 0 );	
		RdDataEn : out std_logic;
		
		Parload	 : in  std_logic;    					-- To load command to rData
		Busy	 : out std_logic;
		
		-- SPI
        SClk     : out std_logic;						-- Output Clock
        MOSI     : out std_logic;
        MISO     : in  std_logic;
		CsInB	 : in  std_logic_vector( 1 downto 0);
		CsOutB	 : out std_logic_vector( 1 downto 0)
	);
	End Component SPICom;
	
	Component RdAddrLst is
    port (
		Clk      : in  std_logic;
		RstB     : in  std_logic;
		Address	 : out  std_logic_vector( 5 downto 0 );	-- Register Address
		
		RdWr	 : out std_logic;						-- R/W
		RdData	 : in  std_logic_vector( 15 downto 0 );	
		RdDataEn : in  std_logic;
		
		Parload	 : out std_logic;    					-- To load command to rData
		Busy	 : in  std_logic;
		
		-- SPI
		CsInB	 : out std_logic_vector( 1 downto 0)
    );
	End Component RdAddrLst;
	
	Component PortMapModule is
	Port
	(
		Temp	: in std_logic
	);
	End Component PortMapModule;
	
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	signal	TM			: integer	range 0 to 65535;
	
	signal	RstB		: std_logic;
	signal	Clk			: std_logic;
	signal  Address		: std_logic_vector( 5 downto 0 );
	
	signal	RdWr		: std_logic;
	signal	RdDataEn	: std_logic;
	signal	WrData	 	: std_logic_vector( 15 downto 0 );	
	signal	RdData	 	: std_logic_vector( 15 downto 0 );	
	
	signal	Parload		: std_logic;
	signal	Busy		: std_logic;
	
	signal	SClk		: std_logic;
	signal	MOSI		: std_logic;
	signal	MISO		: std_logic;
	signal	CsInB		: std_logic_vector( 1 downto 0);
	signal	CsOutB		: std_logic_vector( 1 downto 0);
	
begin

----------------------------------------------------------------------------------
-- Concurrent signal
----------------------------------------------------------------------------------
	
	u_RstB : Process
	Begin
		RstB	<= '0';
		wait for 20*tClk;
		RstB	<= '1';
		wait;
	End Process u_RstB;

	u_Clk : Process
	Begin
		Clk		<= '1';
		wait for tClk/2;
		Clk		<= '0';
		wait for tClk/2;
	End Process u_Clk;
	
	u_SPICom : SPICom 
	Port map
	(
		RstB		=> RstB			,	
		Clk			=> Clk			,
		Address	 	=> Address		,
		
		RdWr	 	=> RdWr			,
		RdData	 	=> RdData		,
		WrData		=> WrData		,
		RdDataEn 	=> RdDataEn		,	
		
		Parload	 	=> Parload		,
		Busy	 	=> Busy			,


		SClk     	=> SClk			,			-- Output Clock
        MOSI     	=> MOSI			,
        MISO     	=> MISO			,
		CsOutB	 	=> CsOutB		,
		CsInB	 	=> CsInB
	);
	
	
	u_RdAddrLst : RdAddrLst 
	Port map
	(
		RstB	 => RstB		,	
		Clk		 => Clk			,
		Address	 => Address		,
		
		RdWr	 => RdWr		,
		RdData	 => RdData		,
		RdDataEn => RdDataEn	,	
		
		Parload	 => Parload		,
		Busy	 => Busy		,
		
		CsInB	 => CsInB
	);
	

-------------------------------------------------------------------------
-- Testbench
-------------------------------------------------------------------------
	
	u_Test : Process
	variable	iSerData	: std_logic_vector( 15 downto 0 );
	Begin
		-------------------------------------------
		-- TM=0 : Reset
		-------------------------------------------
		TM <= 0; wait for 1 ns;
		Report "TM=" & integer'image(TM); 
		wait for 30*tClk;
		
		-------------------------------------------
		-- TM=1 : MISO
		-------------------------------------------	
		-- TM <= 1; wait for 1 ns;
		-- Report "TM=" & integer'image(TM); 
		-- Parload		<= '1';
		-- RdWr		<= '1';
		-- Address		<= "010011";
		-- CsInB		<= "10";
		-- wait until rising_edge(Clk);
		-- Parload		<= '0';
		-- wait until rising_edge(Clk);
		-- wait for 7*1000*tClk;
		
		-- iSerData 	:= x"1A35";
		-- For i in 0 to 15 loop
			-- MISO		<= iSerData(15);
			-- wait for 1000*tClk;
			-- wait until rising_edge(Clk);
			-- iSerData	:=  iSerData(14 downto 0) & '1';
		-- End loop;
		-- wait for 30*tClk;
		-- wait for 1000*tClk;
		
		-- -- -------------------------------------------
		-- -- TM=2 : MISO again
		-- -------------------------------------------
		-- TM <= 2; wait for 1 ns;
		-- Report "TM=" & integer'image(TM);
		-- wait until rising_edge(Clk);
		-- Parload		<= '1';
		-- RdWr		<= '1';
		-- Address		<= "010011";
		-- CsInB		<= "01";
		-- wait until rising_edge(Clk);
		-- Parload		<= '0';
		-- wait until rising_edge(Clk);
		-- wait for 7*1000*tClk;
		
		-- iSerData 	:= x"5AF2";
		-- For i in 0 to 15 loop
			-- MISO		<= iSerData(15);
			-- wait for 1000*tClk;
			-- wait until rising_edge(Clk);
			-- iSerData	:=  iSerData(14 downto 0) & '1';
		-- End loop;
		-- wait for 30*tClk;
		-- wait for 1000*tClk;
		
		-- -------------------------------------------
		-- -- TM=3 : Full = 1
		-- -------------------------------------------	
		-- TM <= 3; wait for 1 ns;
		-- Report "TM=" & integer'image(TM); 
		-- RxFfFull	<= '1';
		-- wait until rising_edge(Clk);
		-- iSerData 	:= '1'&x"35"&'0';
		-- For i in 0 to 9 loop
			-- SerDataIn	<= iSerData(0);
			-- wait for 868*tClk;
			-- wait until rising_edge(Clk);
			-- iSerData	:= '1' & iSerData(9 downto 1);
		-- End loop;
		-- wait for 30*tClk;
		
		-- -------------------------------------------
		-- -- TM=4 : Reset & Normal
		-- -------------------------------------------	
		-- TM <= 4; wait for 1 ns;
		-- Report "TM=" & integer'image(TM); 
		
		-- RxFfFull	<= '0';
		-- wait until rising_edge(Clk);
		-- iSerData 	:= '1'&x"53"&'0';
		-- For i in 0 to 9 loop
			-- SerDataIn	<= iSerData(0);
			-- wait for 868*tClk;
			-- wait until rising_edge(Clk);
			-- iSerData	:= '1' & iSerData(9 downto 1);
		-- End loop;
		wait for 30*tClk;
		wait for 4*24*1000*tClk;
		
		
		
		--------------------------------------------------------
		TM <= 255; wait for 1 ns;
		wait for 20*tClk;
		Report "##### End Simulation #####" Severity Failure;		
		wait;
		
	End Process u_Test;
	
end architecture Testbench;






















