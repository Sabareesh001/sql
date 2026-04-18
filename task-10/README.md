# Task 10: Comprehensive Database Design, Optimization, and Advanced Features

## Objective

Design a normalized database schema for a complex business scenario (eCommerce platform) and implement advanced SQL features to ensure performance, data integrity, and automation.

## Requirements

### 1. Schema Design

Create a normalized database for an eCommerce platform with multiple related tables:

#### Core Tables:

- **Categories**: Product categories with hierarchical relationships
- **Products**: Product information with pricing and descriptions
- **Customers**: Customer information and contact details
- **Orders**: Order header information with dates and status
- **OrderDetails**: Line items for each order
- **Inventory**: Stock levels and warehouse information
- **Reviews**: Customer product reviews and ratings
- **AuditLog**: Track changes to critical tables

#### Design Principles:

- Primary keys (auto-incrementing integers or unique identifiers)
- Foreign key relationships with referential integrity
- Unique constraints (email, SKU, etc.)
- NOT NULL constraints where appropriate
- Default values for timestamps and status columns

### 2. Indexing and Performance

Apply indexing strategies to optimize common queries:

- **Primary Key Indexes**: Automatic (clustered index)
- **Foreign Key Indexes**: For JOIN operations
- **Search Indexes**: On frequently filtered columns (CustomerEmail, ProductSKU, OrderStatus)
- **Composite Indexes**: For multi-column WHERE clauses
- **Analysis**: Identify slow queries and demonstrate index impact

### 3. Triggers

Implement triggers to enforce business rules automatically:

- **Inventory Management**: Update stock levels when orders are placed
- **Order Processing**: Calculate order totals and update customer statistics
- **Audit Logging**: Log all changes to Products and Orders tables
- **Data Validation**: Ensure business rule compliance (e.g., discount limits)

### 4. Transactions

Use transactions to ensure ACID compliance during complex operations:

- **Order Processing Transaction**:
  - Create order header
  - Insert order details
  - Update inventory
  - Calculate totals
  - All-or-nothing execution
- **Inventory Adjustment**:
  - Check current stock
  - Update stock levels
  - Log the transaction
- **Refund/Return Processing**:
  - Create return record
  - Restore inventory
  - Update order status

### 5. Views and Materialized Views

Create views to simplify complex queries:

- **CustomerOrderSummary**: Customer info with order statistics
- **ProductPerformance**: Sales data by product
- **LowInventoryAlert**: Products below minimum stock
- **OrderStatusOverview**: Order counts by status
- **RevenueAnalysis**: Revenue by category and time period

### 6. Documentation and Testing

- Document table relationships (ER diagram in comments)
- Include data dictionary (table/column descriptions)
- Test all constraints and triggers
- Verify transactions rollback on errors
- Demonstrate view functionality
- Performance before/after indexing

## Database Structure Overview

```
eCommerce Database
├── Categories (CategoryID, CategoryName, Description)
├── Products (ProductID, CategoryID, ProductName, SKU, Price, Description)
├── Customers (CustomerID, FirstName, LastName, Email, Phone, Address)
├── Orders (OrderID, CustomerID, OrderDate, TotalAmount, Status)
├── OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice)
├── Inventory (InventoryID, ProductID, Quantity, ReorderLevel, WarehouseLocation)
├── Reviews (ReviewID, ProductID, CustomerID, Rating, ReviewText)
└── AuditLog (AuditID, TableName, ActionType, RecordID, OldValue, NewValue, Timestamp)
```

## Key Features

### Performance Optimization

- Strategic indexing on frequently queried columns
- Composite indexes for multi-column searches
- Foreign key indexes for JOIN performance
- Query analysis with execution plans

### Data Integrity

- Primary and foreign key constraints
- Unique constraints (email, SKU)
- Check constraints (valid ratings, positive prices)
- NOT NULL constraints on critical fields

### Business Logic Automation

- Triggers for inventory management
- Automatic order total calculation
- Audit trail for compliance
- Stock level notifications

### ACID Compliance

- Transactions for complex operations
- Rollback on errors
- Consistent state after operations
- Isolation levels management

## Best Practices Demonstrated

1. **Normalization**: Third Normal Form (3NF) schema design
2. **Relationships**: Proper use of foreign keys
3. **Indexing**: Strategic index creation and maintenance
4. **Constraints**: Comprehensive data validation
5. **Triggers**: Automated business logic without application code
6. **Transactions**: ACID properties for data reliability
7. **Documentation**: Clear comments and data dictionary
8. **Testing**: Comprehensive validation of all features

## Example Scenarios

### Scenario 1: Complete Order Processing

1. Create order record
2. Insert order details
3. Validate inventory
4. Update stock levels
5. Calculate total
6. Confirm or rollback

### Scenario 2: Product Management

1. Add new product with category
2. Set initial inventory
3. Create indexes for searches
4. Monitor low stock alerts
5. Track product reviews

### Scenario 3: Reporting and Analytics

1. Customer order history
2. Product sales performance
3. Revenue by category
4. Inventory status
5. Customer satisfaction ratings
