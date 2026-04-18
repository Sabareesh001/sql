-- Task 9: Stored Procedures and User-Defined Functions
-- Objective: Encapsulate business logic using stored procedures and functions.

-- ============================================================================
-- PART 1: Setup - Create and Populate Tables (if not already created)
-- ============================================================================

-- Verify existing tables or create them if needed
IF OBJECT_ID('Employees', 'U') IS NULL
BEGIN
    CREATE TABLE Employees (
        EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
        FirstName VARCHAR(50) NOT NULL,
        LastName VARCHAR(50) NOT NULL,
        Department VARCHAR(50),
        Salary DECIMAL(10, 2),
        HireDate DATE,
        ManagerID INT
    );
    
    INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, Salary, HireDate, ManagerID) VALUES
    (1, 'John', 'Smith', 'Sales', 80000, '2015-01-15', NULL),
    (2, 'Jane', 'Doe', 'Sales', 70000, '2016-03-20', 1),
    (3, 'Michael', 'Johnson', 'Engineering', 85000, '2014-06-10', NULL),
    (4, 'Sarah', 'Williams', 'Engineering', 75000, '2017-11-05', 3),
    (5, 'Robert', 'Brown', 'Sales', 65000, '2018-09-12', 2),
    (6, 'Emily', 'Davis', 'Marketing', 60000, '2019-02-01', NULL),
    (7, 'David', 'Miller', 'Engineering', 72000, '2016-05-18', 3),
    (8, 'Lisa', 'Wilson', 'Sales', 62000, '2020-08-22', 2),
    (9, 'James', 'Moore', 'Marketing', 55000, '2019-11-10', 6);
END;

IF OBJECT_ID('Sales', 'U') IS NULL
BEGIN
    CREATE TABLE Sales (
        SaleID INT PRIMARY KEY AUTO_INCREMENT,
        EmployeeID INT,
        Department VARCHAR(50),
        SalesAmount DECIMAL(10, 2),
        SaleDate DATE,
        Quantity INT,
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
    );
    
    INSERT INTO Sales (EmployeeID, Department, SalesAmount, SaleDate, Quantity) VALUES
    (2, 'Sales', 5000, '2024-01-15', 10),
    (2, 'Sales', 7500, '2024-02-10', 15),
    (5, 'Sales', 6000, '2024-01-20', 12),
    (5, 'Sales', 4500, '2024-03-15', 9),
    (8, 'Sales', 8000, '2024-01-25', 16),
    (8, 'Sales', 5500, '2024-02-28', 11),
    (2, 'Sales', 6500, '2024-03-05', 13),
    (5, 'Sales', 7200, '2024-03-18', 14),
    (8, 'Sales', 9000, '2024-04-10', 18);
END;

-- ============================================================================
-- PART 2: SCALAR USER-DEFINED FUNCTIONS
-- ============================================================================

-- Function 1: Calculate Discount Based on Sales Amount
-- Discount rules: 
--   - < $5000: 0% discount
--   - $5000-$7999: 5% discount
--   - $8000-$9999: 10% discount
--   - >= $10000: 15% discount
PRINT '=== Creating Scalar Function: Calculate Discount ===';
CREATE FUNCTION dbo.CalculateDiscount(@SalesAmount DECIMAL(10, 2))
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @DiscountPercent DECIMAL(5, 2);
    
    IF @SalesAmount >= 10000
        SET @DiscountPercent = 15.00;
    ELSE IF @SalesAmount >= 8000
        SET @DiscountPercent = 10.00;
    ELSE IF @SalesAmount >= 5000
        SET @DiscountPercent = 5.00;
    ELSE
        SET @DiscountPercent = 0.00;
    
    RETURN @DiscountPercent;
END;

