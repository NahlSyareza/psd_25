LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY main_entity IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    opcode : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    inp : IN STD_LOGIC_VECTOR(127 DOWNTO 0); -- := x"48656C6C6F20576F726C642121212121"; -- "Hello World!!!!!"
    key : IN STD_LOGIC_VECTOR(127 DOWNTO 0); -- := x"2B7E151628AED2A6ABF7158809CF4F3C";
    outp : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
  );
END main_entity;

ARCHITECTURE main_architecture OF main_entity IS
  TYPE united_states IS (
    IDLE,
    FETCH,
    DECODE,
    ENCRYPT_INIT,
    ENCRYPT_SUB,
    ENCRYPT_SHIFT,
    ENCRYPT_MIX,
    ENCRYPT_ROUND,
    ENCRYPT_FINAL,
    DECRYPT_INIT,
    DECRYPT_ROUND,
    DECRYPT_MIX,
    DECRYPT_SHIFT,
    DECRYPT_SUB,
    DECRYPT_FINAL,
    FINAL
  );

  SIGNAL current_state, next_state : united_states;

  -- 0 Encrypt
  -- 1 Decrypt
  SIGNAL encrypt_or_decrypt : STD_LOGIC;

  SIGNAL oi_buffer : STD_LOGIC_VECTOR(127 DOWNTO 0);

  SIGNAL s_box_inp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL s_box_outp : STD_LOGIC_VECTOR(127 DOWNTO 0);

  SIGNAL le_shift_enable : STD_LOGIC;
  SIGNAL le_shift_done : STD_LOGIC;
  SIGNAL le_shift_inp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL le_shift_outp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL le_shift_dbg : INTEGER;

  SIGNAL el_mixer_enable : STD_LOGIC;
  SIGNAL el_mixer_done : STD_LOGIC;
  SIGNAL el_mixer_inp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL el_mixer_outp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL el_mixer_dbg : INTEGER;

  SIGNAL rexim_le_enable : STD_LOGIC;
  SIGNAL rexim_le_done : STD_LOGIC;
  SIGNAL rexim_le_inp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL rexim_le_outp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL rexim_le_dbg : INTEGER;

  SIGNAL key_round_inp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL key_round_outp : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL key_round_sel : INTEGER := 1;
  SIGNAL key_round_kagi : STD_LOGIC_VECTOR(127 DOWNTO 0);

