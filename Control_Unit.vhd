LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Control_Unit IS
	PORT
	(
		Action:				IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Undefined, 01: Read, 10: Write, 11: Commit
		IntAbortStatus:	IN STD_LOGIC;
		
		BuffStatus:			IN STD_LOGIC_VECTOR (2 DOWNTO 0);		--000: Undefined, 001: Hit, 010: Miss, 011: NotAbort, 100: CommitFail, 101: CommitSuccess
		CUStatus:			OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--000: OnIdle, 001: OnRead, 010: OnWrite, 011: OnAbort, 100: OnCommit, 101: OnUpdate--, 110: OnPush, 111: OnPull
		
		Reset:				IN STD_LOGIC;
		Clock:				IN STD_LOGIC
	);
END ENTITY Control_Unit;
			
		
ARCHITECTURE  Controle OF Control_Unit IS
TYPE STATE_TYPE IS (IdleState, ReadState, WriteState, AbortState, CommitState, MemoryUpdateState);
--SIGNAL CurrStateIs, NextStateIs: STATE_TYPE;
SIGNAL CurrStateIs: STATE_TYPE;

BEGIN

	PROCESS (Clock, Reset)
	VARIABLE NextStateIs: STATE_TYPE;
	VARIABLE Status: STD_LOGIC_VECTOR (2 DOWNTO 0);
	BEGIN
		IF (Reset = '1') THEN
			CurrStateIs <= IdleState;
			NextStateIs := IdleState;
			Status := "000";
		
		ELSIF (Clock'EVENT AND Clock = '1') THEN
		
			CASE CurrStateIs IS
				WHEN IdleState =>
					--CUStatus := "000";
					IF (IntAbortStatus = '1') THEN	--AbortCmd
						NextStateIs := AbortState;
						Status := "011";
					ELSIF (Action = "01") THEN			--ReadCmd
						NextStateIs := ReadState;
						Status := "001";
					ELSIF (Action = "10") THEN			--WriteCmd
						NextStateIs := WriteState;
						Status := "010";
					ELSIF (Action = "11") THEN			--CommitCmd
						NextStateIs := CommitState;
						Status := "100";
					END IF;
				
				WHEN ReadState =>
					--CUStatus := "001";
					IF (BuffStatus = "001" OR BuffStatus = "010") THEN
						NextStateIs := IdleState;
						Status := "000";
					END IF;
				
				WHEN WriteState =>
					--CUStatus := "010";
					IF (BuffStatus = "001" OR BuffStatus = "010") THEN
						NextStateIs := IdleState;
						Status := "000";
					END IF;
				
				WHEN AbortState =>
					--CUStatus := "011";
					IF (IntAbortStatus = '0') THEN
						NextStateIs := IdleState;
						Status := "000";
					END IF;
				
				WHEN CommitState =>
					--CUStatus := "100";
					IF (BuffStatus = "100") THEN
						NextStateIs := IdleState;
						Status := "000";
					ELSIF (BuffStatus = "011") THEN
						NextStateIs := MemoryUpdateState;
						Status := "101";
					END IF;
				
				WHEN MemoryUpdateState =>
					--CUStatus := "101";
					IF (BuffStatus = "101") THEN
						NextStateIs := IdleState;
						Status := "000";
					END IF;
				
			END CASE;
			
			CurrStateIs <= NextStateIs;
			CUStatus <= Status;
			
		END IF;
	END PROCESS;

END Controle;