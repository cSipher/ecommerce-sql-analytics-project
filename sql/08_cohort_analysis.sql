

USE EcommerceAnalytics;
GO

WITH FirstOrder AS (
    SELECT 
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate
    FROM dbo.FactOrders
    GROUP BY CustomerID
),
OrdersWithCohort AS (
    SELECT
        fo.CustomerID,
        fo.OrderDate,
        DATEFROMPARTS(YEAR(f.FirstOrderDate), MONTH(f.FirstOrderDate), 1) AS CohortMonth,
        DATEFROMPARTS(YEAR(fo.OrderDate), MONTH(fo.OrderDate), 1)         AS OrderMonth,
        DATEDIFF(MONTH, f.FirstOrderDate, fo.OrderDate)                   AS MonthsSinceFirst
    FROM dbo.FactOrders fo
    JOIN FirstOrder f 
        ON fo.CustomerID = f.CustomerID
)
SELECT
    CohortMonth,
    MonthsSinceFirst,
    COUNT(DISTINCT CustomerID) AS ActiveCustomers
FROM OrdersWithCohort
GROUP BY CohortMonth, MonthsSinceFirst
ORDER BY CohortMonth, MonthsSinceFirst;
GO
