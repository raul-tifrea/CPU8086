----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2025 07:11:36 PM
-- Design Name: 
-- Module Name: InstructionFetch - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InstructionFetch is
Port (
    we            : in  std_logic;
    reset         : in  std_logic;
    clk           : in  std_logic;
    branchAddress : in  std_logic_vector(15 downto 0);
    jumpAddress   : in  std_logic_vector(15 downto 0);
    PCsrc         : in  std_logic;
    jump          : in  std_logic;
    instruction   : out std_logic_vector(15 downto 0);
    PCout         : out std_logic_vector(15 downto 0)
  );
end InstructionFetch;

architecture Behavioral of InstructionFetch is

  signal PC      : std_logic_vector(15 downto 0) := (others => '0');
  signal PC_next : std_logic_vector(15 downto 0);

  type ROM_type is array (0 to 255) of std_logic_vector(15 downto 0);
  signal ROM : ROM_type := (
      --ADDI $1, $0, 3
      0 => x"2823", 
      --ADDI $2, $0, 1  
      1 => x"2841",
      --ADD $3, $1, $2   
      2 => x"014C",
      --SW $3, 2($2)
      3 => x"5262",
      --LW $4, 2($2)   
      4 => x"4A82",
      --BEQ $1, $2, 2   
      5 => x"5942",
      --JUMP 0       
      6 => x"6800", 
      others => x"0000"
  );

begin

  process(clk, reset)
  begin
    if reset = '1' then
      PC <= (others => '0');
    elsif rising_edge(clk) then
      if we = '1' then
        PC <= PC_next;
      end if;
    end if;
  end process;

  process(PC, PCsrc, branchAddress, jump, jumpAddress)
  begin
    PC_next <= std_logic_vector(unsigned(PC) + 1);
    if PCsrc = '1' then
      PC_next <= branchAddress;
    end if;
    if jump = '1' then
      PC_next <= jumpAddress;
    end if;
  end process;

  instruction <= ROM(to_integer(unsigned(PC)));
  PCout       <= PC;

end Behavioral;
