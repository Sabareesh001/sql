-- Task 7: Window Functions and Ranking
-- Objective: Leverage window functions to perform calculations across a set of rows.

-- ===== Step 1: Create the Employees table =====
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2),
    HireDate DATE
);

-- ===== Step 2: Insert sample employee data =====
INSERT INTO Employees (FirstName, LastName, Department, Salary, HireDate) VALUES
('John', 'Smith', 'Sales', 50000, '2020-01-15'),
('Jane', 'Doe', 'Engineering', 75000, '2019-03-20'),
('Michael', 'Johnson', 'Sales', 55000, '2021-06-10'),
('Sarah', 'Williams', 'Engineering', 80000, '2018-11-05'),
('Robert', 'Brown', 'HR', 45000, '2020-09-12'),
('Emily', 'Davis', 'Sales', 52000, '2022-02-01'),
('David', 'Miller', 'Engineering', 78000, '2019-05-18'),
('Lisa', 'Wilson', 'Marketing', 48000, '2021-08-22'),
('James', 'Taylor', 'Sales', 58000, '2021-01-10'),
('Patricia', 'Anderson', 'Engineering', 82000, '2017-07-12');

-- ===== Step 3: Create the Orders table =====
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    OrderDate DATE,
    Amount DECIMAL(10, 2),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- ===== Step 4: Insert sample order data =====
INSERT INTO Orders (EmployeeID, OrderDate, Amount) VALUES
(1, '2026-01-05', 500),
(1, '2026-02-10', 750),
(1, '2026-03-15', 600),
(2, '2026-01-12', 1000),
(2, '2026-02-20', 1200),
(3, '2026-01-18', 450),
(3, '2026-02-25', 550),
(3, '2026-03-10', 700),
(4, '2026-01-25', 800),
(4, '2026-03-05', 900),
(5, '2026-02-14', 350),
(6, '2026-03-01', 400),
(7, '2026-02-28', 1100),
(8, '2026-01-30', 300),
(9, '2026-03-12', 650);

-- ===== Step 5: ROW_NUMBER() - Assign unique sequential numbers =====
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Department,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS OverallRank,
    ROW_NUMBER() OVER (ORDER BY HireDate ASC) AS HireSequence
FROM Employees
ORDER BY OverallRank;

-- ===== Step 6: RANK() - Rank with ties (skips ranks) =====
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM Employees
ORDER BY SalaryRank;

-- ===== Step 7: DENSE_RANK() - Rank with ties (no gaps) =====
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryDenseRank
FROM Employees
ORDER BY SalaryDenseRank;

-- ===== Step 8: PARTITION BY - Rank employees within each department by salary =====
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptSalaryRank,
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptSalaryDenseRank,
    ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptRowNum
FROM Employees
ORDER BY Department, DeptSalaryRank;

-- ===== Step 9: Find top earner in each department =====
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary
FROM (
    SELECT 
        EmployeeID,
        FirstName,
        Department,
        Salary,
        ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptRank
    FROM Employees
) ranked
WHERE DeptRank = 1
ORDER BY Salary DESC;

-- ===== Step 10: LAG() - Compare salary with previous employee (ordered by salary) =====
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    LAG(Salary) OVER (ORDER BY Salary) AS PreviousSalary,
    Salary - LAG(Salary) OVER (ORDER BY Salary) AS SalaryIncrease
FROM Employees
ORDER BY Salary;

-- ===== Step 11: LEAD() - Compare salary with next employee (ordered by salary) =====
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    LEAD(Salary) OVER (ORDER BY Salary) AS NextSalary,
    LEAD(Salary) OVER (ORDER BY Salary) - Salary AS SalaryDifference
FROM Employees
ORDER BY Salary;

-- ===== Step 12: LAG() and LEAD() within departments =====
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    LAG(FirstName) OVER (PARTITION BY Department ORDER BY Salary) AS PreviousEmp,
    LAG(Salary) OVER (PARTITION BY Department ORDER BY Salary) AS PreviousSalary,
    LEAD(FirstName) OVER (PARTITION BY Department ORDER BY Salary) AS NextEmp,
    LEAD(Salary) OVER (PARTITION BY Department ORDER BY Salary) AS NextSalary
FROM Employees
ORDER BY Department, Salary;

