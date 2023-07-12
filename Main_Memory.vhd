LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;

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
TYPE MemStruct IS ARRAY (255 DOWNTO 0) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL Mem: MemStruct;

SIGNAL AddrInt: INTEGER := TO_INTEGER(UNSIGNED(Addr));

BEGIN
	PROCESS (Clock, Reset)
	BEGIN
		IF (Reset = '1') THEN
			--Zera memória
			Mem <= (others=>(others=>'0'));
		
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			Mem(AddrInt) <= Data;
			
		END IF;
	END PROCESS;
END Memory;