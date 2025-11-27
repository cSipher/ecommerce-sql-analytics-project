-- 05_create_dimcustomers.sql
-- Customer dimension with derived churn (no purchase in last 6 months)

USE EcommerceAnalytics;
GO

IF OBJECT_ID('dbo.DimCustomers') IS NOT NULL
    DROP TABLE dbo.DimCustomers;
GO

;WITH LastPurchase AS (
    SELECT
        CustomerID,
        MAX(OrderDate) AS LastOrderDate
    FROM dbo.FactOrders
    GROUP BY CustomerID
)
SELECT
    TRY_CAST(r.CustomerID AS INT)           AS CustomerID,
    r.Quantity                              AS CustomerName,   -- e.g. John Rivera
    TRY_CAST(r.TotalPurchaseAmount AS INT)  AS Age,            -- 27, 31, ...
    r.PaymentMethod                         AS Gender,         -- Male / Female
    CASE 
        WHEN DATEDIFF(MONTH, lp.LastOrderDate, GETDATE()) >= 6 
            THEN 1      -- churned
        ELSE 0          -- active
    END AS Churn
INTO dbo.DimCustomers
FROM dbo.RawEcommerceOrders r
JOIN LastPurchase lp 
    ON lp.CustomerID = TRY_CAST(r.CustomerID AS INT)
GROUP BY
    r.CustomerID,
    r.Quantity,
    r.TotalPurchaseAmount,
    r.PaymentMethod,
    lp.LastOrderDate;
GO

SELECT TOP 20 * FROM dbo.DimCustomers;
GO
