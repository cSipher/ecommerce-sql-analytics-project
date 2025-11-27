

USE EcommerceAnalytics;
GO

SELECT
    DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS MonthStart,
    COUNT(DISTINCT CustomerID)                          AS ActiveCustomers,
    SUM(TotalPurchaseAmount)                           AS TotalRevenue,
    AVG(TotalPurchaseAmount)                           AS AvgOrderValue
FROM dbo.FactOrders
GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
ORDER BY MonthStart;
GO
