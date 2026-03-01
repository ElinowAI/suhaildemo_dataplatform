-- Migration: create_sales_table
-- Pattern  : Expand/Contract - Phase 1 (Expand)

CREATE TABLE IF NOT EXISTS raw.sales_transactions (
    transaction_id   VARCHAR(50)    NOT NULL,
    transaction_date DATE           NOT NULL,
    customer_id      VARCHAR(50)    NOT NULL,
    product_id       VARCHAR(50)    NOT NULL,
    quantity         INTEGER        NOT NULL DEFAULT 0,
    unit_price       DECIMAL(18,2)  NOT NULL DEFAULT 0.00,
    total_amount     DECIMAL(18,2)  NOT NULL DEFAULT 0.00,
    currency         VARCHAR(3)     NOT NULL DEFAULT 'USD',
    source_system    VARCHAR(50)    NOT NULL,
    ingested_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pipeline_run_id  VARCHAR(50)    NULL,
    CONSTRAINT pk_sales PRIMARY KEY (transaction_id)
);
CREATE INDEX IF NOT EXISTS idx_sales_date     ON raw.sales_transactions (transaction_date);
CREATE INDEX IF NOT EXISTS idx_sales_customer ON raw.sales_transactions (customer_id);
