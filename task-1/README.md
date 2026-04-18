# Task 1: Creating and Populating Tables

## Objective

Set up a simple table, insert data, and retrieve that data using basic queries.

## Requirements

### 1. Create a Table

- Use `CREATE TABLE` to define a table (e.g., `Employees` or `Products`) with appropriate data types and constraints.
- Include columns such as:
  - ID (Primary Key, Auto-increment)
  - Name/Title (VARCHAR)
  - Department/Category (VARCHAR)
  - Salary/Price (DECIMAL or INT)
  - Date fields (DATE or DATETIME) if applicable

### 2. Insert Sample Data

- Use `INSERT INTO` to populate the table with multiple rows of sample data.
- Add at least 5-10 rows to have meaningful data to work with in future tasks.

### 3. Retrieve and Verify Data

- Execute a basic `SELECT * FROM TableName;` query to verify all data was inserted correctly.
- Verify that all columns and rows appear as expected.

## Example Structure

```sql
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2),
    HireDate DATE
);

INSERT INTO Employees VALUES
    (1, 'John', 'Smith', 'Sales', 50000, '2020-01-15'),
    (2, 'Jane', 'Doe', 'Engineering', 75000, '2019-03-20'),
    -- Add more rows...
    ;

SELECT * FROM Employees;
```

## Deliverable

- A `.sql` file containing your `CREATE TABLE` and `INSERT INTO` statements
- Verification that the `SELECT *` query returns your data

## Tips

- Start with simple data types: INT, VARCHAR, DECIMAL, DATE
- Use meaningful column names and constraints
- Test your INSERT statements to ensure they execute without errors
