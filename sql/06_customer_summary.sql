
USE EcommerceAnalytics;
GO

IF OBJECT_ID('dbo.CustomerSummary', 'V') IS NOT NULL
    DROP VIEW dbo.CustomerSummary;
GO

CREATE VIEW dbo.CustomerSummary
AS
WITH CustomerOrders AS (
    SELECT
        fo.CustomerID,
        MIN(fo.OrderDate)                      AS FirstOrderDate,
        MAX(fo.OrderDate)                      AS LastOrderDate,
        COUNT(*)                               AS TotalOrders,
        SUM(fo.TotalPurchaseAmount)            AS TotalRevenue,
        AVG(fo.TotalPurchaseAmount)            AS AvgOrderValue,
        CAST(SUM(CASE WHEN fo.Returns = 1 THEN 1 ELSE 0 END) AS DECIMAL(10,2))
        / NULLIF(COUNT(*), 0)                  AS ReturnRate
    FROM dbo.FactOrders fo
    GROUP BY fo.CustomerID
)
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Age,
    c.Gender,
    c.Churn,
    co.FirstOrderDate,
    co.LastOrderDate,
    co.TotalOrders,
    co.TotalRevenue,
    co.AvgOrderValue,
    co.ReturnRate
FROM dbo.DimCustomers c
JOIN CustomerOrders co
    ON c.CustomerID = co.CustomerID;
GO

-- quick preview
SELECT TOP 10 * FROM dbo.CustomerSummary;
GO
