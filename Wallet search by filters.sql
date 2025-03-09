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
        CAST(block_month AS DATE) >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '3' DAY)
        AND CAST(block_time AS DATE) >= CURRENT_DATE - INTERVAL '3' DAY
),
trade_data AS (
    SELECT 
        trader,
        token_name,
        COUNT(DISTINCT token_name) AS traded_tokens,  
        SUM(CASE WHEN action = 'Buy' THEN amount_usd ELSE 0 END) AS total_buy,
        SUM(CASE WHEN action = 'Sell' THEN amount_usd ELSE 0 END) AS total_sell,
        SUM(CASE WHEN action = 'Buy' THEN token_amount ELSE 0 END) AS total_token_buy,
        SUM(CASE WHEN action = 'Sell' THEN token_amount ELSE 0 END) AS total_token_sell,
        SUM(CASE WHEN action = 'Buy' THEN token_amount ELSE 0 END) -
        SUM(CASE WHEN action = 'Sell' THEN token_amount ELSE 0 END) AS not_sold, 
        MIN(CASE WHEN action = 'Buy' THEN block_time END) AS first_buy_time,
        MAX(CASE WHEN action = 'Sell' THEN block_time END) AS last_sell_time,
        COUNT(CASE WHEN action = 'Buy' THEN 1 END) AS total_buy_trades,
        COUNT(*) AS total_trades,  
        COUNT(DISTINCT trade_date) AS trading_days  
    FROM wallet_action
    GROUP BY trader, token_name
),
trade_stats AS (
    SELECT 
        trader,
        token_name,
        total_trades,
        total_buy,
        total_sell,
        total_token_buy,
        total_token_sell,
        not_sold,
        total_sell - total_buy AS PNL_without_not_sold, 
        first_buy_time,
        last_sell_time,
        total_buy_trades,
        trading_days,
        CASE WHEN total_sell > total_buy THEN 1 ELSE 0 END AS profitable_trades,
        CASE WHEN total_sell <= total_buy THEN 1 ELSE 0 END AS unprofitable_trades,
        CASE WHEN (total_sell - total_buy) >= total_buy * 0.5 THEN 1 ELSE 0 END AS profitable_trades_50,
        100 * ((total_sell - total_buy) / NULLIF(total_buy, 0)) AS profit_on_100
    FROM trade_data
    WHERE total_buy > 0  
),
latest_balances AS (
    SELECT 
        address, 
        sol_balance
    FROM solana_utils.latest_balances
    ORDER BY address, block_time DESC
),
wallet_summary AS (
    SELECT
        t.trader,
        COUNT(DISTINCT t.token_name) AS total_trades,  
        ROUND(SUM(t.PNL_without_not_sold), 2) AS total_PNL,  
        ROUND((SUM(t.PNL_without_not_sold) / NULLIF(SUM(t.total_buy), 0)) * 100, 2) AS avg_PNL_percent,  
        DATE_DIFF('minute', MIN(t.first_buy_time), MAX(t.last_sell_time)) / NULLIF(COUNT(*), 0) AS avg_time_in_trade,  
        ROUND((SUM(t.PNL_without_not_sold) / SUM(t.total_buy + t.total_sell) * 100), 2) AS PNL_weighted_by_turnover,  
        ROUND((SUM(t.PNL_without_not_sold) / MAX(t.total_buy)), 2) AS PNL_weighted_by_risk,  
        ROUND(AVG(t.total_buy / NULLIF(t.total_buy_trades, 0)), 2) AS avg_trade_size,  
        SUM(t.total_trades) / NULLIF(SUM(t.trading_days), 0) AS avg_trades_per_day,  
        
        SUM(t.unprofitable_trades) AS unprofitable_trades,
        SUM(t.profitable_trades) AS profitable_trades,
        SUM(t.profitable_trades_50) AS profitable_trades_50,

        ROUND((SUM(t.profitable_trades) * 100.0 / NULLIF(COUNT(*), 0)), 2) AS winrate,
        ROUND((SUM(t.profitable_trades_50) * 100.0 / NULLIF(SUM(t.profitable_trades), 0)), 2) AS wr50,

        ROUND((SUM(t.PNL_without_not_sold) / NULLIF(SUM(t.total_buy), 0)) * 100, 2) AS ROI,
        ROUND((SUM(t.PNL_without_not_sold) / NULLIF(SUM(t.total_buy), 0)) * 100, 2) AS avg_ROI_per_trade,
        ROUND(SUM(t.profit_on_100), 2) AS total_profit_on_100,

        SUM(CASE WHEN t.total_sell > t.total_buy AND t.total_sell <= t.total_buy * 2 THEN 1 ELSE 0 END) AS trades_1_100,  
        SUM(CASE WHEN t.total_sell > t.total_buy * 2 AND t.total_sell <= t.total_buy * 3 THEN 1 ELSE 0 END) AS trades_100_200,  
        SUM(CASE WHEN t.total_sell > t.total_buy * 3 AND t.total_sell <= t.total_buy * 4 THEN 1 ELSE 0 END) AS trades_200_300,  
        SUM(CASE WHEN t.total_sell > t.total_buy * 4 AND t.total_sell <= t.total_buy * 5 THEN 1 ELSE 0 END) AS trades_300_400,  
        SUM(CASE WHEN t.total_sell > t.total_buy * 5 THEN 1 ELSE 0 END) AS trades_400_plus,  

        COALESCE(lb.sol_balance, 0) AS latest_sol_balance 
    FROM trade_stats t
    LEFT JOIN latest_balances lb ON t.trader = lb.address
    GROUP BY t.trader, lb.sol_balance
)
SELECT *
FROM wallet_summary
WHERE ROI > 100
  AND total_trades < 70
  AND winrate >= 30
  AND winrate <= 90
  AND avg_time_in_trade >= 20
  AND total_trades > 5
  AND avg_trade_size > 50
  AND PNL_weighted_by_risk >= 2
  AND PNL_weighted_by_risk <= 50
  AND avg_trades_per_day >= 1
  AND avg_trades_per_day <= 10
  AND latest_sol_balance > 1
  AND trades_200_300 > 1
ORDER BY PNL_weighted_by_risk DESC