-- Function 2: Calculate Bonus Based on Years of Service
-- Bonus rules:
--   - < 2 years: 0%
--   - 2-5 years: 5%
--   - 5-10 years: 10%
--   - > 10 years: 15%
PRINT '=== Creating Scalar Function: Calculate Tenure Bonus ===';
CREATE FUNCTION dbo.CalculateTenureBonus(@HireDate DATE)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @YearsOfService INT;
    DECLARE @BonusPercent DECIMAL(5, 2);
    
    SET @YearsOfService = DATEDIFF(YEAR, @HireDate, CAST(GETDATE() AS DATE));
    
    IF @YearsOfService > 10
        SET @BonusPercent = 15.00;
    ELSE IF @YearsOfService >= 5
        SET @BonusPercent = 10.00;
    ELSE IF @YearsOfService >= 2
        SET @BonusPercent = 5.00;
    ELSE
        SET @BonusPercent = 0.00;
    
    RETURN @BonusPercent;
END;

-- Function 3: Calculate Discounted Amount
-- Returns the final amount after applying discount
PRINT '=== Creating Scalar Function: Calculate Final Amount ===';
CREATE FUNCTION dbo.CalculateFinalAmount(@OriginalAmount DECIMAL(10, 2), @DiscountPercent DECIMAL(5, 2))
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @FinalAmount DECIMAL(10, 2);
    SET @FinalAmount = @OriginalAmount - (@OriginalAmount * @DiscountPercent / 100);
    RETURN @FinalAmount;
END;

-- Function 4: Get Employee Full Name
PRINT '=== Creating Scalar Function: Get Full Name ===';
CREATE FUNCTION dbo.GetFullName(@FirstName VARCHAR(50), @LastName VARCHAR(50))
RETURNS VARCHAR(101)
AS
BEGIN
    DECLARE @FullName VARCHAR(101);
    SET @FullName = LTRIM(RTRIM(@FirstName)) + ' ' + LTRIM(RTRIM(@LastName));
    RETURN @FullName;
END;

-- ============================================================================
-- PART 3: TABLE-VALUED USER-DEFINED FUNCTIONS
-- ============================================================================

-- Table Function 1: Get All Employees in a Department
PRINT '=== Creating Table Function: Get Department Employees ===';
CREATE FUNCTION dbo.GetDepartmentEmployees(@DepartmentName VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Department,
        Salary,
        HireDate,
        dbo.CalculateTenureBonus(HireDate) AS TenureBonusPercent
    FROM Employees
    WHERE Department = @DepartmentName
);

-- Table Function 2: Get Sales Data for a Date Range
PRINT '=== Creating Table Function: Get Sales by Date Range ===';
CREATE FUNCTION dbo.GetSalesByDateRange(@StartDate DATE, @EndDate DATE)
RETURNS TABLE
AS
RETURN (
    SELECT 
        SaleID,
        EmployeeID,
        Department,
        SalesAmount,
        SaleDate,
        Quantity,
        dbo.CalculateDiscount(SalesAmount) AS DiscountPercent,
        dbo.CalculateFinalAmount(SalesAmount, dbo.CalculateDiscount(SalesAmount)) AS FinalAmount
    FROM Sales
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
);

-- Table Function 3: Get Employee Sales Performance
PRINT '=== Creating Table Function: Get Employee Performance ===';
CREATE FUNCTION dbo.GetEmployeeSalesPerformance(@EmployeeID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Department,
        e.Salary,
        COUNT(s.SaleID) AS TotalSales,
        SUM(s.SalesAmount) AS TotalSalesAmount,
        AVG(s.SalesAmount) AS AvgSalesAmount,
        ROUND(SUM(s.SalesAmount) / NULLIF(COUNT(s.SaleID), 0), 2) AS AvgPerSale
    FROM Employees e
    LEFT JOIN Sales s ON e.EmployeeID = s.EmployeeID
    WHERE e.EmployeeID = @EmployeeID
    GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.Department, e.Salary
);

-- ============================================================================
-- PART 4: STORED PROCEDURES
-- ============================================================================