-- ===== Step 13: Window functions with aggregation - Running Total (SUM window function) =====
SELECT 
    OrderID,
    EmployeeID,
    OrderDate,
    Amount,
    SUM(Amount) OVER (ORDER BY OrderID) AS RunningTotal,
    SUM(Amount) OVER (PARTITION BY EmployeeID ORDER BY OrderDate) AS EmployeeRunningTotal
FROM Orders
ORDER BY OrderID;

-- ===== Step 14: Running average and count =====
SELECT 
    OrderID,
    EmployeeID,
    OrderDate,
    Amount,
    AVG(Amount) OVER (ORDER BY OrderID) AS RunningAverage,
    COUNT(*) OVER (ORDER BY OrderID) AS RunningCount,
    AVG(Amount) OVER (PARTITION BY EmployeeID ORDER BY OrderDate) AS EmployeeAvgAmount,
    COUNT(*) OVER (PARTITION BY EmployeeID) AS EmployeeOrderCount
FROM Orders
ORDER BY OrderID;

-- ===== Step 15: FIRST_VALUE() and LAST_VALUE() - Get first and last order amount =====
SELECT 
    OrderID,
    EmployeeID,
    OrderDate,
    Amount,
    FIRST_VALUE(Amount) OVER (PARTITION BY EmployeeID ORDER BY OrderDate) AS FirstOrderAmount,
    LAST_VALUE(Amount) OVER (PARTITION BY EmployeeID ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LastOrderAmount,
    Amount - FIRST_VALUE(Amount) OVER (PARTITION BY EmployeeID ORDER BY OrderDate) AS DiffFromFirst
FROM Orders
ORDER BY EmployeeID, OrderDate;

-- ===== Step 16: NTILE() - Divide employees into quartiles by salary =====
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    NTILE(4) OVER (ORDER BY Salary DESC) AS SalaryQuartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY Salary DESC) = 1 THEN 'Top 25%'
        WHEN NTILE(4) OVER (ORDER BY Salary DESC) = 2 THEN 'Second 25%'
        WHEN NTILE(4) OVER (ORDER BY Salary DESC) = 3 THEN 'Third 25%'
        ELSE 'Bottom 25%'
    END AS SalaryTier
FROM Employees
ORDER BY SalaryQuartile, Salary DESC;

-- ===== Step 17: Complex ranking - Sales ranking with department and running amounts =====
SELECT 
    E.EmployeeID,
    E.FirstName,
    E.Department,
    COUNT(O.OrderID) AS TotalOrders,
    SUM(O.Amount) AS TotalSalesAmount,
    AVG(O.Amount) AS AvgOrderAmount,
    ROW_NUMBER() OVER (ORDER BY SUM(O.Amount) DESC) AS OverallSalesRank,
    RANK() OVER (PARTITION BY E.Department ORDER BY SUM(O.Amount) DESC) AS DeptSalesRank
FROM Employees E
LEFT JOIN Orders O ON E.EmployeeID = O.EmployeeID
GROUP BY E.EmployeeID, E.FirstName, E.Department
ORDER BY OverallSalesRank;

-- ===== Step 18: Identify top 3 orders per employee =====
SELECT 
    EmployeeID,
    OrderID,
    OrderDate,
    Amount
FROM (
    SELECT 
        EmployeeID,
        OrderID,
        OrderDate,
        Amount,
        ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY Amount DESC) AS OrderRank
    FROM Orders
) ranked
WHERE OrderRank <= 3
ORDER BY EmployeeID, OrderRank;

-- ===== Step 19: Salary comparison - Show each employee's salary vs department average =====
SELECT 
    EmployeeID,
    FirstName,
    Department,
    Salary,
    AVG(Salary) OVER (PARTITION BY Department) AS DeptAvgSalary,
    Salary - AVG(Salary) OVER (PARTITION BY Department) AS DiffFromDeptAvg,
    ROUND(((Salary - AVG(Salary) OVER (PARTITION BY Department)) / AVG(Salary) OVER (PARTITION BY Department) * 100), 2) AS PercentDiffFromAvg
FROM Employees
ORDER BY Department, Salary DESC;

-- ===== Step 20: Verify all data =====
SELECT 'Employees Table' AS TableName, COUNT(*) AS RecordCount FROM Employees
UNION ALL
SELECT 'Orders Table' AS TableName, COUNT(*) AS RecordCount FROM Orders;
