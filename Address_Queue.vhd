LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Address_Queue IS
	PORT
	(
		Mode: 	IN STD_LOGIC_VECTOR (1 DOWNTO 0);			--00: Idle, 01: Push, 10: Pull
		Addr:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);			--Endereço de 8 bits
		TrID:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);			--Limite de 4 transações
		
		FIFOStatus:	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Normal, 01: Empty, 10: Full
		Ret:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);			--Retorna endereço, logo mesmo tamanho
		
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
SIGNAL Head, Tail: POINTER;
SIGNAL ModeStorage: STD_LOGIC_VECTOR (1 DOWNTO 0);

BEGIN
	
	--MUX, se 00 ou 11 coloca ModeStorage no ModeStorage, se outro coloca Mode no ModeStorage
	ModeStorage <= ((Mode(0) XOR Mode(1)) AND Mode) OR (NOT(Mode(0) XOR Mode(1)) AND ModeStorage);
	
	PROCESS (Clock)
	BEGIN
		IF (Reset = '1') THEN
			--Inicializa Head como 1 e tail como 0?
			
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			FIFOStatus <= "00";
			
			IF (Head(TrID) > Tail(TrID)) THEN				--Caso fila vazia
				FIFOStatus <= "01";								--Isso ainda tem problema pra quando a lista der overflow	--Tenho que depois ver de mudar pra um sistema de registrador deslocador + contador, pq isso resolveria o problema
																																						--Na verdade usar nesse sistema atual usar um contador já poderia ajudar, pq posso verificar além do tamanho de cada tbm ver quantas vezes ele já deu a volta na cadeia - if CountHead = CountTail + 1
			ELSIF (Mode = "10") THEN							--PULL
				Ret <= MemStorage(TrID, Head(TrID));
				Head(TrID) <= Head(TrID) + 1;
					
			END IF;
			
			IF (Tail(TrID) = "1111") THEN						--Caso fila cheia
				FIFOStatus <= "10";								--Esse daqui não é resolvido pelo de cima, mas um contador que checa se é igual ao tamanho máximo
				
			ELSIF (Mode = "01") THEN							--PUSH
				MemStorage(TrID, Tail(TrID)) <= Addr;
				Tail(TrID) <= Tail(TrID) + 1;
					
			END IF;
			
			--Talvez tbm ver de não adicionar o msm valor duas vezes seguidas (o melhor era nunca colocar valor repetido, mas aí seria mais coisa pra ver depois
			
		END IF;
	END PROCESS;
END Queue;