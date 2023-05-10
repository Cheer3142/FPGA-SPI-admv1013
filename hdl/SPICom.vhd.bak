library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

----------------------------------------------------------------------------------
-- The ADMV1013 protocol consists of a write/read bit followed
-- by six register address bits, 16 data bits, and a parity bit. Both
-- the address and data fields are organized MSB first and end with
-- the LSB. For a write, set the first bit to 0. For a read, set the first bit to 1
-- R(1)/W(0) + A( 5 to 0 ) + Data ( 15 to 0 )
----------------------------------------------------------------------------------

entity SPICom is
    port (
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
		CsOutB	 : out std_logic_vector( 1 downto 0) 	-- /SEN/SEN2 active low
    );
end entity;


architecture RTL of SPICom is
----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
	Constant cBuadCnt	: integer := 999; -- use N-1

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	type StateType is
	(
		StIdle,
		StRdWr,
		StData,
		StInActive
	);
	signal rState		: StateType := StIdle;
	
	signal rBuadCnt		: std_logic_vector( 9 downto 0 );
    signal rSClk   		: std_logic_vector( 1 downto 0 );
    signal rMOSI   		: std_logic;
    signal rMISO   		: std_logic;
    signal rData   		: std_logic_vector( 22 downto 0 ) := (others => '0'); -- 1+6+16
	signal rDataCnt		: std_logic_vector( 4 downto 0 );
	Signal rCsOutB		: std_logic_vector( 1 downto 0 );
	signal rBusy		: std_logic;
	signal rRdWr		: std_logic;
	signal rRdData		: std_logic_vector( 15 downto 0 ) := (others => '0');
	Signal rRdDataEn	: std_logic;
	
