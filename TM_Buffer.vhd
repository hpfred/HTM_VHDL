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
		
		BuffStatus:		OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--000: Undefined, 001: Hit, 010: Miss, 011: NotAbort, 100: CommitFail, 101: CommitSuccess
		
		Reset:	IN STD_LOGIC;
		Clock:	IN STD_LOGIC
	);
END ENTITY TM_Buffer;

ARCHITECTURE  SharedData OF TM_Buffer IS
TYPE ALL_DATA IS ARRAY (9 DOWNTO 0) OF STD_LOGIC_VECTOR (24 DOWNTO 0);
SIGNAL MemBuffer: ALL_DATA;

TYPE RW_SET IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);

--SIGNAL BufferAddress: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL ProcID: STD_LOGIC_VECTOR (1 DOWNTO 0);

BEGIN

	PROCESS (Clock)
		VARIABLE ReadWriteSet: RW_SET;
		VARIABLE FrstNonValid: INTEGER := 2147483647;
		VARIABLE CurrAddr: INTEGER;
		VARIABLE HitFlag, AbortFlag: STD_LOGIC := '0';
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
						
						ReadWriteSet := MemBuffer(CurrAddr, , 15 DOWNTO 8);
						IF (CUStatus = "001") THEN
							ReadWriteSet(ProcID, 0) := '1';
						ELSIF (CUStatus = "010") THEN
							ReadWriteSet(ProcID, 1) := '1';
						END IF;
						MemBuffer(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
						MemBuffer(CurrAddr, 7 DOWNTO 0) <= Data;
						
					ELSE THEN														--Buffer Hit
						ReadWriteSet := MemBuffer(CurrAddr, , 15 DOWNTO 8);
						
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
								ReadWriteSet := MemBuffer(CurrAddr, , 15 DOWNTO 8);
								IF (CUStatus = "001") THEN
									ReadWriteSet(ProcID, 0) := '1';
								ELSIF (CUStatus = "010") THEN
									ReadWriteSet(ProcID, 1) := '1';
								END IF;
								MemBuffer(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
								
								--Guarda na fila?
								
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
							
							ReadWriteSet := MemBuffer(CurrAddr, , 15 DOWNTO 8);
							IF (CUStatus = "001") THEN
								ReadWriteSet(ProcID, 0) := '1';
							ELSIF (CUStatus = "010") THEN
								ReadWriteSet(ProcID, 1) := '1';
							END IF;
							MemBuffer(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
							MemBuffer(CurrAddr, 7 DOWNTO 0) <= Data;
							
							--Guarda na fila?
							
						END IF;
					END IF;
				END IF;
				
			ELSIF (CUStatus = "011") THEN										--Se Status é abort
				FOR Proc IN (0 TO 3) LOOP										--Varre Conflict_Buffer
					ConfBufTrID <= Proc;
					IF (ConfBufStatus(1) is '1') THEN						--Se Proc está com Internal Abort
						FOR Addr IN (0 TO 9) LOOP								--Varre TM_Buffer
							IF ((MemBuffer(Addr,Proc,0) OR MemBuffer(Addr,Proc,1)) = '1') THEN		--Se endereço do TM_Buffer tem RW do procesador retornado true
								--Limpa os dados do processador retornado daquele endereço do TM_Buffer
								--Verifica se ele também possui o RW de algum dos outros processadores retornando true
								--Caso não, então limpa os resto dos dados encontrados no endereço
							END IF;
						END LOOP;
						--Remove Internal Conflict do Proc no Conflict_Buffer
					END IF;
					
					--Para de varrer se CU já voltou pro idle (ou seja, garante que já foram todos endereços de Conflict_Buffer com Internal Abort Flag)
					IF (CUStatus /= "100") THEN
						EXIT;
					END IF;
				END LOOP;
			
			ELSIF (CUStatus = "100") THEN										--Se status é Commit
				ConfBufTrID <= ProcID;
				IF (ConfBufStatus(0) = '1') THEN
					BuffStatus <= "100";
				ELSE
					BuffStatus <= "011";
				END IF;
			
			ELSIF (CUStatus = "101") THEN										--Se Status é MemUpdate
				--Processo de MemUpdate
				--Vai fazendo pull de Address_Queue do processo que commitou e passando pro Main_Memory
				--Quando receber retorno de que a FIFO está vazia o processo é finalizado e retorno Commit Succes pra CU
			
			END IF;
			
		END IF;
		
	END PROCESS;
	
END SharedData;

	
	--Ok, se ele recebe as informações todas aqui oq vai ser feito?
-- Tenho que ver de talvez o primeiro passo ser verificar com o Conflict Buffer se a Transação é zumbi
	--Primeiro faz um varrimento do Buffer Address de 0 até o fim, ou até encontrar o primeiro Valid Flag 0
	--Nesse primeiro varrimento ele compara o endereço recebido com os endereços de armazenados, se ele encontrar um caso de igualdade isso será um Hit, se concluir sem Hit será um Miss (posteriormente terei que tratar de causar erro/abort para Miss em memória cheia)
	--No acontecimento de Miss, ele pega o valor onde parou por encontrar Valid Flag 0 e preenche (validflag=1, address=addres, (procid, read or write)=1, data=data)
	--No acontecimento de um Hit ele para o loop e verifica conflito
	--Ele também adicionará na fila de endereços o endereço dessa instrução recebida
	--=> Aqui ele tbm retorna do estado read/write pro estado idle no Controle
	
	--=> E aqui embaixo quando o caso é de conflito verificado ele muda para o estado abort no Controle
	--A lógica atacante x defensor é utilizada para determinar se ele existe, aka identifica se o atacante é write, e se há alguma RW flag com Write habilitado, caso sim a regra determinará se o atacante e ou defensores terão que ser identificados para abort
	-- > Aqui tbm tenho que ver de fazer o Internal Abort e External Abort, acho até q é pq é a forma de informar o Controle pra mudar pro estado Abort
	--Os casos de conflito "chamam" o módulo conflict flag (que é um array de flags), que aramazenará/fará um assert na flag do id da transacao
	--Logo em seguida as flags do processador com conflito são zeradas, e sendo o caso do conflito ser para todos os processadores usando aquele endereço, zera a entry todas (zera a entry na verdade só precisa zerar os flags e o valid flag)
	--Já para o caso de nenhum conflito ser verificado
	
	--=>Quando commit é bem sucedido o TM buffer será acionado de novo
	--Ele irá puxar da fila de endereços e atualizando eles na memória principal (e se ele for o único processador usando aquele endereço ele remove a entry, se não for, somente as flags daquele processador são zeradas)
	--Quando ele tiver informado ao processador a falha do commit tem que lembrar de zerar o indicador externo de abort
	--Ele também irá infromar ao processador o sucesso do commit após ter feito a atualização completa da memória principal
	
	--Uma outra coisa que tá me travando um pouco na lógica é marcar os conflitos das transações que já estavam como leitura, pq não tenho como identificar elas, somente de que processador elas vieram
	--Além da minha confusão de o que é e como é usado o Internal e External Abort Flags no Artigo, mas essa parte pelo menos acredito que consigo resolver do meu jeito (só talvez tendo um comportamento diferente tbm)
	--A lógica que eu to chegando é de que se abortar uma transação do processador aborta todo processador, se depois eu descobrir sempre posso voltar e mudar ou repensar
	
	
	--Verifica Conflito
						--Atk: R, Def: R  >>  Atk: Nc, Def: Nc
						--Atk: R, Def: W  >>  Atk: C, Def: Nc
						--Atk: W, Def: R  >>  Atk: Nc, Def: C
						--Atk: W, Def: W  >>  Atk: Nc, Def: C
						
						--Tem que ignorar o RWSet do Processador Atacante
						--Atk 00
						--Def 00 00 00
						--
						--Atk = (CUStatus = "001") e (CUStatus = "010")
						--Def = RWSet - RWSet(ProcID)