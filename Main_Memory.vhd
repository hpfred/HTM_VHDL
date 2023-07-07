LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Main_Memory IS
	PORT
	(
		Addr:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);			--Endereço de 8 bits
		Data:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);			--Dado de 8 bits
		
		Reset:	IN STD_LOGIC;
		Clock:	IN STD_LOGIC
	);
END ENTITY Main_Memory;

ARCHITECTURE Memory OF Main_Memory IS
SIGNAL Mem: ARRAY (255 DOWNTO 0) OF STD_LOGIC_VECTOR (7 DOWNTO 0);

BEGIN
	PROCESS (Clock, Reset)
	BEGIN
		IF (Reset = '1') THEN
			--Zera memória
		
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			Mem(Addr) <= Data;
			
		END IF;
	END PROCESS;
END Carinhas;