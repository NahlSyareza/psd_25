LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY le_shift_entity IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    original_input : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    altered_output : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    encrypt_or_decrypt : IN STD_LOGIC;
    is_done : OUT STD_LOGIC
  );
END le_shift_entity;

ARCHITECTURE le_shift_architecture OF le_shift_entity IS
  TYPE le_shift_states IS (IDLE, LOAD, SHIFT, DONE);
  SIGNAL current_state, next_state : le_shift_states;

  SIGNAL first_row : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL second_row : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL third_row : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL fourth_row : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

  logic_proc : PROCESS (reset, clk)
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
      is_done <= '0';
    ELSIF rising_edge(clk) THEN
      current_state <= next_state;
    END IF;
  END PROCESS;

  shift_proc : PROCESS (current_state)
  BEGIN
    CASE (current_state) IS
      WHEN IDLE =>
        next_state <= LOAD;

      WHEN LOAD =>
        first_row <= original_input(127 DOWNTO 120) & original_input(95 DOWNTO 88) & original_input(63 DOWNTO 56) & original_input(31 DOWNTO 24);
        second_row <= original_input(119 DOWNTO 112) & original_input(87 DOWNTO 80) & original_input(55 DOWNTO 48) & original_input(23 DOWNTO 16);
        third_row <= original_input(111 DOWNTO 104) & original_input(79 DOWNTO 72) & original_input(47 DOWNTO 40) & original_input(15 DOWNTO 8);
        fourth_row <= original_input(103 DOWNTO 96) & original_input(71 DOWNTO 64) & original_input(39 DOWNTO 32) & original_input(7 DOWNTO 0);
        next_state <= SHIFT;

      WHEN SHIFT <=
        IF encrypt_or_decrypt = '0' THEN
          second_row <= 
        ELSE
        END IF;
        next_state <= DONE;

      WHEN DONE =>
        -- altered_output <=
        is_done <= '1';

      WHEN OTHERS =>
        next_state <= IDLE;

    END CASE;
  END PROCESS;

END le_shift_entity;