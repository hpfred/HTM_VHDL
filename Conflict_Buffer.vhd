LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

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
--SIGNAL ConflictFlag: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL ConflictFlag: ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);

BEGIN

	Status <= ConflictFlag(TrID);
	IntAbortStatus <= ConflictFlag(0,1) AND ConflictFlag(1,1) AND ConflictFlag(2,1) AND ConflictFlag(3,1);
	
	PROCESS (Mode)
	BEGIN
		IF (Mode = "01") THEN
			ConflictFlag(TrID) <= "11";
			
		ELSIF (Mode = "10") THEN
			ConflictFlag(TrID) <= "01";
			
		ELSIF (Mode = "11") THEN
			ConflictFlag(TrID) <= "00";
			
		END IF;
	END PROCESS;
END Flags;