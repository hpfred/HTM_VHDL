LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Conflict_Buffer IS
	PORT
	(
		TrID:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Mode:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Idle, 01: Set, 10: Reset, 11: Return
		
		Status:	OUT STD_LOGIC;
		
		Clock:	IN STD_LOGIC
	);
END ENTITY Conflict_Buffer;

ARCHITECTURE  Flags OF Conflict_Buffer IS
SIGNAL ConflictFlag: STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN
	
	--Faz uma MUX 4, que recebe o TrID, cada endereço do buffer vai numa entrada e a saída vai pro Status
	--Acredito, mas ainda não tenho certeza, que a síntese do Quartus transforma um Process com cases em um MUX, e isso pode me poupar tempo de fazer os MUXes (já que aparentemente o VHDL não tem nada com componentes básicos pré-prontos)

	Status <= ConflictFlag(TrID);
	
	PROCESS (Mode)
	BEGIN
		IF (Mode = "01") THEN
			ConflictFlag(TrID) <= '1';
			
		ELSIF (Mode = "10") THEN
			ConflictFlag(TrID) <= '0';
			
		END IF;
	END PROCESS;
END Flags;