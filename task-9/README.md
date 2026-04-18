# Task 9: Stored Procedures and User-Defined Functions

## Objective

Encapsulate business logic using stored procedures and functions. Learn to create reusable database code that can be called from applications or other SQL scripts.

## Requirements

### 1. Stored Procedures

- Create a **stored procedure** that accepts parameters.
  - Example: Accept a date range and return total sales for that period.
  - Another example: Accept employee/department criteria and return filtered records.
- The procedure should:
  - Accept input parameters (with appropriate data types).
  - Process data and return results using SELECT statements.
  - Include error handling or conditional logic where appropriate.

### 2. User-Defined Functions

- Create **scalar user-defined function** (returns a single value).
  - Example: Calculate discount percentage based on purchase amount or employee tenure.
  - Another example: Calculate bonus based on sales performance.
- Create **table-valued user-defined function** (returns a table).
  - Example: Get all employees in a department with their salary details.
  - Another example: Get sales data for a specific time period.
- Functions should:
  - Accept input parameters.
  - Perform calculations or queries.
  - Return results deterministically.

### 3. Testing and Verification

- Test the stored procedures by calling them with different parameter values.
- Test user-defined functions by using them in SELECT queries.
- Verify outputs match expected results.
- Demonstrate how to pass parameters and retrieve results.

## Key Concepts

### Stored Procedure Syntax

```sql
CREATE PROCEDURE ProcedureName
    @Parameter1 DataType,
    @Parameter2 DataType = DefaultValue
AS
BEGIN
    -- Procedure body
    SELECT ...
    FROM ...
    WHERE ...
END;

-- Call the procedure
EXEC ProcedureName @Parameter1 = Value1, @Parameter2 = Value2;
```

### Scalar User-Defined Function Syntax

```sql
CREATE FUNCTION FunctionName(@Parameter1 DataType)
RETURNS DataType
AS
BEGIN
    DECLARE @Result DataType;
    -- Function logic
    SET @Result = (SELECT SUM(...) FROM ...);
    RETURN @Result;
END;

-- Call the function
SELECT dbo.FunctionName(@Parameter1) AS Result;
```

### Table-Valued User-Defined Function Syntax

```sql
CREATE FUNCTION FunctionName(@Parameter DataType)
RETURNS TABLE
AS
RETURN (
    SELECT ... FROM ... WHERE ...
);

-- Call the function
SELECT * FROM dbo.FunctionName(@Parameter);
```

## Example Scenarios

### Stored Procedure Examples

1. **Sales Report by Date Range**: Accept start and end dates, return sales summary.
2. **Employee Bonus Calculation**: Accept department, return employees and calculated bonuses.
3. **Department Summary**: Accept department name, return employee count, average salary, total compensation.

### User-Defined Function Examples

1. **Scalar Function - Calculate Discount**: Based on purchase amount or customer loyalty.
2. **Scalar Function - Calculate Tenure Bonus**: Based on hire date, calculate bonus percentage.
3. **Table Function - Get Department Employees**: Return all employees in a given department.
4. **Table Function - Get Sales by Date Range**: Return sales data filtered by date range.

## Best Practices

1. **Naming Conventions**: Prefix procedures with `sp_` (e.g., `sp_GetSales`), functions with meaningful names.
2. **Parameter Naming**: Use `@` prefix for parameters (e.g., `@StartDate`, `@DepartmentID`).
3. **Error Handling**: Include TRY-CATCH blocks or check for NULL inputs.
4. **Documentation**: Add comments explaining the purpose, parameters, and return values.
5. **Performance**: Avoid using user-defined functions in WHERE clauses if performance is critical.
6. **Testing**: Always test with edge cases and various parameter values.
7. **Consistency**: Keep procedure and function logic consistent with business rules.
