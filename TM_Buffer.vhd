LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY TM_Buffer IS
	PORT
	(
		tipos: IN ;
	);
END ENTITY TM_Buffer;

				-- TM_Buffer é um array de vetores de estrutura tipo: 0 00000000 [00 00 00 00] 00000000
				-- 																	| |			|				 |
				-- 																	| |			|				 Data
				-- 																	| |			Read_Write (Fixo somente 4 processadores)
				-- 																	| Address
				-- 																	Valid

--X aqui tá representando o tamanho do buffer (quanto ao numero de endereços de memória diferentes podem ser armazenados nele)
ARCHITECTURE  SharedData OF TM_Buffer IS
--TYPE ALL_DATA IS ARRAY (X DOWNTO 0, 25 DOWNTO 0) OF STD_LOGIC;
TYPE DATA_LINE IS ARRAY (25 DOWNTO 0) OF STD_LOGIC;
TYPE ALL_DATA IS ARRAY (X DOWNTO 0) OF DATA_LINE;
SIGNAL MemStorage: ALL_DATA; --Inicializa tudo zerado

TYPE RW_SET IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL ReadWriteSet: RW_SET;

SIGNAL BufferAddress: STD_LOGIC_VECTOR (X DOWNTO 0);
SIGNAL ProcID: STD_LOGIC_VECTOR (1 DOWNTO 0); --Integer?

BEGIN
	--Não sei se acessar endereço do array dessa forma funciona (até já tava assumindo que não), mas to colocando assim pra estruturar a lógica de como vou fazer este módulo
	--E de qualquer forma, essa lógica ainda precisaria ainda ser mudada pq ele só atualiza na memória em uma momento
	MemStorage(BufferAddress, 25) <= ValidFlag;
	MemStorage(BufferAddress, 24 DOWNTO 17) <= Address;
	MemStorage(BufferAddress, 16 DOWNTO 9) <= ReadWriteSet;
	ReadWriteSet(ProcID, 0) <=  ReadFlag;
	ReadWriteSet(ProcID, 1) <=  WriteFlag;
	MemStorage(BufferAddress, 8 DOWNTO 0) <= Data;
	
	--Ok, se ele recebe as informações todas aqui oq vai ser feito?
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
	
	--??
	--A fila de endereços guarda os endereços de todas transações, mas ele tem uma fila diferente pra cada transação?
	--Se sim (oq agora estou imaginando q sim, mas o artigo n tava claro, dizia para todas transações mas me parecia q seria a msm fila), isso complica ainda mais a implementação, 
	--pq tenho q definir n só o tamanho arbitrário máximo da fila, também tenho q definir o limite arbitrário de máximo de transações (além dos tamanhos máximos arbitrários que já tive que definir antes como o tamanho máximo do buffer e número máximo de processadores/cores)
	
END SharedData;