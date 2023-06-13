library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

----------------------------------------------------------------------------------
-- Read Module for Signal Tap use
--
-- The ADMV1013 protocol consists of a write/read bit followed
-- by six register address bits, 16 data bits, and a parity bit. Both
-- the address and data fields are organized MSB first and end with
-- the LSB. For a write, set the first bit to 0. For a read, set the first bit to 1
-- R(1)/W(0) + A( 5 to 0 ) + Data ( 15 to 0 )
----------------------------------------------------------------------------------

entity RdAddrLst is
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
end entity;


architecture RTL of RdAddrLst is
----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
	Constant cRdWr		: std_logic := '1';
	Constant cCsInB		: std_logic_vector( 1 downto 0 ) := "10";
	
	type MyArrayType is array(0 to 3) of std_logic_vector( 5 downto 0);
	Constant AddressLst	: MyArrayType := 
											(
											"000000",
											"000001",
											"000011",
											"001010"
											);
											
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	type StateType is
	(
		StIdle,
		StLoad,
		StWait,
		StShift
	);
	signal rState		: StateType := StIdle;
	signal rDump		: std_logic_vector( 23 downto 0 );
	Signal rParload		: std_logic_vector( 1 downto 0 );
	Signal rCsInB		: std_logic_vector( 1 downto 0 );
	
	
begin

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------

	u_rState : process(Clk) is
	begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rState <= StIdle;
			else
				case (rState) is
					when StIdle =>
						if ( rDump = x"000000" ) then
							rState		<= StIdle;
						else 
							rState		<= StLoad;
						end if;
						
					when StLoad =>
						if ( rParload(1) = '1' ) then
							rState 		<= StWait;
						else
							rState		<= StLoad;
						end if;
						
					when StWait =>
						if ( Busy = '0' ) then
							rState		<= StShift;
						else
							rState		<= StWait;
						end if;
					
					when StShift =>
						rState <= StIdle;

				end case;
			end if;
		end if;
	end process u_rState;
	
	u_rDump : process(Clk) Is
	begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rDump( 23 downto 18 ) <= AddressLst(0);
				rDump( 17 downto 12 ) <= AddressLst(1);
				rDump( 11 downto 6 )  <= AddressLst(2);
				rDump( 5  downto 0 )  <= AddressLst(3);
			else
				if ( rState = StShift ) then
					rDump( 23 downto 18 ) <= rDump( 17 downto 12 );
					rDump( 17 downto 12 ) <= rDump( 11 downto 6  );
					rDump( 11 downto 6  ) <= rDump( 5  downto 0  );
					rDump( 5  downto 0  ) <= (others=>'0');
				else
					rDump( 23 downto 0  ) <= rDump( 23 downto 0 );
				end if;
			end if;
		end if;
	end process u_rDump;

	u_rParload : process(Clk) Is
	begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rParload( 1 downto 0 ) 		<= "00";
			else
				if ( rState = StLoad ) then
					rParload(0) 	<= not rParload(0);
				else
					rParload(0)		<= '0';
				end if;
				rParload(1)			<= rParload(0); 
			end if;
		end if;
	end process u_rParload;
	
----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	Address( 5 downto 0 )	<= rDump( 23 downto 18 );
	Parload					<= rParload(0);
	RdWr					<= cRdWr;
	CsInB					<= cCsInB;
	
end architecture RTL;






















