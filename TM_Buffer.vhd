-- TM_Buffer é um array de vetores de estrutura tipo: 0 00000000 [00 00 00 00] 00000000
-- 																	| |			|				 |
-- 																	| |			|				 Data [7 DOWNTO 0]
-- 																	| |			Read_Write [15 DOWNTO 8]
-- 																	| Address [23 DOWNTO 16]
-- 																	Valid [24]

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.all;

ENTITY TM_Buffer IS
	PORT
	(
		MemAddress:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Data:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ProcID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		TransactionID:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		
		CUStatus:		IN STD_LOGIC_VECTOR (2 DOWNTO 0);		--000: Idle, 001: Read, 010: Write, 011: Abort, 100: Commit, 101: MemUpdate
		
		ConfBufMode:	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ConfBufTrID:	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ConfBufStatus:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		
		QueueMode:		OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		QueueStatus:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		QueueReturn:	IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		
		MemoryAddr:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		MemoryData:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		
		BuffStatus:		OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--000: Undefined, 001: Hit, 010: Miss, 011: NotAbort, 100: CommitFail, 101: CommitSuccess
		
		Reset:			IN STD_LOGIC;
		Clock:			IN STD_LOGIC
	);
END ENTITY TM_Buffer;

ARCHITECTURE  SharedData OF TM_Buffer IS
TYPE ALL_DATA IS ARRAY (9 DOWNTO 0) OF STD_LOGIC_VECTOR (24 DOWNTO 0);
SIGNAL MemBuffer: ALL_DATA;

TYPE RW_SET IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);

SIGNAL ProcIDint: INTEGER := TO_INTEGER(UNSIGNED(ProcID));
SIGNAL TransactionIDint: INTEGER := TO_INTEGER(UNSIGNED(TransactionID));

