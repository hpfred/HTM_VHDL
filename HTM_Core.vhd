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
		
		TransactionStatus:	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		--6 status do HTM_Core que informam o processador - 000: Undefined, 001: Hit, 010: Miss, 011: NotAbort, 100: CommitFail, 101: CommitSuccess
		HTMCUStatus:			OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		
		Reset:	IN STD_LOGIC;
		Clock:	IN STD_LOGIC
	);
END ENTITY HTM_Core;	
		
ARCHITECTURE  HTM OF HTM_Core IS
COMPONENT Control_Unit IS
	PORT
	(
		Action:				IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		IntAbortStatus:	IN STD_LOGIC;
		BuffStatus:			IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		CUStatus:			OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		Reset:				IN STD_LOGIC;
		Clock:				IN STD_LOGIC
	);
END COMPONENT;

COMPONENT TM_Buffer IS
	PORT
	(
		MemAddress:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Data:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ProcID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		TransactionID:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		CUStatus:		IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		ConfBufMode:	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ConfBufTrID:	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ConfBufStatus:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		CBProcStatus:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		QueueMode:		OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		QueueStatus:	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		QueueReturn:	IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		MemoryAddr:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		MemoryData:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		BuffStatus:		OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		Reset:			IN STD_LOGIC;
		Clock:			IN STD_LOGIC
	);
END COMPONENT;

COMPONENT Conflict_Buffer IS
	PORT
	(
		TrID:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Mode:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Status:				OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ProcStatus:			OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		IntAbortStatus:	OUT STD_LOGIC;
		Reset:				IN STD_LOGIC
	);
END COMPONENT;

COMPONENT Address_Queue IS
	PORT
	(
		Mode: 	IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Addr:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		TrID:		IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		FIFOStatus:	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		Ret:		OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		Reset:	IN STD_LOGIC;
		Clock:	IN STD_LOGIC
	);
END COMPONENT;

COMPONENT Main_Memory IS
	PORT
	(
		Addr:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Data:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Reset:	IN STD_LOGIC;
		Clock:	IN STD_LOGIC
	);
END COMPONENT;

SIGNAL IntAbortStatus: STD_LOGIC;
SIGNAL ConfBufMode, ConfBufTrID, ConfBufStatus: STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL QueueStatus, QueueMode: STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL CUStatus, BuffStatus: STD_LOGIC_VECTOR (2 DOWNTO 0);
SIGNAL QueueReturn, MemoryAddr, MemoryData: STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL CBProcStatus: STD_LOGIC_VECTOR (2 DOWNTO 0);

BEGIN

		TransactionStatus <= BuffStatus;
		HTMCUStatus <= CUStatus;
		
		CU: Control_Unit PORT MAP (
									Action=>Action,
									IntAbortStatus=>IntAbortStatus,
									BuffStatus=>BuffStatus,
									CUStatus=>CUStatus,
									Reset=>Reset,
									Clock=>Clock
								);
						
		Buff: TM_Buffer PORT MAP (
								 MemAddress=>MemAddress,
								 Data=>Data,
								 ProcID=>ProcID,
								 TransactionID=>TransactionID,
								 CUStatus=>CUStatus,
								 ConfBufMode=>ConfBufMode,
								 ConfBufTrID=>ConfBufTrID,
								 ConfBufStatus=>ConfBufStatus,
								 CBProcStatus=>CBProcStatus,
								 QueueMode=>QueueMode,
								 QueueStatus=>QueueStatus,
								 QueueReturn=>QueueReturn,
								 MemoryAddr=>MemoryAddr,
								 MemoryData=>MemoryData,
								 BuffStatus=>BuffStatus,
								 Reset=>Reset,
								 Clock=>Clock
							 );
						
		Abort: Conflict_Buffer PORT MAP (
										  TrID=>ConfBufTrID,
										  Mode=>ConfBufMode,
										  Status=>ConfBufStatus,
										  ProcStatus=>CBProcStatus,
										  IntAbortStatus=>IntAbortStatus,
										  Reset=>Reset
									  );
						
		Commit: Address_Queue PORT MAP (
										 Mode=>QueueMode,
										 Addr=>MemAddress,
										 TrID=>TransactionID,
										 FIFOStatus=>QueueStatus,
										 Ret=>QueueReturn,
										 Reset=>Reset,
										 Clock=>Clock
									 );
						
		Memory: Main_Memory PORT MAP (
									  Addr=>MemoryAddr,
									  Data=>MemoryData,
									  Reset=>Reset,
									  Clock=>Clock
								  );

END HTM;












