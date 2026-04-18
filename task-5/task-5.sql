-- Task 5: Subqueries and Nested Queries
-- Objective: Use subqueries to filter or compute values within a main query.

-- Assuming the Employees and Projects tables from Tasks 1 and 4 exist

-- Query 1: Non-correlated subquery - Employees earning above overall average
SELECT FirstName, LastName, Salary, Department
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees)
ORDER BY Salary DESC;

-- Query 2: Correlated subquery - Employees earning above their department's average
SELECT FirstName, LastName, Salary, Department
FROM Employees e
WHERE Salary > (SELECT AVG(Salary) FROM Employees WHERE Department = e.Department)
ORDER BY Department, Salary DESC;

-- Query 3: Subquery in SELECT list - Show salary difference from overall average
SELECT FirstName, LastName, Salary,
       (SELECT AVG(Salary) FROM Employees) AS AvgSalary,
       Salary - (SELECT AVG(Salary) FROM Employees) AS DiffFromAvg
FROM Employees
ORDER BY DiffFromAvg DESC;

-- Query 4: Subquery with IN operator - Employees in departments with high average salary
SELECT FirstName, LastName, Department, Salary
FROM Employees
WHERE Department IN (SELECT Department FROM Employees WHERE Salary > 70000)
ORDER BY Department, LastName;

-- Query 5: Correlated subquery - Compare department salary to overall average
SELECT FirstName, LastName, Department, Salary,
       (SELECT AVG(Salary) FROM Employees WHERE Department = e.Department) AS DeptAvg
FROM Employees e
WHERE Salary > (SELECT AVG(Salary) FROM Employees)
ORDER BY Department, Salary DESC;

-- Query 6: Subquery with aggregation - Departments and their employee count
SELECT Department, 
       (SELECT COUNT(*) FROM Employees e2 WHERE e2.Department = Employees.Department) AS EmpCount,
       (SELECT AVG(Salary) FROM Employees e2 WHERE e2.Department = Employees.Department) AS DeptAvgSalary
FROM Employees
GROUP BY Department
ORDER BY Department;

-- Query 7: Subquery with WHERE - Find employees on high-budget projects
SELECT FirstName, LastName
FROM Employees
WHERE EmployeeID IN (SELECT EmployeeID FROM Projects WHERE Budget > 80000)
ORDER BY LastName;

-- Query 8: Non-correlated subquery - Highest paid employee per department
SELECT Department, FirstName, LastName, Salary
FROM Employees
WHERE (Department, Salary) IN (
    SELECT Department, MAX(Salary) 
    FROM Employees 
    GROUP BY Department
)
ORDER BY Department;

-- Query 9: Subquery in FROM clause - Get department statistics
SELECT DeptStats.Department, DeptStats.AvgSalary, DeptStats.EmpCount
FROM (
    SELECT Department, AVG(Salary) AS AvgSalary, COUNT(*) AS EmpCount
    FROM Employees
    GROUP BY Department
) AS DeptStats
WHERE DeptStats.AvgSalary > 55000
ORDER BY DeptStats.AvgSalary DESC;

-- Query 10: Nested subqueries - Complex example
SELECT FirstName, LastName, Salary, Department
FROM Employees
WHERE Salary > (
    SELECT AVG(AvgSalary)
    FROM (
        SELECT AVG(Salary) AS AvgSalary
        FROM Employees
        GROUP BY Department
    ) AS DeptAverages
)
ORDER BY Salary DESC;

-- Query 11: Subquery with COUNT - Employees with above-average project count
SELECT FirstName, LastName,
       (SELECT COUNT(*) FROM Projects WHERE EmployeeID = Employees.EmployeeID) AS ProjectCount
FROM Employees
WHERE (SELECT COUNT(*) FROM Projects WHERE EmployeeID = Employees.EmployeeID) > 1
ORDER BY ProjectCount DESC;

-- Query 12: Correlated subquery - Latest project per employee
SELECT FirstName, LastName,
       (SELECT ProjectName FROM Projects WHERE EmployeeID = Employees.EmployeeID ORDER BY StartDate DESC LIMIT 1) AS LatestProject
FROM Employees
WHERE EmployeeID IN (SELECT EmployeeID FROM Projects)
ORDER BY LastName;
