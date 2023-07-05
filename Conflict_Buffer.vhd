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
SIGNAL ConflictFlag: STD_LOGIC_VECTOR (15 DOWNTO 0);		--Antes tava com o tamanho igual ao endereço de Transição e não o tamanho do numero de transições (agora correto, se tem um bit para cada uma)

BEGIN
	
	--Faz uma MUX 16, que recebe o TrID, cada endereço do buffer vai numa entrada e a saída vai pro Status


	PROCESS (Clock)
	BEGIN
	
		--Quando no estado Read e Write ele sempre vai ser somente retorno, e de uma transação especifica, então o "request" poderia ser feito com antencedencia, correto?
	
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