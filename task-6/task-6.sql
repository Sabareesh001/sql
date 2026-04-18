-- Task 6: Date and Time Functions
-- Objective: Manipulate and query data based on date and time values.

-- ===== Step 1: Create the Orders table with date fields =====
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(50),
    OrderDate DATETIME,
    DeliveryDate DATETIME,
    Amount DECIMAL(10, 2)
);

-- ===== Step 2: Insert sample data with various dates =====
INSERT INTO Orders (CustomerName, OrderDate, DeliveryDate, Amount) VALUES
('John Smith', '2026-03-15 10:30:00', '2026-03-22 14:15:00', 150.00),
('Jane Doe', '2026-03-18 09:00:00', '2026-03-25 16:45:00', 200.50),
('Michael Johnson', '2026-02-10 13:45:00', '2026-02-17 11:20:00', 75.25),
('Sarah Williams', '2026-01-05 08:15:00', '2026-01-12 15:30:00', 300.00),
('Robert Brown', '2026-04-01 14:20:00', '2026-04-08 10:00:00', 125.75),
('Emily Davis', '2026-04-10 11:00:00', '2026-04-17 13:00:00', 450.99),
('David Miller', '2025-12-20 16:30:00', '2025-12-27 09:45:00', 89.50),
('Lisa Wilson', '2026-04-15 10:15:00', NULL, 220.00);

-- ===== Step 3: DATEDIFF - Calculate the interval between OrderDate and DeliveryDate =====
SELECT 
    OrderID,
    CustomerName,
    OrderDate,
    DeliveryDate,
    DATEDIFF(DAY, OrderDate, DeliveryDate) AS DeliveryDaysNeeded,
    DATEDIFF(HOUR, OrderDate, DeliveryDate) AS DeliveryHours
FROM Orders
WHERE DeliveryDate IS NOT NULL
ORDER BY OrderID;

-- ===== Step 4: DATEDIFF - Calculate days since order was placed =====
SELECT 
    OrderID,
    CustomerName,
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysSinceOrder,
    DATEDIFF(MONTH, OrderDate, GETDATE()) AS MonthsSinceOrder
FROM Orders
ORDER BY DaysSinceOrder DESC;

-- ===== Step 5: DATEADD - Calculate expected delivery date (add 7 days to OrderDate) =====
SELECT 
    OrderID,
    CustomerName,
    OrderDate,
    DATEADD(DAY, 7, OrderDate) AS ExpectedDelivery_7Days,
    DATEADD(WEEK, 2, OrderDate) AS ExpectedDelivery_2Weeks,
    DATEADD(MONTH, 1, OrderDate) AS ExpectedDelivery_1Month
FROM Orders
ORDER BY OrderID;

-- ===== Step 6: Filter records based on date range - Orders from last 30 days =====
SELECT 
    OrderID,
    CustomerName,
    OrderDate,
    Amount
FROM Orders
WHERE OrderDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY OrderDate DESC;

-- ===== Step 7: Filter records based on date range - Orders placed in Q1 2026 =====
SELECT 
    OrderID,
    CustomerName,
    OrderDate,
    Amount
FROM Orders
WHERE OrderDate >= '2026-01-01' AND OrderDate < '2026-04-01'
ORDER BY OrderDate;

-- ===== Step 8: Filter by date range - Orders placed between 1st and 15th of any month =====
SELECT 
    OrderID,
    CustomerName,
    OrderDate,
    Amount
FROM Orders
WHERE DAY(OrderDate) BETWEEN 1 AND 15
ORDER BY OrderDate;

-- ===== Step 9: CONVERT - Format dates in different formats =====
SELECT 
    OrderID,
    CustomerName,
    -- Different date format styles
    CONVERT(VARCHAR(20), OrderDate, 101) AS Format_MM_DD_YYYY,
    CONVERT(VARCHAR(20), OrderDate, 103) AS Format_DD_MM_YYYY,
    CONVERT(VARCHAR(20), OrderDate, 111) AS Format_YYYY_MM_DD,
    CONVERT(VARCHAR(20), OrderDate, 105) AS Format_DD_MMMM_YYYY,
    CONVERT(VARCHAR(20), OrderDate, 112) AS Format_YYYYMMDD
FROM Orders
ORDER BY OrderID;

-- ===== Step 10: Extract date components (YEAR, MONTH, DAY) =====
SELECT 
    OrderID,
    CustomerName,
    OrderDate,
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    DAY(OrderDate) AS OrderDay,
    DATENAME(MONTH, OrderDate) AS MonthName,
    DATENAME(WEEKDAY, OrderDate) AS DayOfWeek
FROM Orders
ORDER BY OrderID;

-- ===== Step 11: Group by date components - Orders per month =====
SELECT 
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    DATENAME(MONTH, OrderDate) AS MonthName,
    COUNT(*) AS TotalOrders,
    SUM(Amount) AS TotalAmount,
    AVG(Amount) AS AvgOrderAmount
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATENAME(MONTH, OrderDate)
ORDER BY OrderYear, MONTH(OrderDate);

-- ===== Step 12: Complex date calculation - Average delivery time per month =====
SELECT 
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    DATENAME(MONTH, OrderDate) AS MonthName,
    COUNT(*) AS OrderCount,
    AVG(DATEDIFF(DAY, OrderDate, DeliveryDate)) AS AvgDeliveryDays,
    MIN(DATEDIFF(DAY, OrderDate, DeliveryDate)) AS FastestDeliveryDays,
    MAX(DATEDIFF(DAY, OrderDate, DeliveryDate)) AS SlowestDeliveryDays
FROM Orders
WHERE DeliveryDate IS NOT NULL
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATENAME(MONTH, OrderDate)
ORDER BY OrderYear, MONTH(OrderDate);

-- ===== Step 13: Find orders that are overdue (not delivered within 10 days) =====
SELECT 
    OrderID,
    CustomerName,
    OrderDate,
    DeliveryDate,
    DATEDIFF(DAY, OrderDate, DeliveryDate) AS ActualDeliveryDays,
    CASE 
        WHEN DATEDIFF(DAY, OrderDate, DeliveryDate) > 10 THEN 'Overdue'
        ELSE 'On Time'
    END AS DeliveryStatus
FROM Orders
WHERE DeliveryDate IS NOT NULL
ORDER BY DATEDIFF(DAY, OrderDate, DeliveryDate) DESC;

-- ===== Step 14: Verify all data in Orders table =====
SELECT * FROM Orders;
