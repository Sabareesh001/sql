# Task 5: Subqueries and Nested Queries

## Objective

Use subqueries to filter or compute values within a main query.

## Requirements

### 1. Subqueries in WHERE Clause

- Write a query that uses a subquery in the `WHERE` clause.
- Examples:
  - Select employees whose salary is above the department's average salary.
  - Select customers whose purchase amount exceeds the overall average.
  - Select employees who work on projects started after a certain date.
- The subquery runs first and returns a value used by the outer query.

### 2. Subqueries in SELECT List

- Write queries using subqueries in the `SELECT` list to compute dynamic columns.
- Examples:
  - Return each employee's name and the difference between their salary and the average.
  - Show each department with the count of employees in that department.
  - Calculate running or aggregate values alongside individual records.

### 3. Correlated vs Non-Correlated Subqueries

- **Non-correlated subquery**: Runs once and uses the result for comparison.
  - Example: `WHERE Salary > (SELECT AVG(Salary) FROM Employees)`
- **Correlated subquery**: References the outer query and runs for each outer row.
  - Example: `WHERE Salary > (SELECT AVG(Salary) FROM Employees WHERE Department = Employees.Department)`
- Write examples of both types and understand the performance differences.

### 4. Subqueries with Aggregate Functions

- Combine subqueries with aggregation for complex calculations.
- Example: `WHERE Salary > (SELECT AVG(Salary) FROM Employees GROUP BY Department)`

### 5. IN and EXISTS Operators with Subqueries

- Use subqueries with `IN` to check if a value exists in a subquery result.
- Use `EXISTS` to check if a subquery returns any rows (if supported).

## Example Queries

```sql
-- Non-correlated subquery: Find employees earning above average
SELECT FirstName, LastName, Salary, Department
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees);

-- Correlated subquery: Find employees earning above their department's average
SELECT FirstName, LastName, Salary, Department
FROM Employees e
WHERE Salary > (SELECT AVG(Salary) FROM Employees WHERE Department = e.Department);

-- Subquery in SELECT list: Show salary difference from overall average
SELECT FirstName, LastName, Salary,
       (SELECT AVG(Salary) FROM Employees) AS AvgSalary,
       Salary - (SELECT AVG(Salary) FROM Employees) AS DiffFromAvg
FROM Employees;

-- Subquery with IN operator
SELECT FirstName, LastName, Department
FROM Employees
WHERE Department IN (SELECT Department FROM Employees WHERE Salary > 70000);

-- Subquery with GROUP BY
SELECT Department,
       (SELECT COUNT(*) FROM Employees e2 WHERE e2.Department = Employees.Department) AS EmpCount
FROM Employees
GROUP BY Department;
```

## Deliverable

- A `.sql` file with at least 6-8 subquery examples
- Include both correlated and non-correlated subqueries
- Demonstrate subqueries in WHERE clause and SELECT list
- Include examples with IN and/or EXISTS operators if applicable
- Comments explaining:
  - Whether each subquery is correlated or non-correlated
  - What each query accomplishes
  - The order of execution (which runs first)

## Tips

- Non-correlated subqueries are generally more efficient; use correlated only when necessary.
- Subqueries can be nested multiple levels deep, but readability suffers.
- Consider using JOINs as an alternative to subqueries for better performance in some cases.
- Test subqueries incrementally: run the subquery alone first, then in context.
- Use parentheses to make subqueries clear and readable.
- Some databases support `EXISTS` and `NOT EXISTS` for efficiency with subqueries.
