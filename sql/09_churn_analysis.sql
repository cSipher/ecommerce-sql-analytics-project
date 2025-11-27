

USE EcommerceAnalytics;
GO

SELECT
    c.Churn,
    COUNT(DISTINCT c.CustomerID)        AS Customers,
    AVG(cs.TotalOrders)                 AS AvgOrdersPerCustomer,
    AVG(cs.TotalRevenue)                AS AvgRevenuePerCustomer,
    AVG(cs.ReturnRate)                  AS AvgReturnRate,
    AVG(cs.Age)                         AS AvgAge
FROM dbo.DimCustomers c
JOIN dbo.CustomerSummary cs
    ON c.CustomerID = cs.CustomerID
GROUP BY c.Churn
ORDER BY c.Churn;
GO
