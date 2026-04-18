-- Task 1: Creating and Populating Tables
-- Objective: Set up a simple table, insert data, and retrieve that data using basic queries.

-- Step 1: Create the Employees table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Department VARCHAR(50),
    Salary DECIMAL(10, 2),
    HireDate DATE
);

-- Step 2: Insert sample data into the Employees table
INSERT INTO Employees (FirstName, LastName, Department, Salary, HireDate) VALUES
('John', 'Smith', 'Sales', 50000, '2020-01-15'),
('Jane', 'Doe', 'Engineering', 75000, '2019-03-20'),
('Michael', 'Johnson', 'Sales', 55000, '2021-06-10'),
('Sarah', 'Williams', 'Engineering', 80000, '2018-11-05'),
('Robert', 'Brown', 'HR', 45000, '2020-09-12'),
('Emily', 'Davis', 'Sales', 52000, '2022-02-01'),
('David', 'Miller', 'Engineering', 78000, '2019-05-18'),
('Lisa', 'Wilson', 'Marketing', 48000, '2021-08-22');

-- Step 3: Retrieve and verify all data
SELECT * FROM Employees;

-- Verify row count
SELECT COUNT(*) AS TotalRecords FROM Employees;