begin

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	u_rState : process (CLk) is
	begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rState		<= StIdle;
			else
				case ( rState ) is
					when StIdle		=>
						if ( Parload = '1' ) then
							rState	<= StRdWr;
						else
							rState	<= StIdle;
						end if;
					
					when StRdWr	=>
						if ( rSClk( 1 downto 0 ) = "10" ) then
							rState	<= StData;
						else
							rState	<= StRdWr;
						end if;
						
					when StData	=>
						if ( rDataCnt( 4 downto 0 ) = "10110" ) then -- 16 + 6 = 22
							rState	<= StInActive;
						else
							rState	<= StData;
						end if;
					
					when StInActive =>
						rState		<= StIdle;
					
				end case;
			end if;
		end if;
	end process u_rState;
	
	u_rBusy : process (Clk) is
	begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rBusy 	<= '0';
			else
				if ( rState = StIdle ) then
					rBusy <= '0';
				else
					rBusy <= '1';
				end if;
			end if;
		end if;
	end process u_rBusy;
	
    -- SClk generation process Half of FPGA clock
    u_rSClk : process (Clk) is
    begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rSClk( 1 downto 0 ) 	<= "00";
			else
				if ( rState /= StIdle ) then
					rSClk(1) 			<= rSClk(0);	
					if ( rBuadCnt = cBuadCnt ) then
						rSClk(0) 		<= not rSClk(0);
					else
						rSClk(0)		<= rSClk(0);
					end if;
				else
					rSClk( 1 downto 0 )	<= "00";
				end if;
			end if;
        end if;
    end process u_rSClk;
	
	U_rDataCnt : process (Clk) is
	begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rDataCnt( 4 downto 0 ) 		<= (others => '0');
			else
				if ( rState /= StIdle ) then
					if ( rSClk( 1 downto 0 ) = "10" ) then
						rDataCnt( 4 downto 0 )	<= rDataCnt( 4 downto 0 ) + 1;
					else
						rDataCnt( 4 downto 0 )	<= rDataCnt( 4 downto 0 );
					end if;
				else
					rDataCnt( 4 downto 0 )		<= (others => '0');
				end if;
			end if;
		end if;
	end process U_rDataCnt;
	
	u_rData : process (Clk) is
	begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rData( 22 downto 0 )  			<= (others => '0');
			else
				if ( Parload = '1' ) then
					rRdWr						<= RdWr;
					if ( RdWr = '0' ) then
						rData(22) 				<= RdWr;
						rData( 21 downto 16 ) 	<= Address( 5 downto 0 );
						rData( 15 downto 0 ) 	<= WrData( 15 downto 0 );
					else
						rData(22)				<= RdWr;
						rData( 21 downto 16 ) 	<= Address( 5 downto 0 );
						rData( 15 downto 0 ) 	<= (others=>'0');
					end if;
				elsif ( rSClk( 1 downto 0 ) = "10" ) then
					rData( 22 downto 1 ) 		<= rData( 21 downto 0 );
					rData(0)					<= '0';
				else
					rData( 22 downto 0 ) 		<= rData( 22 downto 0 );
				end if;
			end if;
		end if;
	end process u_rData;
	
	u_rBuadCnt : process (Clk) is
	begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rBuadCnt( 9 downto 0 )			<= conv_std_logic_vector(cBuadCnt, rBuadCnt'length);
			else
				if ( rState /= StIdle ) then
					if ( rBuadCnt = cBuadCnt ) then
						rBuadCnt( 9 downto 0 )	<= (others=>'0');
					else
						rBuadCnt( 9 downto 0 )	<= rBuadCnt( 9 downto 0 ) + 1;
					end if;
				else
					rBuadCnt( 9 downto 0 )		<= conv_std_logic_vector(cBuadCnt, rBuadCnt'length);
				end if;
			end if;
		end if;
	end process u_rBuadCnt;
	
    -- MOSI generation process
    u_rMOSI : process (Clk) is
    begin
		if ( rSClk( 1 downto 0 ) = "10" ) then
			if ( RstB = '0' ) then
				rMOSI			<= '0';
			else
				if ( rState /= StIdle ) then
					rMOSI 		<= rData(22);					
				else
					rMOSI		<= '0';
				end if;
			end if;
		end if;
    end process u_rMOSI;
	
    -- MISO generation process
    u_rMISO : process (Clk) is
    begin
		if ( rSClk( 1 downto 0 ) = "10" ) then
			rMISO 	<= MISO;
		end if;
    end process u_rMISO;
	
	u_rRdData : process (Clk) is
	begin
		if ( rSClk( 1 downto 0 ) = "10" ) then
			if ( RstB = '0' ) then
				rRdData( 15 downto 0 )				<= (others=>'0');
			else
				if ( rState = StData ) then
					if ( rRdWr = '1' ) then
						rRdData(0)					<= rMISO;
						rRdData( 15 downto 1 )		<= rRdData( 14 downto 0 );
					else
						rRdData( 15 downto 0 )		<= (others=>'0');
					end if;
				else
					rRdData( 15 downto 0 )			<= (others=>'0');
				end if;
			end if;
		end if;
	end process u_rRdData;
	
	u_rRdDataEn : process (Clk) is
	begin
		if ( rSClk( 1 downto 0 ) = "01" ) then
			if ( RstB = '0' ) then
				rRdDataEn 			<= '0';
			else
				if ( rState = StInActive ) then
					if ( rRdWr = '1' ) then
						rRdDataEn				<= '1';
					else
						rRdDataEn				<= '0';
					end if;
				else
					rRdDataEn				<= '0';
				end if;
			end if;
		end if;
	end process u_rRdDataEn;
	
	u_rCsOutB : process(Clk) is
	begin
		if ( rising_edge(Clk) ) then
			if ( RstB = '0' ) then
				rCsOutB( 1 downto 0 )	<= "11";
			else
				if ( rState /= StIdle ) then
					rCsOutB( 1 downto 0 ) 	<= CsInB( 1 downto 0 );
				else
					rCsOutB( 1 downto 0 )	<= "11";
				end if;
			end if;
		end if;
	end process u_rCsOutB;

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
    SClk 		<= rSClk(0);
    MOSI 		<= rMOSI;
	CsOutB		<= rCsOutB;
	Busy		<= rBusy;
	RdDataEn	<= rRdDataEn;
	RdData		<= rRdData;
	
end architecture RTL;






















