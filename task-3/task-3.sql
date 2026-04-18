-- Task 3: Simple Aggregation and Grouping
-- Objective: Summarize data using aggregate functions and grouping.

-- Assuming the Employees table from Task 1 exists

-- Query 1: Count total employees
SELECT COUNT(*) AS TotalEmployees 
FROM Employees;

-- Query 2: Count employees per department
SELECT Department, COUNT(*) AS EmployeeCount 
FROM Employees 
GROUP BY Department;

-- Query 3: Calculate average salary per department
SELECT Department, 
       AVG(Salary) AS AvgSalary 
FROM Employees 
GROUP BY Department
ORDER BY AvgSalary DESC;

-- Query 4: Sum of salaries by department
SELECT Department, 
       SUM(Salary) AS TotalSalary,
       COUNT(*) AS EmployeeCount
FROM Employees 
GROUP BY Department
ORDER BY TotalSalary DESC;

-- Query 5: Minimum and maximum salary per department
SELECT Department, 
       MIN(Salary) AS MinSalary,
       MAX(Salary) AS MaxSalary,
       COUNT(*) AS EmployeeCount
FROM Employees 
GROUP BY Department
ORDER BY Department;

-- Query 6: Multiple aggregations in one query
SELECT Department, 
       COUNT(*) AS EmployeeCount,
       AVG(Salary) AS AvgSalary,
       MIN(Salary) AS MinSalary,
       MAX(Salary) AS MaxSalary,
       SUM(Salary) AS TotalSalary
FROM Employees 
GROUP BY Department
ORDER BY Department;

-- Query 7: HAVING clause - departments with more than 2 employees
SELECT Department, 
       COUNT(*) AS EmployeeCount,
       AVG(Salary) AS AvgSalary
FROM Employees 
GROUP BY Department
HAVING COUNT(*) > 2
ORDER BY EmployeeCount DESC;

-- Query 8: HAVING clause - departments with average salary > 60000
SELECT Department, 
       COUNT(*) AS EmployeeCount,
       AVG(Salary) AS AvgSalary
FROM Employees 
GROUP BY Department
HAVING AVG(Salary) > 60000
ORDER BY AvgSalary DESC;

-- Query 9: Count employees and average salary, filter with HAVING
SELECT Department, 
       COUNT(*) AS EmployeeCount,
       AVG(Salary) AS AvgSalary
FROM Employees 
GROUP BY Department
HAVING COUNT(*) >= 2 AND AVG(Salary) > 50000
ORDER BY AvgSalary DESC;

-- Query 10: Overall company statistics
SELECT 'All Company' AS Category,
       COUNT(*) AS TotalEmployees,
       AVG(Salary) AS AvgSalary,
       MIN(Salary) AS MinSalary,
       MAX(Salary) AS MaxSalary,
       SUM(Salary) AS TotalPayroll
FROM Employees;
