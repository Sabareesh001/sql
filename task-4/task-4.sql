-- Task 4: Multi-Table JOINs
-- Objective: Combine data from two related tables using JOIN operations.

-- Assuming the Employees table from Task 1 exists

-- Step 1: Create the Projects table
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY AUTO_INCREMENT,
    ProjectName VARCHAR(100) NOT NULL,
    EmployeeID INT,
    StartDate DATE,
    EndDate DATE,
    Budget DECIMAL(12, 2),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Step 2: Insert sample data into the Projects table
INSERT INTO Projects (ProjectName, EmployeeID, StartDate, EndDate, Budget) VALUES
('Website Redesign', 1, '2023-01-10', '2023-06-15', 50000),
('Database Migration', 2, '2023-02-15', '2023-08-20', 75000),
('Mobile App Development', 4, '2023-03-01', '2023-12-31', 120000),
('Customer Portal', 7, '2023-04-10', '2024-01-10', 95000),
('Data Analytics Dashboard', 2, '2023-05-01', '2023-09-30', 65000),
('Security Audit', 3, '2023-06-15', '2023-07-30', 40000),
('Marketing Website', 8, '2023-07-01', NULL, 55000),
('System Upgrade', 4, '2023-08-01', NULL, 80000);

-- Step 3: INNER JOIN - Get employee names with their projects
SELECT e.FirstName, e.LastName, p.ProjectName, p.StartDate, p.Budget
FROM Employees e
INNER JOIN Projects p ON e.EmployeeID = p.EmployeeID;

-- Query 2: INNER JOIN with WHERE clause
SELECT e.FirstName, e.LastName, e.Department, p.ProjectName, p.Budget
FROM Employees e
INNER JOIN Projects p ON e.EmployeeID = p.EmployeeID
WHERE e.Department = 'Engineering'
ORDER BY e.LastName;

-- Query 3: INNER JOIN with aggregation
SELECT e.FirstName, e.LastName, COUNT(p.ProjectID) AS ProjectCount, SUM(p.Budget) AS TotalBudget
FROM Employees e
INNER JOIN Projects p ON e.EmployeeID = p.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY ProjectCount DESC;

-- Query 4: LEFT JOIN - Show all employees with their projects (if any)
SELECT e.FirstName, e.LastName, e.Department, p.ProjectName, p.StartDate
FROM Employees e
LEFT JOIN Projects p ON e.EmployeeID = p.EmployeeID
ORDER BY e.LastName;

-- Query 5: LEFT JOIN to find employees with no projects
SELECT e.FirstName, e.LastName, e.Department, p.ProjectName
FROM Employees e
LEFT JOIN Projects p ON e.EmployeeID = p.EmployeeID
WHERE p.ProjectID IS NULL
ORDER BY e.LastName;

-- Query 6: INNER JOIN with multiple conditions
SELECT e.FirstName, e.LastName, p.ProjectName, p.Budget, p.StartDate
FROM Employees e
INNER JOIN Projects p ON e.EmployeeID = p.EmployeeID
WHERE p.Budget > 60000 AND p.EndDate IS NOT NULL
ORDER BY p.Budget DESC;

-- Query 7: JOIN with complex query - Employees and their projects
SELECT e.EmployeeID, e.FirstName, e.LastName, e.Department, e.Salary,
       p.ProjectID, p.ProjectName, p.Budget
FROM Employees e
LEFT JOIN Projects p ON e.EmployeeID = p.EmployeeID
ORDER BY e.LastName, p.ProjectName;

-- Query 8: COUNT projects per department
SELECT e.Department, COUNT(p.ProjectID) AS ProjectCount, SUM(p.Budget) AS TotalBudget
FROM Employees e
LEFT JOIN Projects p ON e.EmployeeID = p.EmployeeID
GROUP BY e.Department
ORDER BY ProjectCount DESC;
