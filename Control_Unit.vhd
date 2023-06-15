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
		TransactionID	IN STD_LOGIC_VECTOR (3 DOWNTO 0);	--Limite de 16 transações (4 por processador parece um limite válido)
		
		TransactionStatus:	OUT STD_LOGIC_VECTOR (X DOWNTO 0);		--X status do HTM_Core que informam o processador e/ou outros módulos(?)
																						--(OnRead, OnWrite, OnAbort, OnCommit, CommitFail, CommitSucc)?
		
		Reset:	IN STD_LOGIC;		--Não sei se precisa de Reset nesse use-case pra ser honesto
		Clock:	IN STD_LOGIC
	);
END ENTITY Control_Unit;	
			
		
ARCHITECTURE  Controle OF Control_Unit IS
TYPE STATE_TYPE IS (IdleState, ReadState, WriteState, AbortState, CommitState, MemoryUpdateState);
SIGNAL CurrStateIs, NextStateIs: STATE_TYPE;

BEGIN

	PROCESS (Reset, Clock)
	BEGIN
		IF (Reset = '1') THEN
			CurrStateIs <= IdleState;
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			CurrStateIs <= NextStateIs;
		--Tenho que verificar: O Case precisa estar dentro desse IF?
		
			CASE estado_atual IS
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
				
				-- TM_Buffer é um array de vetores de estrutura tipo: 0 00000000 [00 00 00 00] 00000000
				-- 																	| |			|				 |
				-- 																	| |			|				 Data
				-- 																	| |			Read_Write (Fixo somente 4 processadores)
				-- 																	| Addres
				-- 																	Valid
				
				WHEN ReadState =>
					-- Envia dados pro TM_Buffer
					-- No TM_Buffer compara endereço com todos endereços salvos
					
				--Verifica se endereço já existe no TM buffer
				--Se não existe procura primeiro array com valid flag zerado e preenche
				--Se sim ele atualiza os valores
				--Ao acontecer um 'cache' hit (já existe), ele precisa verificar conflito
				
				WHEN WriteState =>
				
				WHEN AbortState =>
				
				WHEN CommitState =>
				
				WHEN MemoryUpdateState =>
				
			END CASE;
		END IF;
	END PROCESS;

END Controle;