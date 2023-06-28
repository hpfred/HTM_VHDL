LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Control_Unit IS
	PORT
	(
		Action:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Undefined, 01: Read, 10: Write, 11: Commit
		Abort:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Non Abort, 01: Internal Abort, 10: External Abort, 11: Error
		
		BuffStatus:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Undefined, 01: Hit, 10: Miss, 11: Abort
		CUStatus:	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--000: OnIdle, 001: OnRead, 010: OnWrite, 011: OnAbort, 100: OnCommit, 101: OnUpdate
		
		Clock:		IN STD_LOGIC
	);
END ENTITY Control_Unit;	
			
		
ARCHITECTURE  Controle OF Control_Unit IS
TYPE STATE_TYPE IS (IdleState, ReadState, WriteState, AbortState, CommitState, MemoryUpdateState);
SIGNAL CurrStateIs, NextStateIs: STATE_TYPE;

BEGIN

	PROCESS (Clock, Reset)
	BEGIN
		IF (Reset = '1') THEN
			--Adicionar de volta um sinal de reset --Adicionar agora o comportamento do reset
		
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			CurrStateIs <= NextStateIs;
		
			CASE CurrStateIs IS
				WHEN IdleState =>
					CUStatus <= '000';
					
					IF (Abort = '01') THEN	--AbortCmd
						NextStateIs <= AbortState;
					ELSIF (Action = '01') THEN	--ReadCmd
						NextStateIs <= ReadState;
					ELSIF (Action = '10') THEN	--WriteCmd
						NextStateIs <= WriteState;
					ELSIF (Action = '11') THEN	--CommitCmd
						NextStateIs <= CommitState;
					END IF;
				
				WHEN ReadState =>
					CUStatus <= '001';
					IF (BuffStatus = '01' OR BuffStatus = '10') THEN
						NextStateIs <= IdleState;
					END IF;
				
				WHEN WriteState =>
					CUStatus <= '010';
					IF (BuffStatus = '01' OR BuffStatus = '10') THEN
						NextStateIs <= IdleState;
					END IF;
				
				WHEN AbortState =>
					CUStatus <= '011';
					--Informa o TM Buffer que está em status de abort, e o endereço de memória
					--No TM buffer ele vai consultar o conflict buffer daquele endereço quais processadores estão em conflito e executar a sequencia de abort (limpando/atualizando o buffer)
					--Ao fim retorna ao Idle State
					IF (Abort = '00') THEN
						NextStateIs <= IdleState;
					END IF;
				
				WHEN CommitState =>
					CUStatus <= '100';
					--Verifica no Conflict Buffer o status de abort do processador
					--Eu to agora é voltando um pouco a questionar a diferenciação da transações e processadores nessa implementação, mas vou ver melhor mais tarde, quando tudo estiver mais avançado
					--Abort false >> MemoryUpdateState
					--Abort true >> Idle & CommitFail
					IF (BuffStatus = '10') THEN
						NextStateIs <= IdleState;
					ELSE
						NextStateIs <= MemoryUpdateState;
					END IF;
				
				WHEN MemoryUpdateState =>
					CUStatus <= '101';
					--Informa o TM buffer que está em status de atualizar, e passa qual a transação
					--No TM buffer ele vai chamando da fila (da transação especifica) um por um, achando o endereço retornado no buffer e passando o dado guardado à memória principal
					--e simultaneamente limpando/atualizando o buffer
					--E no fim ele retorna um Status de Commit bem sucedido
					
					--IF (QueueStatus = [Commit]) THEN
					--END IF;
				
			END CASE;
		END IF;
	END PROCESS;

END Controle;