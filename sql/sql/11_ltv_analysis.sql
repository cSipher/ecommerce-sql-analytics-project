


USE EcommerceAnalytics;
GO

-- 12-month LTV from first purchase
WITH FirstOrder AS (
    SELECT
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate
    FROM dbo.FactOrders
    GROUP BY CustomerID
),
OrdersWithin12Months AS (
    SELECT
        fo.CustomerID,
        fo.TotalPurchaseAmount,
        fo.OrderDate,
        f.FirstOrderDate
    FROM dbo.FactOrders fo
    JOIN FirstOrder f
        ON fo.CustomerID = f.CustomerID
    WHERE fo.OrderDate <= DATEADD(MONTH, 12, f.FirstOrderDate)
)
SELECT
    CustomerID,
    SUM(TotalPurchaseAmount) AS LTV_12_Months
FROM OrdersWithin12Months
GROUP BY CustomerID
ORDER BY LTV_12_Months DESC;
GO


-- Total lifetime value
SELECT
    CustomerID,
    SUM(TotalPurchaseAmount) AS LifetimeValue
FROM dbo.FactOrders
GROUP BY CustomerID
ORDER BY LifetimeValue DESC;
GO
