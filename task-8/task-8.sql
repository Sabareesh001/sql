-- Task 8: Common Table Expressions (CTEs) and Recursive Queries
-- Objective: Simplify complex queries and process hierarchical data using CTEs.

-- ============================================================================
-- PART 1: Setup - Create and Populate Tables
-- ============================================================================

-- Create Employees table with manager relationships
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Department VARCHAR(50),
    Salary DECIMAL(10, 2),
    ManagerID INT,
    FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID)
);

-- Create Sales table for non-recursive CTE example
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    Department VARCHAR(50),
    SalesAmount DECIMAL(10, 2),
    SaleDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Create Categories table for recursive CTE example
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL,
    ParentCategoryID INT,
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);

-- ============================================================================
-- Insert sample data into Employees
-- ============================================================================
INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, Salary, ManagerID) VALUES
(1, 'John', 'Smith', 'Sales', 80000, NULL),           -- CEO
(2, 'Jane', 'Doe', 'Sales', 70000, 1),                -- Reports to John
(3, 'Michael', 'Johnson', 'Engineering', 85000, NULL), -- Engineering Director
(4, 'Sarah', 'Williams', 'Engineering', 75000, 3),    -- Reports to Michael
(5, 'Robert', 'Brown', 'Sales', 65000, 2),            -- Reports to Jane
(6, 'Emily', 'Davis', 'Marketing', 60000, 1),         -- Reports to John
(7, 'David', 'Miller', 'Engineering', 72000, 3),      -- Reports to Michael
(8, 'Lisa', 'Wilson', 'Sales', 62000, 2),             -- Reports to Jane
(9, 'James', 'Moore', 'Marketing', 55000, 6);         -- Reports to Emily

-- ============================================================================
-- Insert sample data into Sales
-- ============================================================================
INSERT INTO Sales (EmployeeID, Department, SalesAmount, SaleDate) VALUES
(2, 'Sales', 5000, '2024-01-15'),
(2, 'Sales', 7500, '2024-02-10'),
(5, 'Sales', 6000, '2024-01-20'),
(5, 'Sales', 4500, '2024-03-15'),
(8, 'Sales', 8000, '2024-01-25'),
(8, 'Sales', 5500, '2024-02-28'),
(6, 'Marketing', 3000, '2024-01-10'),
(6, 'Marketing', 4000, '2024-02-15'),
(9, 'Marketing', 2500, '2024-03-20');

-- ============================================================================
-- Insert sample data into Categories
-- ============================================================================
INSERT INTO Categories (CategoryID, CategoryName, ParentCategoryID) VALUES
(1, 'Electronics', NULL),                  -- Root category
(2, 'Computers', 1),                       -- Child of Electronics
(3, 'Mobile Devices', 1),                  -- Child of Electronics
(4, 'Laptops', 2),                         -- Child of Computers
(5, 'Desktops', 2),                        -- Child of Computers
(6, 'Smartphones', 3),                     -- Child of Mobile Devices
(7, 'Tablets', 3),                         -- Child of Mobile Devices
(8, 'Gaming Laptops', 4),                  -- Child of Laptops
(9, 'Budget Laptops', 4);                  -- Child of Laptops

-- ============================================================================
-- PART 2: NON-RECURSIVE CTE EXAMPLES
-- ============================================================================

-- Example 1: Simple Non-Recursive CTE
-- Breaking down sales analysis into steps for clarity
PRINT '=== Example 1: Non-Recursive CTE - Sales Summary by Department ===';
WITH SalesBySales AS (
    SELECT 
        Department,
        COUNT(*) AS TotalTransactions,
        SUM(SalesAmount) AS TotalSales,
        AVG(SalesAmount) AS AvgSalesAmount
    FROM Sales
    GROUP BY Department
)
SELECT 
    Department,
    TotalTransactions,
    TotalSales,
    AvgSalesAmount,
    ROUND((TotalSales / (SELECT SUM(SalesAmount) FROM Sales)) * 100, 2) AS PercentageOfTotal
FROM SalesBySales
ORDER BY TotalSales DESC;

