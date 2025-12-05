LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY main_entity IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    opcode : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    inp : IN STD_LOGIC_VECTOR(127 DOWNTO 0) := x"74F47ECF248D35E4BA56A0D6A29F5ACD";
    key : IN STD_LOGIC_VECTOR(127 DOWNTO 0) := x"2B7E151628AED2A6ABF7158809CF4F3C";
    outp : OUT STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0')
  );
END main_entity;

ARCHITECTURE main_architecture OF main_entity IS
  TYPE united_states IS (IDLE, ENCRYPT_XOR, ENCRYPT_SUB, ENCRYPT_SHIFT, ENCRYPT_MIX, ENCRYPT_ROUND, DECRYPT_ROUND, DECRYPT_MIX, DECRYPT_SHIFT, DECRYPT_SUB, DECRYPT_XOR);
  SIGNAL current_state, next_state : united_states;

  -- 0 Encrypt
  -- 1 Decrypt
  SIGNAL encrypt_or_decrypt : STD_LOGIC;

  SIGNAL xor_outp : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0');

  SIGNAL s_box_inp : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0');
  SIGNAL s_box_outp : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0');

BEGIN

  s_box : ENTITY work.s_box_entity
    PORT MAP(
      original_input => s_box_inp,
      altered_output => s_box_outp
    );

  logic_proc : PROCESS (reset, clk)
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
    ELSIF rising_edge(clk) THEN
      current_state <= next_state;
    END IF;
  END PROCESS;

  main_proc : PROCESS (current_state, opcode)
  BEGIN
    next_state <= current_state;

    CASE (current_state) IS
      WHEN IDLE =>
        IF opcode = "0001" THEN
          next_state <= ENCRYPT_XOR;
        ELSIF opcode = "0010" THEN
          next_state <= DECRYPT_ROUND;
        ELSE
          next_state <= IDLE;
        END IF;

      WHEN ENCRYPT_XOR =>
        encrypt_or_decrypt <= '0';
        xor_outp <= inp XOR key;
        next_state <= ENCRYPT_SUB;

      WHEN ENCRYPT_SUB =>
        s_box_inp <= xor_outp;
        next_state <= ENCRYPT_SHIFT;

        -- Start of Decryption
      WHEN DECRYPT_ROUND =>
        encrypt_or_decrypt <= 1;
        next_state <= DECRYPT_MIX;

      WHEN OTHERS =>
        next_state <= IDLE;
    END CASE;
  END PROCESS;

END main_architecture;