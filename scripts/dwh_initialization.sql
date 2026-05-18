/*
============================================================================
Script: Create DataWarehouse database and bronze/silver/gold schemas
============================================================================
Purpose: Recreate the DataWarehouse database from scratch and establish
          the initial data tier schemas used for Bronze, Silver, and Gold
          data pipeline layers.
Warning: This script is destructive. It drops the existing DataWarehouse
          database if it exists, so run only in non-production or controlled
          environments where data loss is acceptable.
Notes:
   - Drops the existing DataWarehouse database if it exists.
   - Creates a fresh DataWarehouse database.
   - Creates three schemas: bronze, silver, gold.
   - Intended for initial setup or rebuilds.
----------------------------------------------------------------------------
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
