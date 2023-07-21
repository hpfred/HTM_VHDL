LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Testbench_HTM_Core IS
	
END ENTITY Testbench_HTM_Core;	
			
		
ARCHITECTURE  TEST OF Testbench_HTM_Core IS
SIGNAL Clock: STD_LOGIC := '0';
SIGNAL Reset: STD_LOGIC := '1';

SIGNAL Action, ProcID, TransactionID, ID: STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL TransactionStatus, HTMCUStatus: STD_LOGIC_VECTOR (2 DOWNTO 0);
SIGNAL MemAddress, Data: STD_LOGIC_VECTOR (7 DOWNTO 0);

COMPONENT HTM_Core IS
 PORT
	(
		Action:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--00: Undefined, 01: Read, 10: Write, 11: Commit
		MemAddress:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);				--EndereÃ§o (8 bits)
		Data:						IN STD_LOGIC_VECTOR (7 DOWNTO 0);				--Dado (8 bits)
		ProcID:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--4 Processadores
		TransactionID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--4 TransaÃ§Ãµes
		TransactionStatus:	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);				--000: Undefined, 001: Hit, 010: Miss, 011: NotAbort, 100: CommitFail, 101: CommitSuccess, 110: NoInternalAborts
		HTMCUStatus:			OUT STD_LOGIC_VECTOR (2 DOWNTO 0);				--
		Reset:					IN STD_LOGIC;
		Clock:					IN STD_LOGIC
	);
	
END COMPONENT;
BEGIN
	Clock <= NOT Clock AFTER 5 ns;
	PROCESS
	BEGIN
		--INIT
		Reset <= '1';
		Action <= "00";
		MemAddress <= "00000000";
		Data <= "00000000";
		ID <= "00";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		Reset <= '0';
		
		--READ
		--ID: 10 - Action: 01 - Addr: 01100010
		Action <= "01";
		MemAddress <= "01100010";
		ID <= "10";
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		
		--READ
		--ID: 10 - Action: 01 - Addr: 11011111
		Action <= "01";
		MemAddress <= "11011111";
		ID <= "10";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--WRITE
		--ID: 01 - Action: 10 - Data: 000000001 - Addr: 11101001
		Action <= "10";
		MemAddress <= "11101001";
		Data <= "00000001";
		ID <= "01";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--READ
		--ID: 10 - Action: 01 - Addr: 10100011
		Action <= "01";
		MemAddress <= "10100011";
		ID <= "10";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--READ
		--ID: 00 - Action: 01 - Addr: 11011111
		Action <= "01";
		MemAddress <= "11011111";
		ID <= "00";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--READ
		--ID: 00 - Action: 01 - Addr: 10100011
		Action <= "01";
		MemAddress <= "10100011";
		ID <= "00";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--WRITE
		--ID: 00 - Action: 10 - Data: 10010001 - Addr: 11101110
		Action <= "10";
		MemAddress <= "11101110";
		Data <= "10010001";
		ID <= "00";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--COMMIT-SUCCESS
		Action <= "11";
		ID <= "00";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		--Action <= "00";
		--WAIT UNTIL TransactionStatus'EVENT AND (TransactionStatus = "100" OR TransactionStatus = "101");
		WAIT UNTIL HTMCUStatus = "000";
		
		--READ
		--ID: 10 - Action: 01 - Addr: 10110101
		Action <= "01";
		MemAddress <= "10110101";
		ID <= "10";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--READ
		--ID: 11 - Action: 01 - Addr: 11101110
		Action <= "01";
		MemAddress <= "11101110";
		ID <= "11";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--WRITE
		--ID: 10 - Action: 10 - Data: 11111101 - Addr: 10110101
		Action <= "10";
		MemAddress <= "10110101";
		Data <= "11111101";
		ID <= "10";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--WRITE
		--ID: 10 - Action: 10 - Data: 11101010 - Addr: 10110101
		Action <= "10";
		MemAddress <= "10110101";
		Data <= "11101010";
		ID <= "10";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--COMMIT-SUCCESS
		Action <= "11";
		ID <= "10";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		--Action <= "00";
		--WAIT UNTIL TransactionStatus'EVENT AND (TransactionStatus = "100" OR TransactionStatus = "101");
		WAIT UNTIL HTMCUStatus = "000";
		
		--READ
		--ID: 01 - Action: 01 - Addr: 01100010
		Action <= "01";
		MemAddress <= "01100010";
		ID <= "01";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--READ
		--ID: 11 - Action: 01 - Addr: 10110101
		Action <= "01";
		MemAddress <= "10110101";
		ID <= "11";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--WRITE
		--ID: 01 - Action: 10 - Data: 10000000 - Addr: 10100011
		Action <= "10";
		MemAddress <= "10100011";
		Data <= "10000000";
		ID <= "01";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--READ
		--ID: 01 - Action: 01 - Addr: 01100010
		Action <= "01";
		MemAddress <= "01100010";
		ID <= "01";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--READ
		--ID: 11 - Action: 01 - Addr: 11011111
		Action <= "01";
		MemAddress <= "11011111";
		ID <= "11";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--READ
		--ID: 11 - Action: 01 - Addr: 01100010
		Action <= "01";
		MemAddress <= "01100010";
		ID <= "11";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--COMMIT-SUCCESS
		Action <= "11";
		ID <= "11";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		--Action <= "00";
		--WAIT UNTIL TransactionStatus'EVENT AND (TransactionStatus = "100" OR TransactionStatus = "101");
		WAIT UNTIL HTMCUStatus = "000";
		
		--READ
		--ID: 01 - Action: 01 - Addr: 10100011
		Action <= "01";
		MemAddress <= "10100011";
		ID <= "01";
		WAIT UNTIL HTMCUStatus /= "000";
		IF (HTMCUStatus = "011") THEN
			WAIT UNTIL TransactionStatus'EVENT AND TransactionStatus = "110";
			WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		END IF;
		WAIT UNTIL (TransactionStatus = "001" OR TransactionStatus = "010");
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		
		--COMMIT-SUCCESS
		Action <= "11";
		ID <= "01";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		--Action <= "00";
		--WAIT UNTIL TransactionStatus'EVENT AND (TransactionStatus = "100" OR TransactionStatus = "101");
		WAIT UNTIL HTMCUStatus = "000";
		
		--END
		Action <= "00";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		
	END PROCESS;
	
	ProcID <= ID;
	TransactionID <= ID;
	Core: HTM_Core PORT MAP (Action,MemAddress,Data,ProcID,TransactionID,TransactionStatus,HTMCUStatus,Reset,Clock);
	
