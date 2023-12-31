LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Conflict_Buffer IS
	PORT
	(
		TrID:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Mode:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Idle, 01: Set, 10: Reset Internal, 11: Reset Abort
		
		Status:				OUT STD_LOGIC_VECTOR (1 DOWNTO 0);		--Array(InternalAbortFlag, ExternalAbortFlag)
		ProcStatus:			OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--1 DOWNTO 0: TrID com InternalConflict, 2: '1' quando nenhum InternalConflict
		IntAbortStatus:	OUT STD_LOGIC;
		
		Reset:				IN STD_LOGIC
	);
END ENTITY Conflict_Buffer;

ARCHITECTURE  Flags OF Conflict_Buffer IS
TYPE FlagBuff IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL ConflictFlag: FlagBuff;
--Todas minha memórias/buffers são feitas com signal, mas me pergunto se com variable seria má prática

BEGIN
	
	Status <= ConflictFlag(TO_INTEGER(UNSIGNED(TrID)));
	IntAbortStatus <= ConflictFlag(0)(1) OR ConflictFlag(1)(1) OR ConflictFlag(2)(1) OR ConflictFlag(3)(1);
	
	ProcStatus <= "000" WHEN ConflictFlag(0)(1) = '1' ELSE
					  "001" WHEN ConflictFlag(1)(1) = '1' ELSE
					  "010" WHEN ConflictFlag(2)(1) = '1' ELSE
					  "011" WHEN ConflictFlag(3)(1) = '1' ELSE
					  (others => '1');
	
	--PROCESS (Clock, Reset)
	PROCESS (Mode, Reset)		--Fiz sem clock, mas acho que no final dá na mesma. Tenho que ver
		VARIABLE TrIDint: INTEGER := TO_INTEGER(UNSIGNED(TrID));
	BEGIN
		TrIDint := TO_INTEGER(UNSIGNED(TrID));
		
		IF (Reset = '1') THEN
			ConflictFlag <= (others=>(others=>'0'));
		END IF;
	
		CASE Mode IS
			WHEN "00" =>
				ConflictFlag(TrIDint) <= ConflictFlag(TrIDint);
		
			WHEN "01" =>
				ConflictFlag(TrIDint) <= "11";
				
			WHEN "10" =>
				ConflictFlag(TrIDint) <= "01";
				
			WHEN others =>
				ConflictFlag(TrIDint) <= "00";
				
		END CASE;
	END PROCESS;
	
END Flags;