-- Example 2: Multi-Step Non-Recursive CTE
-- Calculate department sales, ranking, and cumulative totals
PRINT '';
PRINT '=== Example 2: Multi-Step Non-Recursive CTE - Sales Analytics ===';
WITH MonthlySales AS (
    SELECT 
        Department,
        YEAR(SaleDate) AS Year,
        MONTH(SaleDate) AS Month,
        SUM(SalesAmount) AS MonthlySales
    FROM Sales
    GROUP BY Department, YEAR(SaleDate), MONTH(SaleDate)
),
DepartmentAnnualSales AS (
    SELECT 
        Department,
        SUM(MonthlySales) AS AnnualSales,
        COUNT(*) AS MonthsActive
    FROM MonthlySales
    GROUP BY Department
),
RankedDepartments AS (
    SELECT 
        Department,
        AnnualSales,
        MonthsActive,
        ROW_NUMBER() OVER (ORDER BY AnnualSales DESC) AS DepartmentRank
    FROM DepartmentAnnualSales
)
SELECT 
    DepartmentRank,
    Department,
    AnnualSales,
    MonthsActive,
    ROUND(AnnualSales / MonthsActive, 2) AS AvgMonthlySales
FROM RankedDepartments;

-- Example 3: Non-Recursive CTE with Complex Logic
-- Employee performance analysis
PRINT '';
PRINT '=== Example 3: Non-Recursive CTE - Employee Performance ===';
WITH EmployeeSalesTotal AS (
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Department,
        e.Salary,
        COALESCE(SUM(s.SalesAmount), 0) AS TotalSalesAmount,
        COALESCE(COUNT(s.SaleID), 0) AS NumberOfSales
    FROM Employees e
    LEFT JOIN Sales s ON e.EmployeeID = s.EmployeeID
    GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.Department, e.Salary
),
EmployeePerformance AS (
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Department,
        Salary,
        TotalSalesAmount,
        NumberOfSales,
        CASE 
            WHEN NumberOfSales > 3 THEN 'High Performer'
            WHEN NumberOfSales > 1 THEN 'Medium Performer'
            ELSE 'Low Performer'
        END AS PerformanceLevel
    FROM EmployeeSalesTotal
)
SELECT 
    FirstName,
    LastName,
    Department,
    Salary,
    TotalSalesAmount,
    NumberOfSales,
    PerformanceLevel
FROM EmployeePerformance
ORDER BY TotalSalesAmount DESC;

-- ============================================================================
-- PART 3: RECURSIVE CTE EXAMPLES
-- ============================================================================

-- Example 1: Recursive CTE - Organizational Hierarchy
-- Display employee reporting chain (manager-employee relationships)
PRINT '';
PRINT '=== Example 1: Recursive CTE - Organizational Hierarchy ===';
WITH EmployeeHierarchy AS (
    -- Anchor Member: Start with top-level employees (no manager)
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        ManagerID,
        Department,
        Salary,
        0 AS Level,  -- Root level
        CAST(FirstName + ' ' + LastName AS VARCHAR(MAX)) AS FullHierarchy
    FROM Employees
    WHERE ManagerID IS NULL
    
    UNION ALL
    
    -- Recursive Member: Get employees reporting to the above employees
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.ManagerID,
        e.Department,
        e.Salary,
        eh.Level + 1 AS Level,
        CAST(eh.FullHierarchy + ' -> ' + e.FirstName + ' ' + e.LastName AS VARCHAR(MAX)) AS FullHierarchy
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
    WHERE eh.Level < 10  -- Prevent infinite loops: max depth of 10
)
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Department,
    Salary,
    Level,
    REPLICATE('  ', Level) + FullHierarchy AS OrganizationChart
FROM EmployeeHierarchy
ORDER BY FullHierarchy;

-- Example 2: Recursive CTE - Category Hierarchy
-- Display product category tree with depth limit
PRINT '';
PRINT '=== Example 2: Recursive CTE - Product Category Tree ===';
WITH CategoryHierarchy AS (
    -- Anchor Member: Root categories (no parent)
    SELECT 
        CategoryID,
        CategoryName,
        ParentCategoryID,
        0 AS Level,
        CAST(CategoryName AS VARCHAR(MAX)) AS CategoryPath
    FROM Categories
    WHERE ParentCategoryID IS NULL
    
    UNION ALL
    
    -- Recursive Member: Child categories
    SELECT 
        c.CategoryID,
        c.CategoryName,
        c.ParentCategoryID,
        ch.Level + 1 AS Level,
        CAST(ch.CategoryPath + ' > ' + c.CategoryName AS VARCHAR(MAX)) AS CategoryPath
    FROM Categories c
    INNER JOIN CategoryHierarchy ch ON c.ParentCategoryID = ch.CategoryID
    WHERE ch.Level < 5  -- Prevent infinite loops: max depth of 5
)
SELECT 
    CategoryID,
    CategoryName,
    ParentCategoryID,
    Level,
    REPLICATE('    ', Level) + CategoryPath AS CategoryHierarchy
