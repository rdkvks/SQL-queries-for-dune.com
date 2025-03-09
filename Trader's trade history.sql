WITH wallet_action AS (
    SELECT 
        trader_id AS trader,
        project, 
        block_time, 
        amount_usd,
        CAST(block_time AS DATE) AS trade_date,  
        CASE 
            WHEN token_bought_symbol = 'SOL' THEN 'Sell'
            WHEN token_sold_symbol = 'SOL' THEN 'Buy'
            ELSE NULL
        END AS action,
        CASE 
            WHEN token_bought_symbol != 'SOL' THEN token_bought_symbol
            WHEN token_sold_symbol != 'SOL' THEN token_sold_symbol
            ELSE NULL
        END AS token_name,
        CASE 
            WHEN token_bought_symbol = 'SOL' THEN token_sold_amount
            WHEN token_sold_symbol = 'SOL' THEN token_bought_amount
            ELSE 0
        END AS token_amount,
        CASE
            WHEN token_bought_symbol != 'SOL' THEN token_bought_mint_address
            WHEN token_sold_symbol != 'SOL' THEN token_sold_mint_address
            ELSE 'So11111111111111111111111111111111111111112'
        END AS token_address
    FROM dex_solana.trades
    WHERE 
        CAST(block_month AS DATE) >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '{{period}}' DAY)
        AND CAST(block_time AS DATE) >= CURRENT_DATE - INTERVAL '{{period}}' DAY
),
trade_data AS (
    SELECT 
        trader,
        token_name,
        token_address,
        COUNT(DISTINCT token_name) AS traded_tokens,  
        SUM(CASE WHEN action = 'Buy' THEN amount_usd ELSE 0 END) AS total_buy,
        SUM(CASE WHEN action = 'Sell' THEN amount_usd ELSE 0 END) AS total_sell,
        SUM(CASE WHEN action = 'Sell' THEN amount_usd ELSE 0 END) -
        SUM(CASE WHEN action = 'Buy' THEN amount_usd ELSE 0 END) AS PNL,
        SUM(CASE WHEN action = 'Buy' THEN token_amount ELSE 0 END) AS total_token_buy,
        SUM(CASE WHEN action = 'Sell' THEN token_amount ELSE 0 END) AS total_token_sell,
        MIN(CASE WHEN action = 'Buy' THEN block_time END) AS first_buy_time,
        MAX(CASE WHEN action = 'Sell' THEN block_time END) AS last_sell_time,
        COUNT(CASE WHEN action = 'Buy' THEN 1 END) AS total_buy_trades,
        COUNT(*) AS total_trades,  
        COUNT(DISTINCT trade_date) AS trading_days  
    FROM wallet_action
    WHERE trader = '{{wallet}}'
    GROUP BY trader, token_name, token_address
)
SELECT
    token_name,
    total_buy,
    total_sell,
    PNL,
    total_token_buy,
    total_token_sell,
    first_buy_time,
    last_sell_time,
    token_address
FROM trade_data
WHERE total_buy > 0  
ORDER BY first_buy_time desc
