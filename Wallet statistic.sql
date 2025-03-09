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
        END AS token_amount
    FROM dex_solana.trades
    WHERE 
        CAST(block_month AS DATE) >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '{{Period}}' DAY)
        AND CAST(block_time AS DATE) >= CURRENT_DATE - INTERVAL '{{Period}}' DAY
),
trade_data AS (
    SELECT 
        trader,
        token_name,
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
    WHERE trader = '{{wallet address}}'
    GROUP BY trader, token_name
),
trade_stats AS (
    SELECT 
        trader,
        token_name,
        total_trades,
        PNL,
        total_buy,
        total_sell,
        total_token_buy,
        total_token_sell,
        first_buy_time,
        last_sell_time,
        total_buy_trades,
        trading_days,
        CASE WHEN total_sell > total_buy THEN 1 ELSE 0 END AS profitable_trades,
        CASE WHEN total_sell <= total_buy THEN 1 ELSE 0 END AS unprofitable_trades
    FROM trade_data
    WHERE total_buy > 0  
),
wallet_summary AS (
    SELECT
        trader,
        COUNT(DISTINCT token_name) AS total_trades,  
        ROUND(SUM(PNL), 2) AS total_PNL,  
        ROUND((SUM(PNL) / NULLIF(SUM(total_buy), 0)) * 100, 2) AS avg_PNL_percent,  
        DATE_DIFF('minute', MIN(first_buy_time), MAX(last_sell_time)) / NULLIF(COUNT(*), 0) AS avg_time_in_trade,  
        ROUND((SUM(PNL) / SUM(total_buy + total_sell) * 100), 2) AS PNL_weighted_by_turnover,  
        ROUND((SUM(PNL) / MAX(total_buy)), 2) AS PNL_weighted_by_risk,  
        ROUND(AVG(total_buy / NULLIF(total_buy_trades, 0)), 2) AS avg_trade_size,  
        SUM(total_trades) / NULLIF(SUM(trading_days), 0) AS avg_trades_per_day,  
        SUM(unprofitable_trades) AS unprofitable_trades,
        SUM(profitable_trades) AS profitable_trades,
        ROUND((SUM(profitable_trades) * 100.0 / NULLIF(COUNT(*), 0)), 2) AS winrate,
        ROUND((SUM(PNL) / NULLIF(SUM(total_buy), 0)) * 100, 2) AS ROI,
        ROUND((SUM(PNL) / NULLIF(SUM(total_buy), 0)) * 100, 2) AS avg_ROI_per_trade,  
        SUM(CASE WHEN total_sell > total_buy AND total_sell <= total_buy * 2 THEN 1 ELSE 0 END) AS trades_1_100,  
        SUM(CASE WHEN total_sell > total_buy * 2 AND total_sell <= total_buy * 3 THEN 1 ELSE 0 END) AS trades_100_200,  
        SUM(CASE WHEN total_sell > total_buy * 3 AND total_sell <= total_buy * 4 THEN 1 ELSE 0 END) AS trades_200_300,  
        SUM(CASE WHEN total_sell > total_buy * 4 AND total_sell <= total_buy * 5 THEN 1 ELSE 0 END) AS trades_300_400,  
        SUM(CASE WHEN total_sell > total_buy * 5 THEN 1 ELSE 0 END) AS trades_400_plus  
    FROM trade_stats
    GROUP BY trader
)
SELECT * FROM wallet_summary;
