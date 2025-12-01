----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2025 07:17:21 PM
-- Design Name: 
-- Module Name: DataMem - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dataMemory is
  port (
    CLK       : in  std_logic;
    MemWrite  : in  std_logic;
    ALUResIn  : in  std_logic_vector(15 downto 0);
    ReadData2 : in  std_logic_vector(15 downto 0);
    MemData   : out std_logic_vector(15 downto 0);
    ALUResOut : out std_logic_vector(15 downto 0)
  );
end dataMemory;

architecture Behavioral of dataMemory is
  type MEM_type is array(0 to 127) of std_logic_vector(15 downto 0);
  signal MEM : MEM_type := ( others => (others => '0'));
begin
 
  process(CLK)
  begin
    if rising_edge(CLK) then
      if MemWrite = '1' then
          MEM(to_integer(unsigned(ALUResIn))) <= ReadData2;
        end if;
      end if;
  end process;

  
  MemData <= MEM(to_integer(unsigned(ALUResIn))) ;

ALUResOut <= ALUResIn;
end Behavioral;
