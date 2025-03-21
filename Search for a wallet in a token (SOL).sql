WITH token_trades AS (
    SELECT 
        trader_id AS trader,
        token_bought_mint_address AS bought_address,
        token_sold_mint_address AS sold_address,
        token_bought_amount,
        token_sold_amount,
        block_month,  
        CASE 
            WHEN token_bought_mint_address = '{{token_address}}' THEN 'Buy'
            WHEN token_sold_mint_address = '{{token_address}}' THEN 'Sell'
            ELSE NULL
        END AS action
    FROM dex_solana.trades
    WHERE 
        (token_bought_mint_address = '{{token_address}}' OR token_sold_mint_address = '{{token_address}}')
        AND block_month = DATE '{{month}}'
),
sol_trades AS (
    SELECT 
        trader,
        SUM(CASE WHEN action = 'Buy' THEN token_sold_amount ELSE 0 END) AS total_buy_sol,
        SUM(CASE WHEN action = 'Sell' THEN token_bought_amount ELSE 0 END) AS total_sell_sol,
        COUNT(CASE WHEN action = 'Buy' THEN 1 END) AS buy_trades,
        COUNT(CASE WHEN action = 'Sell' THEN 1 END) AS sell_trades
    FROM token_trades
    WHERE action IS NOT NULL
    GROUP BY trader
)
SELECT 
    trader,
    total_buy_sol,
    total_sell_sol,
    buy_trades,
    sell_trades
FROM sol_trades
WHERE 
    total_buy_sol BETWEEN 0.1 AND 0.2 -- Пример фильтра по покупке в SOL
    AND total_sell_sol BETWEEN 0.3 AND 1 -- Пример фильтра по продаже в SOL
ORDER BY total_sell_sol DESC;
