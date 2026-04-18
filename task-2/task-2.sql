-- Task 2: Basic Filtering and Sorting
-- Objective: Write queries that filter records and sort the result set.

-- Assuming the Employees table from Task 1 exists
-- If not, uncomment and run the CREATE and INSERT statements from task-1.sql

-- Query 1: Filter by specific department
SELECT * FROM Employees 
WHERE Department = 'Sales';

-- Query 2: Filter by salary range
SELECT * FROM Employees 
WHERE Salary > 50000;

-- Query 3: Filter and sort by salary descending
SELECT FirstName, LastName, Department, Salary 
FROM Employees 
WHERE Salary >= 50000 
ORDER BY Salary DESC;

-- Query 4: Filter by multiple departments using OR
SELECT FirstName, LastName, Department, Salary 
FROM Employees 
WHERE Department = 'Sales' OR Department = 'Engineering'
ORDER BY Department ASC, LastName ASC;

-- Query 5: Filter using AND condition
SELECT FirstName, LastName, Department, Salary 
FROM Employees 
WHERE Department = 'Engineering' AND Salary > 75000
ORDER BY Salary DESC;

-- Query 6: Pattern matching with LIKE
SELECT FirstName, LastName, Department 
FROM Employees 
WHERE FirstName LIKE 'J%'
ORDER BY FirstName;

-- Query 7: Using IN operator
SELECT FirstName, LastName, Department, Salary 
FROM Employees 
WHERE Department IN ('Sales', 'HR', 'Marketing')
ORDER BY Department, LastName;

-- Query 8: Using BETWEEN for range
SELECT FirstName, LastName, Salary 
FROM Employees 
WHERE Salary BETWEEN 45000 AND 60000
ORDER BY Salary DESC;

-- Query 9: Complex conditions with parentheses
SELECT FirstName, LastName, Department, Salary 
FROM Employees 
WHERE (Department = 'Sales' OR Department = 'Marketing') 
  AND Salary > 50000
ORDER BY Salary DESC;

-- Query 10: NOT condition
SELECT FirstName, LastName, Department, Salary 
FROM Employees 
WHERE Department != 'Engineering'
ORDER BY Department, LastName;