BEGIN

  key_round : ENTITY work.key_round_entity
    PORT MAP(
      original_input => key_round_inp,
      altered_output => key_round_outp,
      clk => clk,
      reset => reset,
      round_sel => key_round_sel,
      original_key => key,
      round_key_out => key_round_kagi
    );

  s_box : ENTITY work.s_box_entity
    PORT MAP(
      original_input => s_box_inp,
      altered_output => s_box_outp,
      encrypt_or_decrypt => encrypt_or_decrypt
    );

  le_shift : ENTITY work.le_shift_entity
    PORT MAP(
      enable => le_shift_enable,
      clk => clk,
      reset => reset,
      original_input => le_shift_inp,
      altered_output => le_shift_outp,
      encrypt_or_decrypt => encrypt_or_decrypt,
      done => le_shift_done,
      debug_states => le_shift_dbg
    );

  el_mixer : ENTITY work.el_mixer_entity
    PORT MAP(
      clk => clk,
      reset => reset,
      enable => el_mixer_enable,
      original_input => el_mixer_inp,
      altered_output => el_mixer_outp,
      done => el_mixer_done,
      debug_states => el_mixer_dbg
    );

  rexim_le : ENTITY work.rexim_le_entity
    PORT MAP(
      clk => clk,
      reset => reset,
      enable => rexim_le_enable,
      original_input => rexim_le_inp,
      altered_output => rexim_le_outp,
      debug_states => rexim_le_dbg,
      done => rexim_le_done
    );

  logic_proc : PROCESS (reset, clk)
  BEGIN
    IF reset = '1' THEN
      current_state <= IDLE;
    ELSIF rising_edge(clk) THEN
      current_state <= next_state;
    END IF;
  END PROCESS;

  main_proc : PROCESS (current_state, opcode, le_shift_done, el_mixer_done, rexim_le_done)
  BEGIN
    next_state <= current_state;

    CASE (current_state) IS
      WHEN IDLE =>
        le_shift_enable <= '0';
        el_mixer_enable <= '0';
        rexim_le_enable <= '0';
        next_state <= FETCH;
      WHEN FETCH =>
        next_state <= DECODE;

      WHEN DECODE =>
        IF opcode = "0000" THEN
          key_round_sel <= 0;
          encrypt_or_decrypt <= '0';
          next_state <= ENCRYPT_INIT;
        ELSIF opcode = "0001" THEN
          encrypt_or_decrypt <= '0';
          next_state <= ENCRYPT_SUB;
        ELSIF opcode = "0010" THEN
          encrypt_or_decrypt <= '0';
          next_state <= ENCRYPT_SHIFT;
        ELSIF opcode = "0011" THEN
          encrypt_or_decrypt <= '0';
          next_state <= ENCRYPT_MIX;
        ELSIF opcode <= "0100" THEN
          encrypt_or_decrypt <= '0';
          next_state <= ENCRYPT_ROUND;
        ELSIF opcode <= "0101" THEN
          encrypt_or_decrypt <= '0';
          next_state <= ENCRYPT_FINAl;
        ELSIF opcode = "1000" THEN
          key_round_sel <= 10;
          encrypt_or_decrypt <= '1';
          next_state <= DECRYPT_INIT;
        ELSIF opcode = "1001" THEN
          encrypt_or_decrypt <= '1';
          next_state <= DECRYPT_MIX;
        ELSIF opcode = "1010" THEN
          encrypt_or_decrypt <= '1';
          next_state <= DECRYPT_SHIFT;
        ELSIF opcode = "1011" THEN
          encrypt_or_decrypt <= '1';
          next_state <= DECRYPT_SUB;
        ELSIF opcode = "1100" THEN
          encrypt_or_decrypt <= '1';
          next_state <= DECRYPT_ROUND;
        ELSIF opcode = "1101" THEN
          encrypt_or_decrypt <= '1';
          next_state <= DECRYPT_FINAL;
        ELSE
          next_state <= IDLE;
        END IF;

      WHEN DECRYPT_INIT =>
        oi_buffer <= inp XOR key_round_kagi;
        key_round_sel <= key_round_sel - 1;
        next_state <= IDLE;

      WHEN DECRYPT_MIX =>
        outp <= oi_buffer;
        rexim_le_enable <= '1';
        rexim_le_inp <= oi_buffer;
        IF rexim_le_done = '1' THEN
          next_state <= IDLE;
        END IF;

      WHEN DECRYPT_SHIFT =>
        outp <= rexim_le_outp;
        le_shift_enable <= '1';
        IF key_round_sel = 9 THEN
          le_shift_inp <= oi_buffer;
        ELSE
          le_shift_inp <= rexim_le_outp;
        END IF;
        IF le_shift_done = '1' THEN
          next_state <= IDLE;
        END IF;

      WHEN DECRYPT_SUB =>
        outp <= le_shift_outp;
        s_box_inp <= le_shift_outp;
        next_state <= IDLE;

      WHEN DECRYPT_ROUND =>
        outp <= s_box_outp;
        key_round_inp <= s_box_outp;
        next_state <= IDLE;

      WHEN DECRYPT_FINAL =>
        outp <= key_round_outp;
        oi_buffer <= key_round_outp;
        -- key_round_sel <= key_round_sel - 1;
        IF key_round_sel > 0 THEN
          key_round_sel <= key_round_sel - 1;
        ELSE
          key_round_sel <= 0;
        END IF;
        next_state <= IDLE;

      WHEN ENCRYPT_INIT =>
        oi_buffer <= inp XOR key_round_kagi;
        key_round_sel <= 1 + key_round_sel;
        next_state <= IDLE;

      WHEN ENCRYPT_SUB =>
        outp <= oi_buffer;
        s_box_inp <= oi_buffer;
        next_state <= IDLE;

      WHEN ENCRYPT_SHIFT =>
        outp <= s_box_outp;
        le_shift_enable <= '1';
        le_shift_inp <= s_box_outp;
        IF le_shift_done = '1' THEN
          next_state <= IDLE;
        END IF;

      WHEN ENCRYPT_MIX =>
        outp <= le_shift_outp;
        el_mixer_enable <= '1';
        el_mixer_inp <= le_shift_outp;
        IF el_mixer_done = '1' THEN
          next_state <= IDLE;
        END IF;

      WHEN ENCRYPT_ROUND =>
        outp <= el_mixer_outp;
        IF key_round_sel = 10 THEN
          key_round_inp <= le_shift_outp;
        ELSE
          key_round_inp <= el_mixer_outp;
        END IF;
        next_state <= IDLE;

      WHEN ENCRYPT_FINAL =>
        oi_buffer <= key_round_outp;
        outp <= key_round_outp;
        -- key_round_sel <= 1 + key_round_sel;
        IF key_round_sel < 10 THEN
          key_round_sel <= key_round_sel + 1;
        ELSE
          key_round_sel <= 10;
        END IF;
        next_state <= IDLE;

      WHEN OTHERS =>
        next_state <= IDLE;
    END CASE;
  END PROCESS;

END main_architecture;