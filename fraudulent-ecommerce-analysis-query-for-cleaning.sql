CREATE DATABASE fraudulent_transactions;  -- Query to create a DataBase named with fraudulent transactions .

USE fraudulent_transactions;  -- Query to use the database .

-- Create a Table with same number of columns as in your dataset . 
CREATE TABLE Transactions(
    TransactionID VARCHAR(255) NOT NULL,
    CustomerID VARCHAR(255) NOT NULL,
    TransactionAmount DECIMAL(10, 2),
    TransactionDate DATETIME,
    PaymentMethod VARCHAR(50),
    ProductCategory VARCHAR(50),
    Quantity INT,
    CustomerAge INT,
    CustomerLocation VARCHAR(100),
    DeviceUsed VARCHAR(50),
    IPAddress VARCHAR(50),
    ShippingAddress VARCHAR(255),
    BillingAddress VARCHAR(255),
    IsFraudulent BOOLEAN,
    AccountAgeDays INT,
    TransactionHour INT,
    PRIMARY KEY (TransactionID)
);


-- Query To Load the Data to our MySQL DataBase :
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Fraudulent_E-Commerce_Transaction_Data.csv'
INTO TABLE Transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify the data is imported and by simple SELECT ALL QUERY :
SELECT * FROM Transactions;

-- DATA CLEANING : First, find the Missing Values: Then Delete it from the Database .
SELECT *
FROM Transactions
WHERE TransactionAmount IS NULL
   OR TransactionDate IS NULL
   OR PaymentMethod IS NULL
   OR ProductCategory IS NULL
   OR Quantity IS NULL
   OR CustomerAge IS NULL
   OR CustomerLocation IS NULL
   OR DeviceUsed IS NULL
   OR IPAddress IS NULL
   OR ShippingAddress IS NULL
   OR BillingAddress IS NULL
   OR IsFraudulent IS NULL
   OR AccountAgeDays IS NULL
   OR TransactionHour IS NULL;

DELETE FROM Transactions
WHERE TransactionAmount IS NULL
   OR TransactionDate IS NULL
   OR PaymentMethod IS NULL
   OR ProductCategory IS NULL
   OR Quantity IS NULL
   OR CustomerAge IS NULL
   OR CustomerLocation IS NULL
   OR DeviceUsed IS NULL
   OR IPAddress IS NULL
   OR ShippingAddress IS NULL
   OR BillingAddress IS NULL
   OR IsFraudulent IS NULL
   OR AccountAgeDays IS NULL
   OR TransactionHour IS NULL;

-- Standardize Data Formats like Date and Address:
UPDATE Transactions
SET TransactionDate = STR_TO_DATE(TransactionDate, '%Y-%m-%d %H:%i:%s')
WHERE TransactionDate IS NOT NULL;

UPDATE Transactions
SET ShippingAddress = UPPER(ShippingAddress),
    BillingAddress = UPPER(BillingAddress);

-- Identify Duplicate and Remove it :
SELECT TransactionId , COUNT(*)
FROM Transactions
GROUP BY TransactionID
HAVING COUNT(*) > 1;

-- Since i have discovered no duplicates in my dataset , I would proceed to the next stage.

-- Correct Inaccurate Data
UPDATE Transactions
SET CustomerAge = NULL
WHERE CustomerAge < 18 OR CustomerAge > 120; 

-- Check for valid Data Ranges and Values . 
-- In our Dataset I have gone through Customer Age , Transaction Amount , Quantity. The Data Set is verified without any illogical values.

-- Standardize categorial data's :
UPDATE Transactions
SET PaymentMethod = CASE
	WHEN PaymentMethod = "credit card" THEN "Credit Card"
    WHEN PaymentMethod = "debit card" THEN "Debit Card"
    WHEN PaymentMethod = "bank transfer" THEN "Bank Transfer"
    ELSE PaymentMethod
END
WHERE PaymentMethod IN ("credit card","debit card","bank transfer");

UPDATE Transactions
SET ProductCategory = CASE 
	WHEN ProductCategory = "clothing"  THEN "Clothing"
    WHEN ProductCategory = "home & garden"  THEN "Home & Garden"
    WHEN ProductCategory = "toys & games"  THEN "Toys & Games"
    WHEN ProductCategory = "electronics"  THEN "Electronics"
    WHEN ProductCategory = "health & beauty"  THEN "Health & Beauty"
    ELSE ProductCategory
END
WHERE ProductCategory IN ("clothing","home & garden","home & garden","electronics","health & beauty");

-- Remove Invalid Data. Ensure IP address are in a valid format .
DELETE FROM Transactions
WHERE IPAddress NOT REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$';

-- Creating a new column name as CustomerAgeGroup for analysis purpose .
ALTER TABLE Transactions
ADD COLUMN CustomerAgeGroup VARCHAR(20);

-- Filling with respect to the age of the customers .
UPDATE Transactions
SET CustomerAgeGroup = CASE
	WHEN CustomerAge BETWEEN 13 AND 18 THEN 'Teenager'
	WHEN CustomerAge BETWEEN 19 AND 35 THEN 'Young Adult'
	WHEN CustomerAge BETWEEN 36 AND 55 THEN 'Adult'
	WHEN CustomerAge BETWEEN 56 AND 65 THEN 'Senior'
ELSE 'Other'
END; 

ALTER TABLE Transactions
MODIFY COLUMN CustomerAgeGroup VARCHAR(20) AFTER CustomerAge;
