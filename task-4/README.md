# Task 4: Multi-Table JOINs

## Objective

Combine data from two related tables using JOIN operations.

## Requirements

### 1. Create Related Tables

- Create a second table that relates to your Employee table.
- Example: Create an `Orders` table related to a `Customers` table, or a `Projects` table related to `Employees`.
- Establish a foreign key relationship between the tables.
- Ensure proper data relationships (one-to-many, etc.)

### 2. INNER JOIN

- Write an `INNER JOIN` query to retrieve combined information from both tables.
- Example: Get customer names along with their order details, or employee names with their project assignments.
- Only rows with matching records in both tables appear in results.

### 3. LEFT JOIN (Optional Exploration)

- Write a `LEFT JOIN` query to understand how missing matches are handled.
- Example: Show all customers even if they have no orders.
- LEFT JOIN returns all rows from the left table, with NULLs for non-matching right table rows.

### 4. JOIN Conditions and Multiple Joins

- Use `ON` clause to specify the join condition (e.g., `ON Employees.EmployeeID = Projects.EmployeeID`).
- Write queries joining multiple columns if necessary.
- Explore combining data from more than two tables if desired.

## Example Structure

```sql
-- Create a related table
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY AUTO_INCREMENT,
    ProjectName VARCHAR(100),
    EmployeeID INT,
    StartDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Insert sample data
INSERT INTO Projects VALUES
    (1, 'Website Redesign', 1, '2023-01-10'),
    (2, 'Database Migration', 2, '2023-02-15'),
    -- Add more rows...
    ;

-- INNER JOIN example
SELECT Employees.FirstName, Employees.LastName, Projects.ProjectName, Projects.StartDate
FROM Employees
INNER JOIN Projects ON Employees.EmployeeID = Projects.EmployeeID;

-- LEFT JOIN example
SELECT Employees.FirstName, Employees.LastName, Projects.ProjectName
FROM Employees
LEFT JOIN Projects ON Employees.EmployeeID = Projects.EmployeeID;
```

## Deliverable

- `.sql` file(s) containing:
  - `CREATE TABLE` statement for the related table with a foreign key
  - `INSERT INTO` statements with sample data
  - At least 3-4 INNER JOIN queries
  - At least 2 LEFT JOIN queries (or other join types)
- Comments explaining each join and what data it retrieves

## Tips

- Use table aliases to shorten query code: `FROM Employees AS e INNER JOIN Projects AS p`
- Ensure the join condition uses matching columns (usually foreign key matches primary key)
- Test queries with different conditions to see varied result sets
- INNER JOIN: Only matching rows | LEFT JOIN: All left table rows + matching right table rows
- Other join types to explore: RIGHT JOIN, FULL OUTER JOIN (if supported by your database)
