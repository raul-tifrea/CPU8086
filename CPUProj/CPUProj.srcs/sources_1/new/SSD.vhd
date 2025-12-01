----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2025 07:14:27 PM
-- Design Name: 
-- Module Name: SSD - Behavioral
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
use IEEE.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SSD is
Port (
    clk    : in  std_logic;
    digits : in  std_logic_vector(31 downto 0);
    an     : out std_logic_vector(3 downto 0);
    cat    : out std_logic_vector(6 downto 0)
  );
end SSD;

architecture Behavioral of SSD is
 signal refresh_counter : unsigned(19 downto 0) := (others => '0');
  signal digit_select    : unsigned(1 downto 0) := (others => '0');
  signal current_digit   : std_logic_vector(3 downto 0);
  signal seg_pattern     : std_logic_vector(6 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      refresh_counter <= refresh_counter + 1;
      digit_select    <= refresh_counter(19 downto 18);
    end if;
  end process;

  process(digit_select, digits)
  begin
    case digit_select is
      when "00" => current_digit <= digits(19 downto 16);
      when "01" => current_digit <= digits(23 downto 20);
      when "10" => current_digit <= digits(27 downto 24);
      when "11" => current_digit <= digits(31 downto 28);
      when others => current_digit <= "0000";
    end case;
  end process;

  process(current_digit)
  begin
    case current_digit is
      when "0000" => seg_pattern <= "1000000"; 
      when "0001" => seg_pattern <= "1111001";
      when "0010" => seg_pattern <= "0100100"; 
      when "0011" => seg_pattern <= "0110000"; 
      when "0100" => seg_pattern <= "0011001"; 
      when "0101" => seg_pattern <= "0010010"; 
      when "0110" => seg_pattern <= "0000010";
      when "0111" => seg_pattern <= "1111000"; 
      when "1000" => seg_pattern <= "0000000"; 
      when "1001" => seg_pattern <= "0010000"; 
      when "1010" => seg_pattern <= "0001000"; 
      when "1011" => seg_pattern <= "0000011"; 
      when "1100" => seg_pattern <= "1000110"; 
      when "1101" => seg_pattern <= "0100001"; 
      when "1110" => seg_pattern <= "0000110"; 
      when "1111" => seg_pattern <= "0001110"; 
      when others => seg_pattern <= "1111111"; 
    end case;
  end process;

  process(digit_select)
  begin
    an <= "1111";
    case digit_select is
      when "00" => an(0) <= '0';
      when "01" => an(1) <= '0';
      when "10" => an(2) <= '0';
      when "11" => an(3) <= '0';
      when others => null;
    end case;
  end process;

  cat <= seg_pattern;

end Behavioral;
