LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Address_Queue IS
	PORT
	(
		Mode: IN STD_LOGIC_VECTOR (1 DOWNTO 0);		--00: Idle, 01: Push, 10: Pull
		Addr:	IN STD_LOGIC_VECTOR (7 DOWNTO 0);		--Endereço de 8 bits
		TrID:	IN STD_LOGIC_VECTOR (3 DOWNTO 0);		--Limite de 16 transações
		
		Ret:	OUT STD_LOGIC_VECTOR (7 DOWNTO 0);		--Retorna endereço, logo mesmo tamanho
		
		Clock:	IN STD_LOGIC
	);
END ENTITY Address_Queue;

ARCHITECTURE  Queue OF Address_Queue IS
TYPE TRANS_ADDR_MEM IS ARRAY (X DOWNTO 0) OF STD_LOGIC;		--Limite de X endereços para cada transação
TYPE ALL_DATA IS ARRAY (3 DOWNTO 0) OF TRANS_ADDR_MEM;
SIGNAL MemStorage: ALL_DATA;

COMPONENT Control_Unit IS
	PORT
	(
		Action:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		MemAddress:		IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Data:				IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ProcID:			IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		TransactionID:	IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		
		TransactionStatus:	OUT STD_LOGIC_VECTOR (X DOWNTO 0);
		
		Clock:	IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	Control: Control_Unit PORT MAP (
											  Action=>
											  );

	--Se Push coloca ADDR no próximo espaço disponível do array TrID da Memória
	--Se Pull coloca o primeiro valor do array TrID da Memória no Ret, e avança uma posição todos valores desse array (sobresecrevendo esse primeiro salvo no Ret - porém cuidar pra quando fazer isso n acabar fazendo Ret receber um fio conectando o valor do Array, de forma que quando remove ele o Ret fica errado)
	

END Queue;