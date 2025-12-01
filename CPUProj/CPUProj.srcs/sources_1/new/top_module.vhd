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
           btnC : in STD_LOGIC;                    -- Button Center: Step Clock
           btnR : in STD_LOGIC;                    -- Button Right: Reset
           sw   : in STD_LOGIC_VECTOR (15 downto 0); 
           led  : out STD_LOGIC_VECTOR (15 downto 0); 
           cat  : out STD_LOGIC_VECTOR (6 downto 0);
           an   : out STD_LOGIC_VECTOR (3 downto 0));
end MIPS_16_Top;

architecture Behavioral of MIPS_16_Top is

    -- COMPONENT DECLARATIONS
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

    -- Note: Entity name is InstructionExecuteUnit, file is InstrExeUnit.vhd
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

    -- SIGNALS
    -- Data Paths
    signal Instruction, PC_out, PC_next : STD_LOGIC_VECTOR(15 downto 0);
    signal RD1, RD2, ExtImm, ALURes, MemData, ALUResOut, WriteData : STD_LOGIC_VECTOR(15 downto 0);
    signal BranchAddress, JumpTarget : STD_LOGIC_VECTOR(15 downto 0);
    signal DisplayData : STD_LOGIC_VECTOR(15 downto 0); -- What is currently on SSD
    
    -- Control Signals
    signal RegWrite, RegDst, ExtOp, Jump, Branch, MemWrite, MemToReg, ALUSrc, Zero, PCSrc : STD_LOGIC;
    signal ALUOp : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Clocking
    signal cpu_clk : STD_LOGIC;
    signal reset_signal : STD_LOGIC;

begin

    -- Reset mapping
    reset_signal <= btnR;
    
    -- Jump Target Logic: Concatenate PC top 3 bits with Instruction lower 13 bits
    -- FIX: Use only the bottom 11 bits for target, preserve top 5 bits of PC
    JumpTarget <= PC_out(15 downto 11) & Instruction(10 downto 0);

    -- Branch Logic
    PCSrc <= Branch and Zero;

    -- WriteBack MUX
    WriteData <= MemData when MemToReg = '1' else ALUResOut;

    -- =========================================================================
    --                               PORT MAPPING
    -- =========================================================================

    -- Debouncer (Center Button -> CPU Clock)
    Debouncer_Unit: debouncer port map (
        clk => clk, 
        btn => btnC,
        enable => cpu_clk 
    );

    -- MODIFY THIS SECTION IN MIPS_16_Top.vhd

    IF_Unit: InstructionFetch port map (
        we => '1',
        reset => reset_signal,
        clk => not cpu_clk, -- CHANGE THIS LINE: Add "not"
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

    -- =========================================================================
    --                           DEBUGGING / DISPLAY LOGIC
    -- =========================================================================

    -- 1. SSD DATA SELECTOR (Multiplexer controlled by sw[2:0])
    process(sw(2 downto 0), Instruction, PC_out, RD1, RD2, ExtImm, ALURes, MemData, WriteData)
    begin
        case sw(2 downto 0) is
            when "000" => DisplayData <= Instruction; -- Instruction from memory
            when "001" => DisplayData <= PC_out;      -- Program Counter
            when "010" => DisplayData <= RD1;         -- Register Read 1
            when "011" => DisplayData <= RD2;         -- Register Read 2
            when "100" => DisplayData <= ExtImm;      -- Extended Immediate
            when "101" => DisplayData <= ALURes;      -- ALU Result
            when "110" => DisplayData <= MemData;     -- Memory Read Data
            when "111" => DisplayData <= WriteData;   -- Data being written back
            when others => DisplayData <= x"FFFF"; 
        end case;
    end process;

    -- 2. SSD DRIVER
    -- We pad DisplayData with 0s because SSD expects 32 bits (8 hex digits), 
    -- but we only have 4 hex digits (16 bits) of data.
    -- 2. SSD DRIVER
    -- FIX: SSD.vhd reads bits 31 downto 16. We must put DisplayData there.
    SSD_Unit: SSD port map (
        clk => clk, 
        digits => DisplayData & x"0000", -- CHANGED THIS LINE (Swapped order)
        an => an,
        cat => cat
    );

    -- 3. LED DRIVER (Controlled by sw[15])
    -- sw[15] = 0 -> LEDs show the 16-bit value currently on the SSD.
    -- sw[15] = 1 -> LEDs show Control Signals (RegWrite, Branch, etc.)
    process(sw(15), DisplayData, RegWrite, MemWrite, Branch, Jump, Zero, MemToReg, ALUSrc, ExtOp, ALUOp, PCSrc, cpu_clk)
    begin
        if sw(15) = '0' then
            led <= DisplayData; -- Normal Data View
        else
            -- Control Signal View
            led <= (others => '0'); -- Clear all first
            led(0) <= RegWrite;
            led(1) <= MemWrite;
            led(2) <= Branch;
            led(3) <= Jump;
            led(4) <= PCSrc;    -- Real branch decision (Zero AND Branch)
            led(5) <= Zero;
            led(6) <= MemToReg;
            led(7) <= ALUSrc;
            led(8) <= ExtOp;
            led(11 downto 9) <= ALUOp(2 downto 0); -- Show 3 bits of ALUOp
            led(15) <= cpu_clk; -- Show clock pulse on top LED
        end if;
    end process;

end Behavioral;
