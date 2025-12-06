-- modul: behavioral style pada process statements, fsm, function pada xtime dan mix_column

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY el_mixer_entity IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    enable : IN STD_LOGIC;
    original_input : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    altered_output : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    done : OUT STD_LOGIC
  );
END el_mixer_entity;

ARCHITECTURE el_mixer_architecture OF el_mixer_entity IS
  TYPE el_mixer_states IS (IDLE, LOAD, MIX, STITCH, FINAL);
  SIGNAL current_state, next_state : el_mixer_states;

  SIGNAL col0, col1, col2, col3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL mix0, mix1, mix2, mix3 : STD_LOGIC_VECTOR(31 DOWNTO 0);

  FUNCTION xtime(b : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    VARIABLE result : STD_LOGIC_VECTOR(7 DOWNTO 0);
  BEGIN
    IF b(7) = '1' THEN
      result := (b(6 DOWNTO 0) & '0') XOR x"1B";
    ELSE
      result := b(6 DOWNTO 0) & '0';
    END IF;
    RETURN result;
  END FUNCTION;

  FUNCTION mix_column(col : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    VARIABLE a0, a1, a2, a3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    VARIABLE r0, r1, r2, r3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  BEGIN
    a0 := col(31 DOWNTO 24);
    a1 := col(23 DOWNTO 16);
    a2 := col(15 DOWNTO 8);
    a3 := col(7 DOWNTO 0);

    r0 := xtime(a0) XOR (xtime(a1) XOR a1) XOR a2 XOR a3;
    r1 := a0 XOR xtime(a1) XOR (xtime(a2) XOR a2) XOR a3;
    r2 := a0 XOR a1 XOR xtime(a2) XOR (xtime(a3) XOR a3);
    r3 := (xtime(a0) XOR a0) XOR a1 XOR a2 XOR xtime(a3);

    RETURN r0 & r1 & r2 & r3;
  END FUNCTION;

BEGIN

  logic_proc : PROCESS (reset, clk, enable)
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
    ELSIF rising_edge(clk) AND enable = '1' THEN
      current_state <= next_state;
    END IF;
  END PROCESS;

  mix_proc : PROCESS (current_state)
  BEGIN
    CASE (current_state) IS
      WHEN IDLE =>
        done <= '0';
        next_state <= LOAD;

      WHEN LOAD =>
        col0 <= original_input(127 DOWNTO 96);
        col1 <= original_input(95 DOWNTO 64);
        col2 <= original_input(63 DOWNTO 32);
        col3 <= original_input(31 DOWNTO 0);
        next_state <= MIX;

      WHEN MIX =>
        mix0 <= mix_column(col0);
        mix1 <= mix_column(col1);
        mix2 <= mix_column(col2);
        mix3 <= mix_column(col3);
        next_state <= STITCH;

      WHEN STITCH =>
        altered_output <= mix0 & mix1 & mix2 & mix3;
        next_state <= FINAL;

      WHEN FINAL =>
        done <= '1';
        IF reset = '1' THEN
          next_state <= IDLE;
        END IF;

      WHEN OTHERS =>
        done <= '0';
        next_state <= IDLE;

    END CASE;
  END PROCESS;

END el_mixer_architecture;
