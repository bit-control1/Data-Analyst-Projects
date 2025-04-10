-- Standardizing Data

-- Preview company names before trimming extra spaces
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Clean up extra spaces in company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Review unique values in the industry column
SELECT DISTINCT industry
FROM layoffs_staging2;

-- Find rows where industry names may have inconsistent naming (e.g., 'Crypto')
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Standardize industry name to 'Crypto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Check unique countries for standardization
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Normalize inconsistent country name formatting (e.g., extra characters)
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Remove periods from end of country names (e.g., 'United States.')
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Preview cleaned country names
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Convert date strings to proper DATE format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Update date column with proper DATE values
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Verify date format conversion
SELECT `date`
FROM layoffs_staging2;

-- Modify column data type to actual DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Set empty strings in industry column to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Check for NULL or empty industries
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Example: Check for a specific company with possibly missing info
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- Join to get correct industry from another record with the same company
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Fill in missing industries by matching companies with known industries
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Final check on staging table
SELECT *
FROM layoffs_staging2;

-- Check for fully null rows in key metrics (might be useless for analysis)
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove rows where no layoffs or percentages were reported
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Verify cleanup
SELECT *
FROM layoffs_staging2;

-- Drop row_num column since it's no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;




