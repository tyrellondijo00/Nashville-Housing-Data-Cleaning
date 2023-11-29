SELECT *
FROM NashvilleHousing

-- POPULATE ADDRESS DATA

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- Checking For Relationship Between Property Address and Trimmed Address

--WITH CTE_Housing AS (
--    SELECT
--        REPLACE(PropertyAddress, '  ', ' ') AS TrimmedPropertyAddress,
--        REPLACE(OwnerAddress, '  ', ' ') AS TrimmedOwnerAddress,
--        CASE
--            WHEN CHARINDEX(', TN', OwnerAddress) > 0 AND
--                 REPLACE(LEFT(OwnerAddress, CHARINDEX(', TN', OwnerAddress) - 1), '  ', ' ') = REPLACE(PropertyAddress, '  ', ' ')
--            THEN 'True'
--            ELSE 'False'
--        END AS FollowsRule
--    FROM NashvilleHousing
--)

--SELECT *
--FROM CTE_Housing
--WHERE FollowsRule = 'False' AND TrimmedOwnerAddress IS NOT NULL AND TrimmedPropertyAddress IS NOT NULL;


SELECT 
    REPLACE(TRIM(BOTH ' ' FROM a.PropertySplitAddress), '  ', ' ') AS CleanedPropertyAddress,
    REPLACE(TRIM(BOTH ' ' FROM b.OwnerSplitAddress), '  ', ' ') AS CleanedOwnerAddress
FROM 
    NashvilleHousing a
JOIN 
    NashvilleHousing b
    ON a.UniqueID = b.UniqueID
WHERE 
    REPLACE(TRIM(BOTH ' ' FROM a.PropertySplitAddress), '  ', ' ') 
    <> 
    REPLACE(TRIM(BOTH ' ' FROM b.OwnerSplitAddress), '  ', ' ');


-- Relationship Between Property Address And Parcel ID
-- Filled The Null Values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


-- Breaking Out Addresses Into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM NashvilleHousing

--SELECT
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
--SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
--FROM NashvilleHousing

SELECT 
PARSENAME (REPLACE(PropertyAddress, ',', '.') , 2) AS Address,
PARSENAME (REPLACE(PropertyAddress, ',', '.') , 1) AS City
FROM NashvilleHousing

-- Create New Columns For Owner And Property Addresses
-- Propert Address Splits 

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'PropertySplitAddress')
BEGIN
    ALTER TABLE NashvilleHousing
    DROP COLUMN PropertySplitAddress;
END
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = PARSENAME (REPLACE(PropertyAddress, ',', '.') , 2)


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'PropertySplitCity')
BEGIN
    ALTER TABLE NashvilleHousing
    DROP COLUMN PropertySplitCity;
END
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertySplitCity = PARSENAME (REPLACE(PropertyAddress, ',', '.') , 1)



-- Owner Address Splits

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.') , 3) AS Address,
PARSENAME (REPLACE(OwnerAddress, ',', '.') , 3) AS City,
PARSENAME (REPLACE(OwnerAddress, ',', '.') , 1) AS State
FROM NashvilleHousing

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'OwnerSplitAddress')
BEGIN
    ALTER TABLE NashvilleHousing
    DROP COLUMN OwnerSplitAddress;
END
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 3)

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'OwnerSplitCity')
BEGIN
    ALTER TABLE NashvilleHousing
    DROP COLUMN OwnerSplitCity;
END
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 2)

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NashvilleHousing' AND COLUMN_NAME = 'OwnerSplitState')
BEGIN
    ALTER TABLE NashvilleHousing
    DROP COLUMN OwnerSplitState;
END
ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 1)


-- CHANGING 'Y' AND 'N' TO 'Yes' AND 'No'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY (SoldAsVacant)
ORDER BY 2


SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant= 'N' THEN 'No'
		ELSE SoldAsVacant
	END		
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant= 'N' THEN 'No'
		ELSE SoldAsVacant
	END	


-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	ORDER BY UniqueID
	) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


-- REMOVING USELESS COLUMNS

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

SELECT *
FROM NashvilleHousing