END TEST;


--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--Action <= "XX";
--MemAddress <= "XXXXXXXX";
--Data <= "XXXXXXXX";
--ProcID <= "XX";
--TransactionID <= "XX";
---->> OUT TransactionStatus


---------------------------------------------
-----------------------------------------INIT
--Reset <= '1';
--Action <= "00";
--MemAddress <= "00000000";
--Data <= "00000000";
--ID <= "00";
--WAIT UNTIL Clock'EVENT AND Clock = '0' ;
--Reset <= '0';
---------------------------------------------
-----------------------------------------READ
--Action <= "01";
--MemAddress <= "YYYYYYYY";
--ID <= "XX";
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
----------------------------------------------
-----------------------------------------WRITE
--Action <= "10";
--MemAddress <= "YYYYYYYY";
--Data <= "ZZZZZZZZ";
--ID <= "XX";
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
----------------------------------------------
-----------------------------------------ABORT
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
-----------------------------------------------
-----------------------------------------COMMIT
--Action <= "11";
--ID <= "XX";
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--------------------------------------------5 COMMIT : + 3 por atualizaÃ§Ã£o na memÃ³ria
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
----------------------------------------------------
-----------------------------------------LAST-ACTION
--Action <= "00";
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
-----------------------------------------------------
-----------------------------------------------------


--Pra fazer o Testbench era uma boa ideia ter uma forma padronizada de como os valores vÃ£o ser enviados
--Uma primeira coisa que seria boa Ã© fazer um cÃ³digo falso/teÃ³rico de C, e quais as instruÃ§Ãµes que o compilador geraria e enviaria pro HTM_Core
--Junto com isso tambÃ©m separar essas instruÃ§Ãµes de cada processador, pra eu poder saber quais vÃ£o estar vindo concorrentemente e "fora de ordem"
--E idealmente eu fazer algum cÃ³digo pra automatizar isso pra gerar os vÃ¡rios testes
--Bonus/Ideal tambÃ©m Ã© eu fazer esse cÃ³digo automatizado gerar as saÃ­das de Status que se espera pra fazer o teste e comparaÃ§Ã£o