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
		IntAbortStatus:	OUT STD_LOGIC;
		
		Reset:				IN STD_LOGIC
	);
END ENTITY Conflict_Buffer;

ARCHITECTURE  Flags OF Conflict_Buffer IS
TYPE FlagBuff IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL ConflictFlag: FlagBuff;

SIGNAL TrIDint: INTEGER := TO_INTEGER(UNSIGNED(TrID));

BEGIN

	Status <= ConflictFlag(TrIDint);
	IntAbortStatus <= ConflictFlag(0)(1) OR ConflictFlag(1)(1) OR ConflictFlag(2)(1) OR ConflictFlag(3)(1);
	
	PROCESS (Mode)
	BEGIN
		CASE Mode IS
			WHEN "00" =>
				ConflictFlag(TrIDint) <= ConflictFlag(TrIDint);
		
			WHEN "01" =>
				ConflictFlag(TrIDint) <= "11";
				
			WHEN "10" =>
				ConflictFlag(TrIDint) <= "01";
				
			--WHEN "11" =>			--4 out of 81 cases (U, X, etc)
			WHEN others =>
				ConflictFlag(TrIDint) <= "00";
				
		END CASE;
	END PROCESS;
END Flags;