-- Stored Procedure 1: Get Sales Report by Date Range
-- Returns sales summary for a given date range
PRINT '=== Creating Stored Procedure: Get Sales Report ===';
CREATE PROCEDURE dbo.sp_GetSalesReport
    @StartDate DATE,
    @EndDate DATE,
    @Department VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @TotalSales DECIMAL(10, 2);
    DECLARE @RecordCount INT;
    
    SET @TotalSales = COALESCE(SUM(SalesAmount), 0)
    FROM Sales
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
        AND (@Department IS NULL OR Department = @Department);
    
    SET @RecordCount = COUNT(*)
    FROM Sales
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
        AND (@Department IS NULL OR Department = @Department);
    
    -- Print summary information
    PRINT CHAR(13) + '=== Sales Report ===';
    PRINT 'Period: ' + CONVERT(VARCHAR(10), @StartDate, 120) + ' to ' + CONVERT(VARCHAR(10), @EndDate, 120);
    IF @Department IS NOT NULL
        PRINT 'Department: ' + @Department;
    PRINT 'Total Records: ' + CAST(@RecordCount AS VARCHAR(10));
    PRINT 'Total Sales: $' + CAST(@TotalSales AS VARCHAR(15));
    
    -- Return detailed records
    SELECT 
        SaleID,
        EmployeeID,
        Department,
        SalesAmount,
        SaleDate,
        Quantity,
        dbo.CalculateDiscount(SalesAmount) AS DiscountPercent,
        dbo.CalculateFinalAmount(SalesAmount, dbo.CalculateDiscount(SalesAmount)) AS FinalAmount
    FROM Sales
    WHERE SaleDate BETWEEN @StartDate AND @EndDate
        AND (@Department IS NULL OR Department = @Department)
    ORDER BY SaleDate DESC;
END;

-- Stored Procedure 2: Calculate Department Compensation Summary
-- Returns total compensation (salary + bonus) for employees in a department
PRINT '';
PRINT '=== Creating Stored Procedure: Department Compensation Summary ===';
CREATE PROCEDURE dbo.sp_GetDepartmentCompensationSummary
    @DepartmentName VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE Department = @DepartmentName)
    BEGIN
        PRINT 'Error: Department "' + @DepartmentName + '" not found.';
        RETURN;
    END
    
    DECLARE @EmployeeCount INT;
    DECLARE @TotalSalary DECIMAL(10, 2);
    DECLARE @AvgSalary DECIMAL(10, 2);
    
    SELECT 
        @EmployeeCount = COUNT(*),
        @TotalSalary = SUM(Salary),
        @AvgSalary = AVG(Salary)
    FROM Employees
    WHERE Department = @DepartmentName;
    
    -- Print summary
    PRINT CHAR(13) + '=== Department Compensation Summary ===';
    PRINT 'Department: ' + @DepartmentName;
    PRINT 'Employee Count: ' + CAST(@EmployeeCount AS VARCHAR(10));
    PRINT 'Total Salary: $' + CAST(@TotalSalary AS VARCHAR(15));
    PRINT 'Average Salary: $' + CAST(@AvgSalary AS VARCHAR(15));
    
    -- Return detailed employee records with bonus calculations
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Salary,
        HireDate,
        dbo.CalculateTenureBonus(HireDate) AS TenureBonusPercent,
        ROUND(Salary * dbo.CalculateTenureBonus(HireDate) / 100, 2) AS BonusAmount,
        ROUND(Salary + (Salary * dbo.CalculateTenureBonus(HireDate) / 100), 2) AS TotalCompensation
    FROM Employees
    WHERE Department = @DepartmentName
    ORDER BY Salary DESC;
END;

-- Stored Procedure 3: Get Employee Sales Commission
-- Calculates commission for an employee based on total sales
PRINT '';
PRINT '=== Creating Stored Procedure: Employee Sales Commission ===';
CREATE PROCEDURE dbo.sp_CalculateEmployeeCommission
    @EmployeeID INT,
    @CommissionPercentage DECIMAL(5, 2) = 5.00
