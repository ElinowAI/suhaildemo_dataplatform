-- Transform : raw -> silver
-- Layer     : Silver (cleaned + aggregated)
-- Depends   : raw.sales_transactions

CREATE TABLE IF NOT EXISTS silver.sales_daily_summary (
    summary_date       DATE           NOT NULL,
    customer_id        VARCHAR(50)    NOT NULL,
    total_transactions INTEGER        NOT NULL DEFAULT 0,
    total_quantity     INTEGER        NOT NULL DEFAULT 0,
    total_revenue      DECIMAL(18,2)  NOT NULL DEFAULT 0.00,
    avg_order_value    DECIMAL(18,2)  NOT NULL DEFAULT 0.00,
    currency           VARCHAR(3)     NOT NULL DEFAULT 'USD',
    refreshed_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_daily PRIMARY KEY (summary_date, customer_id)
);

INSERT INTO silver.sales_daily_summary (
    summary_date, customer_id, total_transactions,
    total_quantity, total_revenue, avg_order_value, currency, refreshed_at
)
SELECT
    transaction_date, customer_id,
    COUNT(*), SUM(quantity), SUM(total_amount), AVG(total_amount),
    currency, CURRENT_TIMESTAMP
FROM raw.sales_transactions
WHERE ingested_at >= CURRENT_DATE - INTERVAL '1 day'
GROUP BY transaction_date, customer_id, currency
ON CONFLICT (summary_date, customer_id) DO UPDATE SET
    total_transactions = EXCLUDED.total_transactions,
    total_quantity     = EXCLUDED.total_quantity,
    total_revenue      = EXCLUDED.total_revenue,
    avg_order_value    = EXCLUDED.avg_order_value,
    refreshed_at       = EXCLUDED.refreshed_at;
