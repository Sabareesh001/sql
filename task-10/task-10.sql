-- Task 10: Comprehensive Database Design, Optimization, and Advanced Features
-- Objective: Design a normalized database schema for an eCommerce platform with advanced SQL features
-- Database: eCommerce Platform

-- ============================================================================
-- PART 1: DROP EXISTING OBJECTS (FOR CLEAN SETUP)
-- ============================================================================

PRINT '=== Dropping existing objects for clean setup ===';

-- Drop triggers first (dependencies)
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'TR' AND name = 'trg_UpdateOrderTotal')
    DROP TRIGGER dbo.trg_UpdateOrderTotal;
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'TR' AND name = 'trg_UpdateInventoryOnOrder')
    DROP TRIGGER dbo.trg_UpdateInventoryOnOrder;
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'TR' AND name = 'trg_LogProductChanges')
    DROP TRIGGER dbo.trg_LogProductChanges;
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'TR' AND name = 'trg_LogOrderChanges')
    DROP TRIGGER dbo.trg_LogOrderChanges;

-- Drop views
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'V' AND name = 'vw_CustomerOrderSummary')
    DROP VIEW dbo.vw_CustomerOrderSummary;
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'V' AND name = 'vw_ProductPerformance')
    DROP VIEW dbo.vw_ProductPerformance;
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'V' AND name = 'vw_LowInventoryAlert')
    DROP VIEW dbo.vw_LowInventoryAlert;
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'V' AND name = 'vw_OrderStatusOverview')
    DROP VIEW dbo.vw_OrderStatusOverview;
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'V' AND name = 'vw_RevenueAnalysis')
    DROP VIEW dbo.vw_RevenueAnalysis;

-- Drop tables
DROP TABLE IF EXISTS dbo.Reviews;
DROP TABLE IF EXISTS dbo.AuditLog;
DROP TABLE IF EXISTS dbo.OrderDetails;
DROP TABLE IF EXISTS dbo.Inventory;
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Products;
DROP TABLE IF EXISTS dbo.Customers;
DROP TABLE IF EXISTS dbo.Categories;

-- ============================================================================
-- PART 2: CREATE NORMALIZED DATABASE SCHEMA
-- ============================================================================

PRINT '';
PRINT '=== Creating normalized database schema ===';

-- Table 1: Categories
-- Purpose: Product category hierarchy
CREATE TABLE dbo.Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(500),
    ParentCategoryID INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);
PRINT 'Created: Categories table';

-- Table 2: Products
-- Purpose: Product catalog with pricing and description
CREATE TABLE dbo.Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    CategoryID INT NOT NULL,
    ProductName VARCHAR(200) NOT NULL,
    SKU VARCHAR(50) NOT NULL UNIQUE,  -- Stock Keeping Unit
    Description VARCHAR(1000),
    Price DECIMAL(10, 2) NOT NULL CHECK (Price > 0),
    DiscountPercentage DECIMAL(5, 2) DEFAULT 0 CHECK (DiscountPercentage >= 0 AND DiscountPercentage <= 100),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CHECK (Price > 0)
);
PRINT 'Created: Products table';

-- Table 3: Customers
-- Purpose: Customer information for eCommerce
CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    PostalCode VARCHAR(20),
    Country VARCHAR(50),
    TotalOrders INT DEFAULT 0,
    TotalSpent DECIMAL(12, 2) DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastOrderDate DATETIME
);
PRINT 'Created: Customers table';

-- Table 4: Orders
-- Purpose: Order header information
CREATE TABLE dbo.Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(12, 2) DEFAULT 0,
    Status VARCHAR(50) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Refunded')),
    ShippingAddress VARCHAR(200),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
PRINT 'Created: Orders table';

-- Table 5: OrderDetails
-- Purpose: Line items for each order
CREATE TABLE dbo.OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice > 0),
    LineTotal AS (Quantity * UnitPrice) PERSISTED,
    DiscountApplied DECIMAL(5, 2) DEFAULT 0,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
PRINT 'Created: OrderDetails table';

