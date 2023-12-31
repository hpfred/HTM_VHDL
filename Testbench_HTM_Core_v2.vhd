LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Testbench_HTM_Core IS
	
END ENTITY Testbench_HTM_Core;	
			
		
ARCHITECTURE  TEST OF Testbench_HTM_Core IS
SIGNAL Clock: STD_LOGIC := '0';
SIGNAL Reset: STD_LOGIC := '1';

SIGNAL Action, ProcID, TransactionID, ID: STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL TransactionStatus: STD_LOGIC_VECTOR (2 DOWNTO 0);
SIGNAL MemAddress, Data: STD_LOGIC_VECTOR (7 DOWNTO 0);

COMPONENT HTM_Core IS
 PORT
	(
		Action:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--00: Undefined, 01: Read, 10: Write, 11: Commit
		MemAddress:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);				--Endereço (8 bits)
		Data:						IN STD_LOGIC_VECTOR (7 DOWNTO 0);				--Dado (8 bits)
		ProcID:					IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--4 Processadores
		TransactionID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);				--4 Transações
		TransactionStatus:	OUT STD_LOGIC_VECTOR (2 DOWNTO 0);				--000: Undefined, 001: Hit, 010: Miss, 011: NotAbort, 100: CommitFail, 101: CommitSuccess
		Reset:					IN STD_LOGIC;
		Clock:					IN STD_LOGIC
	);
	
END COMPONENT;
BEGIN
	Clock <= NOT Clock AFTER 5 ns;
	PROCESS
	BEGIN
		WAIT UNTIL Clock'EVENT AND Clock = '0' ;
		Reset <= '0';
		
		Action <= "01";
		--Action <= "10";
		MemAddress <= "00000001";
		Data <= "00000001";
		ID <= "01";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		--Wait Until TransactionStatus is Hit or Miss (?)
		
		Action <= "10";
		MemAddress <= "00000001";
		Data <= "11111111";
		ID <= "10";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		
		Action <= "11";
		MemAddress <= "00000001";--
		Data <= "00000001";--
		ID <= "01";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		
		Action <= "11";
		MemAddress <= "00000001";--
		Data <= "00000001";--
		ID <= "10";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		
		Action <= "00";
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		WAIT UNTIL Clock'EVENT AND Clock = '1' ;
		
	END PROCESS;
	
	ProcID <= ID;
	TransactionID <= ID;
	Core: HTM_Core PORT MAP (Action,MemAddress,Data,ProcID,TransactionID,TransactionStatus,Reset,Clock);
	
END TEST;

--WAIT UNTIL Clock'EVENT AND Clock = '1' ;
--Action <= "XX";
--MemAddress <= "XXXXXXXX";
--Data <= "XXXXXXXX";
--ProcID <= "XX";
--TransactionID <= "XX";
---OUT TransactionStatus;

--Numero de Clocks necessarios para cada ação:
--Read	> 2 ou 3?
--			> wait until TStat = ...
--Write	> 2 ou 3?
--			> wait until TStat = ...
--Abort	> Depende quantos aborts (e se eu mudar o buffer)
--			> wait until TStat = ...
--Commit > Depende ainda mais de diversos fatores
--			> wait until TStat = ...


--Pra fazer o Testbench era uma boa ideia ter uma forma padronizada de como os valores vão ser enviados
--Uma primeira coisa que seria boa é fazer um código falso/teórico de C, e quais as instruções que o compilador geraria e enviaria pro HTM_Core
--Junto com isso também separar essas instruções de cada processador, pra eu poder saber quais vão estar vindo concorrentemente e "fora de ordem"
--E idealmente eu fazer algum código pra automatizar isso pra gerar os vários testes
--Bonus/Ideal também é eu fazer esse código automatizado gerar as saídas de Status que se espera pra fazer o teste e comparação