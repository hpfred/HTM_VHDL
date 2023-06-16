LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Control_Unit IS
	PORT
	(
		Action:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);	--3 ações possíveis de receber do processador (Read, Write, Commit)
		MemAddress:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);	--Endereço de 8 bits (Limite de 256 endereços)
		Data:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);	--8 bits de Dado
		ProcID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);	--Limite de 4 Cores/Processadores
		TransactionID:	IN STD_LOGIC_VECTOR (3 DOWNTO 0);	--Limite de 16 transações (4 por processador parece um limite válido)
		
		TransactionStatus:	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--6 status do HTM_Core que informam o processador -(OnRead, OnWrite, OnAbort, OnCommit, CommitFail, CommitSucc)? -Talvez seja interessante só o resultado de Commit?
		
		Clock:	IN STD_LOGIC
	);
END ENTITY Control_Unit;	
			
		
ARCHITECTURE  Controle OF Control_Unit IS
TYPE STATE_TYPE IS (IdleState, ReadState, WriteState, AbortState, CommitState, MemoryUpdateState);
SIGNAL CurrStateIs, NextStateIs: STATE_TYPE;

BEGIN

	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
			CurrStateIs <= NextStateIs;
		--Tenho que verificar: O Case precisa estar dentro desse IF? -Problema que posso ter é que ele vai repetir duas vezes, ao invés de só na borda de subida
		
			CASE CurrStateIs IS
				WHEN IdleState =>
					IF (ReadCmd) THEN
						NextStateIs <= ReadState;
					ELSIF (WriteCmd) THEN
						NextStateIs <= WriteState;
					ELSIF (AbortCmd) THEN
						NextStateIs <= AbortState;
					ELSIF (CommitCmd) THEN
						NextStateIs <= CommitState;
					END IF;
				
				WHEN ReadState =>
					--PORT MAP Status Read
					--IF RetStat HIT/MISS >> IdleState
				
				WHEN WriteState =>
					--Mesma coisa que read
				
				WHEN AbortState =>
					--Informa o TM Buffer que está em status de abort, e o endereço de memória
					--No TM buffer ele vai consultar o conflict buffer daquele endereço quais processadores estão em conflito e executar a sequencia de abort (limpando/atualizando o buffer)
					--Ao fim retorna ao Idle State
				
				WHEN CommitState =>
					--Verifica no Conflict Buffer o status de abort do processador
					--Eu to agora é voltando um pouco a questionar a diferenciação da transações e processadores nessa implementação, mas vou ver melhor mais tarde, quando tudo estiver mais avançado
					--Abort false >> MemoryUpdateState
					--Abort true >> Idle & CommitFail
				
				WHEN MemoryUpdateState =>
					--Informa o TM buffer que está em status de atualizar, e passa qual a transação
					--No TM buffer ele vai chamando da fila (da transação especifica) um por um, achando o endereço retornado no buffer e passando o dado guardado à memória principal
					--e simultaneamente limpando/atualizando o buffer
					--E no fim ele retorna um Status de Commit bem sucedido
				
			END CASE;
		END IF;
	END PROCESS;

END Controle;