BEGIN

	PROCESS (Reset, Clock)
		VARIABLE ReadWriteSet: RW_SET;
		VARIABLE FrstNonValid: INTEGER := 2147483647;
		VARIABLE CurrAddr: INTEGER := 0;					--STD_LOGIC_VECTOR (3 DOWNTO 0); Se manter integer mudar pra unsigned?
		VARIABLE HitFlag, AbortFlag, ProcFlag: STD_LOGIC := '0';
		VARIABLE UpdateAddress: STD_LOGIC_VECTOR (7 DOWNTO 0);
		VARIABLE QueueModeTemp: STD_LOGIC_VECTOR (1 DOWNTO 0);
	BEGIN
		IF (Reset = '1') THEN
			MemBuffer <= (others=>(Others=>'0'));
			--
			BuffStatus <= (others => '0');
			ConfBufMode <= (others => '0');
			ConfBufTrID <= (others => '0');
			QueueMode <= (others => '0');
			QueueModeTemp := (others => '0');
			MemoryAddr <= (others => '0');
			MemoryData <= (others => '0');
			
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			--Zera BuffStatus no inicio de cada execução?
			QueueMode <= QueueModeTemp;
			
			--Fora o problema com a FIFO, e diminuindo o tempo na CU, ainda tenho um Clock aqui que vai executar extra/errado
			--Então provavelmente tenho que resolver com um contador, ou algum flag que só reseta quando o CUStatus mudar (?)
			IF (CUStatus = "001" OR CUStatus = "010") THEN				--Se Status é Read ou Write
				ConfBufTrID <= TransactionID;
				IF (ConfBufStatus(0) = '0') THEN									--Verifica com Conflict_Buffer se é transação zumbi
					FOR CurrAddr IN 0 TO 9 LOOP	--'length-1
						IF (MemBuffer(CurrAddr)(24) = '0' AND FrstNonValid > CurrAddr) THEN
							FrstNonValid := CurrAddr;
							HitFlag := '0';
						END IF;
						
						IF MemBuffer(CurrAddr)(23 DOWNTO 16) = MemAddress THEN
							HitFlag := '1';
							EXIT;
						END IF;
					END LOOP;
					--TODO: Caso de MISS por Overflow
					--IF (CurrAddr = 9) THEN OVERFLOW.MISS
					
					IF (HitFlag = '0') THEN										--Buffer Miss
						BuffStatus <= "010";
						QueueModeTemp := "01";
						
						MemBuffer(CurrAddr)(24) <= '1';
						MemBuffer(CurrAddr)(23 DOWNTO 16) <= MemAddress;
						
						ReadWriteSet(3) := MemBuffer(CurrAddr)(15 DOWNTO 14);
						ReadWriteSet(2) := MemBuffer(CurrAddr)(13 DOWNTO 12);
						ReadWriteSet(1) := MemBuffer(CurrAddr)(11 DOWNTO 10);
						ReadWriteSet(0) := MemBuffer(CurrAddr)(9 DOWNTO 8);
						IF (CUStatus = "001") THEN
							ReadWriteSet(ProcIDint)(0) := '1';
						ELSIF CUStatus = "010" THEN
							ReadWriteSet(ProcIDint)(1) := '1';
						END IF;
						MemBuffer(CurrAddr)(15 DOWNTO 14) <= ReadWriteSet(3);
						MemBuffer(CurrAddr)(13 DOWNTO 12) <= ReadWriteSet(2);
						MemBuffer(CurrAddr)(11 DOWNTO 10) <= ReadWriteSet(1);
						MemBuffer(CurrAddr)(9 DOWNTO 8) <= ReadWriteSet(0);
						MemBuffer(CurrAddr)(7 DOWNTO 0) <= Data;
						
						--Guarda na fila --Adicionar IF só pra fazer nos Writes?
						QueueModeTemp := "00";
							
					ELSE																--Buffer Hit
						BuffStatus <= "001";
						
						ReadWriteSet(3) := MemBuffer(CurrAddr)(15 DOWNTO 14);
						ReadWriteSet(2) := MemBuffer(CurrAddr)(13 DOWNTO 12);
						ReadWriteSet(1) := MemBuffer(CurrAddr)(11 DOWNTO 10);
						ReadWriteSet(0) := MemBuffer(CurrAddr)(9 DOWNTO 8);
						
						IF (CUStatus = "001") THEN								--Read
							FOR i IN 0 TO 3 LOOP
								IF (ReadWriteSet(i)(1) = '1' AND ProcID /= i) THEN
									ConfBufMode <= "00";
									ConfBufTrID <= ProcID;
									ConfBufMode <= "01";
									AbortFlag := '1';
								END IF;
							END LOOP;
							
							IF (AbortFlag = '0') THEN
								IF (CUStatus = "001") THEN
									ReadWriteSet(ProcIDint)(0) := '1';
								ELSIF (CUStatus = "010") THEN
									ReadWriteSet(ProcIDint)(1) := '1';
								END IF;
								MemBuffer(CurrAddr)(15 DOWNTO 14) <= ReadWriteSet(3);
								MemBuffer(CurrAddr)(13 DOWNTO 12) <= ReadWriteSet(2);
								MemBuffer(CurrAddr)(11 DOWNTO 10) <= ReadWriteSet(1);
								MemBuffer(CurrAddr)(9 DOWNTO 8) <= ReadWriteSet(0);
								
							END IF;
							AbortFlag := '0';
							
						ELSIF (CUStatus = "010") THEN							--Write
							QueueModeTemp := "01";
							FOR i IN 0 TO 3 LOOP
								IF (ReadWriteSet(i) /= "00" AND ProcID /= i) THEN
									ConfBufMode <= "00";
									---ConfBufTrID <= i;
									ConfBufMode <= "01";
								END IF;
							END LOOP;
							
							IF (CUStatus = "001") THEN
								ReadWriteSet(ProcIDint)(0) := '1';
							ELSIF (CUStatus = "010") THEN
								ReadWriteSet(ProcIDint)(1) := '1';
							END IF;
							MemBuffer(CurrAddr)(15 DOWNTO 14) <= ReadWriteSet(3);
							MemBuffer(CurrAddr)(13 DOWNTO 12) <= ReadWriteSet(2);
							MemBuffer(CurrAddr)(11 DOWNTO 10) <= ReadWriteSet(1);
							MemBuffer(CurrAddr)(9 DOWNTO 8) <= ReadWriteSet(0);
							MemBuffer(CurrAddr)(7 DOWNTO 0) <= Data;
							
							--Guarda na fila
							QueueModeTemp := "00";
							
						END IF;
					END IF;
				END IF;
				
			ELSIF (CUStatus = "011") THEN										--Se Status é abort
				FOR Proc IN 0 TO 3 LOOP																				--Varre Conflict_Buffer
					--ConfBufTrID <= Proc;
					ConfBufTrID <= STD_LOGIC_VECTOR(TO_UNSIGNED(Proc, ConfBufTrID'length));
					IF (ConfBufStatus(1) = '1') THEN																--Se Proc está com Internal Abort
						FOR Addr IN 0 TO 9 LOOP																		--Varre TM_Buffer
							ReadWriteSet(3) := MemBuffer(Addr)(15 DOWNTO 14);
							ReadWriteSet(2) := MemBuffer(Addr)(13 DOWNTO 12);
							ReadWriteSet(1) := MemBuffer(Addr)(11 DOWNTO 10);
							ReadWriteSet(0) := MemBuffer(Addr)(9 DOWNTO 8);
							IF ((ReadWriteSet(Proc)(0) OR ReadWriteSet(Proc)(1)) = '1') THEN					--Se endereço do TM_Buffer tem RW do procesador retornado true
								ReadWriteSet(Proc) := "00";
								FOR P IN 0 TO 3 LOOP
									ProcFlag := ReadWriteSet(P)(0) OR ReadWriteSet(P)(1) OR ProcFlag;		--Verifica se endereço é usado por outro processador
								END LOOP;
								IF (ProcFlag = '0') THEN
									MemBuffer(Addr)(24) <= '0';
								END IF;
								ProcFlag := '0';
								MemBuffer(Addr)(15 DOWNTO 14) <= ReadWriteSet(3);
								MemBuffer(Addr)(13 DOWNTO 12) <= ReadWriteSet(2);
								MemBuffer(Addr)(11 DOWNTO 10) <= ReadWriteSet(1);
								MemBuffer(Addr)(9 DOWNTO 8) <= ReadWriteSet(0);
							END IF;
						END LOOP;
						ConfBufMode <= "00";																				--Remove flag de Internal Conflict do Conflict_Buffer
						--ConfBufTrID <= Proc;
						ConfBufTrID <= STD_LOGIC_VECTOR(TO_UNSIGNED(Proc, ConfBufTrID'length));
						ConfBufMode <= "10";
					END IF;
					
					--Remove tudo da fila na sequencia de abort?
					
					IF (CUStatus /= "100") THEN								--Para de varrer se CU já voltou pro idle
						EXIT;
					END IF;
				END LOOP;
			
			ELSIF (CUStatus = "100") THEN										--Se status é Commit
				ConfBufTrID <= ProcID;
				IF (ConfBufStatus(0) = '1') THEN					--AQUI que acho que deveria ir deassert da flag externa
					BuffStatus <= "100";
				ELSE
					BuffStatus <= "011";
				END IF;
			
			ELSIF (CUStatus = "101") THEN										--Se Status é MemUpdate
				IF (QueueStatus /= "01") THEN									--Se fila não vazia faz pull da FIFO
					QueueModeTemp := "10";
					QueueModeTemp := "00";
					--while(QueueUpdated /= 0) - ou algo assim pra garantir só depois de atualizar?
					UpdateAddress := QueueReturn;
					--Aqui também deve dar problema, pq o modo só altera no clock, então oq tá retornando de QueueReturn não é oq se deseja
					--Não só o modo, mas retorno da saída é alterado no puslo de clock também
					
					FOR Addr IN 0 TO 9 LOOP
						IF MemBuffer(Addr)(23 DOWNTO 16) = UpdateAddress THEN
							MemoryAddr <= UpdateAddress;								--Atualiza na Memória Principal
							MemoryData <= MemBuffer(Addr)(7 DOWNTO 0);
							--Talvez alguma entrada de comunicação, pra dizer se é Fetch ou Post
						
							ReadWriteSet(3) := MemBuffer(Addr)(15 DOWNTO 14);	--Remove/Limpa Buffer depois de atualizado na Memória Principal
							ReadWriteSet(2) := MemBuffer(Addr)(13 DOWNTO 12);
							ReadWriteSet(1) := MemBuffer(Addr)(11 DOWNTO 10);
							ReadWriteSet(0) := MemBuffer(Addr)(9 DOWNTO 8);
							ReadWriteSet(TransactionIDint) := "00";
							FOR P IN 0 TO 3 LOOP
								ProcFlag := ReadWriteSet(P)(0) OR ReadWriteSet(P)(1) OR ProcFlag;
							END LOOP;
							IF (ProcFlag = '0') THEN
								MemBuffer(Addr)(24) <= '0';
							END IF;
							ProcFlag := '0';
							MemBuffer(Addr)(15 DOWNTO 14) <= ReadWriteSet(3);
							MemBuffer(Addr)(13 DOWNTO 12) <= ReadWriteSet(2);
							MemBuffer(Addr)(11 DOWNTO 10) <= ReadWriteSet(1);
							MemBuffer(Addr)(9 DOWNTO 8) <= ReadWriteSet(0);
						END IF;
					END LOOP;
					
				ELSE																			--Se a FIFO está vazia o processo é finalizado e retorna Commit Succes
					BuffStatus <= "101";

					ConfBufMode <= "00";													--Deassert da Conflict Flag Externa		--Na verdade agora eu to em dúvida, acho que não seria aqui, por mais que seja oq o artigo parece indicar. Eu acho que fazer o deassert deve ser após o commit fail
					ConfBufTrID <= TransactionID;
					ConfBufMode <= "11";
				END IF;
			
			END IF;
			
			QueueMode <= QueueModeTemp;
			
		END IF;
		
	END PROCESS;
	
END SharedData;