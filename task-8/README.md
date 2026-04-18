# Task 8: Common Table Expressions (CTEs) and Recursive Queries

## Objective

Simplify complex queries and process hierarchical data using CTEs. Master both non-recursive and recursive CTEs for improved query readability and handling of hierarchical data structures.

## Requirements

### 1. Non-Recursive CTE

- Write a CTE to structure a multi-step query for better readability.
- Example: Breaking down a complex aggregation (e.g., calculating total sales by department and year).
- Use the `WITH` clause to define one or more CTEs.
- Demonstrate how CTEs improve query organization and make complex logic easier to understand.

### 2. Recursive CTE

- Create a recursive CTE to display hierarchical data.
- Examples:
  - **Organizational Chart**: Display manager-employee relationships at different levels.
  - **Category Tree**: Show parent-child category relationships.
  - **File Directory Structure**: Display nested folder hierarchies.
- Components of a recursive CTE:
  - **Anchor Member**: The initial query that starts the recursion.
  - **Recursive Member**: The query that references the CTE itself.
  - **UNION ALL**: Combines the anchor and recursive members.

### 3. Prevent Infinite Loops

- Implement proper termination conditions using:
  - A depth counter or level limit to stop recursion.
  - A WHERE clause condition that prevents further recursion.
  - The `MAXRECURSION` hint (SQL Server) to set a maximum recursion depth.

## Key Concepts

### Non-Recursive CTE Syntax

```sql
WITH CTE_Name AS (
    SELECT ...
    FROM ...
    WHERE ...
)
SELECT * FROM CTE_Name;
```

### Recursive CTE Syntax

```sql
WITH RECURSIVE CTE_Name AS (
    -- Anchor Member: Initial query
    SELECT ... FROM ...
    WHERE ...

    UNION ALL

    -- Recursive Member: References the CTE itself
    SELECT ... FROM CTE_Name
    WHERE ... -- Termination condition
)
SELECT * FROM CTE_Name;
```

## Example Scenarios

### Scenario 1: Non-Recursive CTE

Breaking down a sales analysis query:

1. Calculate monthly sales by department.
2. Calculate total sales across all departments.
3. Calculate percentage contribution by department.

### Scenario 2: Recursive CTE

Organizational hierarchy:

1. Start with top-level managers (anchor member).
2. Recursively add employees under each manager (recursive member).
3. Include a depth limit to avoid infinite loops.

## Best Practices

1. **Readability**: Use meaningful CTE names that describe their purpose.
2. **Performance**: Consider indexing columns used in JOIN conditions.
3. **Termination**: Always include a clear termination condition in recursive CTEs.
4. **Recursion Limits**: Set appropriate depth limits based on your data structure.
5. **Testing**: Test with small datasets first to verify the recursion logic.
