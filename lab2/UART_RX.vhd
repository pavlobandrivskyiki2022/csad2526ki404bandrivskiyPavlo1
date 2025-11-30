library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RX is
    generic (
        CLK_FREQ  : integer := 50000000; -- Частота 50 МГц
        BAUD_RATE : integer := 9600      -- Швидкість 9600
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        rx_line   : in  std_logic;                    -- Вхідна лінія Rx
        data_out  : out std_logic_vector(7 downto 0); -- Прийнятий байт
        rx_done   : out std_logic                     -- Імпульс готовності (1 = є нові дані)
    );
end UART_RX;

architecture Behavioral of UART_RX is
    constant BIT_PERIOD : integer := CLK_FREQ / BAUD_RATE;
    
    type state_type is (IDLE, START, DATA, STOP);
    signal state : state_type := IDLE;
    
    signal clk_cnt  : integer range 0 to BIT_PERIOD := 0;
    signal bit_idx  : integer range 0 to 7 := 0;
    signal rx_buffer : std_logic_vector(7 downto 0) := (others => '0');
    
begin

    process(clk, reset)
    begin
        if reset = '0' then
            state    <= IDLE;
            clk_cnt  <= 0;
            bit_idx  <= 0;
            data_out <= (others => '0');
            rx_done  <= '0';
        elsif rising_edge(clk) then
            rx_done <= '0'; -- Скидаємо прапорець за замовчуванням
            
            case state is
                -- 1. Очікування: чекаємо, поки лінія впаде в 0 (Start bit)
                when IDLE =>
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if rx_line = '0' then
                        state <= START;
                    end if;

                -- 2. Перевірка Старт-біта (зчитуємо в середині інтервалу)
                when START =>
                    if clk_cnt = BIT_PERIOD / 2 then
                        if rx_line = '0' then -- Якщо все ще 0, значить це справді старт
                            clk_cnt <= 0;
                            state   <= DATA;
                        else
                            state <= IDLE; -- Помилкова тривога (шум)
                        end if;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;

                -- 3. Зчитування 8 біт даних
                when DATA =>
                    if clk_cnt < BIT_PERIOD - 1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= 0;
                        rx_buffer(bit_idx) <= rx_line; -- Запам'ятовуємо біт
                        
                        if bit_idx < 7 then
                            bit_idx <= bit_idx + 1;
                        else
                            bit_idx <= 0;
                            state   <= STOP;
                        end if;
                    end if;

                -- 4. Стоп-біт
                when STOP =>
                    if clk_cnt < BIT_PERIOD - 1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= 0;
                        state    <= IDLE;
                        data_out <= rx_buffer; -- Видаємо зібраний байт на вихід
                        rx_done  <= '1';       -- Сигналимо, що дані готові
                    end if;
            end case;
        end if;
    end process;

end Behavioral;