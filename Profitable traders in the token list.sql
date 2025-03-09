WITH token_trades AS (
    SELECT 
        trader_id AS trader,
        token_bought_mint_address AS bought_address,
        token_sold_mint_address AS sold_address,
        amount_usd,
        token_bought_amount,
        token_sold_amount,
        block_month,
        CASE 
            WHEN token_bought_mint_address IN (
'3n9Dk5r3GWAqPhRtUFmhBxGRQ4cvU7gQ6zJBj4Y9pump',  
'AtpvhwYfYDny4D9qca4UktnSaa4FLAmdo2s4rncApump',  
'JDqVV29BHCNLTEm5Pqgft8xPshEqMEDFDY4TAPwqpump',  
'7P9vjHjSte1KJDMftkJEfLww3tJDiMCwKHJ89oDipump',  
'D4QLMh4cANSHTfrfANARVpjRPAUTsXMwncJmCzETpump',  
'4nf5jUVLpD9QbsiqUwCE7LvVpWrEGAytjNdKN3GUpump',  
'5tBYYeGJjHf9SE1sbHWHR72oCgc2Xfre138aEPnKpump',  
'Hre4bwCBEDiLyBm8kLruW3WFv15QUpqvB18t95JUpump',  
'6xjQ2seBDYLfcudK5HkFa8o9DPi6t4DfiBbZLfd9pump',  
'39iPk3NUhFwa3YyZ1nn9pFzYBXQjUFquCL7GP8iMpump',  
'9fcfqnpSW3ifkZeaRS19uHeovDRBLy57V89zh2rtpump',  
'9gg9ikj4dzsrGy2fNYvjnFYLVuyNRyeLAW4tzDPZpump',  
'GVKRSpb3haXVNzU8Gx2PHMuHYf83DAuHrGDQjkua4PQh',  
'MhbLzHSkWtJWAJRSnhgzFi9dm8AxuyNa9XLahB1pump',  
'84oBUfjeodVZ6Zxym4MaCpez7T3BSvtmEmkAovDLpump',  
'DU7oCn61jiUMfujkTsbuDEcKpSJ77arDJZV6ynKipump',  
'GhgpTqBX7rNgXYVgz4E3kExpuiqaFMKh81wqeXwbpump',  
'ANtzwGATFL5a6bTnTVf8tXcFKsxZYTTSYnf6Cf7SGUPk'
) THEN token_bought_mint_address
WHEN token_sold_mint_address IN (
'3n9Dk5r3GWAqPhRtUFmhBxGRQ4cvU7gQ6zJBj4Y9pump',  
'AtpvhwYfYDny4D9qca4UktnSaa4FLAmdo2s4rncApump',  
'JDqVV29BHCNLTEm5Pqgft8xPshEqMEDFDY4TAPwqpump',  
'7P9vjHjSte1KJDMftkJEfLww3tJDiMCwKHJ89oDipump',  
'D4QLMh4cANSHTfrfANARVpjRPAUTsXMwncJmCzETpump',  
'4nf5jUVLpD9QbsiqUwCE7LvVpWrEGAytjNdKN3GUpump',  
'5tBYYeGJjHf9SE1sbHWHR72oCgc2Xfre138aEPnKpump',  
'Hre4bwCBEDiLyBm8kLruW3WFv15QUpqvB18t95JUpump',  
'6xjQ2seBDYLfcudK5HkFa8o9DPi6t4DfiBbZLfd9pump',  
'39iPk3NUhFwa3YyZ1nn9pFzYBXQjUFquCL7GP8iMpump',  
'9fcfqnpSW3ifkZeaRS19uHeovDRBLy57V89zh2rtpump',  
'9gg9ikj4dzsrGy2fNYvjnFYLVuyNRyeLAW4tzDPZpump',  
'GVKRSpb3haXVNzU8Gx2PHMuHYf83DAuHrGDQjkua4PQh',  
'MhbLzHSkWtJWAJRSnhgzFi9dm8AxuyNa9XLahB1pump',  
'84oBUfjeodVZ6Zxym4MaCpez7T3BSvtmEmkAovDLpump',  
'DU7oCn61jiUMfujkTsbuDEcKpSJ77arDJZV6ynKipump',  
'GhgpTqBX7rNgXYVgz4E3kExpuiqaFMKh81wqeXwbpump',  
'ANtzwGATFL5a6bTnTVf8tXcFKsxZYTTSYnf6Cf7SGUPk'
) THEN token_sold_mint_address
        END AS token_address,
        CASE 
            WHEN token_bought_mint_address IN (
'3n9Dk5r3GWAqPhRtUFmhBxGRQ4cvU7gQ6zJBj4Y9pump',  
'AtpvhwYfYDny4D9qca4UktnSaa4FLAmdo2s4rncApump',  
'JDqVV29BHCNLTEm5Pqgft8xPshEqMEDFDY4TAPwqpump',  
'7P9vjHjSte1KJDMftkJEfLww3tJDiMCwKHJ89oDipump',  
'D4QLMh4cANSHTfrfANARVpjRPAUTsXMwncJmCzETpump',  
'4nf5jUVLpD9QbsiqUwCE7LvVpWrEGAytjNdKN3GUpump',  
'5tBYYeGJjHf9SE1sbHWHR72oCgc2Xfre138aEPnKpump',  
'Hre4bwCBEDiLyBm8kLruW3WFv15QUpqvB18t95JUpump',  
'6xjQ2seBDYLfcudK5HkFa8o9DPi6t4DfiBbZLfd9pump',  
'39iPk3NUhFwa3YyZ1nn9pFzYBXQjUFquCL7GP8iMpump',  
'9fcfqnpSW3ifkZeaRS19uHeovDRBLy57V89zh2rtpump',  
'9gg9ikj4dzsrGy2fNYvjnFYLVuyNRyeLAW4tzDPZpump',  
'GVKRSpb3haXVNzU8Gx2PHMuHYf83DAuHrGDQjkua4PQh',  
'MhbLzHSkWtJWAJRSnhgzFi9dm8AxuyNa9XLahB1pump',  
'84oBUfjeodVZ6Zxym4MaCpez7T3BSvtmEmkAovDLpump',  
'DU7oCn61jiUMfujkTsbuDEcKpSJ77arDJZV6ynKipump',  
'GhgpTqBX7rNgXYVgz4E3kExpuiqaFMKh81wqeXwbpump',  
'ANtzwGATFL5a6bTnTVf8tXcFKsxZYTTSYnf6Cf7SGUPk'
) THEN 'Buy'
            WHEN token_sold_mint_address IN (
'3n9Dk5r3GWAqPhRtUFmhBxGRQ4cvU7gQ6zJBj4Y9pump',  
'AtpvhwYfYDny4D9qca4UktnSaa4FLAmdo2s4rncApump',  
'JDqVV29BHCNLTEm5Pqgft8xPshEqMEDFDY4TAPwqpump',  
'7P9vjHjSte1KJDMftkJEfLww3tJDiMCwKHJ89oDipump',  
'D4QLMh4cANSHTfrfANARVpjRPAUTsXMwncJmCzETpump',  
'4nf5jUVLpD9QbsiqUwCE7LvVpWrEGAytjNdKN3GUpump',  
'5tBYYeGJjHf9SE1sbHWHR72oCgc2Xfre138aEPnKpump',  
'Hre4bwCBEDiLyBm8kLruW3WFv15QUpqvB18t95JUpump',  
'6xjQ2seBDYLfcudK5HkFa8o9DPi6t4DfiBbZLfd9pump',  
'39iPk3NUhFwa3YyZ1nn9pFzYBXQjUFquCL7GP8iMpump',  
'9fcfqnpSW3ifkZeaRS19uHeovDRBLy57V89zh2rtpump',  
'9gg9ikj4dzsrGy2fNYvjnFYLVuyNRyeLAW4tzDPZpump',  
'GVKRSpb3haXVNzU8Gx2PHMuHYf83DAuHrGDQjkua4PQh',  
'MhbLzHSkWtJWAJRSnhgzFi9dm8AxuyNa9XLahB1pump',  
'84oBUfjeodVZ6Zxym4MaCpez7T3BSvtmEmkAovDLpump',  
'DU7oCn61jiUMfujkTsbuDEcKpSJ77arDJZV6ynKipump',  
'GhgpTqBX7rNgXYVgz4E3kExpuiqaFMKh81wqeXwbpump',  
'ANtzwGATFL5a6bTnTVf8tXcFKsxZYTTSYnf6Cf7SGUPk') THEN 'Sell'
            ELSE NULL
        END AS action
    FROM dex_solana.trades
    WHERE 
        (token_bought_mint_address IN (
'3n9Dk5r3GWAqPhRtUFmhBxGRQ4cvU7gQ6zJBj4Y9pump',  
'AtpvhwYfYDny4D9qca4UktnSaa4FLAmdo2s4rncApump',  
'JDqVV29BHCNLTEm5Pqgft8xPshEqMEDFDY4TAPwqpump',  
'7P9vjHjSte1KJDMftkJEfLww3tJDiMCwKHJ89oDipump',  
'D4QLMh4cANSHTfrfANARVpjRPAUTsXMwncJmCzETpump',  
'4nf5jUVLpD9QbsiqUwCE7LvVpWrEGAytjNdKN3GUpump',  
'5tBYYeGJjHf9SE1sbHWHR72oCgc2Xfre138aEPnKpump',  
'Hre4bwCBEDiLyBm8kLruW3WFv15QUpqvB18t95JUpump',  
'6xjQ2seBDYLfcudK5HkFa8o9DPi6t4DfiBbZLfd9pump',  
'39iPk3NUhFwa3YyZ1nn9pFzYBXQjUFquCL7GP8iMpump',  
'9fcfqnpSW3ifkZeaRS19uHeovDRBLy57V89zh2rtpump',  
'9gg9ikj4dzsrGy2fNYvjnFYLVuyNRyeLAW4tzDPZpump',  
'GVKRSpb3haXVNzU8Gx2PHMuHYf83DAuHrGDQjkua4PQh',  
'MhbLzHSkWtJWAJRSnhgzFi9dm8AxuyNa9XLahB1pump',  
'84oBUfjeodVZ6Zxym4MaCpez7T3BSvtmEmkAovDLpump',  
'DU7oCn61jiUMfujkTsbuDEcKpSJ77arDJZV6ynKipump',  
'GhgpTqBX7rNgXYVgz4E3kExpuiqaFMKh81wqeXwbpump',  
'ANtzwGATFL5a6bTnTVf8tXcFKsxZYTTSYnf6Cf7SGUPk'
) 
        OR token_sold_mint_address IN (
'3n9Dk5r3GWAqPhRtUFmhBxGRQ4cvU7gQ6zJBj4Y9pump',  
'AtpvhwYfYDny4D9qca4UktnSaa4FLAmdo2s4rncApump',  
'JDqVV29BHCNLTEm5Pqgft8xPshEqMEDFDY4TAPwqpump',  
'7P9vjHjSte1KJDMftkJEfLww3tJDiMCwKHJ89oDipump',  
'D4QLMh4cANSHTfrfANARVpjRPAUTsXMwncJmCzETpump',  
'4nf5jUVLpD9QbsiqUwCE7LvVpWrEGAytjNdKN3GUpump',  
'5tBYYeGJjHf9SE1sbHWHR72oCgc2Xfre138aEPnKpump',  
'Hre4bwCBEDiLyBm8kLruW3WFv15QUpqvB18t95JUpump',  
'6xjQ2seBDYLfcudK5HkFa8o9DPi6t4DfiBbZLfd9pump',  
'39iPk3NUhFwa3YyZ1nn9pFzYBXQjUFquCL7GP8iMpump',  
'9fcfqnpSW3ifkZeaRS19uHeovDRBLy57V89zh2rtpump',  
'9gg9ikj4dzsrGy2fNYvjnFYLVuyNRyeLAW4tzDPZpump',  
'GVKRSpb3haXVNzU8Gx2PHMuHYf83DAuHrGDQjkua4PQh',  
'MhbLzHSkWtJWAJRSnhgzFi9dm8AxuyNa9XLahB1pump',  
'84oBUfjeodVZ6Zxym4MaCpez7T3BSvtmEmkAovDLpump',  
'DU7oCn61jiUMfujkTsbuDEcKpSJ77arDJZV6ynKipump',  
'GhgpTqBX7rNgXYVgz4E3kExpuiqaFMKh81wqeXwbpump',  
'ANtzwGATFL5a6bTnTVf8tXcFKsxZYTTSYnf6Cf7SGUPk'
))
        AND CAST(block_month AS DATE) >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '365' DAY)
        AND CAST(block_time AS DATE) >= CURRENT_DATE - INTERVAL '365' DAY
),
trade_summary AS (
    SELECT 
        trader,
        token_address,
        SUM(CASE WHEN action = 'Buy' THEN amount_usd ELSE 0 END) AS total_buy_usd,
        SUM(CASE WHEN action = 'Sell' THEN amount_usd ELSE 0 END) AS total_sell_usd
    FROM token_trades
    GROUP BY trader, token_address
),
high_profit_traders AS (
    SELECT 
        trader,
        token_address
    FROM trade_summary
    WHERE ((total_sell_usd - total_buy_usd) / NULLIF(total_buy_usd, 0)) * 100 > 300
),
trader_token_count AS (
    SELECT 
        trader,
        COUNT(DISTINCT token_address) AS traded_tokens
    FROM high_profit_traders
    GROUP BY trader
)
SELECT 
    trader,
    traded_tokens
FROM trader_token_count
WHERE traded_tokens >= 5 
ORDER BY traded_tokens DESC;
