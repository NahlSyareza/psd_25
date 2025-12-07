LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY rexim_le_entity IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    enable : IN STD_LOGIC;
    original_input : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    altered_output : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    debug_states : OUT INTEGER;
    done : OUT STD_LOGIC
  );
END rexim_le_entity;

ARCHITECTURE rexim_le_architecture OF rexim_le_entity IS
  TYPE rexim_le_states IS (IDLE, LOAD, UNMIX, STITCH, FINAL);
  SIGNAL current_state, next_state : rexim_le_states;

  SIGNAL a0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a3 : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL b0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b3 : STD_LOGIC_VECTOR(31 DOWNTO 0);

  FUNCTION x2_f (inp : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    VARIABLE t : STD_LOGIC_VECTOR(7 DOWNTO 0);
  BEGIN
    t := inp(6 DOWNTO 0) & '0';

    IF inp(7) = '1' THEN
      RETURN t XOR x"1B";
    ELSE
      RETURN t;
    END IF;
  END FUNCTION;

  FUNCTION x4_f (inp : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN x2_f(x2_f(inp));
  END FUNCTION;

  FUNCTION x8_f (inp : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN x4_f(x2_f(inp));
  END FUNCTION;

  FUNCTION actual_functionality (inp : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    VARIABLE beholder : STD_LOGIC_VECTOR(31 DOWNTO 0);
    VARIABLE first_b : STD_LOGIC_VECTOR(7 DOWNTO 0);
    VARIABLE second_b : STD_LOGIC_VECTOR(7 DOWNTO 0);
    VARIABLE third_b : STD_LOGIC_VECTOR(7 DOWNTO 0);
    VARIABLE fourth_b : STD_LOGIC_VECTOR(7 DOWNTO 0);
  BEGIN
    first_b := inp(31 DOWNTO 24);
    second_b := inp(23 DOWNTO 16);
    third_b := inp(15 DOWNTO 8);
    fourth_b := inp(7 DOWNTO 0);

    beholder(31 DOWNTO 24) := (x8_f(first_b) XOR x4_f(first_b) XOR x2_f(first_b)) XOR (x8_f(second_b) XOR x2_f(second_b) XOR second_b) XOR (x8_f(third_b) XOR x4_f(third_b) XOR third_b) XOR (x8_f(fourth_b) XOR fourth_b);
    beholder(23 DOWNTO 16) := (x8_f(first_b) XOR first_b) XOR (x8_f(second_b) XOR x4_f(second_b) XOR x2_f(second_b)) XOR (x8_f(third_b) XOR x2_f(third_b) XOR third_b) XOR (x8_f(fourth_b) XOR x4_f(fourth_b) XOR fourth_b);
    beholder(15 DOWNTO 8) := (x8_f(first_b) XOR x4_f(first_b) XOR first_b) XOR (x8_f(second_b) XOR second_b) XOR (x8_f(third_b) XOR x4_f(third_b) XOR x2_f(third_b)) XOR (x8_f(fourth_b) XOR x2_f(fourth_b) XOR fourth_b);
    beholder(7 DOWNTO 0) := (x8_f(first_b) XOR x2_f(first_b) XOR first_b) XOR (x8_f(second_b) XOR x4_f(second_b) XOR second_b) XOR (x8_f(third_b) XOR third_b) XOR (x8_f(fourth_b) XOR x4_f(fourth_b) XOR x2_f(fourth_b));

    RETURN beholder;
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

  inv_mix_proc : PROCESS (current_state)
  BEGIN
    CASE (current_state) IS
      WHEN IDLE =>
        done <= '0';
        debug_states <= 0;
        next_state <= LOAD;

      WHEN LOAD =>
        a0 <= original_input(127 DOWNTO 96);
        a1 <= original_input(95 DOWNTO 64);
        a2 <= original_input(63 DOWNTO 32);
        a3 <= original_input(31 DOWNTO 0);
        debug_states <= 1;
        next_state <= UNMIX;

      WHEN UNMIX =>
        b0 <= actual_functionality(a0);
        b1 <= actual_functionality(a1);
        b2 <= actual_functionality(a2);
        b3 <= actual_functionality(a3);
        debug_states <= 2;
        next_state <= STITCH;

      WHEN STITCH =>
        altered_output <= b0 & b1 & b2 & b3;
        debug_states <= 3;
        next_state <= FINAL;

      WHEN FINAL =>
        done <= '1';
        debug_states <= 4;
        next_state <= IDLE;

      WHEN OTHERS =>
        done <= '0';
        next_state <= IDLE;

    END CASE;
  END PROCESS;

END rexim_le_architecture;