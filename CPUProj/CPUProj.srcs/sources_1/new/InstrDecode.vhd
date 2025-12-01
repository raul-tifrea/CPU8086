----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2025 07:16:05 PM
-- Design Name: 
-- Module Name: InstrDecode - Behavioral
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

entity InstrDecode is
  port (
    clk       : in  std_logic;
    Instr     : in  std_logic_vector(15 downto 0);
    RegWrite  : in  std_logic;
    RegDst    : in  std_logic;
    WriteData : in  std_logic_vector(15 downto 0);
    ExtOp     : in  std_logic;
    ReadData1 : out std_logic_vector(15 downto 0);
    ReadData2 : out std_logic_vector(15 downto 0);
    ExtImm    : out std_logic_vector(15 downto 0)
  );
end InstrDecode;

architecture Behavioral of InstrDecode is
type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);
signal reg_file : reg_array := (others => (others => '0'));

signal write_addr : unsigned(2 downto 0);
signal rs_idx : unsigned(2 downto 0);
signal rt_idx : unsigned(2 downto 0);
signal rd_idx : unsigned(2 downto 0);

begin

rs_idx <= unsigned(Instr(10 downto 8));
rt_idx <= unsigned(Instr(7 downto 5));
rd_idx <= unsigned(Instr(4 downto 2));

 
process(Instr, ExtOp)
begin
if ExtOp = '1' then
    ExtImm <= (15 downto 8 => Instr(7)) & Instr(7 downto 0);
else
    ExtImm <= (15 downto 8 => '0') & Instr(7 downto 0);
end if;
end process;

write_addr <= rt_idx when RegDst = '0' else rd_idx;

process(clk)
begin
    if rising_edge(clk) then
      if RegWrite = '1' then
        reg_file(to_integer(write_addr)) <= WriteData;
      end if;
    end if;
  end process;
  
ReadData1 <= reg_file(to_integer(rs_idx));
ReadData2 <= reg_file(to_integer(rt_idx));

end Behavioral;
