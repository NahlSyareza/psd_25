LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY le_shift_entity IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    enable : IN STD_LOGIC;
    original_input : IN STD_LOGIC_VECTOR(127 DOWNTO 0); -- := "11001111011111100111111100110101111111100010011010010100001011001000001000110010110101010101100001100010010100110101100110100001";
    altered_output : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    encrypt_or_decrypt : IN STD_LOGIC;
    done : OUT STD_LOGIC
  );
END le_shift_entity;

ARCHITECTURE le_shift_architecture OF le_shift_entity IS
  TYPE le_shift_states IS (IDLE, LOAD, SHIFT, STITCH, FINAL);
  SIGNAL current_state, next_state : le_shift_states;

  SIGNAL first_row : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL second_row : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL third_row : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL fourth_row : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL first_col : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL second_col : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL third_col : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL fourth_col : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

  logic_proc : PROCESS (reset, clk, enable)
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
    ELSIF rising_edge(clk) AND enable = '1' THEN
      current_state <= next_state;
    END IF;
  END PROCESS;

  shift_proc : PROCESS (current_state)
  BEGIN
    CASE (current_state) IS
      WHEN IDLE =>
        done <= '0';
        next_state <= LOAD;

      WHEN LOAD =>
        first_row <= original_input(127 DOWNTO 120) & original_input(95 DOWNTO 88) & original_input(63 DOWNTO 56) & original_input(31 DOWNTO 24);
        second_row <= original_input(119 DOWNTO 112) & original_input(87 DOWNTO 80) & original_input(55 DOWNTO 48) & original_input(23 DOWNTO 16);
        third_row <= original_input(111 DOWNTO 104) & original_input(79 DOWNTO 72) & original_input(47 DOWNTO 40) & original_input(15 DOWNTO 8);
        fourth_row <= original_input(103 DOWNTO 96) & original_input(71 DOWNTO 64) & original_input(39 DOWNTO 32) & original_input(7 DOWNTO 0);
        next_state <= SHIFT;

      WHEN SHIFT =>
        IF encrypt_or_decrypt = '0' THEN
          second_row <= second_row(23 DOWNTO 0) & second_row(31 DOWNTO 24);
          third_row <= third_row(15 DOWNTO 0) & third_row(31 DOWNTO 16);
          fourth_row <= fourth_row(7 DOWNTO 0) & fourth_row(31 DOWNTO 8);
        ELSE
          second_row <= second_row(7 DOWNTO 0) & second_row(31 DOWNTO 8);
          third_row <= third_row(15 DOWNTO 0) & third_row(31 DOWNTO 16);
          fourth_row <= fourth_row(23 DOWNTO 0) & fourth_row(31 DOWNTO 24);
        END IF;
        next_state <= STITCH;

      WHEN STITCH =>
        first_col <= first_row(31 DOWNTO 24) & second_row(31 DOWNTO 24) & third_row(31 DOWNTO 24) & fourth_row(31 DOWNTO 24);
        second_col <= first_row(23 DOWNTO 16) & second_row(23 DOWNTO 16) & third_row(23 DOWNTO 16) & fourth_row(23 DOWNTO 16);
        third_col <= first_row(15 DOWNTO 8) & second_row(15 DOWNTO 8) & third_row(15 DOWNTO 8) & fourth_row(15 DOWNTO 8);
        fourth_col <= first_row(7 DOWNTO 0) & second_row(7 DOWNTO 0) & third_row(7 DOWNTO 0) & fourth_row(7 DOWNTO 0);
        next_state <= FINAL;

      WHEN FINAL =>
        altered_output <= first_col & second_col & third_col & fourth_col;
        done <= '1';
        IF reset = '1' THEN
          next_state <= IDLE;
        END IF;

      WHEN OTHERS =>
        done <= '0';
        next_state <= IDLE;

    END CASE;
  END PROCESS;

END le_shift_architecture;