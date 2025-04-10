-- Data Cleaning

-- View all data from the original layoffs table
SELECT *
FROM layoffs;

-- Create a staging table with the same structure as the original
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Check structure of the newly created staging table
SELECT *
FROM layoffs_staging;

-- Copy all records from original table to staging table
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Preview duplicates by generating row numbers based on identical field values
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- Use CTE to isolate duplicate rows based on specific columns
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
 industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
-- Select only the duplicates (row_num > 1)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Example check of data for a specific company
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Create a more refined staging table with a new row_num column added
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Preview the new staging table
SELECT *
FROM layoffs_staging2;

-- Insert data into layoffs_staging2 with row numbers for duplicate filtering
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
 industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Identify duplicates based on row_num
SELECT *
FROM layoffS_staging2
WHERE row_num > 1;

-- Remove duplicate records from the staging table
DELETE 
FROM layoffS_staging2
WHERE row_num > 1;

-- View the cleaned data
SELECT *
FROM layoffS_staging2;


