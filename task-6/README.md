# Task 6: Date and Time Functions

## Objective

Manipulate and query data based on date and time values using built-in SQL date functions.

## Requirements

### 1. Use Date Functions for Interval Calculations

- Use `DATEDIFF` to calculate intervals (e.g., days between hire date and today).
- Use `DATEADD` to adjust dates (e.g., add days/months to a date).
- Calculate employee tenure or project duration.

### 2. Filter Records Based on Date Ranges

- Write a query to retrieve records within a specific date range (e.g., employees hired in the last 30 days).
- Filter orders or records placed within the last 6 months.
- Query records from a specific month or year.

### 3. Format Date Outputs

- Use `CONVERT` (SQL Server) or `DATE_FORMAT` (MySQL) to format dates as strings.
- Display dates in different formats (e.g., 'DD-MMM-YYYY', 'MM/DD/YYYY').
- Extract components (YEAR, MONTH, DAY) from date columns.

## Example Queries

```sql
-- Calculate age/tenure in days
SELECT EmployeeID, FirstName,
       DATEDIFF(DAY, HireDate, GETDATE()) AS DaysEmployed
FROM Employees;

-- Filter employees hired in the last 30 days
SELECT * FROM Employees
WHERE HireDate >= DATEADD(DAY, -30, GETDATE());

-- Format date output
SELECT EmployeeID, FirstName,
       CONVERT(VARCHAR(20), HireDate, 103) AS FormattedHireDate
FROM Employees;
```

## Deliverable

Create SQL queries in `task-6.sql` that:

1. Create/use an Orders or Employees table with date fields
2. Demonstrate at least 3 different date function operations
3. Show filtering by date ranges
4. Display formatted date outputs
5. Include comments explaining each query
