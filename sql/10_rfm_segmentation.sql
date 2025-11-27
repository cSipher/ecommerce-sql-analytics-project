

USE EcommerceAnalytics;
GO

WITH Base AS (
    SELECT
        cs.CustomerID,
        cs.CustomerName,
        cs.TotalOrders,
        cs.TotalRevenue,
        cs.LastOrderDate,
        DATEDIFF(DAY, cs.LastOrderDate, GETDATE()) AS DaysSinceLast
    FROM dbo.CustomerSummary cs
),
Scored AS (
    SELECT
        *,
        NTILE(3) OVER (ORDER BY DaysSinceLast DESC) AS RecencyScore,   -- 1 = most recent
        NTILE(3) OVER (ORDER BY TotalOrders ASC)    AS FrequencyScore, -- 3 = most frequent
        NTILE(3) OVER (ORDER BY TotalRevenue ASC)   AS MonetaryScore   -- 3 = highest spend
    FROM Base
)
SELECT
    CustomerID,
    CustomerName,
    RecencyScore,
    FrequencyScore,
    MonetaryScore,
    CASE
        WHEN RecencyScore = 1 AND FrequencyScore = 3 AND MonetaryScore = 3
            THEN 'Champion'
        WHEN RecencyScore <= 2 AND FrequencyScore >= 2 AND MonetaryScore >= 2
            THEN 'Loyal'
        WHEN RecencyScore = 3 AND FrequencyScore = 1
            THEN 'At Risk'
        ELSE 'Others'
    END AS Segment
FROM Scored
ORDER BY Segment, CustomerID;
GO
