library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    Port ( clk      : in STD_LOGIC;
           r        : in STD_LOGIC;
           sw       : in STD_LOGIC_VECTOR (15 downto 0);
           led      : out STD_LOGIC_VECTOR (15 downto 0);
           an       : out STD_LOGIC_VECTOR (7 downto 0); 
           seg      : out STD_LOGIC_VECTOR (0 to 6);
           dp       : out std_logic 
           );
end fsm;

architecture Behavioral of fsm is

component driver7seg is
    Port ( clk      : in STD_LOGIC; 
           Din      : in STD_LOGIC_VECTOR (31 downto 0); 
           an       : out STD_LOGIC_VECTOR (7 downto 0); 
           seg      : out STD_LOGIC_VECTOR (0 to 6); 
           dp_in    : in STD_LOGIC_VECTOR (7 downto 0); 
           dp_out   : out STD_LOGIC; 
           rst      : in STD_LOGIC); 
end component;

component debouncer is
    Port ( clk     : in  STD_LOGIC;
           btn_in  : in  STD_LOGIC;
           btn_out : out STD_LOGIC);
end component;

type states is (start, get_rnd, led_on, sw_on, sw_off, led_off, count, blink, game_over, reg_mistake, mistake_wait);
signal current_state, next_state: states;

signal i: integer range 0 to 15;
signal i_bin: std_logic_vector(3 downto 0);
signal score: std_logic_vector(15 downto 0);
signal display_data: std_logic_vector(31 downto 0);

signal mistakes: integer range 0 to 4 := 0;
signal blink_cnt: integer range 0 to 25000000 := 0;
signal blink_toggles: integer range 0 to 6 := 0;
signal led_reg: std_logic_vector(15 downto 0) := (others => '0');
signal an_internal : std_logic_vector(7 downto 0);

signal sw_clean: std_logic_vector(15 downto 0);
signal m, s, z, u : integer range 0 to 9 := 0;

begin
    led <= led_reg;
    an <= x"FF" when (current_state = blink and led_reg(0) = '1') else an_internal;
    
    display_data <= score & x"A05E" when current_state = game_over else x"FFFF" & score;

    gen_debouncers: for j in 0 to 15 generate
        deb_inst: debouncer port map (clk => clk, 
        btn_in => sw(j), 
        btn_out => sw_clean(j));
    end generate;

    Memoria_CLS: process(clk, r)
    begin
      if r = '1' then current_state <= start;
      elsif rising_edge(clk) then current_state <= next_state;
      end if;
    end process;

    CLC: process(current_state, sw_clean, i, mistakes, blink_toggles, z)
    begin
      case current_state is
        when start   => next_state <= get_rnd;
        when get_rnd => next_state <= led_on;
        when led_on  => next_state <= sw_on;
        when sw_on   => 
            if sw_clean(i) = '1' then next_state <= sw_off;
            elsif unsigned(sw_clean) /= 0 and sw_clean(i) = '0' then next_state <= reg_mistake;
            else next_state <= sw_on; end if;
        when sw_off  => 
            if unsigned(sw_clean) = 0 then next_state <= led_off;
            else next_state <= sw_off; end if;     
        when reg_mistake => next_state <= mistake_wait;
        when mistake_wait =>
            if mistakes >= 3 then next_state <= game_over;
            elsif unsigned(sw_clean) = 0 then next_state <= get_rnd;
            else next_state <= mistake_wait; end if;
        when led_off => next_state  <= count;
        when count   => 
            if z = 9 then next_state <= blink; else next_state <= get_rnd; end if;
        when blink   => 
            if blink_toggles = 6 then next_state <= get_rnd; else next_state <= blink; end if;
        when game_over => next_state <= game_over;
        when others  => next_state <= start;                         
      end case;
    end process;

    LFSR: process(clk, r)
        variable shiftreg: std_logic_vector(15 downto 0) := x"ABCD";
        variable firstbit: std_logic;
    begin
       if r = '1' then shiftreg := x"ABCD"; i_bin <= x"D";
       elsif rising_edge(clk) then 
         firstbit := shiftreg(1) xnor shiftreg(0);
         shiftreg := firstbit & shiftreg(15 downto 1);
         i_bin <= shiftreg(3 downto 0);
       end if;
    end process;

    Control_Reg: process(clk, r)
    begin
      if r = '1' then
        i <= 13; led_reg <= x"0000"; mistakes <= 0;
        u <= 0; z <= 0; s <= 0; m <= 0;
        blink_cnt <= 0; blink_toggles <= 0;
      elsif rising_edge(clk) then 
        if current_state = get_rnd then i <= to_integer(unsigned(i_bin)); end if;
        if current_state = led_on then led_reg(i) <= '1';
        elsif current_state = led_off then led_reg(i) <= '0'; end if;

        if current_state = reg_mistake then mistakes <= mistakes + 1; led_reg(i) <= '0'; end if;

        if current_state = count then
            if u = 9 then
                u <= 0;
                if z = 9 then
                    z <= 0;
                    if s = 9 then
                        s <= 0;
                        if m = 9 then m <= 0; else m <= m + 1; end if;
                    else s <= s + 1; end if;
                else z <= z + 1; end if;
            else u <= u + 1; end if;
        end if;

        if current_state = blink then
            if blink_cnt = 25000000 then 
                blink_cnt <= 0; led_reg <= not led_reg; blink_toggles <= blink_toggles + 1;
            else blink_cnt <= blink_cnt + 1; end if;
        elsif current_state = get_rnd then
            blink_toggles <= 0; led_reg <= x"0000";
        end if;
        
        if current_state = game_over then led_reg <= x"FFFF"; end if;
      end if;
    end process;

    score <= std_logic_vector(TO_UNSIGNED(m,4)) &
             std_logic_vector(TO_UNSIGNED(s,4)) &
             std_logic_vector(TO_UNSIGNED(z,4)) &
             std_logic_vector(TO_UNSIGNED(u,4));       

    U_driver: driver7seg port map(
        clk=>clk, rst=>r, Din=>display_data, seg=>seg, an=>an_internal, dp_in=>x"00", dp_out=>dp
    );

end Behavioral;