

USE EcommerceAnalytics;
GO

IF OBJECT_ID('dbo.RawEcommerceOrders') IS NOT NULL
    DROP TABLE dbo.RawEcommerceOrders;
GO

CREATE TABLE dbo.RawEcommerceOrders (
    CustomerID            NVARCHAR(50),
    CustomerName          NVARCHAR(255),
    Age                   NVARCHAR(50),
    CustomerAge           NVARCHAR(50),
    Gender                NVARCHAR(20),
    Churn                 NVARCHAR(10),
    PurchaseDate          NVARCHAR(50),
    ProductCategory       NVARCHAR(100),
    ProductPrice          NVARCHAR(50),
    Quantity              NVARCHAR(50),
    TotalPurchaseAmount   NVARCHAR(50),
    PaymentMethod         NVARCHAR(50),
    Returns               NVARCHAR(10)
);
GO
