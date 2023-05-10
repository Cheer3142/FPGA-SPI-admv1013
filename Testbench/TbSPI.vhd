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
end entity;


architecture RTL of TbSPI is
----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
	constant	tClk			: time := 10 ns;
	
-------------------------------------------------------------------------
-- Component Declaration
-------------------------------------------------------------------------
	Component SPICom Is
	Port(
		Address	 : in  std_logic_vector( 5 downto 0 );	-- Register Address
		
		RdWr	 : in  std_logic;						-- R/W
		RdData	 : out std_logic_vector( 15 downto 0 );	
		RdDataEn : out std_logic;
		
		Parload	 : in  std_logic;    					-- To load command to rData
		Busy	 : out std_logic;
		CsInB	 : in  std_logic_vector( 1 downto 0)
	);
	End Component SPICom;
	
	Component RdAddrLst Is
	Port(
		Address	 : out std_logic_vector( 5 downto 0 );	-- Register Address
		
		RdWr	 : out std_logic;						-- R/W
		RdData	 : in  std_logic_vector( 15 downto 0 );	
		RdDataEn : in  std_logic;
		
		Parload	 : out std_logic;    					-- To load command to rData
		Busy	 : in  std_logic;
		CsInB	 : out std_logic_vector( 1 downto 0)
	);
	End Component RdAddrLst;
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	-- internal Signal (C)
	Signal rAddress			: std_logic_vector( 5 downto 0 );
	signal rRdWr			: std_logic; 
	Signal rRdData			: std_logic_vector( 15 downto 0 );	
	Signal rRdDataEn		: std_logic;
	
	signal rParload			: std_logic;
	Signal rBusy			: std_logic;
	Signal rCsInB			: std_logic_vector( 1 downto 0 );
	
begin

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	u_SPICom : SPICom 
	Port map
	(
		Address	 => rAddress,
		
		RdWr	 => rRdWr,
		RdData	 => rRdData,
		RdDataEn => rRdDataEn,	
		
		Parload	 => rParload,
		Busy	 => rBusy,
		CsInB	 => rCsInB
	);

	u_RdAddrLst : RdAddrLst 
	Port map
	(
		Address	 => rAddress,
		
		RdWr	 => rRdWr,
		RdData	 => rRdData,
		RdDataEn => rRdDataEn,	
		
		Parload	 => rParload,
		Busy	 => rBusy,
		CsInB	 => rCsInB
	);

	
----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	
end architecture RTL;






















