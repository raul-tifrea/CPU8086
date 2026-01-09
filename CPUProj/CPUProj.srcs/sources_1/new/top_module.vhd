----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2025 01:50:42 PM
-- Design Name: 
-- Module Name: top_module - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MIPS_16_Top is
    Port ( clk  : in STD_LOGIC;
           btnC : in STD_LOGIC;                    -- clock
           btnR : in STD_LOGIC;                    -- reset
           sw   : in STD_LOGIC_VECTOR (15 downto 0); 
           led  : out STD_LOGIC_VECTOR (15 downto 0); 
           cat  : out STD_LOGIC_VECTOR (6 downto 0);
           an   : out STD_LOGIC_VECTOR (3 downto 0));
end MIPS_16_Top;

architecture Behavioral of MIPS_16_Top is

    
    component debouncer
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           enable : out STD_LOGIC);
    end component;

    component InstructionFetch
    Port ( we : in STD_LOGIC;
           reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           branchAddress : in STD_LOGIC_VECTOR(15 downto 0);
           jumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
           PCsrc : in STD_LOGIC;
           jump : in STD_LOGIC;
           instruction : out STD_LOGIC_VECTOR(15 downto 0);
           PCout : out STD_LOGIC_VECTOR(15 downto 0));
    end component;

    component InstrDecode
    Port ( clk : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR(15 downto 0);
           RegWrite : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           WriteData : in STD_LOGIC_VECTOR(15 downto 0);
           ExtOp : in STD_LOGIC;
           ReadData1 : out STD_LOGIC_VECTOR(15 downto 0);
           ReadData2 : out STD_LOGIC_VECTOR(15 downto 0);
           ExtImm : out STD_LOGIC_VECTOR(15 downto 0));
    end component;

    component MainControl
    Port ( Instr : in STD_LOGIC_VECTOR(4 downto 0);
           RegWrite : out STD_LOGIC;
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           Jump : out STD_LOGIC;
           Branch : out STD_LOGIC;
           MemWrite : out STD_LOGIC;
           MemToReg : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

    component InstructionExecuteUnit
    Port ( PCout : in STD_LOGIC_VECTOR(15 downto 0);
           RD1 : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           ExtImm : in STD_LOGIC_VECTOR(15 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(3 downto 0);
           ALURes : out STD_LOGIC_VECTOR(15 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
           ZeroSignal : out STD_LOGIC);
    end component;

    component dataMemory
    Port ( CLK : in STD_LOGIC;
           MemWrite : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
           ReadData2 : in STD_LOGIC_VECTOR(15 downto 0);
           MemData : out STD_LOGIC_VECTOR(15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    component SSD
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
    end component;

    signal Instruction, PC_out, PC_next : STD_LOGIC_VECTOR(15 downto 0);
    signal RD1, RD2, ExtImm, ALURes, MemData, ALUResOut, WriteData : STD_LOGIC_VECTOR(15 downto 0);
    signal BranchAddress, JumpTarget : STD_LOGIC_VECTOR(15 downto 0);
    signal DisplayData : STD_LOGIC_VECTOR(15 downto 0); -- What is currently on SSD
    
    signal RegWrite, RegDst, ExtOp, Jump, Branch, MemWrite, MemToReg, ALUSrc, Zero, PCSrc : STD_LOGIC;
    signal ALUOp : STD_LOGIC_VECTOR(3 downto 0);
    
    signal cpu_clk : STD_LOGIC;
    signal reset_signal : STD_LOGIC;

begin

    reset_signal <= btnR;
    
    JumpTarget <= PC_out(15 downto 11) & Instruction(10 downto 0);

    PCSrc <= Branch and Zero;

    WriteData <= MemData when MemToReg = '1' else ALUResOut;

    Debouncer_Unit: debouncer port map (
        clk => clk, 
        btn => btnC,
        enable => cpu_clk 
    );

    
    IF_Unit: InstructionFetch port map (
        we => '1',
        reset => reset_signal,
        clk => not cpu_clk, 
        branchAddress => BranchAddress,
        jumpAddress => JumpTarget,
        PCsrc => PCSrc,
        jump => Jump,
        instruction => Instruction,
        PCout => PC_out
    );

    ID_Unit: InstrDecode port map (
        clk => cpu_clk, 
        Instr => Instruction,
        RegWrite => RegWrite,
        RegDst => RegDst,
        WriteData => WriteData,
        ExtOp => ExtOp,
        ReadData1 => RD1,
        ReadData2 => RD2,
        ExtImm => ExtImm
    );

    Control_Unit: MainControl port map (
        Instr => Instruction(15 downto 11),
        RegWrite => RegWrite,
        RegDst => RegDst,
        ExtOp => ExtOp,
        Jump => Jump,
        Branch => Branch,
        MemWrite => MemWrite,
        MemToReg => MemToReg,
        ALUSrc => ALUSrc,
        ALUOp => ALUOp
    );

    EX_Unit: InstructionExecuteUnit port map (
        PCout => PC_out,
        RD1 => RD1,
        RD2 => RD2,
        ExtImm => ExtImm,
        ALUSrc => ALUSrc,
        ALUOp => ALUOp,
        ALURes => ALURes,
        BranchAddress => BranchAddress,
        ZeroSignal => Zero
    );

    MEM_Unit: dataMemory port map (
        CLK => cpu_clk, 
        MemWrite => MemWrite,
        ALUResIn => ALURes,
        ReadData2 => RD2,
        MemData => MemData,
        ALUResOut => ALUResOut
    );

    process(sw(2 downto 0), Instruction, PC_out, RD1, RD2, ExtImm, ALURes, MemData, WriteData)
    begin
        case sw(2 downto 0) is
            when "000" => DisplayData <= Instruction; 
            when "001" => DisplayData <= PC_out;      
            when "010" => DisplayData <= RD1;         
            when "011" => DisplayData <= RD2;         
            when "100" => DisplayData <= ExtImm;      
            when "101" => DisplayData <= ALURes;      
            when "110" => DisplayData <= MemData;     
            when "111" => DisplayData <= WriteData;   
            when others => DisplayData <= x"FFFF"; 
        end case;
    end process;

    SSD_Unit: SSD port map (
        clk => clk, 
        digits => DisplayData & x"0000",
        an => an,
        cat => cat
    );

    process(sw(15), DisplayData, RegWrite, MemWrite, Branch, Jump, Zero, MemToReg, ALUSrc, ExtOp, ALUOp, PCSrc, cpu_clk)
    begin
        if sw(15) = '0' then
            led <= DisplayData; 
        else
            led <= (others => '0');
            led(0) <= RegWrite;
            led(1) <= MemWrite;
            led(2) <= Branch;
            led(3) <= Jump;
            led(4) <= PCSrc;   
            led(5) <= Zero;
            led(6) <= MemToReg;
            led(7) <= ALUSrc;
            led(8) <= ExtOp;
            led(11 downto 9) <= ALUOp(2 downto 0); 
            led(15) <= cpu_clk; 
        end if;
    end process;

end Behavioral;
