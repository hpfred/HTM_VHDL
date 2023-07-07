LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY HTM_Core IS
	PORT
	(
		Action:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--3 ações possíveis de receber do processador (Read, Write, Commit)
		MemAddress:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);				--Endereço de 8 bits (Limite de 256 endereços)
		Data:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);				--8 bits de Dado
		ProcID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--Limite de 4 Cores/Processadores
		TransactionID:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--Limite de 4 transações (1 por processador)
		
		TransactionStatus:	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--6 status do HTM_Core que informam o processador -(OnRead, OnWrite, OnAbort, OnCommit, CommitFail, CommitSucc)? -Talvez seja interessante só o resultado de Commit?
		
		Clock:	IN STD_LOGIC
	);
END ENTITY HTM_Core;	
		
ARCHITECTURE  HTM OF HTM_Core IS
COMPONENT Control_Unit IS
	PORT
	(
		Action:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		MemAddress:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Data:						IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ProcID:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		TransactionID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		TransactionStatus:	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		Reset:					IN STD_LOGIC;
		Clock:					IN STD_LOGIC
	);
END COMPONENT;

COMPONENT TM_Buffer IS
	PORT
	(
		MemAddress:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Data:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ProcID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		TransactionID:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Status:			IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		RetStatus:		OUT STD_LOGIC_VECTOR ();
		Reset:			IN STD_LOGIC;
		Clock:			IN STD_LOGIC
	);

COMPONENT Conflict_Buffer IS
	PORT
	(
		TrID:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Mode:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Status:	OUT STD_LOGIC;
		Clock:	IN STD_LOGIC
	);

COMPONENT Address_Queue IS
	PORT
	(
		Mode: 	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Addr:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		TrID:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Ret:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		Reset:	IN STD_LOGIC;
		Clock:	IN STD_LOGIC
	);

COMPONENT Main_Memory IS
	PORT
	(
	);
END COMPONENT;

BEGIN

		CU: Control_Unit PORT MAP (
									Action=>Action,
									MemAddress=>MemAddress,
									Data=>Data,
									ProcID=>ProcID,
									TransactionID=>TransactionID,
									TransactionStatus=>TransactionStatus,
									Reset=>Reset,
									Clock=>Clock
								);
						
		Buff: TM_Buffer PORT MAP (
								 MemAddress=>MemAddress,
								 Data=>Data,
								 ProcID=>ProcID,
								 TransactionID=>TransactionID,
								 Status=>[X],
								 RetStatus=>[X],
								 Reset=>Reset,
								 Clock=>Clock
							 );
						
		Abort: Conflict_Buffer PORT MAP (
											TrID=>TransactionID,
											Mode=>[X],
											Status=>[X],
											Clock=>Clock
										);
						
		Commit: Address_Queue PORT MAP (
										 Mode=>[X],
										 Addr=>MemAddress,
										 TrID=>TransactionID,
										 Ret=>[X],
										 Reset=>Reset,
										 Clock=>Clock
									 );
						
		Memory: Main_Memory PORT MAP (
									 );

END HTM;