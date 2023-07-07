-- TM_Buffer é um array de vetores de estrutura tipo: 0 00000000 [00 00 00 00] 00000000
-- 																	| |			|				 |
-- 																	| |			|				 Data [7 DOWNTO 0]
-- 																	| |			Read_Write [15 DOWNTO 8]
-- 																	| Address [23 DOWNTO 16]
-- 																	Valid [24]

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

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

SIGNAL ProcID: STD_LOGIC_VECTOR (1 DOWNTO 0);

BEGIN

	PROCESS (Reset, Clock)
		VARIABLE ReadWriteSet: RW_SET;
		VARIABLE FrstNonValid: INTEGER := 2147483647;
		VARIABLE CurrAddr: INTEGER;
		VARIABLE HitFlag, AbortFlag, ProcFlag: STD_LOGIC := '0';
		VARIABLE UpdateAddress: STD_LOGIC_VECTOR (7 DOWNTO 0);
	BEGIN
		IF (Reset = '1') THEN
			--TODO: Inicializa tudo zerado
			--reset : std_logic_vector(N downto 0) <= (others => '0')
			
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			--Zera BuffStatus no inicio de cada execução?
		
			IF (CUStatus = "001" OR CUStatus = "010") THEN				--Se Status é Read ou Write
				ConfBufTrID <= TransactionID;
				IF (ConfBufStatus = '0') THEN									--Verifica com Conflict_Buffer se é transação zumbi
					FOR CurrAddr IN (0 TO 9) LOOP
						IF (MemBuffer(i, 24) = '0' AND FrstNonValid > CurrAddr) THEN
							FrstNonValid := CurrAddr;
							HitFlag := '0';
						END IF;
						
						IF (MemBuffer(i, (23 DOWNTO 16)) = MemAddress) THEN
							HitFlag := '1';
							EXIT;
						END IF;
					END LOOP;
					--TODO: Caso de MISS por Overflow
					--IF (CurrAddr = 9) THEN OVERFLOW.MISS
					
					IF (HitFlag = '0') THEN										--Buffer Miss
						MemBuffer(CurrAddr, 24) <= '1';
						MemBuffer(CurrAddr, 23 DOWNTO 16) <= MemAddress;
						
						ReadWriteSet := MemBuffer(CurrAddr, 15 DOWNTO 8);
						IF (CUStatus = "001") THEN
							ReadWriteSet(ProcID, 0) := '1';
						ELSIF (CUStatus = "010") THEN
							ReadWriteSet(ProcID, 1) := '1';
						END IF;
						MemBuffer(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
						MemBuffer(CurrAddr, 7 DOWNTO 0) <= Data;
						
						QueueMode <= "01";										--Guarda na fila --Adicionar IF só pra fazer nos Writes?
						QueueMode <= "00";
							
					ELSE																--Buffer Hit
						ReadWriteSet := MemBuffer(CurrAddr, 15 DOWNTO 8);
						
						IF (CUStatus = "001") THEN								--Read
							FOR i IN (0 TO 3) LOOP
								IF (ReadWriteSet(i,1) = '1' AND ProcID /= i) THEN
									ConfBufMode <= "00";
									ConfBufTrID <= ProcID;
									ConfBufMode <= "01";
									AbortFlag := '1';
								END IF;
							END LOOP;
							
							IF (AbortFlag = '0') THEN
								ReadWriteSet := MemBuffer(CurrAddr, 15 DOWNTO 8);
								IF (CUStatus = "001") THEN
									ReadWriteSet(ProcID, 0) := '1';
								ELSIF (CUStatus = "010") THEN
									ReadWriteSet(ProcID, 1) := '1';
								END IF;
								MemBuffer(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
								
							END IF;
							AbortFlag := '0';
							
						ELSIF (CUStatus = "010") THEN							--Write
							FOR i IN (0 TO 3) LOOP
								IF (ReadWriteSet(i) /= "00" AND ProcID /= i) THEN
									ConfBufMode <= "00";
									ConfBufTrID <= i;
									ConfBufMode <= "01";
								END IF;
							END LOOP;
							
							ReadWriteSet := MemBuffer(CurrAddr, 15 DOWNTO 8);
							IF (CUStatus = "001") THEN
								ReadWriteSet(ProcID, 0) := '1';
							ELSIF (CUStatus = "010") THEN
								ReadWriteSet(ProcID, 1) := '1';
							END IF;
							MemBuffer(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
							MemBuffer(CurrAddr, 7 DOWNTO 0) <= Data;
							
							QueueMode <= "01";									--Guarda na fila
							QueueMode <= "00";
							
						END IF;
					END IF;
				END IF;
				
			ELSIF (CUStatus = "011") THEN										--Se Status é abort
				FOR Proc IN (0 TO 3) LOOP																				--Varre Conflict_Buffer
					ConfBufTrID <= Proc;
					IF (ConfBufStatus(1) = '1') THEN																--Se Proc está com Internal Abort
						FOR Addr IN (0 TO 9) LOOP																		--Varre TM_Buffer
							ReadWriteSet := MemBuffer(Addr, 15 DOWNTO 8);
							IF ((ReadWriteSet(Proc,0) OR ReadWriteSet(Proc,1)) = '1') THEN					--Se endereço do TM_Buffer tem RW do procesador retornado true
								ReadWriteSet(Proc) := "00";
								FOR P IN (0 TO 3) LOOP
									ProcFlag := ReadWriteSet(P,0) OR ReadWriteSet(P,1) OR ProcFlag;		--Verifica se endereço é usado por outro processador
								END LOOP;
								IF (ProcFlag = '0') THEN
									MemBuffer(Addr, 24) <= '0';
								END IF;
								ProcFlag := '0';
								MemBuffer(Addr, 15 DOWNTO 8) <= ReadWriteSet;
							END IF;
						END LOOP;
						ConfBufMode <= "00";																				--Remove flag de Internal Conflict do Conflict_Buffer
						ConfBufTrID <= Proc;
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
					QueueMode <= "10";
					QueueMode <= "00";
					UpdateAddress <= QueueReturn;
					
					FOR Addr IN (0 TO 9) LOOP
						IF (MemBuffer(Addr, (23 DOWNTO 16)) = UpdateAddress) THEN
							MemoryAddr <= UpdateAddress;								--Atualiza na Memória Principal
							MemoryData <= MemBuffer(Addr, (7 DOWNTO 0));
							--Talvez alguma entrada de comunicação, pra dizer se é Fetch ou Post
						
							ReadWriteSet := MemBuffer(Addr, 15 DOWNTO 8);		--Remove/Limpa Buffer depois de atualizado na Memória Principal
							ReadWriteSet(TransactionID) := "00";
							FOR P IN (0 TO 3) LOOP
								ProcFlag := ReadWriteSet(P,0) OR ReadWriteSet(P,1) OR ProcFlag;
							END LOOP;
							IF (ProcFlag = '0') THEN
								MemBuffer(Addr, 24) <= '0';
							END IF;
							ProcFlag := '0';
							MemBuffer(Addr, 15 DOWNTO 8) <= ReadWriteSet;
						END IF;
					END LOOP;
					
				ELSE																			--Se a FIFO está vazia o processo é finalizado e retorna Commit Succes
					BuffStatus <= "101";

					ConfBufMode <= "00";													--Deassert da Conflict Flag Externa		--Na verdade agora eu to em dúvida, acho que não seria aqui, por mais que seja oq o artigo parece indicar. Eu acho que fazer o deassert deve ser após o commit fail
					ConfBufTrID <= TransactionID;
					ConfBufMode <= "11";
				END IF;
			
			END IF;
			
		END IF;
		
	END PROCESS;
	
END SharedData;