FROM CategoryHierarchy
ORDER BY CategoryPath;

-- Example 3: Recursive CTE with Row Numbering
-- Show organizational levels with employee counts
PRINT '';
PRINT '=== Example 3: Recursive CTE - Organizational Levels ===';
WITH EmployeeHierarchyWithCount AS (
    -- Anchor Member
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        ManagerID,
        Department,
        0 AS Level,
        ROW_NUMBER() OVER (ORDER BY EmployeeID) AS SequenceNum
    FROM Employees
    WHERE ManagerID IS NULL
    
    UNION ALL
    
    -- Recursive Member
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.ManagerID,
        e.Department,
        ehc.Level + 1 AS Level,
        ROW_NUMBER() OVER (ORDER BY e.EmployeeID) AS SequenceNum
    FROM Employees e
    INNER JOIN EmployeeHierarchyWithCount ehc ON e.ManagerID = ehc.EmployeeID
    WHERE ehc.Level < 10  -- Termination: max 10 levels
)
SELECT 
    Level,
    COUNT(*) AS EmployeeCount,
    STRING_AGG(FirstName + ' ' + LastName, ', ') AS Employees
FROM EmployeeHierarchyWithCount
GROUP BY Level
ORDER BY Level;

-- ============================================================================
-- PART 4: BEST PRACTICES AND ADVANCED EXAMPLES
-- ============================================================================

-- Example 1: Recursive CTE with MAXRECURSION hint (SQL Server specific)
-- Prevents runaway queries with a hard limit
PRINT '';
PRINT '=== Example 4: Recursive CTE with MAXRECURSION Hint ===';
WITH LimitedHierarchy AS (
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        ManagerID,
        0 AS Level
    FROM Employees
    WHERE ManagerID IS NULL
    
    UNION ALL
    
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.ManagerID,
        lh.Level + 1
    FROM Employees e
    INNER JOIN LimitedHierarchy lh ON e.ManagerID = lh.EmployeeID
    WHERE lh.Level < 10
)
SELECT * FROM LimitedHierarchy
OPTION (MAXRECURSION 100);  -- Hard limit of 100 recursive levels

-- Example 2: Number all nodes in a hierarchy for tracking
PRINT '';
PRINT '=== Example 5: Recursive CTE with Node Numbering ===';
WITH NumberedHierarchy AS (
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        ManagerID,
        0 AS Level,
        CAST('1' AS VARCHAR(100)) AS NodeNumber
    FROM Employees
    WHERE ManagerID IS NULL
    
    UNION ALL
    
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.ManagerID,
        nh.Level + 1,
        CAST(nh.NodeNumber + '.' + CAST(ROW_NUMBER() OVER (PARTITION BY nh.EmployeeID ORDER BY e.EmployeeID) AS VARCHAR(10)) AS VARCHAR(100))
    FROM Employees e
    INNER JOIN NumberedHierarchy nh ON e.ManagerID = nh.EmployeeID
    WHERE nh.Level < 10
)
SELECT 
    NodeNumber,
    EmployeeID,
    FirstName,
    LastName,
    Level,
    REPLICATE('  ', Level) + FirstName + ' ' + LastName AS HierarchyDisplay
FROM NumberedHierarchy
ORDER BY NodeNumber;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify data insertion
PRINT '';
PRINT '=== Data Verification ===';
SELECT 'Employees' AS TableName, COUNT(*) AS RecordCount FROM Employees
UNION ALL
SELECT 'Sales', COUNT(*) FROM Sales
UNION ALL
SELECT 'Categories', COUNT(*) FROM Categories;

-- Show all data in each table for reference
PRINT '';
PRINT '=== All Employees ===';
SELECT * FROM Employees ORDER BY ManagerID, EmployeeID;

PRINT '';
PRINT '=== All Sales ===';
SELECT * FROM Sales ORDER BY SaleDate;

PRINT '';
PRINT '=== All Categories ===';
SELECT * FROM Categories ORDER BY ParentCategoryID, CategoryID;
