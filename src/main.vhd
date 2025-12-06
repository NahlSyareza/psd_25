LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY main_entity IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    opcode : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    inp : IN STD_LOGIC_VECTOR(127 DOWNTO 0) := x"48656C6C6F20576F726C642121212121"; -- "Hello World!!!!!"
    key : IN STD_LOGIC_VECTOR(127 DOWNTO 0) := x"2B7E151628AED2A6ABF7158809CF4F3C";
    outp : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
  );
END main_entity;

ARCHITECTURE main_architecture OF main_entity IS
  TYPE united_states IS (IDLE, ENCRYPT_XOR, ENCRYPT_SUB, ENCRYPT_SHIFT, ENCRYPT_MIX, ENCRYPT_ROUND, DECRYPT_ROUND, DECRYPT_MIX, DECRYPT_SHIFT, DECRYPT_SUB, DECRYPT_XOR, FINAL);
  SIGNAL current_state, next_state : united_states;

  -- 0 Encrypt
  -- 1 Decrypt
  SIGNAL encrypt_or_decrypt : STD_LOGIC;

  SIGNAL xor_outp : STD_LOGIC_VECTOR(127 DOWNTO 0);

  SIGNAL s_box_inp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL s_box_outp : STD_LOGIC_VECTOR(127 DOWNTO 0);

  SIGNAL le_shift_enable : STD_LOGIC;
  SIGNAL le_shift_done : STD_LOGIC;
  SIGNAL le_shift_inp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL le_shift_outp : STD_LOGIC_VECTOR(127 DOWNTO 0);

  SIGNAL el_mixer_enable : STD_LOGIC;
  SIGNAL el_mixer_done : STD_LOGIC;
  SIGNAL el_mixer_inp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL el_mixer_outp : STD_LOGIC_VECTOR(127 DOWNTO 0);

  SIGNAL key_exp_enable : STD_LOGIC;
  SIGNAL key_exp_done : STD_LOGIC;
  SIGNAL round_num : INTEGER RANGE 0 TO 10;
  SIGNAL current_round_key : STD_LOGIC_VECTOR(127 DOWNTO 0);

BEGIN

  s_box : ENTITY work.s_box_entity
    PORT MAP(
      original_input => s_box_inp,
      altered_output => s_box_outp
    );

  -- menggunakan komponen key_expansion
  key_exp : ENTITY work.key_expansion_entity
    PORT MAP(
      clk => clk,
      reset => reset,
      enable => key_exp_enable,
      original_key => key,
      round_num => round_num,
      round_key => current_round_key,
      done => key_exp_done
    );

  le_shift : ENTITY work.le_shift_entity
    PORT MAP(
      enable => le_shift_enable,
      clk => clk,
      reset => reset,
      original_input => le_shift_inp,
      altered_output => le_shift_outp,
      encrypt_or_decrypt => encrypt_or_decrypt,
      done => le_shift_done
    );

  el_mixer : ENTITY work.el_mixer_entity
    PORT MAP(
      clk => clk,
      reset => reset,
      enable => el_mixer_enable,
      original_input => el_mixer_inp,
      altered_output => el_mixer_outp,
      done => el_mixer_done
    );

  logic_proc : PROCESS (reset, clk)
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
    ELSIF rising_edge(clk) THEN
      current_state <= next_state;
    END IF;
  END PROCESS;

  main_proc : PROCESS (current_state, opcode, le_shift_done, el_mixer_done)
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

      WHEN ENCRYPT_SHIFT =>
        le_shift_enable <= '1';
        le_shift_inp <= s_box_outp;
        IF le_shift_done = '1' THEN
          next_state <= ENCRYPT_MIX;
        END IF;

      WHEN ENCRYPT_MIX =>
        le_shift_enable <= '0';
        el_mixer_enable <= '1';
        el_mixer_inp <= le_shift_outp;
        IF el_mixer_done = '1' THEN
          next_state <= ENCRYPT_ROUND;
        END IF;

      WHEN ENCRYPT_ROUND =>
        next_state <= FINAL;

        -- Start of Decryption
      WHEN DECRYPT_ROUND =>
        encrypt_or_decrypt <= '1';
        next_state <= DECRYPT_MIX;

      WHEN OTHERS =>
        next_state <= IDLE;
    END CASE;
  END PROCESS;

END main_architecture;