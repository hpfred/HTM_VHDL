LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;

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
TYPE TRANS_ADDR_MEM IS ARRAY (9 DOWNTO 0) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
TYPE ALL_DATA IS ARRAY (3 DOWNTO 0) OF TRANS_ADDR_MEM;
SIGNAL MemStorage: ALL_DATA;

TYPE POINTER IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (3 DOWNTO 0);
--SIGNAL Head, Tail: POINTER;		--Troquei pra VAR pq como Signal espera até o Clock pra atualizar, parecia pedindo pra dar problema

--SIGNAL TrIDint: INTEGER := TO_INTEGER(UNSIGNED(TrID));

BEGIN
	PROCESS (Reset, Clock)
		VARIABLE Head, Tail: POINTER;
		VARIABLE TrIDint: INTEGER := TO_INTEGER(UNSIGNED(TrID));
	BEGIN
		IF (Reset = '1') THEN
			FIFOStatus <= "01";
			Ret <= (others=>'0');
			MemStorage <= (others=>(others=>(others=>'0')));
			Head := (others=>"0001");
			Tail := (others=>"0000");
			
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			TrIDint := TO_INTEGER(UNSIGNED(TrID));
			IF (Head(TrIDint) > Tail(TrIDint)) THEN				--Caso fila vazia
				FIFOStatus <= "01";								--Isso ainda tem problema pra quando a lista der overflow	--Tenho que depois ver de mudar pra um sistema de registrador deslocador + contador, pq isso resolveria o problema
																																						--Na verdade usar nesse sistema atual usar um contador já poderia ajudar, pq posso verificar além do tamanho de cada tbm ver quantas vezes ele já deu a volta na cadeia - if CountHead = CountTail + 1
			ELSIF (Mode = "10") THEN							--PULL
				Ret <= MemStorage(TrIDint)(TO_INTEGER(UNSIGNED(Head(TrIDint))));
				Head(TrIDint) := Head(TrIDint) + 1;
				IF (Head(TrIDint) > Tail(TrIDint)) THEN				--Testa fila vazia de novo pra deixar Status atualizado
					FIFOStatus <= "01";
				ELSE
					FIFOStatus <= "00";
				END IF;
					
			END IF;
			
			IF (Tail(TrIDint) = "1111") THEN						--Caso fila cheia
				FIFOStatus <= "10";								--Esse daqui não é resolvido pelo de cima, mas um contador que checa se é igual ao tamanho máximo
				
			ELSIF (Mode = "01") THEN							--PUSH
				MemStorage(TrIDint)(TO_INTEGER(UNSIGNED(Tail(TrIDint)))) <= Addr;
				Tail(TrIDint) := Tail(TrIDint) + 1;
				IF (Tail(TrIDint) = "1111") THEN						--Testa fila cheia de novo pra deixar Status atualizado
					FIFOStatus <= "10";
				ELSE
					FIFOStatus <= "00";
				END IF;	
				
			END IF;
			
			--Adicionar FIFOStatusTemp como var, e sempre inicializa 00?
			
		END IF;
	END PROCESS;
END Queue;