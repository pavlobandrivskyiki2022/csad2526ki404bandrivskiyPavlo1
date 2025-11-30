library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX is
    generic (
        CLK_FREQ  : integer := 50000000; -- Тактова частота плати (50 МГц)
        BAUD_RATE : integer := 9600      -- Бажана швидкість UART
    );
    port (
        clk       : in  std_logic;                    -- Тактовий сигнал
        reset     : in  std_logic;                    -- Скидання (активний 0)
        tx_start  : in  std_logic;                    -- Команда почати передачу
        data_in   : in  std_logic_vector(7 downto 0); -- Байт даних для передачі
        tx_line   : out std_logic;                    -- Вихідна лінія Tx
        tx_busy   : out std_logic                     -- Статус: 1 - зайнятий, 0 - готовий
    );
end UART_TX;

architecture Behavioral of UART_TX is
    -- Розрахунок дільника частоти
    constant BIT_PERIOD : integer := CLK_FREQ / BAUD_RATE;
    
    -- Оголошення станів FSM (згідно твоєї діаграми)
    type state_type is (IDLE, START, DATA, STOP);
    signal state : state_type := IDLE;
    
    -- Внутрішні сигнали
    signal clk_cnt  : integer range 0 to BIT_PERIOD := 0; -- Лічильник для таймінгу біта
    signal bit_idx  : integer range 0 to 7 := 0;          -- Індекс біта (0..7)
    signal data_reg : std_logic_vector(7 downto 0) := (others => '0'); -- Буфер даних
    
begin

    process(clk, reset)
    begin
        if reset = '0' then
            state   <= IDLE;
            tx_line <= '1'; -- У стані спокою лінія завжди 1
            tx_busy <= '0';
            clk_cnt <= 0;
            bit_idx <= 0;
        elsif rising_edge(clk) then
            case state is
                
                -- 1. Стан Очікування
                when IDLE =>
                    tx_line <= '1';
                    tx_busy <= '0';
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    
                    if tx_start = '1' then
                        data_reg <= data_in; -- Запам'ятовуємо вхідні дані
                        state    <= START;
                        tx_busy  <= '1';
                    end if;

                -- 2. Старт-біт (логічний 0)
                when START =>
                    tx_line <= '0'; -- Опускаємо лінію
                    
                    if clk_cnt < BIT_PERIOD - 1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= 0;
                        state   <= DATA;
                    end if;

                -- 3. Передача даних (8 біт)
                when DATA =>
                    tx_line <= data_reg(bit_idx); -- Виводимо поточний біт
                    
                    if clk_cnt < BIT_PERIOD - 1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= 0;
                        if bit_idx < 7 then
                            bit_idx <= bit_idx + 1; -- Переходимо до наступного біта
                        else
                            bit_idx <= 0;
                            state   <= STOP; -- Усі біти передано
                        end if;
                    end if;

                -- 4. Стоп-біт (логічна 1)
                when STOP =>
                    tx_line <= '1'; -- Піднімаємо лінію
                    
                    if clk_cnt < BIT_PERIOD - 1 then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= 0;
                        state   <= IDLE; -- Повертаємось до очікування
                    end if;
                    
            end case;
        end if;
    end process;

end Behavioral;