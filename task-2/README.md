# Task 2: Basic Filtering and Sorting

## Objective

Write queries that filter records and sort the result set.

## Requirements

### 1. Filtering with WHERE Clause

- Use the `WHERE` clause to filter records based on conditions.
- Write queries to retrieve:
  - Records matching a specific value (e.g., `WHERE Department = 'Sales'`)
  - Records within a range (e.g., `WHERE Salary > 50000`)
  - Records matching a pattern (e.g., `WHERE FirstName LIKE 'J%'`)

### 2. Sorting with ORDER BY

- Apply the `ORDER BY` clause to sort results in ascending (ASC) or descending (DESC) order.
- Sort by numeric columns (e.g., `ORDER BY Salary DESC`)
- Sort by text columns (e.g., `ORDER BY LastName ASC`)
- Sort by multiple columns (e.g., `ORDER BY Department ASC, Salary DESC`)

### 3. Complex Conditions with AND/OR

- Write queries that combine multiple conditions:
  - `WHERE Department = 'Sales' AND Salary > 50000`
  - `WHERE Department = 'Sales' OR Department = 'Engineering'`
  - Use parentheses to control condition precedence: `WHERE (Department = 'Sales' OR Department = 'HR') AND Salary > 40000`

### 4. Additional Filtering Operators

- Experiment with operators like `IN`, `BETWEEN`, `NOT`, and wildcards with `LIKE`

## Example Queries

```sql
-- Filter by department
SELECT * FROM Employees WHERE Department = 'Sales';

-- Filter by salary range and sort
SELECT * FROM Employees
WHERE Salary BETWEEN 50000 AND 75000
ORDER BY Salary DESC;

-- Multiple conditions
SELECT * FROM Employees
WHERE (Department = 'Sales' OR Department = 'Engineering')
  AND Salary > 60000
ORDER BY LastName ASC;

-- Pattern matching
SELECT * FROM Employees WHERE FirstName LIKE 'J%';
```

## Deliverable

- A `.sql` file with at least 5-8 different filtering and sorting queries
- Comments explaining what each query does

## Tips

- Test each query individually to verify results
- Use `LIMIT` to see a sample of large result sets
- Remember: `WHERE` filters rows before sorting, and `ORDER BY` sorts the filtered results
- SQL operators: `=`, `<>`, `<`, `>`, `<=`, `>=`, `LIKE`, `IN`, `BETWEEN`, `NOT`
