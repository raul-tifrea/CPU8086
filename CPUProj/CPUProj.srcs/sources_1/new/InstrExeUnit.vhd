----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2025 07:17:00 PM
-- Design Name: 
-- Module Name: InstrExeUnit - Behavioral
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

entity InstructionExecuteUnit is
  port (
    PCout         : in  std_logic_vector(15 downto 0); 
    RD1           : in  std_logic_vector(15 downto 0); 
    RD2           : in  std_logic_vector(15 downto 0); 
    ExtImm        : in  std_logic_vector(15 downto 0); 
    ALUSrc        : in  std_logic;
    ALUOp         : in  std_logic_vector(3 downto 0); 
    ALURes        : out std_logic_vector(15 downto 0);
    BranchAddress : out std_logic_vector(15 downto 0);
    ZeroSignal    : out std_logic
  );
end InstructionExecuteUnit;

architecture Behavioral of InstructionExecuteUnit is
  signal ALUinput2  : std_logic_vector(15 downto 0);
  signal ALUresult_i: std_logic_vector(15 downto 0);
begin


ALUinput2 <= ExtImm when ALUSrc = '1' else RD2;


process(RD1, ALUinput2, ALUOp)
 begin
  case ALUOp is

      when "0000" => -- ADD
        ALUresult_i <= std_logic_vector(unsigned(RD1) + unsigned(ALUinput2));

      when "0001" => -- SUB
        ALUresult_i <= std_logic_vector(unsigned(RD1) - unsigned(ALUinput2));

      when "0010" => -- AND
        ALUresult_i <= RD1 and ALUinput2;

      when "0011" => -- OR
        ALUresult_i <= RD1 or ALUinput2;

      when "0100" => -- XOR
        ALUresult_i <= RD1 xor ALUinput2;

      when "0110" => -- SLL )
        ALUresult_i <= std_logic_vector(shift_left(unsigned(RD1), 1));

      when "0111" => -- SRL 
        ALUresult_i <= std_logic_vector(shift_right(unsigned(RD1), 1));

      when "1000" => -- MOV
        ALUresult_i <= ALUinput2;

      when "1001" => -- INC
        ALUresult_i <= std_logic_vector(unsigned(RD1) + 1);

      when "1010" => -- DEC
        ALUresult_i <= std_logic_vector(unsigned(RD1) - 1);

      when "1011" => -- NOT
        ALUresult_i <= not RD1;

      when others =>
        ALUresult_i <= (others => '0');

  end case;
end process;

ZeroSignal <= '1' when ALUresult_i = x"0000" else '0';
BranchAddress <= std_logic_vector(unsigned(PCout) + unsigned(ExtImm));
ALURes <= ALUresult_i;

end Behavioral;
