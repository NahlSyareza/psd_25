LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY main_entity IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    opcode : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    inp : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    outp : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')
  );
END main_entity;

ARCHITECTURE main_architecture OF main_entity IS
  TYPE united_states IS (IDLE, START_ENCRYPT, START_DECRYPT, ENCRYPTING, DECRYPTING, FINISH_ENCRYPT, FINISH_DECRYPT, STORE_KEY);
  SIGNAL current_state, next_state : united_states;

  SIGNAL bffr : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

BEGIN

  logic_proc : PROCESS (reset, clk)
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
    ELSIF rising_edge(clk) THEN
      current_state <= next_state;
    END IF;
  END PROCESS;

  main_proc : PROCESS (inp, current_state)
  BEGIN
    next_state <= current_state;

    CASE (current_state) IS
      WHEN IDLE =>
        IF opcode = "0001" THEN
          next_state <= START_ENCRYPT;
        ELSIF opcode = "0010" THEN
          next_state <= START_DECRYPT;
        ELSIF opcode = "0011" THEN
          next_state <= STORE_KEY;
        ELSE
          next_state <= IDLE;
        END IF;

      WHEN START_ENCRYPT =>
        next_state <= ENCRYPTING;
        bffr <= inp(0) & inp(3 DOWNTO 1);

      WHEN OTHERS =>
        next_state <= IDLE;
    END CASE;
  END PROCESS;

END main_architecture;