Ecommerce Customer Analytics — SQL Portfolio Project

A complete end-to-end SQL analytics project using Python-generated synthetic ecommerce data and Microsoft SQL Server.
This project demonstrates data cleaning, modeling, feature engineering, cohort analysis, churn prediction, RFM segmentation, LTV computation, and advanced business analytics.


               ┌──────────────────────────┐
               │  CSV Raw Ecommerce Data   │
               └───────────────┬──────────┘
                               │ BULK INSERT
                               ▼
                 ┌──────────────────────────┐
                 │  RawEcommerceOrders      │
                 │ (Staging Table, NVARCHAR)│
                 └───────────────┬──────────┘
                                 │ Cleaning + Casting
                                 ▼
      ┌────────────────────────────────────────────────────┐
      │                  Star Schema                        │
      │                                                    │
      │   DimCustomers  ◄───────►  FactOrders              │
      │   (Customer info)         (Every order event)      │
      └────────────────────────────────────────────────────┘
                                 ▼
                   Advanced Analytics Layer
                                 ▼
                 Cohorts | RFM | Churn | LTV | Trends



Key Business Questions Answered
✔ What is the monthly revenue trend?
✔ Which customers are likely churned?
✔ Who are the most valuable customers (LTV)?
✔ What are the top-performing product categories?
✔ What are the customer segments (RFM)?
✔ How do different payment methods perform?
✔ What are retention rates by cohort?





1. Data Loading (Staging Layer)

Raw dataset loaded into a staging table (NVARCHAR-only) to prevent type errors.


CREATE TABLE dbo.RawEcommerceOrders (
    CustomerID NVARCHAR(50),
    CustomerName NVARCHAR(255),
    Age NVARCHAR(50),
    CustomerAge NVARCHAR(50),
    Gender NVARCHAR(20),
    Churn NVARCHAR(10),
    PurchaseDate NVARCHAR(50),
    ProductCategory NVARCHAR(100),
    ProductPrice NVARCHAR(50),
    Quantity NVARCHAR(50),
    TotalPurchaseAmount NVARCHAR(50),
    PaymentMethod NVARCHAR(50),
    Returns NVARCHAR(10)
);

2.Dimensional Model (Star Schema)
⭐ FactOrders

Contains all transactions:

SELECT
    TRY_CAST(CustomerID AS INT) AS CustomerID,
    TRY_CAST(CustomerName AS DATETIME2) AS PurchaseDate,
    TRY_CAST(CustomerName AS DATE) AS OrderDate,
    Age AS ProductCategory,
    TRY_CAST(CustomerAge AS DECIMAL(10,2)) AS ProductPrice,
    TRY_CAST(Gender AS INT) AS Quantity,
    TRY_CAST(Churn AS DECIMAL(12,2)) AS TotalPurchaseAmount,
    PaymentMethod,
    TRY_CAST(ProductPrice AS BIT) AS Returns
INTO dbo.FactOrders
FROM dbo.RawEcommerceOrders;


DimCustomers

Churn is derived using “no order in last 180 days”.

SELECT
    CustomerID,
    CustomerName,
    Age,
    Gender,
    CASE WHEN DATEDIFF(DAY, LastOrderDate, GETDATE()) > 180 THEN 1 ELSE 0 END AS Churn
INTO DimCustomers
FROM CustomerSummary;


3. Monthly Revenue Trend
SELECT
    DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS MonthStart,
    COUNT(DISTINCT CustomerID) AS ActiveCustomers,
    SUM(TotalPurchaseAmount) AS TotalRevenue,
    AVG(TotalPurchaseAmount) AS AvgOrderValue
FROM dbo.FactOrders
GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
ORDER BY MonthStart;


4. Cohort Analysis (Retention)

Tracks user retention by cohort month.

WITH FirstOrder AS (
    SELECT CustomerID, MIN(OrderDate) AS FirstOrderDate
    FROM dbo.FactOrders
    GROUP BY CustomerID
),
OrdersWithCohort AS (
    SELECT
        fo.CustomerID,
        fo.OrderDate,
        DATEFROMPARTS(YEAR(f.FirstOrderDate), MONTH(f.FirstOrderDate), 1) AS CohortMonth,
        DATEFROMPARTS(YEAR(fo.OrderDate), MONTH(fo.OrderDate), 1) AS OrderMonth,
        DATEDIFF(MONTH, f.FirstOrderDate, fo.OrderDate) AS MonthsSinceFirst
    FROM dbo.FactOrders fo
    JOIN FirstOrder f ON fo.CustomerID = f.CustomerID
)
SELECT CohortMonth, MonthsSinceFirst, COUNT(*) AS ActiveCustomers
FROM OrdersWithCohort
GROUP BY CohortMonth, MonthsSinceFirst
ORDER BY CohortMonth, MonthsSinceFirst;


5. RFM Segmentation
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
    SELECT *,
        NTILE(3) OVER (ORDER BY DaysSinceLast DESC) AS RecencyScore,
        NTILE(3) OVER (ORDER BY TotalOrders ASC)    AS FrequencyScore,
        NTILE(3) OVER (ORDER BY TotalRevenue ASC)   AS MonetaryScore
    FROM Base
)
SELECT
    CustomerID,
    CustomerName,
    RecencyScore,
    FrequencyScore,
    MonetaryScore,
    CASE
        WHEN RecencyScore = 1 AND FrequencyScore = 3 AND MonetaryScore = 3 THEN 'Champion'
        WHEN RecencyScore <= 2 AND FrequencyScore >= 2 AND MonetaryScore >= 2 THEN 'Loyal'
        WHEN RecencyScore = 3 AND FrequencyScore = 1 THEN 'At Risk'
        ELSE 'Others'
    END AS Segment
FROM Scored
ORDER BY Segment;


6. LTV (Lifetime Value)
12-Month LTV:

WITH FirstOrder AS (
    SELECT CustomerID, MIN(OrderDate) AS FirstOrderDate
    FROM dbo.FactOrders
    GROUP BY CustomerID
),
OrdersWithin12Months AS (
    SELECT
        fo.CustomerID,
        fo.TotalPurchaseAmount,
        fo.OrderDate
    FROM dbo.FactOrders fo
    JOIN FirstOrder f ON fo.CustomerID = f.CustomerID
    WHERE fo.OrderDate <= DATEADD(MONTH, 12, f.FirstOrderDate)
)
SELECT CustomerID, SUM(TotalPurchaseAmount) AS LTV_12_Months
FROM OrdersWithin12Months
GROUP BY CustomerID
ORDER BY LTV_12_Months DESC;


Total LTV:
SELECT
    CustomerID,
    SUM(TotalPurchaseAmount) AS LifetimeValue
FROM dbo.FactOrders
GROUP BY CustomerID
ORDER BY LifetimeValue DESC;
