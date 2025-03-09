WITH token_trades AS (
    SELECT 
        trader_id AS trader,
        token_bought_mint_address AS bought_address,
        token_sold_mint_address AS sold_address,
        amount_usd,
        block_month,  
        CASE 
            WHEN token_bought_mint_address = '{{token_address}}' THEN 'Buy'
            WHEN token_sold_mint_address = '{{token_address}}' THEN 'Sell'
            ELSE NULL
        END AS action
    FROM dex_solana.trades
    WHERE 
        (token_bought_mint_address = '{{token_address}}' OR token_sold_mint_address = '{{token_address}}')
        AND block_month = date '{{month}}'
)
SELECT 
    trader,
    SUM(CASE WHEN action = 'Buy' THEN amount_usd ELSE 0 END) AS total_buy,
    SUM(CASE WHEN action = 'Sell' THEN amount_usd ELSE 0 END) AS total_sell,
    COUNT(CASE WHEN action = 'Buy' THEN 1 END) AS buy_trades,
    COUNT(CASE WHEN action = 'Sell' THEN 1 END) AS sell_trades
FROM token_trades
GROUP BY trader
HAVING 
    SUM(CASE WHEN action = 'Buy' THEN amount_usd ELSE 0 END) BETWEEN 15 AND 25
    AND SUM(CASE WHEN action = 'Sell' THEN amount_usd ELSE 0 END) BETWEEN 1000 AND 1200
ORDER BY total_sell DESC;
