LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Address_Queue IS
	PORT
	(
		Mode: 	IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Idle, 01: Push, 10: Pull
		Addr:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);		--Endereço de 8 bits
		TrID:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--Limite de 4 transações
		
		FIFOStatus:	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Normal, 01: Empty, 10: Full
		Ret:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);		--Retorna endereço, logo mesmo tamanho
		
		Reset:	IN STD_LOGIC;
		Clock:	IN STD_LOGIC
	);
END ENTITY Address_Queue;

ARCHITECTURE  Queue OF Address_Queue IS
--Assumindo X do tamanho da fila como 10 também
TYPE TRANS_ADDR_MEM IS ARRAY (9 DOWNTO 0) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
TYPE ALL_DATA IS ARRAY (3 DOWNTO 0) OF TRANS_ADDR_MEM;
SIGNAL MemStorage: ALL_DATA;

TYPE POINTER IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (3 DOWNTO 0);
--TYPE POINTER IS ARRAY (3 DOWNTO 0) OF INTEGER;
SIGNAL Head, Tail: POINTER;-- := ("", "", );
--Inicializa Head como 1 e tail como 0?

BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Reset = '1') THEN
			-- ?
			
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			IF (Mode = "01") THEN							--PUSH
				MemStorage(TrID, Tail(TrID)) <= Addr;
				Tail(TrID) <= Tail(TrID) + 1;
				
			ELSIF (Mode = "10") THEN						--PULL
				--Esvaziar o dado dentro da posição?
				Ret <= MemStorage(TrID, Head(TrID));
				Head(TrID) <= Head(TrID) + 1;
				
			--ELSE THEN Ret <= "00000000"; ? - Talvez fique mais fácil eu perceber quando estiver botando tudo junto se eu estiver pegando valor de Ret errado (antes de atualizar, ou não estar atualizando pro valor certo)
			END IF;
			
			--Devo ter que enviar um retorno de que quando Head = Tail a fila está vazia (pra informar quando parar de passar pra memória principal) --O Rafael tinha falado de colocar informando quando cheio, mas isso não é tão urgente pro momento
			IF (Head(TrID) > Tail(TrID)) THEN		--Isso ainda tem problema pra quando a lista der overflow
				FIFOStatus <= "01";
			END IF;
			--Isso vou ter que mudar depois pra ser enviado pra antes do push e pull, pq se ele tentar dar pull numa lista vazia vai ter comportamento incorreto antes de verificar que está vazia
		END IF;
	END PROCESS;
END Queue;