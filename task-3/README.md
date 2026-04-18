# Task 3: Simple Aggregation and Grouping

## Objective

Summarize data using aggregate functions and grouping.

## Requirements

### 1. Aggregate Functions

- Use aggregate functions to calculate summaries:
  - `COUNT()` - Count the number of rows
  - `SUM()` - Sum numeric values
  - `AVG()` - Calculate average values
  - `MIN()` - Find minimum value
  - `MAX()` - Find maximum value
- Apply these functions to calculate totals or averages across the entire table

### 2. GROUP BY Clause

- Use `GROUP BY` to aggregate data by a specific column.
- Examples:
  - Count the number of employees per department
  - Calculate total salary per department
  - Find average salary by department
- Write queries that group by one or more columns

### 3. HAVING Clause (Optional)

- Filter grouped results using the `HAVING` clause.
- Use `HAVING` to show only groups that meet certain criteria.
- Example: Show only departments with more than 2 employees

### 4. Combining Aggregate Functions with Sorting

- Sort grouped results by the aggregate values.
- Example: `ORDER BY COUNT(*) DESC` to show departments with most employees first

## Example Queries

```sql
-- Count total employees
SELECT COUNT(*) AS TotalEmployees FROM Employees;

-- Count employees per department
SELECT Department, COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Department;

-- Average salary per department
SELECT Department, AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY Department
ORDER BY AvgSalary DESC;

-- Departments with more than 2 employees
SELECT Department, COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Department
HAVING COUNT(*) > 2;

-- Multiple aggregations
SELECT Department,
       COUNT(*) AS EmployeeCount,
       AVG(Salary) AS AvgSalary,
       MIN(Salary) AS MinSalary,
       MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY Department;
```

## Deliverable

- A `.sql` file with at least 6-8 aggregation and grouping queries
- Queries demonstrating COUNT, SUM, AVG, MIN, and MAX functions
- Examples with and without HAVING clause
- Comments explaining each query's purpose

## Tips

- When using `GROUP BY`, all non-aggregated columns in the `SELECT` list must be in the `GROUP BY` clause
- Aggregate functions ignore NULL values (except COUNT(\*))
- Use aliases (AS) to make output columns more readable
- `HAVING` is used to filter after grouping, whereas `WHERE` filters before grouping
