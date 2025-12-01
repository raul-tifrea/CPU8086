----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2025 07:09:30 PM
-- Design Name: 
-- Module Name: debouncer - Behavioral
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

entity debouncer is
  port (
    clk     : in  std_logic;           
    btn     : in  std_logic;           
    enable  : out std_logic            
  );
end debouncer;

architecture Behavioral of debouncer is
  signal btn_sync   : std_logic_vector(1 downto 0) := (others => '0');
  signal btn_edge   : std_logic := '0';
  signal pulse_cnt  : unsigned(23 downto 0) := (others => '0'); 
  signal pulse_on   : std_logic := '0';
begin
 process(clk)
  begin
    if rising_edge(clk) then
      btn_sync(0) <= btn;
      btn_sync(1) <= btn_sync(0);
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if (btn_sync(1) = '1' and btn_sync(0) = '0') then
        btn_edge <= '1';
      else
        btn_edge <= '0';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if btn_edge = '1' then
        pulse_on  <= '1';
        pulse_cnt <= (others => '0');
      elsif pulse_on = '1' then
        if pulse_cnt = 10_000_000 then   
          pulse_on <= '0';
        else
          pulse_cnt <= pulse_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  enable <= pulse_on;

end Behavioral;