AS
BEGIN
    DECLARE @FirstName VARCHAR(50);
    DECLARE @LastName VARCHAR(50);
    DECLARE @TotalSales DECIMAL(10, 2);
    DECLARE @Commission DECIMAL(10, 2);
    
    -- Get employee details
    SELECT 
        @FirstName = FirstName,
        @LastName = LastName
    FROM Employees
    WHERE EmployeeID = @EmployeeID;
    
    -- Check if employee exists
    IF @FirstName IS NULL
    BEGIN
        PRINT 'Error: Employee ID ' + CAST(@EmployeeID AS VARCHAR(10)) + ' not found.';
        RETURN;
    END
    
    -- Calculate total sales
    SELECT @TotalSales = COALESCE(SUM(SalesAmount), 0)
    FROM Sales
    WHERE EmployeeID = @EmployeeID;
    
    -- Calculate commission
    SET @Commission = (@TotalSales * @CommissionPercentage) / 100;
    
    -- Print results
    PRINT CHAR(13) + '=== Commission Report ===';
    PRINT 'Employee: ' + dbo.GetFullName(@FirstName, @LastName);
    PRINT 'Total Sales: $' + CAST(@TotalSales AS VARCHAR(15));
    PRINT 'Commission Rate: ' + CAST(@CommissionPercentage AS VARCHAR(10)) + '%';
    PRINT 'Commission Amount: $' + CAST(@Commission AS VARCHAR(15));
    
    -- Return transaction details
    SELECT 
        SaleID,
        SalesAmount,
        SaleDate,
        ROUND(SalesAmount * @CommissionPercentage / 100, 2) AS CommissionOnSale
    FROM Sales
    WHERE EmployeeID = @EmployeeID
    ORDER BY SaleDate DESC;
END;

-- Stored Procedure 4: Get Top Sales Performers
-- Returns top performers by total sales amount
PRINT '';
PRINT '=== Creating Stored Procedure: Top Sales Performers ===';
CREATE PROCEDURE dbo.sp_GetTopSalesPerformers
    @TopCount INT = 5,
    @MinimumSalesAmount DECIMAL(10, 2) = 0
AS
BEGIN
    SELECT TOP (@TopCount)
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Department,
        e.Salary,
        COUNT(s.SaleID) AS NumberOfSales,
        SUM(s.SalesAmount) AS TotalSales,
        AVG(s.SalesAmount) AS AvgSalesPerTransaction,
        ROUND(SUM(s.SalesAmount) * 5 / 100, 2) AS EstimatedCommission5Percent
    FROM Employees e
    LEFT JOIN Sales s ON e.EmployeeID = s.EmployeeID
    GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.Department, e.Salary
    HAVING SUM(s.SalesAmount) >= @MinimumSalesAmount OR SUM(s.SalesAmount) IS NULL
    ORDER BY TotalSales DESC;
END;

-- ============================================================================
-- PART 5: TESTING AND DEMONSTRATION
-- ============================================================================

PRINT CHAR(13) + CHAR(13);
PRINT '==============================================================';
PRINT 'PART 5: TESTING SCALAR FUNCTIONS';
PRINT '==============================================================';

-- Test Scalar Function 1: Calculate Discount
PRINT CHAR(13) + '--- Test: Calculate Discount Function ---';
SELECT 
    SalesAmount,
    dbo.CalculateDiscount(SalesAmount) AS DiscountPercent,
    dbo.CalculateFinalAmount(SalesAmount, dbo.CalculateDiscount(SalesAmount)) AS FinalAmount
FROM Sales
ORDER BY SalesAmount DESC;

-- Test Scalar Function 2: Calculate Tenure Bonus
PRINT CHAR(13) + '--- Test: Calculate Tenure Bonus Function ---';
SELECT 
    FirstName,
    LastName,
    HireDate,
    DATEDIFF(YEAR, HireDate, CAST(GETDATE() AS DATE)) AS YearsOfService,
    dbo.CalculateTenureBonus(HireDate) AS BonusPercent,
    ROUND(Salary * dbo.CalculateTenureBonus(HireDate) / 100, 2) AS BonusAmount
FROM Employees
ORDER BY HireDate ASC;

-- Test Scalar Function 4: Get Full Name
PRINT CHAR(13) + '--- Test: Get Full Name Function ---';
SELECT 
    EmployeeID,
    dbo.GetFullName(FirstName, LastName) AS FullName,
    Department
FROM Employees
ORDER BY FirstName;

-- ============================================================================

