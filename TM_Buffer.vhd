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
		TransactionID:	IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		Status:			IN STD_LOGIC_VECTOR (2 DOWNTO 0);		--Qual o estado atual da FSM > 000: Idle, 001: Read, 010: Write, 011: Abort, 100: Commit, 101: MemUpdate
		
		RetStatus:		OUT STD_LOGIC_VECTOR (); --Hit ou Miss, Abort?
		
		Clock:	IN STD_LOGIC
	);
END ENTITY TM_Buffer;

--X aqui tá representando o tamanho do buffer (quanto ao numero de endereços de memória diferentes podem ser armazenados nele)
ARCHITECTURE  SharedData OF TM_Buffer IS
TYPE DATA_LINE IS ARRAY (24 DOWNTO 0) OF STD_LOGIC;
TYPE ALL_DATA IS ARRAY (X DOWNTO 0) OF DATA_LINE;
SIGNAL MemStorage: ALL_DATA; --Inicializa tudo zerado

TYPE RW_SET IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL ReadWriteSet: RW_SET;

SIGNAL BufferAddress: STD_LOGIC_VECTOR (X DOWNTO 0);
SIGNAL ProcID: STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL CurrAddr: INTEGER;		--SIGNAL FrstNonValid: INTEGER;
SIGNAL HitFlag: STD_LOGIC;

BEGIN
	--Não sei se acessar endereço do array dessa forma funciona (até já tava assumindo que não), mas to colocando assim pra estruturar a lógica de como vou fazer este módulo
	--E de qualquer forma, essa lógica ainda precisaria ainda ser mudada pq ele só atualiza na memória em uma momento
	MemStorage(BufferAddress, 24) <= ValidFlag;
	MemStorage(BufferAddress, 23 DOWNTO 16) <= Address;
	MemStorage(BufferAddress, 15 DOWNTO 8) <= ReadWriteSet;
	ReadWriteSet(ProcID, 0) <=  ReadFlag;
	ReadWriteSet(ProcID, 1) <=  WriteFlag;
	MemStorage(BufferAddress, 7 DOWNTO 0) <= Data;
	
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
	
	--Y = (X+1)*(X+1)
	PROCESS (Clock)
	BEGIN
		
		IF (Status = "Read" OR Status = "Write") THEN
			--PORT MAP Conflict_Buffer TrID Ret		--Verifica se transação zumbi
			--Esse retorno só vai atualizar no pulso de clock, então preciso ver de mudar o funcionamento
			IF (Ret = '0') THEN		--Queria fazer a lógica inversa, com Ret = 1 dar break, pra não precisar colocar tudo dentro de if e if, mas percebi que não dá (a principio)
				FOR CurrAddr IN (0 TO Y) LOOP		--Percebi que como é vetor ele n quer percorrer até X, ele que percorrer até X²
					--EXIT WHEN (MemStorage(i, 24) = '0');
					IF (MemStorage(i, 24) = '0') THEN
						HitFlag <= '0';
						EXIT;
					END IF;
					
					--Também percebi que o for que identifica o primeiro endereço não válido não pode ser o mesmo que procura o endereço no buffer
					--Pq no caso de conflito, ao limpar uma entry, um valid no meio do buffer pode ser zerado, e todos os endereços que vem depois seriam ignorados
					--A outra solução disso, pra não pesquisar sempre o buffer todo, seria o uso de uma lista encadeada, mas não é o meu foco pra agora ao menos
					
					IF (MemStorage(i, (23 DOWNTO 16)) = MemAddress) THEN
						HitFlag <= '1';
						EXIT;
					END IF;
				END LOOP;
				--IF (CurrAddr = (Y)) THEN OVERFLOW.MISS
				
				IF (HitFlag = '0') THEN		--Storage Miss -Usar buffer ao invés de storage como nome da variavel faria mais sentido talvez
					MemStorage(CurrAddr, 24) <= '1';
					MemStorage(CurrAddr, 23 DOWNTO 16) <= MemAddress;
					MemStorage(CurrAddr, 15 DOWNTO 8) <= ReadWriteSet;
					ReadWriteSet(ProcID, 0) <=  (Status = '010'); --Essa lógica tá errada, ReadWriteSet preciso fazer com que seja as posições especificas daquela linha do buffer
					ReadWriteSet(ProcID, 1) <=  (Status = '011'); --Poderia é adicionar antes disso algo tipo: ReadWriteSet <= MemStorage(CurrAddr, 15 DOWNTO 8)
					MemStorage(CurrAddr, 7 DOWNTO 0) <= Data;
					
				ELSE THEN						--Storage Hit
					--Verifica Conflito
					--Atk: R, Def: R  >>  Atk: Nc, Def: Nc
					--Atk: R, Def: W  >>  Atk: C, Def: Nc
					--Atk: W, Def: R  >>  Atk: Nc, Def: C
					--Atk: W, Def: W  >>  Atk: Nc, Def: C
					
					
				END IF;

				
			END IF;
		END IF;
		
	END PROCESS;
	
END SharedData;