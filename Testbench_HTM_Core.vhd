LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Testbench_HTM_Core IS
	
END ENTITY Testbench_HTM_Core;	
			
		
ARCHITECTURE  TEST OF Testbench_HTM_Core IS
SIGNAL Clock: STD_LOGIC := '0';
SIGNAL Reset: STD_LOGIC := '1';

SIGNAL ActionProcID, TransactionID: STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL TransactionStatus: STD_LOGIC_VECTOR (2 DOWNTO 0);
SIGNAL MemAddress, Data: STD_LOGIC_VECTOR (7 DOWNTO 0);

COMPONENT HTM_Core IS
 PORT
	(
		Action:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--00: Idle, 01: Read, 10: Write, 11: Commit)
		MemAddress:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);				--Endereço (8 bits)
		Data:						IN STD_LOGIC_VECTOR (7 DOWNTO 0);				--Dado (8 bits)
		ProcID:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--4 Processadores
		TransactionID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--4 Transações
		TransactionStatus:	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);				--000: Undefined, 001: Hit, 010: Miss, 011: NotAbort, 100: CommitFail, 101: CommitSuccess
		Reset:					IN STD_LOGIC;
		Clock:					IN STD_LOGIC
	);
	
END COMPONENT;
BEGIN
	Clock <= NOT Clock AFTER 5 ns;
	PROCESS
	BEGIN
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		Reset <= '0';
		Action <= "XX";
		MemAddress <= "XXXXXXXX";
		Data <= "XXXXXXXX";
		ProcID <= "XX";
		TransactionID <= "XX";
		--OUT TransactionStatus;
		
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		Action <= "XX";
		MemAddress <= "XXXXXXXX";
		Data <= "XXXXXXXX";
		ProcID <= "XX";
		TransactionID <= "XX";
		--OUT TransactionStatus;
		
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		Action <= "XX";
		MemAddress <= "XXXXXXXX";
		Data <= "XXXXXXXX";
		ProcID <= "XX";
		TransactionID <= "XX";
		--OUT TransactionStatus;
		
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		Action <= "XX";
		MemAddress <= "XXXXXXXX";
		Data <= "XXXXXXXX";
		ProcID <= "XX";
		TransactionID <= "XX";
		--OUT TransactionStatus;

	END PROCESS;
	
	Core: HTM_Core PORT MAP (Action,MemAddress,Data,ProcID,TransactionID,TransactionStatus,Reset,Clock);
	
END TEST;

--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--Action <= "XX";
--MemAddress <= "XXXXXXXX";
--Data <= "XXXXXXXX";
--ProcID <= "XX";
--TransactionID <= "XX";
---OUT TransactionStatus;