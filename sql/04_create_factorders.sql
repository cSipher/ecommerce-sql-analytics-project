

USE EcommerceAnalytics;
GO

IF OBJECT_ID('dbo.FactOrders') IS NOT NULL
    DROP TABLE dbo.FactOrders;
GO

SELECT
    TRY_CAST(CustomerID AS INT)                      AS CustomerID,
    TRY_CONVERT(DATETIME2, CustomerName)             AS PurchaseDate,       -- timestamp
    TRY_CONVERT(DATE,      CustomerName)             AS OrderDate,
    Age                                              AS ProductCategory,    -- Home, Books...
    TRY_CONVERT(DECIMAL(10,2), CustomerAge)          AS ProductPrice,       -- price
    TRY_CONVERT(INT, Gender)                         AS Quantity,           -- units
    TRY_CONVERT(DECIMAL(12,2), Churn)                AS TotalPurchaseAmount,-- amount
    PurchaseDate                                     AS PaymentMethod,      -- PayPal, Cash...
    TRY_CONVERT(BIT, ProductPrice)                   AS Returns            -- 1.0 / 0.0
INTO dbo.FactOrders
FROM dbo.RawEcommerceOrders;
GO

SELECT TOP 10 * FROM dbo.FactOrders;
GO
