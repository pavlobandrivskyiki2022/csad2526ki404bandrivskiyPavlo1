library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TB is
    -- Testbench не має портів, бо це замкнута система
end UART_TB;

architecture Behavioral of UART_TB is

    -- Параметри (мають співпадати з модулями)
    constant CLK_FREQ  : integer := 50000000;
    constant BAUD_RATE : integer := 9600;
    constant CLK_PERIOD : time := 20 ns; -- 1/50MHz = 20ns

    -- Оголошуємо Передавач
    component UART_TX
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            tx_start  : in  std_logic;
            data_in   : in  std_logic_vector(7 downto 0);
            tx_line   : out std_logic;
            tx_busy   : out std_logic
        );
    end component;

    -- Оголошуємо Приймач
    component UART_RX
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            rx_line   : in  std_logic;
            data_out  : out std_logic_vector(7 downto 0);
            rx_done   : out std_logic
        );
    end component;

    -- Сигнали для з'єднання
    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';
    
    signal tx_start   : std_logic := '0';
    signal data_to_tx : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_busy    : std_logic;
    signal tx_rx_line : std_logic; -- Дріт, що з'єднує TX і RX
    
    signal data_from_rx : std_logic_vector(7 downto 0);
    signal rx_done      : std_logic;

begin

    -- Підключаємо Передавач
    UUT_TX: UART_TX 
        port map (
            clk => clk, reset => reset, tx_start => tx_start,
            data_in => data_to_tx, tx_line => tx_rx_line, tx_busy => tx_busy
        );

    -- Підключаємо Приймач (слухає той самий дріт tx_rx_line)
    UUT_RX: UART_RX 
        port map (
            clk => clk, reset => reset, rx_line => tx_rx_line,
            data_out => data_from_rx, rx_done => rx_done
        );

    -- Генерація тактової частоти (Clock)
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Сценарій тестування
    stim_proc: process
    begin
        -- 1. Скидання (Reset)
        reset <= '0';
        wait for 100 ns;
        reset <= '1';
        wait for 100 ns;

        -- 2. Відправка числа 171 (двійкове 10101011)
        data_to_tx <= "10101011"; 
        tx_start   <= '1'; -- Натискаємо кнопку "Start"
        wait for CLK_PERIOD;
        tx_start   <= '0'; -- Відпускаємо

        -- 3. Чекаємо, поки передача закінчиться
        -- (При швидкості 9600 це займе багато часу, близько 1 мс)
        wait for 1.2 ms;

        -- 4. Перевірка (для звіту)
        assert data_from_rx = "10101011"
            report "Test Failed! Received wrong data." severity error;
            
        report "Test Finished Successfully!" severity note;
        
        wait;
    end process;

end Behavioral;