-- Table 6: Inventory
-- Purpose: Track product stock levels
CREATE TABLE dbo.Inventory (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT NOT NULL UNIQUE,
    Quantity INT DEFAULT 0 CHECK (Quantity >= 0),
    ReorderLevel INT DEFAULT 10,
    WarehouseLocation VARCHAR(100),
    LastRestockDate DATETIME,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
PRINT 'Created: Inventory table';

-- Table 7: Reviews
-- Purpose: Customer product reviews and ratings
CREATE TABLE dbo.Reviews (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ReviewTitle VARCHAR(200),
    ReviewText VARCHAR(1000),
    HelpfulCount INT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
PRINT 'Created: Reviews table';

-- Table 8: AuditLog
-- Purpose: Track changes to critical tables for compliance
CREATE TABLE dbo.AuditLog (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    TableName VARCHAR(100) NOT NULL,
    ActionType VARCHAR(20) NOT NULL CHECK (ActionType IN ('INSERT', 'UPDATE', 'DELETE')),
    RecordID INT,
    ColumnName VARCHAR(100),
    OldValue VARCHAR(500),
    NewValue VARCHAR(500),
    ModifiedBy VARCHAR(100) DEFAULT SYSTEM_USER,
    ModifiedDate DATETIME DEFAULT GETDATE()
);
PRINT 'Created: AuditLog table';

-- ============================================================================
-- PART 3: CREATE INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

PRINT '';
PRINT '=== Creating indexes for performance optimization ===';

-- Foreign Key Indexes (for JOIN performance)
CREATE INDEX idx_Products_CategoryID ON Products(CategoryID);
CREATE INDEX idx_Orders_CustomerID ON Orders(CustomerID);
CREATE INDEX idx_OrderDetails_OrderID ON OrderDetails(OrderID);
CREATE INDEX idx_OrderDetails_ProductID ON OrderDetails(ProductID);
CREATE INDEX idx_Inventory_ProductID ON Inventory(ProductID);
CREATE INDEX idx_Reviews_ProductID ON Reviews(ProductID);
CREATE INDEX idx_Reviews_CustomerID ON Reviews(CustomerID);
PRINT 'Created: Foreign key indexes';

-- Search Indexes (frequently used in WHERE clauses)
CREATE INDEX idx_Products_SKU ON Products(SKU);
CREATE INDEX idx_Products_IsActive ON Products(IsActive);
CREATE INDEX idx_Customers_Email ON Customers(Email);
CREATE INDEX idx_Orders_Status ON Orders(Status);
CREATE INDEX idx_Orders_OrderDate ON Orders(OrderDate);
CREATE INDEX idx_Inventory_Quantity_ReorderLevel ON Inventory(Quantity, ReorderLevel);
PRINT 'Created: Search indexes';

-- Composite Indexes (multi-column queries)
CREATE INDEX idx_OrderDetails_OrderID_ProductID ON OrderDetails(OrderID, ProductID);
CREATE INDEX idx_Products_CategoryID_IsActive ON Products(CategoryID, IsActive);
CREATE INDEX idx_Reviews_ProductID_Rating ON Reviews(ProductID, Rating);
PRINT 'Created: Composite indexes';

-- ============================================================================
-- PART 4: INSERT SAMPLE DATA
-- ============================================================================

PRINT '';
PRINT '=== Inserting sample data ===';

-- Insert Categories
INSERT INTO Categories (CategoryName, Description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Computers', 'Desktop and laptop computers'),
('Accessories', 'Computer accessories and peripherals'),
('Furniture', 'Office and home furniture'),
('Software', 'Software applications and licenses');
PRINT 'Inserted: Categories';

-- Insert Products
INSERT INTO Products (CategoryID, ProductName, SKU, Description, Price, DiscountPercentage) VALUES
(2, 'Laptop Pro 15', 'LAPTOP-001', 'High-performance laptop with 15-inch display', 1299.99, 5),
(2, 'Desktop Workstation', 'DESKTOP-001', 'Professional desktop for video editing', 1999.99, 0),
(3, 'Mechanical Keyboard', 'KB-001', 'RGB mechanical keyboard', 149.99, 10),
(3, 'Wireless Mouse', 'MOUSE-001', 'Ergonomic wireless mouse', 49.99, 0),
(1, 'Monitor 27inch', 'MON-001', '4K monitor with HDR', 599.99, 15),
(4, 'Desk Lamp LED', 'LAMP-001', 'Energy-efficient LED desk lamp', 79.99, 0),
(5, 'Windows 11 Pro', 'WIN11-PRO', 'Windows 11 Professional License', 199.99, 5);
PRINT 'Inserted: Products';

-- Insert Customers
INSERT INTO Customers (FirstName, LastName, Email, Phone, Address, City, State, PostalCode, Country) VALUES
('John', 'Smith', 'john.smith@email.com', '555-0101', '123 Main St', 'New York', 'NY', '10001', 'USA'),
('Jane', 'Doe', 'jane.doe@email.com', '555-0102', '456 Oak Ave', 'Los Angeles', 'CA', '90001', 'USA'),
('Michael', 'Johnson', 'michael.j@email.com', '555-0103', '789 Pine Rd', 'Chicago', 'IL', '60601', 'USA'),
('Sarah', 'Williams', 'sarah.w@email.com', '555-0104', '321 Elm St', 'Houston', 'TX', '77001', 'USA'),
('David', 'Brown', 'david.brown@email.com', '555-0105', '654 Maple Dr', 'Phoenix', 'AZ', '85001', 'USA');
PRINT 'Inserted: Customers';

-- Insert Orders
INSERT INTO Orders (CustomerID, Status, ShippingAddress) VALUES
(1, 'Delivered', '123 Main St, New York, NY 10001'),
(1, 'Processing', '123 Main St, New York, NY 10001'),
(2, 'Delivered', '456 Oak Ave, Los Angeles, CA 90001'),
(3, 'Shipped', '789 Pine Rd, Chicago, IL 60601'),
(4, 'Pending', '321 Elm St, Houston, TX 77001'),
(5, 'Delivered', '654 Maple Dr, Phoenix, AZ 85001');
PRINT 'Inserted: Orders';

-- Insert OrderDetails
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, DiscountApplied) VALUES
(1, 1, 1, 1299.99, 5),      -- Order 1: Laptop Pro 15
(1, 3, 2, 149.99, 10),      -- Order 1: 2x Mechanical Keyboard
(2, 2, 1, 1999.99, 0),      -- Order 2: Desktop Workstation
(2, 4, 1, 49.99, 0),        -- Order 2: Wireless Mouse
(3, 5, 2, 599.99, 15),      -- Order 3: 2x Monitor 27inch
(4, 1, 1, 1299.99, 5),      -- Order 4: Laptop Pro 15
(5, 3, 3, 149.99, 10),      -- Order 5: 3x Mechanical Keyboard
(6, 7, 1, 199.99, 5);       -- Order 6: Windows 11 Pro
PRINT 'Inserted: OrderDetails';

-- Insert Inventory
INSERT INTO Inventory (ProductID, Quantity, ReorderLevel, WarehouseLocation) VALUES
(1, 45, 10, 'Warehouse A - Shelf 1'),
(2, 8, 5, 'Warehouse B - Shelf 5'),
(3, 120, 20, 'Warehouse A - Shelf 3'),
(4, 200, 50, 'Warehouse A - Shelf 2'),
(5, 3, 10, 'Warehouse B - Shelf 1'),
(6, 75, 15, 'Warehouse A - Shelf 4'),
(7, 30, 10, 'Warehouse C - Shelf 2');
PRINT 'Inserted: Inventory';

-- Insert Reviews
INSERT INTO Reviews (ProductID, CustomerID, Rating, ReviewTitle, ReviewText) VALUES
(1, 1, 5, 'Excellent laptop!', 'Very fast and reliable. Great build quality.'),
(1, 2, 4, 'Good laptop', 'Works well, battery life is decent.'),
(3, 1, 5, 'Perfect keyboard', 'Mechanical switches feel great, RGB is nice.'),
(4, 3, 4, 'Good value', 'Comfortable mouse, reasonable price.'),
(5, 2, 5, 'Crystal clear display', 'Amazing 4K resolution and color accuracy.'),
(7, 5, 5, 'Great OS', 'Windows 11 Pro is stable and feature-rich.');
PRINT 'Inserted: Reviews';

-- ============================================================================
-- PART 5: CREATE TRIGGERS FOR BUSINESS LOGIC
-- ============================================================================

PRINT '';
PRINT '=== Creating triggers for automated business logic ===';

-- Trigger 1: Update Order Total when OrderDetails are inserted/updated
CREATE TRIGGER dbo.trg_UpdateOrderTotal
ON dbo.OrderDetails
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update the TotalAmount in Orders table
    UPDATE Orders
    SET TotalAmount = (
        SELECT SUM(Quantity * UnitPrice * (1 - DiscountApplied / 100))
        FROM OrderDetails
        WHERE OrderID = Orders.OrderID
    ),
    ModifiedDate = GETDATE()
    WHERE OrderID IN (SELECT DISTINCT OrderID FROM inserted);
    
    PRINT 'Trigger: Order total updated';
END;

-- Trigger 2: Update Inventory when Orders are placed
CREATE TRIGGER dbo.trg_UpdateInventoryOnOrder
ON dbo.OrderDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate stock availability
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Inventory inv ON i.ProductID = inv.ProductID
        WHERE inv.Quantity < i.Quantity
    )
    BEGIN
        RAISERROR ('Insufficient inventory for product.', 16, 1);
        ROLLBACK;
        RETURN;
    END
    
    -- Update inventory
    UPDATE Inventory
    SET Quantity = Quantity - i.Quantity,
        LastRestockDate = GETDATE()
    FROM Inventory inv
    JOIN inserted i ON inv.ProductID = i.ProductID;
    
    PRINT 'Trigger: Inventory updated';
END;

-- Trigger 3: Log Product changes to AuditLog
CREATE TRIGGER dbo.trg_LogProductChanges
ON dbo.Products
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Log INSERT
    INSERT INTO AuditLog (TableName, ActionType, RecordID, ColumnName, NewValue)
    SELECT 'Products', 'INSERT', ProductID, 'ProductName', ProductName
    FROM inserted
    WHERE NOT EXISTS (SELECT 1 FROM deleted);
    
    -- Log UPDATE
    INSERT INTO AuditLog (TableName, ActionType, RecordID, ColumnName, OldValue, NewValue)
    SELECT 'Products', 'UPDATE', i.ProductID, 'Price', CAST(d.Price AS VARCHAR(20)), CAST(i.Price AS VARCHAR(20))
    FROM inserted i
    JOIN deleted d ON i.ProductID = d.ProductID
    WHERE i.Price <> d.Price;
    
    -- Log DELETE
    INSERT INTO AuditLog (TableName, ActionType, RecordID, ColumnName, OldValue)
    SELECT 'Products', 'DELETE', ProductID, 'ProductName', ProductName
    FROM deleted
    WHERE NOT EXISTS (SELECT 1 FROM inserted);
    
    PRINT 'Trigger: Product changes logged';
END;

-- Trigger 4: Log Order changes
CREATE TRIGGER dbo.trg_LogOrderChanges
ON dbo.Orders
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Log status changes
    INSERT INTO AuditLog (TableName, ActionType, RecordID, ColumnName, OldValue, NewValue)
    SELECT 'Orders', 'UPDATE', i.OrderID, 'Status', d.Status, i.Status
    FROM inserted i
    LEFT JOIN deleted d ON i.OrderID = d.OrderID
    WHERE i.Status <> ISNULL(d.Status, 'N/A');
    
    PRINT 'Trigger: Order changes logged';
END;

-- ============================================================================
-- PART 6: CREATE VIEWS FOR DATA ANALYSIS
-- ============================================================================

PRINT '';
PRINT '=== Creating views for simplified queries ===';

-- View 1: Customer Order Summary
CREATE VIEW dbo.vw_CustomerOrderSummary
AS
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalSpent,
    AVG(o.TotalAmount) AS AvgOrderValue,
    MAX(o.OrderDate) AS LastOrderDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email;
PRINT 'Created View: vw_CustomerOrderSummary';

-- View 2: Product Performance
CREATE VIEW dbo.vw_ProductPerformance
AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.Price,
    c.CategoryName,
    COUNT(od.OrderDetailID) AS TotalUnitsSold,
    SUM(od.Quantity * od.UnitPrice) AS TotalRevenue,
    AVG(r.Rating) AS AvgRating,
    COUNT(r.ReviewID) AS ReviewCount
FROM Products p
LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
LEFT JOIN Reviews r ON p.ProductID = r.ProductID
GROUP BY p.ProductID, p.ProductName, p.SKU, p.Price, c.CategoryName;
PRINT 'Created View: vw_ProductPerformance';

-- View 3: Low Inventory Alert
CREATE VIEW dbo.vw_LowInventoryAlert
AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    i.Quantity,
    i.ReorderLevel,
    (i.ReorderLevel - i.Quantity) AS UnitsToReorder,
    i.WarehouseLocation,
    CASE 
        WHEN i.Quantity = 0 THEN 'OUT OF STOCK'
        WHEN i.Quantity < i.ReorderLevel THEN 'LOW STOCK'
        ELSE 'IN STOCK'
    END AS InventoryStatus
FROM Products p
JOIN Inventory i ON p.ProductID = i.ProductID
WHERE i.Quantity <= i.ReorderLevel;
PRINT 'Created View: vw_LowInventoryAlert';

-- View 4: Order Status Overview
CREATE VIEW dbo.vw_OrderStatusOverview
AS
SELECT 
    Status,
    COUNT(OrderID) AS OrderCount,
    SUM(TotalAmount) AS TotalRevenue,
    AVG(TotalAmount) AS AvgOrderValue,
    MIN(OrderDate) AS EarliestOrder,
    MAX(OrderDate) AS LatestOrder
FROM Orders
GROUP BY Status;
PRINT 'Created View: vw_OrderStatusOverview';

-- View 5: Revenue Analysis
CREATE VIEW dbo.vw_RevenueAnalysis
AS
SELECT 
    c.CategoryName,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    COUNT(od.OrderDetailID) AS TotalLineItems,
    SUM(od.Quantity) AS TotalUnitsSold,
    SUM(od.Quantity * od.UnitPrice) AS TotalRevenue,
    AVG(od.UnitPrice) AS AvgProductPrice,
    YEAR(o.OrderDate) AS Year,
    MONTH(o.OrderDate) AS Month
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
LEFT JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY c.CategoryName, YEAR(o.OrderDate), MONTH(o.OrderDate);
PRINT 'Created View: vw_RevenueAnalysis';

-- ============================================================================
-- PART 7: CREATE STORED PROCEDURES FOR COMPLEX OPERATIONS
-- ============================================================================

PRINT '';
PRINT '=== Creating stored procedures for complex operations ===';

-- Procedure 1: Process Order with Transaction
CREATE PROCEDURE dbo.sp_ProcessOrder
    @CustomerID INT,
    @ShippingAddress VARCHAR(200),
    @OrderDetails AS OrderDetailTableType READONLY
AS
BEGIN
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @OrderID INT;
        
        -- Create order header
        INSERT INTO Orders (CustomerID, ShippingAddress, Status)
        VALUES (@CustomerID, @ShippingAddress, 'Processing');
        
        SET @OrderID = SCOPE_IDENTITY();
        
        -- Insert order details and update inventory
        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
        SELECT @OrderID, ProductID, Quantity, 
               (SELECT Price FROM Products WHERE ProductID = OrderDetails.ProductID)
        FROM @OrderDetails;
        
        -- Update customer statistics
        UPDATE Customers
        SET TotalOrders = TotalOrders + 1,
            LastOrderDate = GETDATE()
        WHERE CustomerID = @CustomerID;
        
        COMMIT TRANSACTION;
        
        SELECT @OrderID AS OrderID;
        PRINT 'Order processed successfully';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: Order processing failed';
        THROW;
    END CATCH
END;

-- Procedure 2: Check and Alert Low Inventory
CREATE PROCEDURE dbo.sp_CheckLowInventory
AS
BEGIN
    SELECT * FROM vw_LowInventoryAlert;
END;

-- Procedure 3: Get Customer Order History
CREATE PROCEDURE dbo.sp_GetCustomerOrderHistory
    @CustomerID INT
AS
BEGIN
    SELECT 
        o.OrderID,
        o.OrderDate,
        o.Status,
        o.TotalAmount,
        COUNT(od.OrderDetailID) AS LineItemCount
    FROM Orders o
    LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE o.CustomerID = @CustomerID
    GROUP BY o.OrderID, o.OrderDate, o.Status, o.TotalAmount
    ORDER BY o.OrderDate DESC;
END;

PRINT 'Created Stored Procedures';

-- ============================================================================
-- PART 8: DEMONSTRATION AND TESTING
-- ============================================================================

PRINT '';
PRINT '==============================================================';
PRINT 'PART 8: TESTING AND DEMONSTRATION';
PRINT '==============================================================';

-- Test 1: View all products with availability
PRINT '';
PRINT '--- Test 1: Product Inventory Status ---';
SELECT 
    p.ProductName,
    p.SKU,
    p.Price,
    i.Quantity,
    i.ReorderLevel,
    CASE WHEN i.Quantity = 0 THEN 'OUT OF STOCK'
         WHEN i.Quantity < i.ReorderLevel THEN 'LOW STOCK'
         ELSE 'IN STOCK' END AS Status
FROM Products p
JOIN Inventory i ON p.ProductID = i.ProductID
ORDER BY i.Quantity ASC;

-- Test 2: View Customer Order Summary
PRINT '';
PRINT '--- Test 2: Customer Order Summary ---';
SELECT * FROM vw_CustomerOrderSummary
ORDER BY TotalSpent DESC;

-- Test 3: View Product Performance
PRINT '';
PRINT '--- Test 3: Top Products by Revenue ---';
SELECT TOP 5 * FROM vw_ProductPerformance
WHERE TotalRevenue IS NOT NULL
ORDER BY TotalRevenue DESC;

-- Test 4: Low Inventory Alert
PRINT '';
PRINT '--- Test 4: Low Inventory Alert ---';
SELECT * FROM vw_LowInventoryAlert
ORDER BY UnitsToReorder DESC;

-- Test 5: Order Status Overview
PRINT '';
PRINT '--- Test 5: Order Status Overview ---';
SELECT * FROM vw_OrderStatusOverview
ORDER BY OrderCount DESC;

-- Test 6: Revenue by Category
PRINT '';
PRINT '--- Test 6: Revenue by Category ---';
SELECT 
    CategoryName,
    SUM(TotalRevenue) AS TotalRevenue,
    COUNT(*) AS TransactionCount
FROM vw_RevenueAnalysis
WHERE TotalRevenue IS NOT NULL
GROUP BY CategoryName
ORDER BY TotalRevenue DESC;

-- Test 7: Audit Log Sample
PRINT '';
PRINT '--- Test 7: Audit Log (Recent Changes) ---';
SELECT TOP 10 * FROM AuditLog
ORDER BY ModifiedDate DESC;

-- Test 8: Transaction Test - Update Order Status
PRINT '';
PRINT '--- Test 8: Update Order Status (with Transaction) ---';
BEGIN TRANSACTION;
    UPDATE Orders
    SET Status = 'Shipped',
        ModifiedDate = GETDATE()
    WHERE OrderID = 1;
    
    SELECT 'Order 1 Status Updated' AS Message;
    SELECT * FROM Orders WHERE OrderID = 1;
COMMIT TRANSACTION;

-- Test 9: Query Performance - Customer with most orders
PRINT '';
PRINT '--- Test 9: Customer with Most Orders ---';
SELECT TOP 5 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS FullName,
    COUNT(o.OrderID) AS OrderCount,
    SUM(o.TotalAmount) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY COUNT(o.OrderID) DESC;

-- Test 10: Complex Join - Order Details with Product Info
PRINT '';
PRINT '--- Test 10: Order Details with Product and Customer Info ---';
SELECT 
    c.FirstName + ' ' + c.LastName AS CustomerName,
    o.OrderID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.LineTotal AS Total,
    o.Status
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
ORDER BY o.OrderID, od.OrderDetailID;

-- ============================================================================
-- PART 9: CONSTRAINT AND TRIGGER VERIFICATION
-- ============================================================================

PRINT '';
PRINT '==============================================================';
PRINT 'PART 9: CONSTRAINT AND TRIGGER VERIFICATION';
PRINT '==============================================================';

-- Verify Foreign Key Relationships
PRINT '';
PRINT '--- Verify Foreign Key Relationships ---';
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME IS NOT NULL
    AND TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Verify Unique Constraints
PRINT '';
PRINT '--- Verify Unique Constraints ---';
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE CONSTRAINT_NAME LIKE '%UQ%' OR CONSTRAINT_NAME LIKE '%PK%'
    AND TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;

-- Verify Check Constraints
PRINT '';
PRINT '--- Verify Check Constraints ---';
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;

-- List all indexes
PRINT '';
PRINT '--- Summary of All Indexes ---';
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME, INDEX_NAME;

-- ============================================================================
-- PART 10: DATA DICTIONARY AND DOCUMENTATION
-- ============================================================================

PRINT '';
PRINT '==============================================================';
PRINT 'DATA DICTIONARY';
PRINT '==============================================================';

PRINT '';
PRINT '--- Table Structure ---';
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

PRINT '';
PRINT '==============================================================';
PRINT 'SETUP COMPLETE';
PRINT '==============================================================';
PRINT 'Database: Comprehensive eCommerce Platform';
PRINT 'Tables: 8';
PRINT 'Views: 5';
PRINT 'Triggers: 4';
PRINT 'Procedures: 3';
PRINT 'Indexes: 15+';
PRINT '';
PRINT 'All schema, data, and automation features are ready for use.';
