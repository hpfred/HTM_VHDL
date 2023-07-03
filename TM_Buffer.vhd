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
	--Forma de basicamente dar um define no X do tamanho do buffer
	--ENTITY regn IS
	--GENERIC ( N	: INTEGER := 16);
	--PORT (	D	: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
 	--	reset, clock	: IN STD_LOGIC;
	--	Q	: OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0) );
	--END regn;

	PORT
	(
		MemAddress:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Data:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ProcID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		TransactionID:	IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		
		CUStatus:		IN STD_LOGIC_VECTOR (2 DOWNTO 0);		--000: Idle, 001: Read, 010: Write, 011: Abort, 100: Commit, 101: MemUpdate
		
		BuffStatus:		OUT STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Undefined, 01: Hit, 10: Miss, 11: Abort
		AbortStatus:	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--00: Non Abort, 01: Internal Abort, 10: External Abort, 11: Error
		--Aborted:			OUT STD_LOGIC_VECTOR (3 DOWNTO 0);		--Assert nos bits equivalentes do ProcID que foi abortado
		
		Clock:	IN STD_LOGIC
	);
END ENTITY TM_Buffer;

ARCHITECTURE  SharedData OF TM_Buffer IS
--TYPE DATA_LINE IS ARRAY (24 DOWNTO 0) OF STD_LOGIC; 
--TYPE ALL_DATA IS ARRAY (X DOWNTO 0) OF DATA_LINE; 
TYPE ALL_DATA IS ARRAY (X DOWNTO 0) OF STD_LOGIC_VECTOR (24 DOWNTO 0);
SIGNAL MemBuffer: ALL_DATA;		--Inicializa tudo zerado

TYPE RW_SET IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
--SIGNAL ReadWriteSet: RW_SET;

SIGNAL BufferAddress: STD_LOGIC_VECTOR (X DOWNTO 0);
SIGNAL ProcID: STD_LOGIC_VECTOR (1 DOWNTO 0);
--SIGNAL FrstNonValid: INTEGER;
--SIGNAL CurrAddr: INTEGER;
--SIGNAL HitFlag, AbortFlag: STD_LOGIC := '0';

BEGIN
	
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
	
	--Y = (X+1)*(X+1)
	PROCESS (Clock)
		VARIABLE ReadWriteSet: RW_SET;
		VARIABLE FrstNonValid: INTEGER := 2147483647;
		VARIABLE CurrAddr: INTEGER;
		VARIABLE HitFlag, AbortFlag: STD_LOGIC := '0';
	BEGIN
		--reset : std_logic_vector(N downto 0) <= (others => '0')
		
		IF (Status = '010' OR Status = '011') THEN		--Se Status é Read ou Write
			--PORT MAP Conflict_Buffer TrID Ret
			--Esse retorno só vai atualizar no pulso de clock, então preciso ver de mudar o funcionamento
			--Uma das soluções que eu poderia fazer é o status retornado n ser somente a flag de conflito, e sim ser o id da transação com o primeiro bit sendo o flag, assim garantindo que a execução só prossiga quando o request for respondido apropriadamente
			IF (Ret = '0') THEN
				FOR CurrAddr IN (0 TO Y) LOOP
					IF (MemBuffer(i, 24) = '0' AND FrstNonValid > CurrAddr) THEN
						FrstNonValid := CurrAddr;
						HitFlag := '0';
					END IF;
					
					IF (MemBuffer(i, (23 DOWNTO 16)) = MemAddress) THEN
						HitFlag := '1';
						EXIT;
					END IF;
				END LOOP;
				--IF (CurrAddr = Y) THEN OVERFLOW.MISS
				--Estou desconsiderando no momento a possibilidade de overflow
				
				IF (HitFlag = '0') THEN		--Buffer Miss
					MemBuffer(CurrAddr, 24) <= '1';
					MemBuffer(CurrAddr, 23 DOWNTO 16) <= MemAddress;
					ReadWriteSet := MemBuffer(CurrAddr, , 15 DOWNTO 8);
					ReadWriteSet(ProcID, 0) :=  (Status = "010");		--Se eu quisesse fazer direto precisaria fazer algo tipo 15-(ProcID*2)		--Repensando eu não acho que isso vai funcionar, mas vou ter que confirmar depois
					ReadWriteSet(ProcID, 1) :=  (Status = '011');		--																	  e	15-(ProcID*2)-1
					MemBuffer(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
					MemBuffer(CurrAddr, 7 DOWNTO 0) <= Data;
					
				ELSE THEN						--Buffer Hit
					--Verifica Conflito
					--Atk: R, Def: R  >>  Atk: Nc, Def: Nc
					--Atk: R, Def: W  >>  Atk: C, Def: Nc
					--Atk: W, Def: R  >>  Atk: Nc, Def: C
					--Atk: W, Def: W  >>  Atk: Nc, Def: C
					
					--Tem que ignorar o RWSet do Processador Atacante
					--Atk 00
					--Def 00 00 00
					ReadWriteSet := MemBuffer(CurrAddr, , 15 DOWNTO 8);
					--Atk = (Status = '010') e (Status = '011')
					--Def = RWSet - RWSet(ProcID)
					
					IF (Status = '010') THEN	--Read
						FOR i IN (0 TO 3) LOOP
							IF (ReadWriteSet(i,1) = '1' AND ProcID /= i) THEN
								--Marca flag de conflito do Processador ProcID
								AbortFlag := '1';
							END IF;
						END LOOP;
						
						IF (AbortFlag = '0') THEN
							--Atualiza no Buffer (e guarda na fila?)
							--Essa parte do RWSet especificamente eu acho que já dava pra ter atualizado antes até, pq vai ser atualizado em todas situações (até no abort dele mesmo, pq dps o AbortState é quem vai esvaziar isso)
							ReadWriteSet := MemBuffer(CurrAddr, , 15 DOWNTO 8);
							ReadWriteSet(ProcID, 0) :=  (Status = '010');
							ReadWriteSet(ProcID, 1) :=  (Status = '011');
							MemBuffer(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
							
							--Guarda na fila?
						END IF;
						--E se aboort flag por 1? O abortflag é atualizado no conflict_Buffer, porém isso pode ser feito dentro do próprio for tbm
						
					ELSIF (Status = '011') THEN	--Write --Aqui poderia ser somente else
						FOR i IN (0 TO 3) LOOP
							IF (ReadWriteSet(i) /= '00' AND ProcID /= i) THEN
								--Marca flag de conflito do Processador i
								AbortFlag := '1';
								--Pode havar o caso de manipular o Conflict_Buffer de mais de um ProcID em um unico clock, então teria que ver o método melhor
								--Se for precisar fazer em clocks diferentes tenho que rever isso
								--Se for tentar em um unico clock oq eu posso fazer é sensitividade por modo, e trocar pra set no inicio e idle ao fim
							END IF;
						END LOOP;
						
						--Atualiza no Buffer (e guarda na fila?)
						ReadWriteSet := MemBuffer(CurrAddr, , 15 DOWNTO 8);
						ReadWriteSet(ProcID, 0) :=  (Status = '010');
						ReadWriteSet(ProcID, 1) :=  (Status = '011');
						MemBuffer(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
						MemBuffer(CurrAddr, 7 DOWNTO 0) <= Data;
						
						--Guarda na fila?
						
					END IF;
				END IF;
			END IF;
			
		ELSIF (CUStatus = '100') THEN		--Se Status é abort
		ELSIF (CUStatus = '101') THEN		--Se Status é MemUpdate
		END IF;
		
	END PROCESS;
	
END SharedData;