PRINT CHAR(13) + CHAR(13);
PRINT '==============================================================';
PRINT 'PART 5: TESTING TABLE-VALUED FUNCTIONS';
PRINT '==============================================================';

-- Test Table Function 1: Get Department Employees
PRINT CHAR(13) + '--- Test: Get Department Employees Function ---';
SELECT * FROM dbo.GetDepartmentEmployees('Sales');

-- Test Table Function 2: Get Sales by Date Range
PRINT CHAR(13) + '--- Test: Get Sales by Date Range Function ---';
SELECT * FROM dbo.GetSalesByDateRange('2024-01-01', '2024-02-29');

-- Test Table Function 3: Get Employee Performance
PRINT CHAR(13) + '--- Test: Get Employee Sales Performance Function ---';
SELECT * FROM dbo.GetEmployeeSalesPerformance(2);

-- ============================================================================

PRINT CHAR(13) + CHAR(13);
PRINT '==============================================================';
PRINT 'PART 5: TESTING STORED PROCEDURES';
PRINT '==============================================================';

-- Test Stored Procedure 1: Sales Report by Date Range (All Departments)
PRINT CHAR(13) + '--- Test: Sales Report (All Departments) ---';
EXEC dbo.sp_GetSalesReport @StartDate = '2024-01-01', @EndDate = '2024-04-30';

-- Test Stored Procedure 1: Sales Report by Date Range (Sales Department Only)
PRINT CHAR(13) + '--- Test: Sales Report (Sales Department Only) ---';
EXEC dbo.sp_GetSalesReport @StartDate = '2024-01-01', @EndDate = '2024-04-30', @Department = 'Sales';

-- Test Stored Procedure 2: Department Compensation Summary
PRINT CHAR(13) + '--- Test: Department Compensation Summary ---';
EXEC dbo.sp_GetDepartmentCompensationSummary @DepartmentName = 'Engineering';

PRINT CHAR(13) + '--- Test: Department Compensation Summary (Sales) ---';
EXEC dbo.sp_GetDepartmentCompensationSummary @DepartmentName = 'Sales';

-- Test Stored Procedure 3: Employee Commission
PRINT CHAR(13) + '--- Test: Employee Sales Commission ---';
EXEC dbo.sp_CalculateEmployeeCommission @EmployeeID = 2, @CommissionPercentage = 5.00;

PRINT CHAR(13) + '--- Test: Employee Sales Commission (Employee 8) ---';
EXEC dbo.sp_CalculateEmployeeCommission @EmployeeID = 8, @CommissionPercentage = 7.50;

-- Test Stored Procedure 4: Top Sales Performers
PRINT CHAR(13) + '--- Test: Top 3 Sales Performers ---';
EXEC dbo.sp_GetTopSalesPerformers @TopCount = 3;

PRINT CHAR(13) + '--- Test: Top 5 Performers with Minimum Sales $5000 ---';
EXEC dbo.sp_GetTopSalesPerformers @TopCount = 5, @MinimumSalesAmount = 5000;

-- ============================================================================
-- PART 6: VERIFICATION AND SUMMARY
-- ============================================================================

PRINT CHAR(13) + CHAR(13);
PRINT '==============================================================';
PRINT 'PART 6: SUMMARY OF CREATED OBJECTS';
PRINT '==============================================================';

-- List all created functions
PRINT CHAR(13) + '--- Scalar Functions ---';
SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE,
    DATA_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'dbo'
    AND ROUTINE_NAME IN ('CalculateDiscount', 'CalculateTenureBonus', 'CalculateFinalAmount', 'GetFullName')
ORDER BY ROUTINE_NAME;

PRINT CHAR(13) + '--- Table-Valued Functions ---';
SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'dbo'
    AND ROUTINE_NAME IN ('GetDepartmentEmployees', 'GetSalesByDateRange', 'GetEmployeeSalesPerformance')
ORDER BY ROUTINE_NAME;

-- List all created procedures
PRINT CHAR(13) + '--- Stored Procedures ---';
SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'dbo'
    AND ROUTINE_NAME LIKE 'sp_%'
ORDER BY ROUTINE_NAME;
