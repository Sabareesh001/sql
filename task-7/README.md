# Task 7: Window Functions and Ranking

## Objective

Leverage window functions to perform calculations across a set of rows, enabling advanced analytics and ranking operations.

## Requirements

### 1. Ranking Functions

- Use `ROW_NUMBER()` to assign unique sequential numbers to rows.
- Use `RANK()` to assign ranks where ties get the same rank (skips next rank).
- Use `DENSE_RANK()` to assign ranks where ties get the same rank (no gaps).
- Rank employees by salary within each department.

### 2. PARTITION BY and ORDER BY

- Use `PARTITION BY` to divide rows into groups/partitions.
- Use `ORDER BY` to specify the ranking order within each partition.
- Demonstrate department-wise salary rankings.
- Show category-wise product sales rankings.

### 3. Lead and Lag Functions

- Use `LEAD()` to access values from the next row.
- Use `LAG()` to access values from the previous row.
- Calculate salary differences between consecutive employees.
- Compare current order amounts with previous/next orders.

### 4. Aggregation Window Functions

- Use `SUM()`, `AVG()`, `COUNT()` as window functions with `OVER` clause.
- Calculate running totals (cumulative sum).
- Calculate department-wise averages alongside individual records.

## Example Queries

```sql
-- Rank employees by salary within each department
SELECT EmployeeID, FirstName, Department, Salary,
       RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryRank
FROM Employees;

-- Lead and Lag - Compare with adjacent rows
SELECT EmployeeID, FirstName, Salary,
       LAG(Salary) OVER (ORDER BY Salary) AS PrevSalary,
       LEAD(Salary) OVER (ORDER BY Salary) AS NextSalary
FROM Employees;

-- Running total
SELECT OrderID, Amount,
       SUM(Amount) OVER (ORDER BY OrderID) AS RunningTotal
FROM Orders;
```

## Deliverable

Create SQL queries in `task-7.sql` that:

1. Create/use tables with employee and order data
2. Demonstrate ROW_NUMBER(), RANK(), and DENSE_RANK()
3. Use PARTITION BY for department/category grouping
4. Show LEAD() and LAG() operations
5. Include running totals and aggregation window functions
6. Include comments explaining each query
