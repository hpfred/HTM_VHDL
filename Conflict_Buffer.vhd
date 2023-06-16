LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Conflict_Buffer IS
	PORT
	(
		TrID:		IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		Mode:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Idle, 01: Set, 10: Reset, 11: Return
		
		Status:	OUT STD_LOGIC;
		
		Clock:	IN STD_LOGIC
	);
END ENTITY Conflict_Buffer;

ARCHITECTURE  Flags OF Conflict_Buffer IS
SIGNAL ConflictFlag: STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN
	PROCESS (Clock) --Mode e TrID ao invés de Clock?
	BEGIN
		IF (Mode = "01") THEN
			ConflictFlag(TrID) <= '1';
			
		ELSIF (Mode = "10") THEN
			ConflictFlag(TrID) <= '0';
			
		ELSIF (Mode = "11") THEN
			Status <= ConflictFlag(TrID);
			--Esse Status poderia ficar fora do process, de forma que ele sempre vai atualizar o Retorno automaticamente?
			
		END IF;
	END PROCESS;
END Flags;