/*
==============================================================================================
Script: Create DataWarehouse Database and bronze/silver/gold schemas
==============================================================================================
Objective: This script initializes the DataWarehouse database by creating it from scratch and 
setting up the necessary schemas for the Bronze, Silver, and Gold layers of the data pipeline.
This is a foundational step in establishing the data warehouse environment.
 
Warning: This script is destructive as it drops the existing DataWarehouse database if it 
exists. It should be used with caution in non-production environments where data loss is 
acceptable.

This script performs the following actions:
1. Checks for the existence of the DataWarehouse database and drops it if found.
2. Creates a new DataWarehouse database.
3. Creates three schemas within the DataWarehouse database: bronze, silver, and gold.
4. Intended for initial setup or rebuilds.
==============================================================================================
*/

USE master;
GO

-- Drop the database 'DataWarehouse' if it already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;

-- Create the new database 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO

-- Switch to the new database
USE DataWarehouse;
GO

-- Create schemas for bronze, silver, and gold layers
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
