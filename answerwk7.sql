-- Drop in the right order: child before parent
DROP TABLE IF EXISTS OrderProducts_Q1;
DROP TABLE IF EXISTS Orders_Q1;

DROP TABLE IF EXISTS OrderItems_Q2;
DROP TABLE IF EXISTS Orders_Q2;

DROP TABLE IF EXISTS ProductDetail;
DROP TABLE IF EXISTS OrderDetails;


DROP TABLE IF EXISTS ProductDetail;
CREATE TABLE ProductDetail (
  OrderID INT PRIMARY KEY,
  CustomerName VARCHAR(100),
  Products TEXT
) ENGINE=InnoDB;

INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'Mr Eric',   'Laptop, Mouse'),
(102, 'Mr Zablon', 'Tablet, Keyboard, Mouse'),
(103, 'Ma Kenny', 'Phone');

SELECT * FROM ProductDetail;

DROP TABLE IF EXISTS Orders_Q1;
CREATE TABLE Orders_Q1 (
  OrderID INT PRIMARY KEY,
  CustomerName VARCHAR(100)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS OrderProducts_Q1;
CREATE TABLE OrderProducts_Q1 (
  OrderID INT,
  Product VARCHAR(255),
  PRIMARY KEY (OrderID, Product),
  FOREIGN KEY (OrderID) REFERENCES Orders_Q1(OrderID) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO Orders_Q1 (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName FROM ProductDetail;

-- Use JSON_TABLE if supported
INSERT INTO OrderProducts_Q1 (OrderID, Product)
SELECT pd.OrderID,
       TRIM(jt.product) AS Product
FROM ProductDetail pd
CROSS JOIN JSON_TABLE(
  CONCAT('["', REPLACE(pd.Products, ', ', '","'), '"]'),
  "$[*]" COLUMNS (product VARCHAR(255) PATH "$")
) AS jt;

SELECT * FROM Orders_Q1;
SELECT * FROM OrderProducts_Q1;

-- Manual fallback if JSON_TABLE not available
/*
INSERT INTO OrderProducts_Q1 (OrderID, Product) VALUES
(101, 'Laptop'),
(101, 'Mouse'),
(102, 'Tablet'),
(102, 'Keyboard'),
(102, 'Mouse'),
(103, 'Phone');

SELECT * FROM Orders_Q1;
SELECT * FROM OrderProducts_Q1;
*/

DROP TABLE IF EXISTS OrderDetails;
CREATE TABLE OrderDetails (
  OrderID INT,
  CustomerName VARCHAR(100),
  Product VARCHAR(255),
  Quantity INT
) ENGINE=InnoDB;

INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'Sir Eric',    'Laptop',   2),
(101, 'Mr Zablon',    'Mouse',    1),
(102, 'Ma Kenny',  'Tablet',   3),
(102, 'Ma Mercy',  'Keyboard', 1),
(102, 'Jane Smith',  'Mouse',    2),
(103, 'Emily Clark', 'Phone',    1);

SELECT * FROM OrderDetails;

DROP TABLE IF EXISTS Orders_Q2;
CREATE TABLE Orders_Q2 (
  OrderID INT PRIMARY KEY,
  CustomerName VARCHAR(100)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS OrderItems_Q2;
CREATE TABLE OrderItems_Q2 (
  OrderID INT,
  Product VARCHAR(255),
  Quantity INT,
  PRIMARY KEY (OrderID, Product),
  FOREIGN KEY (OrderID) REFERENCES Orders_Q2(OrderID) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO Orders_Q2 (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName FROM OrderDetails;

INSERT INTO OrderItems_Q2 (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity FROM OrderDetails;

SELECT * FROM Orders_Q2;
SELECT * FROM OrderItems_Q2;
