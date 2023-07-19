LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY Address_Queue IS
	PORT
	(
		Mode: 	IN STD_LOGIC_VECTOR (1 DOWNTO 0);			--00: Idle, 01: Push, 10: Pull --11: Esvazia fila do Proc abortado(?) > Head = Tail + 1 --Melhor ainda > Head = 1, Tail = 0, igual o reset --Pull All
		Addr:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);			--Endereço de 8 bits
		TrID:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);			--Limite de 4 transações
		
		FIFOStatus:	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Normal, 01: Empty, 10: Full
		Ret:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);			--Retorna endereço, logo mesmo tamanho
		
		Reset:	IN STD_LOGIC;
		Clock:	IN STD_LOGIC
	);
END ENTITY Address_Queue;

ARCHITECTURE  Queue OF Address_Queue IS
TYPE POINTER IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (3 DOWNTO 0);
TYPE TRANS_ADDR_MEM IS ARRAY (9 DOWNTO 0) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
TYPE ALL_DATA IS ARRAY (3 DOWNTO 0) OF TRANS_ADDR_MEM;
SIGNAL MemStorage: ALL_DATA;

BEGIN
	PROCESS (Reset, Clock)
		VARIABLE Head, Tail: POINTER;
		VARIABLE TrIDint: INTEGER := TO_INTEGER(UNSIGNED(TrID));
		VARIABLE Status: STD_LOGIC_VECTOR (1 DOWNTO 0);
	BEGIN
		IF (Reset = '1') THEN
			FIFOStatus <= "01";
			Status := "01";
			Ret <= (others=>'0');
			MemStorage <= (others=>(others=>(others=>'0')));
			Head := (others=>"0000");
			Tail := (others=>"1111");
			
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			TrIDint := TO_INTEGER(UNSIGNED(TrID));
			IF (Head(TrIDint) > Tail(TrIDint)) THEN				--Caso fila vazia
				Status := "01";									--Isso ainda tem problema pra quando a lista der overflow	--Tenho que depois ver de mudar pra um sistema de registrador deslocador + contador, pq isso resolveria o problema
																		--Agora nem sei se tem caso de overflow na verdade, pq Pull só é feito no commit, então a lista não é ciclica (se der overflow vai estar cheia). E eu quando esvazio total a fila, só zerar os ponteiros de Head e Tail
			ELSIF (Head(TrIDint) = "1111") THEN						--Caso fila cheia
				Status := "10";									--Esse daqui não é resolvido pelo de cima, mas um contador que checa se é igual ao tamanho máximo
			ELSE																																		--Na verdade usar nesse sistema atual usar um contador já poderia ajudar, pq posso verificar além do tamanho de cada tbm ver quantas vezes ele já deu a volta na cadeia - if CountHead = CountTail + 1
				Status := "00";
			END IF;
			
			IF (Mode = "10" AND Status /= "01") THEN								--PULL
				Ret <= MemStorage(TrIDint)(TO_INTEGER(UNSIGNED(Head(TrIDint))));
				Head(TrIDint) := Head(TrIDint) + 1;
				
			ELSIF (Mode = "01" AND Status /= "10") THEN							--PUSH
				Tail(TrIDint) := Tail(TrIDint) + 1;
				MemStorage(TrIDint)(TO_INTEGER(UNSIGNED(Tail(TrIDint)))) <= Addr;
				
			ELSIF (Mode = "11") THEN													--PULL-ALL/EMPTY_FIFO
				Tail(TrIDint) := "0000";
				Tail(TrIDint) := "1111";
				
			END IF;
			
			FIFOStatus <= Status;
			
		END IF;
	END PROCESS;
END Queue;