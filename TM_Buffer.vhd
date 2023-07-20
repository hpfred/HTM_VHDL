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
		CBProcStatus:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		
		QueueMode:		OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		QueueStatus:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		QueueReturn:	IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		
		MemoryAddr:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		MemoryData:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		
		BuffStatus:		OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--000: Undefined, 001: Hit, 010: Miss, 011: NotAbort, 100: CommitFail, 101: CommitSuccess,.. 110: NoInternalAborts	--Talvez reordenar a numeração, mas vejo isso depois (pouco importante)
		Reset:			IN STD_LOGIC;
		Clock:			IN STD_LOGIC
	);
END ENTITY TM_Buffer;

ARCHITECTURE  SharedData OF TM_Buffer IS
TYPE RW_SET IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
TYPE ALL_DATA IS ARRAY (9 DOWNTO 0) OF STD_LOGIC_VECTOR (24 DOWNTO 0);
SIGNAL MemBuffer: ALL_DATA;

BEGIN

	PROCESS (Reset, Clock)
		VARIABLE ReadWriteSet: RW_SET;
		VARIABLE FrstNonValid: INTEGER := 2147483647;
		VARIABLE CurrAddr: INTEGER := 0;
		VARIABLE HitFlag, AbortFlag, ProcFlag: STD_LOGIC := '0';
		VARIABLE UpdateAddress: STD_LOGIC_VECTOR (7 DOWNTO 0);
		VARIABLE QueueModeTemp: STD_LOGIC_VECTOR (1 DOWNTO 0);
		
		VARIABLE ProcIDint: INTEGER := 0;
		VARIABLE TransactionIDint: INTEGER := 0;
		
		VARIABLE FSMClockCount: INTEGER := 0;
		VARIABLE TempBuffEntry: STD_LOGIC_VECTOR (24 DOWNTO 0);
		VARIABLE BuffStatusTemp: STD_LOGIC_VECTOR (2 DOWNTO 0);
		VARIABLE ConfBufModeTemp: STD_LOGIC_VECTOR (1 DOWNTO 0);
		VARIABLE ProcStatus: INTEGER := 7;
		VARIABLE AddrTemp: INTEGER := 0;
	BEGIN
		IF (Reset = '1') THEN
			MemBuffer <= (others=>(Others=>'0'));
			--
			BuffStatus <= (others => '0');
			BuffStatusTemp := (others => '0');
			ConfBufMode <= (others => '0');
			ConfBufModeTemp := (others => '0');
			ConfBufTrID <= (others => '0');
			QueueMode <= (others => '0');
			QueueModeTemp := (others => '0');
			MemoryAddr <= (others => '0');
			MemoryData <= (others => '0');
			FSMClockCount := 0;
			ProcStatus := 7;
			AddrTemp := 0;
			
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			QueueModeTemp := "00";
			BuffStatusTemp := "000";
			ConfBufModeTemp := "00";
			ProcIDint := TO_INTEGER(UNSIGNED(ProcID));
			TransactionIDint := TO_INTEGER(UNSIGNED(TransactionID));
			
			---------------------------------------------------------------------------------------------------------------
			IF (CUStatus = "000") THEN												--Se Status é Idle
				FSMClockCount := 0;
				
			---------------------------------------------------------------------------------------------------------------
			ELSIF (CUStatus = "001" OR CUStatus = "010") THEN				--Se Status é Read ou Write
				IF (FSMClockCount = 0) THEN
					ConfBufTrID <= TransactionID;
					FSMClockCount := FSMClockCount + 1;
					FrstNonValid := 2147483647;
					
					--QueueModeTemp := "01";
					
					FOR CurrAddr IN 0 TO 9 LOOP	--'length-1
						IF (MemBuffer(CurrAddr)(24) = '0' AND FrstNonValid > CurrAddr) THEN
							FrstNonValid := CurrAddr;
						END IF;
						
						IF (MemBuffer(CurrAddr)(23 DOWNTO 16) = MemAddress AND (MemBuffer(CurrAddr)(24) = '1')) THEN
							HitFlag := '1';
							EXIT;
						ELSIF (CurrAddr = 9) THEN
							CurrAddr := FrstNonValid;
							HitFlag := '0';
							EXIT;
						END IF;						
					END LOOP;
					--TODO: Caso de MISS por Overflow
					--ASSERT (CurrAddr < 9 OR HitFlag = '1') REPORT "Erro : Overflow Miss";
					ASSERT (CurrAddr > 9) REPORT "Erro : Overflow Miss";
						
					ReadWriteSet(3) := MemBuffer(CurrAddr)(15 DOWNTO 14);
					ReadWriteSet(2) := MemBuffer(CurrAddr)(13 DOWNTO 12);
					ReadWriteSet(1) := MemBuffer(CurrAddr)(11 DOWNTO 10);
					ReadWriteSet(0) := MemBuffer(CurrAddr)(9 DOWNTO 8);
					TempBuffEntry := MemBuffer(CurrAddr);
					
					IF (HitFlag = '0') THEN										--Buffer Miss
						BuffStatusTemp := "010";
						QueueModeTemp := "01";
						
						TempBuffEntry(24) := '1';
						TempBuffEntry(23 DOWNTO 16) := MemAddress;
						TempBuffEntry(7 DOWNTO 0) := Data;
						
						IF (CUStatus = "001") THEN
							ReadWriteSet(ProcIDint)(0) := '1';
						ELSIF CUStatus = "010" THEN
							ReadWriteSet(ProcIDint)(1) := '1';
						END IF;
						TempBuffEntry(15 DOWNTO 14) := ReadWriteSet(3);
						TempBuffEntry(13 DOWNTO 12) := ReadWriteSet(2);
						TempBuffEntry(11 DOWNTO 10) := ReadWriteSet(1);
						TempBuffEntry(9 DOWNTO 8) := ReadWriteSet(0);
							
					ELSE																--Buffer Hit
						BuffStatusTemp := "001";
						
						--Se Hit > Testa se aquele processador já usou aquele endereço, e caso não, então dá push na fila --Assim evita de um endereço aparecer mais de uma vez na fila denecessariamente (?)
						IF (ReadWriteSet(ProcIDint)(0) OR ReadWriteSet(ProcIDint)(1)) = '0' THEN
							QueueModeTemp := "01";
						END IF;
						
						IF (CUStatus = "001") THEN								--Read
							FOR i IN 0 TO 3 LOOP
								IF (ReadWriteSet(i)(1) = '1' AND ProcID /= i) THEN
									ConfBufTrID <= ProcID;
									ConfBufModeTemp := "01";
									AbortFlag := '1';
								END IF;
							END LOOP;
							
							IF (AbortFlag = '0') THEN
								IF (CUStatus = "001") THEN
									ReadWriteSet(ProcIDint)(0) := '1';
								ELSIF (CUStatus = "010") THEN
									ReadWriteSet(ProcIDint)(1) := '1';
								END IF;
								TempBuffEntry(15 DOWNTO 14) := ReadWriteSet(3);
								TempBuffEntry(13 DOWNTO 12) := ReadWriteSet(2);
								TempBuffEntry(11 DOWNTO 10) := ReadWriteSet(1);
								TempBuffEntry(9 DOWNTO 8) := ReadWriteSet(0);
								
							END IF;
							AbortFlag := '0';
							
						ELSIF (CUStatus = "010") THEN							--Write
							FOR i IN 0 TO 3 LOOP
								IF (ReadWriteSet(i) /= "00" AND ProcID /= i) THEN
									ConfBufTrID <= STD_LOGIC_VECTOR(TO_UNSIGNED(i , ConfBufTrID'length));
									ConfBufModeTemp := "01";
								END IF;
							END LOOP;
							
							IF (CUStatus = "001") THEN
								ReadWriteSet(ProcIDint)(0) := '1';
							ELSIF (CUStatus = "010") THEN
								ReadWriteSet(ProcIDint)(1) := '1';
							END IF;
							TempBuffEntry(15 DOWNTO 14) := ReadWriteSet(3);
							TempBuffEntry(13 DOWNTO 12) := ReadWriteSet(2);
							TempBuffEntry(11 DOWNTO 10) := ReadWriteSet(1);
							TempBuffEntry(9 DOWNTO 8) := ReadWriteSet(0);
							TempBuffEntry(7 DOWNTO 0) := Data;
								
						END IF;
					END IF;
				ELSE																	--FSMClockCount > 0
					IF (ConfBufStatus(0) = '0') THEN							--Verifica com Conflict_Buffer se é transação zumbi, e atualiza os dados somente se não for
						MemBuffer(CurrAddr) <= TempBuffEntry;
					END IF;
				END IF;
			
			---------------------------------------------------------------------------------------------------------------	
			ELSIF (CUStatus = "011") THEN										--Se Status é abort
				IF (TO_INTEGER(UNSIGNED(CBProcStatus)) /= ProcStatus) THEN
					ProcStatus := TO_INTEGER(UNSIGNED(CBProcStatus));
					IF (ProcStatus > 3) THEN
						--nenhum conflito
						BuffStatusTemp := "110";
						
					ELSE
						FOR Addr IN 0 TO 9 LOOP																	--Varre TM_Buffer				
							ReadWriteSet(3) := MemBuffer(Addr)(15 DOWNTO 14);
							ReadWriteSet(2) := MemBuffer(Addr)(13 DOWNTO 12);
							ReadWriteSet(1) := MemBuffer(Addr)(11 DOWNTO 10);
							ReadWriteSet(0) := MemBuffer(Addr)(9 DOWNTO 8);
							IF ((ReadWriteSet(ProcStatus)(0) OR ReadWriteSet(ProcStatus)(1)) = '1') THEN					--Se endereço do TM_Buffer tem RW do procesador retornado true
								ReadWriteSet(ProcStatus) := "00";
								ProcFlag := '0';
								FOR P IN 0 TO 3 LOOP
									ProcFlag := ReadWriteSet(P)(0) OR ReadWriteSet(P)(1) OR ProcFlag;		--Verifica se endereço é usado por outro processador
								END LOOP;
								IF (ProcFlag = '0') THEN
									MemBuffer(Addr)(24) <= '0';
								END IF;
								MemBuffer(Addr)(15 DOWNTO 14) <= ReadWriteSet(3);
								MemBuffer(Addr)(13 DOWNTO 12) <= ReadWriteSet(2);
								MemBuffer(Addr)(11 DOWNTO 10) <= ReadWriteSet(1);
								MemBuffer(Addr)(9 DOWNTO 8) <= ReadWriteSet(0);			--Se for atualizar varios endereços em um clock isso provavelmente daria problema, então mudar pra var ou sei lá
							END IF;
						END LOOP;
						ConfBufTrID <= STD_LOGIC_VECTOR(TO_UNSIGNED(ProcStatus, ConfBufTrID'length));
						ConfBufModeTemp := "10";
					END IF;
				END IF;
			
			---------------------------------------------------------------------------------------------------------------
			ELSIF (CUStatus = "100") THEN										--Se status é Commit
				ConfBufTrID <= ProcID;
				
				IF (FSMClockCount < 2) THEN
					FSMClockCount := FSMClockCount + 1;
				ELSIF (FSMClockCount = 2) THEN
					IF (ConfBufStatus(0) = '1') THEN	
						ConfBufModeTemp := "11";
						QueueModeTemp := "11";
						--BuffStatusTemp := "100";
						FSMClockCount := FSMClockCount + 1;
					ELSE
						BuffStatusTemp := "011";
						FSMClockCount := 0;
					END IF;
				ELSE
					BuffStatusTemp := "100";
					FSMClockCount := 0;
				END IF;
			
			---------------------------------------------------------------------------------------------------------------
			ELSIF (CUStatus = "101") THEN										--Se Status é MemUpdate
				IF (FSMClockCount < 3) THEN
					IF (QueueStatus /= "01") THEN								--Se fila não vazia faz pull da FIFO
						QueueModeTemp := "10";
						FSMClockCount := FSMClockCount + 1;
					ELSE																--Se a FIFO está vazia o processo é finalizado e retorna Commit Succes
						IF FSMClockCount = 0 THEN
							BuffStatusTemp := "101";
						END IF;
						FSMClockCount := FSMClockCount + 1;
						
						ConfBufTrID <= TransactionID;
						ConfBufModeTemp := "11";
					END IF;	
					
				ELSE					
					AddrTemp := 0;
					WHILE (AddrTemp < 10) LOOP
						IF MemBuffer(AddrTemp)(23 DOWNTO 16) = QueueReturn THEN
							EXIT;
						END IF;
						AddrTemp := AddrTemp + 1;
					END LOOP;
					ASSERT AddrTemp < 10 REPORT "Erro : Nao deveria ser possivel";
					
					--Atualizar no Read é desnecessário, mas não salva tempo nenhum, então ao menos por enquanto vou deixar assim
					MemoryAddr <= QueueReturn;								--Atualiza na Memória Principal
					MemoryData <= MemBuffer(AddrTemp)(7 DOWNTO 0);
				
					ReadWriteSet(3) := MemBuffer(AddrTemp)(15 DOWNTO 14);	--Remove/Limpa Buffer depois de atualizado na Memória Principal
					ReadWriteSet(2) := MemBuffer(AddrTemp)(13 DOWNTO 12);
					ReadWriteSet(1) := MemBuffer(AddrTemp)(11 DOWNTO 10);
					ReadWriteSet(0) := MemBuffer(AddrTemp)(9 DOWNTO 8);
					ReadWriteSet(TransactionIDint) := "00";
					ProcFlag := '0';
					FOR P IN 0 TO 3 LOOP
						ProcFlag := ReadWriteSet(P)(0) OR ReadWriteSet(P)(1) OR ProcFlag;
					END LOOP;
					IF (ProcFlag = '0') THEN
						MemBuffer(AddrTemp)(24) <= '0';
					END IF;
					MemBuffer(AddrTemp)(15 DOWNTO 14) <= ReadWriteSet(3);
					MemBuffer(AddrTemp)(13 DOWNTO 12) <= ReadWriteSet(2);
					MemBuffer(AddrTemp)(11 DOWNTO 10) <= ReadWriteSet(1);
					MemBuffer(AddrTemp)(9 DOWNTO 8) <= ReadWriteSet(0);
							
					FSMClockCount := 0;
				END IF;
					
			END IF;
			
			QueueMode <= QueueModeTemp;
			BuffStatus <= BuffStatusTemp;
			ConfBufMode <= ConfBufModeTemp;
			
		END IF;
		
	END PROCESS;
	
END SharedData;