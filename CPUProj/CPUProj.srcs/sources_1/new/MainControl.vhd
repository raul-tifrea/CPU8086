----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2025 07:17:43 PM
-- Design Name: 
-- Module Name: MainControl - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MainControl is
  port (
    Instr    : in  std_logic_vector(4 downto 0); 
    RegWrite : out std_logic;
    RegDst   : out std_logic;
    ExtOp    : out std_logic;
    Jump     : out std_logic;
    Branch   : out std_logic;
    MemWrite : out std_logic;
    MemToReg : out std_logic;
    ALUSrc   : out std_logic;
    ALUOp    : out std_logic_vector(3 downto 0) 
  );
end MainControl;

architecture Behavioral of MainControl is
begin
  process(Instr)
  begin
    
    RegWrite <= '0';
    RegDst   <= '0';
    ExtOp    <= '0';
    Jump     <= '0';
    Branch   <= '0';
    MemWrite <= '0';
    MemToReg <= '0';
    ALUSrc   <= '0';
    ALUOp    <= "0000";

    case Instr is
      when "00000" =>  -- ADD
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "0000";

      when "00001" =>  -- SUB
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "0001";

      when "00010" =>  -- AND
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "0010";

      when "00011" =>  -- OR
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "0011";

      when "00100" =>  -- XOR
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "0100";

    

      when "00101" =>  -- ADDI
        RegWrite <= '1';
        ALUSrc   <= '1';
        ExtOp    <= '1';
        ALUOp    <= "0000";

      when "00110" =>  -- SUBI
        RegWrite <= '1';
        ALUSrc   <= '1';
        ExtOp    <= '1';
        ALUOp    <= "0001";

      when "00111" =>  -- ANDI
        RegWrite <= '1';
        ALUSrc   <= '1';
        ALUOp    <= "0010";

      when "01000" =>  -- ORI
        RegWrite <= '1';
        ALUSrc   <= '1';
        ALUOp    <= "0011";

     

      when "01001" =>  -- LOAD (LW)
        RegWrite <= '1';
        ALUSrc   <= '1';
        ExtOp    <= '1';
        MemToReg <= '1';
        ALUOp    <= "0000";  

      when "01010" =>  -- STORE (SW)
        ALUSrc   <= '1';
        ExtOp    <= '1';
        MemWrite <= '1';
        ALUOp    <= "0000";  

      when "01011" =>  -- BEQ
        Branch <= '1';
        ALUOp  <= "0001";  

      when "01100" =>  -- BNE
        Branch <= '1';
        ALUOp  <= "0001";  

    

      when "01101" =>  -- JUMP
        Jump <= '1';

 

      when "01110" =>  -- SLL
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "0110";

      when "01111" =>  -- SRL
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "0111";

   

      when "10000" =>  -- MOV
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "1000";

      when "10001" =>  -- INC
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "1001";

      when "10010" =>  -- DEC
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "1010";

      when "10011" =>  -- NOT
        RegWrite <= '1';
        RegDst   <= '1';
        ALUOp    <= "1011";

      when others => null;  -- NOP

    end case;
  end process;
end Behavioral;
