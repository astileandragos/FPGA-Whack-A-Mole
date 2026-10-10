library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity driver7seg is
    Port ( clk : in STD_LOGIC; 
           Din : in STD_LOGIC_VECTOR (31 downto 0); 
           an : out STD_LOGIC_VECTOR (7 downto 0); 
           seg : out STD_LOGIC_VECTOR (0 to 6); 
           dp_in : in STD_LOGIC_VECTOR (7 downto 0); 
           dp_out : out STD_LOGIC; 
           rst : in STD_LOGIC); 
end driver7seg;

architecture Behavioral of driver7seg is

signal en_1kHz : STD_LOGIC;
signal state : STD_LOGIC_VECTOR(16 downto 0);
signal addr : STD_LOGIC_VECTOR(2 downto 0);
signal cseg : STD_LOGIC_VECTOR(3 downto 0);

begin

div1kHz: process(clk, rst)
begin
   if rst = '1' then 
        state <= '0' & X"0000";
        en_1kHz <= '0';
   elsif rising_edge(clk) then
        if state = '1' & X"869F" then 
            state <= '0' & X"0000"; 
            en_1kHz <= '1';
        else
            state <= state + 1;
            en_1kHz <= '0';
        end if;
   end if;         
end process;

counter_3bits: process(clk, rst)
begin
  if rst = '1' then
      addr <= "000";
  elsif rising_edge(clk) then       
      if en_1kHz = '1' then
          addr <= addr + 1;   
      end if;
  end if;   
end process;

dcd3_8: process(addr)
begin
  case addr is
      when "000" => an <= "01111111";       
      when "001" => an <= "10111111"; 
      when "010" => an <= "11011111"; 
      when "011" => an <= "11101111"; 
      when "100" => an <= "11110111"; 
      when "101" => an <= "11111011"; 
      when "110" => an <= "11111101"; 
      when "111" => an <= "11111110"; 
      when others => an <= "11111111";
   end case; 
end process;

data_mux8: process(addr,Din,dp_in)
begin
  case addr is
      when "000" => cseg <= Din(31 downto 28); dp_out <= not dp_in(7);
      when "001" => cseg <= Din(27 downto 24); dp_out <= not dp_in(6);
      when "010" => cseg <= Din(23 downto 20); dp_out <= not dp_in(5);
      when "011" => cseg <= Din(19 downto 16); dp_out <= not dp_in(4);
      when "100" => cseg <= Din(15 downto 12); dp_out <= not dp_in(3);
      when "101" => cseg <= Din(11 downto 8);  dp_out <= not dp_in(2);
      when "110" => cseg <= Din(7 downto 4);   dp_out <= not dp_in(1);
      when "111" => cseg <= Din(3 downto 0);   dp_out <= not dp_in(0);
      when others => cseg <= "XXXX"; dp_out <= 'X';
   end case; 
end process;

dcd7seg:process(cseg)
begin
  case cseg is
      when "0000" =>  seg <= "0000001"; 
      when "0001" =>  seg <= "1001111"; 
      when "0010" =>  seg <= "0010010"; 
      when "0011" =>  seg <= "0000110"; 
      when "0100" =>  seg <= "1001100"; 
      when "0101" =>  seg <= "0100100"; 
      when "0110" =>  seg <= "0100000"; 
      when "0111" =>  seg <= "0001111";
      when "1000" =>  seg <= "0000000"; 
      when "1001" =>  seg <= "0000100"; 
      when "1010" =>  seg <= "1110001"; 
      when "1011" =>  seg <= "1100000"; 
      when "1100" =>  seg <= "0110001"; 
      when "1101" =>  seg <= "1000010"; 
      when "1110" =>  seg <= "0110000"; 
      when "1111" =>  seg <= "1111111"; 
      when others => seg <= "XXXXXXX";
   end case; 
end process;

end Behavioral;