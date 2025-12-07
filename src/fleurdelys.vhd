LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY fleurdelys_entity IS
END fleurdelys_entity;

ARCHITECTURE fleurdelys_architecture OF fleurdelys_entity IS
  SIGNAL clk : STD_LOGIC;
  SIGNAL reset : STD_LOGIC;
  SIGNAL opcode : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL inp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL key : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL outp : STD_LOGIC_VECTOR(127 DOWNTO 0);

  CONSTANT beohr : TIME := 100 ns;

  PROCEDURE clean_call (
    SIGNAL opcode : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    opcode_inp : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    delay_count : IN INTEGER
  ) IS
  BEGIN
    opcode <= opcode_inp;
    WAIT FOR beohr * delay_count;
  END PROCEDURE;

BEGIN

  UUT : ENTITY work.main_entity
    PORT MAP(
      clk => clk,
      reset => reset,
      opcode => opcode,
      inp => inp,
      key => key,
      outp => outp
    );

  clk_proc : PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR beohr/2;
    clk <= '1';
    WAIT FOR beohr/2;
  END PROCESS;

  main_proc : PROCESS
  BEGIN
    WAIT FOR beohr;

    reset <= '0';
    inp <= x"052BC3FB4A020CEDCBAB86FC0C06D404";
    key <= x"2B7E151628AED2A6ABF7158809CF4F3C";

    -- Tenth round / 24
    clean_call(opcode, "1000", 4);
    -- clean_call
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    ASSERT (outp = x"B5BCCF8C41252D289583A21AC0E74C50") REPORT "Mismatch on Round 10" SEVERITY error;
    clean_call(opcode, "1101", 4);

    -- Ninth round / 28
    clean_call(opcode, "1001", 8);
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    ASSERT (outp = x"CABA28CA3F802CCA01A72780FFD5942C") REPORT "Mismatch on Round 9" SEVERITY error;
    clean_call(opcode, "1101", 4);

    -- Eighth round
    clean_call(opcode, "1001", 8);
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    ASSERT (outp = x"D16791A1BE65EDAB8CD9BE391D4047C2") REPORT "Mismatch on Round 8" SEVERITY error;
    clean_call(opcode, "1101", 4);

    -- Seventh round
    clean_call(opcode, "1001", 8);
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    ASSERT (outp = x"3F0AB75C75F40FD75C1398704DA0F3EB") REPORT "Mismatch on Round 7" SEVERITY error;
    clean_call(opcode, "1101", 4);

    -- Sixth round
    clean_call(opcode, "1001", 8);
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    ASSERT (outp = x"15A20F32BB477F0005531FC3856D1D9F") REPORT "Mismatch on Round 6" SEVERITY error;
    clean_call(opcode, "1101", 4);

    -- Fifth round
    clean_call(opcode, "1001", 8);
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    ASSERT (outp = x"60D9C705C33AD054E5AEF119C0F23172") REPORT "Mismatch ON Round 5" SEVERITY error;
    clean_call(opcode, "1101", 4);

    -- Fourth round
    clean_call(opcode, "1001", 8);
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    ASSERT (outp = x"CD68E6D0815ADEDF2145764A118556FB") REPORT "Mismatch on Round 4" SEVERITY error;
    clean_call(opcode, "1101", 4);

    -- Third round
    clean_call(opcode, "1001", 8);
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    ASSERT (outp = x"0B5EA4BF15DD68981F664898C7964CAA") REPORT "Mismatch on Round 3" SEVERITY error;
    clean_call(opcode, "1101", 4);

    -- Second round
    clean_call(opcode, "1001", 8);
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    ASSERT (outp = x"6169B6E8AABCC86E5ADA2F59EC6CB6DC") REPORT "Mismatch on Round 2" SEVERITY error;
    clean_call(opcode, "1101", 4);

    -- First round
    clean_call(opcode, "1001", 8);
    clean_call(opcode, "1010", 8);
    clean_call(opcode, "1011", 4);
    clean_call(opcode, "1100", 4);
    clean_call(opcode, "1101", 4);
    ASSERT (outp = x"48656C6C6F20576F726C642121212121") REPORT "Mismatch on Round 1" SEVERITY error;

  END PROCESS;
END fleurdelys_architecture;