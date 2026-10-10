library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer is
    Port ( clk     : in  STD_LOGIC;
           btn_in  : in  STD_LOGIC;
           btn_out : out STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is

    signal count : integer range 0 to 1000000 := 0;
    signal state : std_logic := '0';   
    signal sync_0, sync_1 : std_logic := '0';
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            sync_0 <= btn_in;
            sync_1 <= sync_0;
            
            if sync_1 /= state then
                count <= count + 1;
                if count = 1000000 then 
                    state <= sync_1;
                    count <= 0;
                end if;
            else
                count <= 0;
            end if;
        end if;
    end process;
    
    btn_out <= state;
end Behavioral;