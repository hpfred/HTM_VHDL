LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Address_Queue IS
	PORT
	(
		Mode: IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Idle, 01: Push, 10: Pull
		Addr:	IN STD_LOGIC_VECTOR (7 DOWNTO 0);		--Endereço de 8 bits
		TrID:	IN STD_LOGIC_VECTOR (3 DOWNTO 0);		--Limite de 16 transações
		
		Ret:	OUT STD_LOGIC_VECTOR (7 DOWNTO 0);		--Retorna endereço, logo mesmo tamanho
		
		Clock:	IN STD_LOGIC
	);
END ENTITY Address_Queue;

ARCHITECTURE  Queue OF Address_Queue IS
TYPE TRANS_ADDR_MEM IS ARRAY (X DOWNTO 0) OF STD_LOGIC_VECTOR (7 DOWNTO 0);		--Limite de X endereços para cada transação
TYPE ALL_DATA IS ARRAY (3 DOWNTO 0) OF TRANS_ADDR_MEM;
SIGNAL MemStorage: ALL_DATA;

TYPE POINTER IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (Y DOWNTO 0);
SIGNAL Head, Tail: POINTER;-- := ("", "", );

BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Mode = "01") THEN
			MemStorage(TrID, Tail(TrID)) <= Addr;
			Tail(TrID) <= Tail(TrID) + 1;
			
		ELSIF (Mode = "10") THEN
			Ret <= MemStorage(TrID, Head(TrID));
			Head(TrID) <= Head(TrID) + 1;
		--ELSE THEN Ret <= "00000000"; ? - Talvez fique mais fácil eu perceber quando estiver botando tudo junto se eu estiver pegando valor de Ret errado (antes de atualizar, ou não estar atualizando pro valor certo)
		END IF;
	END PROCESS;
END Queue;