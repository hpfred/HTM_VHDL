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
				-- 																	| Addres
				-- 																	Valid

ARCHITECTURE  SharedData OF TM_Buffer IS
TYPE ALL_DATA IS ARRAY (X DOWNTO 0, 25 DOWNTO 0) OF STD_LOGIC;
SIGNAL Mem: ALL_DATA; --:= ("000000000000", "000000111111", "101010101010", "010101010100", "111111111111", "111111000000", "111001100110");

BEGIN
	

END SharedData;