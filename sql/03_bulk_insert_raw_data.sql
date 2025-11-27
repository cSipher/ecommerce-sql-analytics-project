

USE EcommerceAnalytics;
GO

TRUNCATE TABLE dbo.RawEcommerceOrders;
GO

BULK INSERT dbo.RawEcommerceOrders
FROM 'C:\EcommerceProject\ecommerce_customer_data_large.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',      -- newline
    CODEPAGE = '65001',          -- UTF-8
    DATAFILETYPE = 'char',
    TABLOCK
);
GO
