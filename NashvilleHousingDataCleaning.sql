/*
Cleaning Data in SQL Queries
*/

Select *
From [Portfolio Project]..nashHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate)
From NashHousing


Update NashHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashHousing
Add SaleDateConverted Date;

Update NashHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashHousing
--Where PropertyAddress is NULL
Order by ParcelID

Select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress) 
FROM NashHousing a
JOIN NashHousing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyaddress is NULL

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress) 
FROM NashHousing a
JOIN NashHousing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyaddress is NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City

FROM NashHousing

ALTER TABLE NashHousing
Add PropertySplitAddress NVARChar(255);

Update NashHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashHousing
Add PropertySplitCity NVARChar(255);

Update NashHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertySplitCity,
PropertySplitAddress
FROM NashHousing



SELECT OwnerAddress
FROM NashHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashHousing


ALTER TABLE NashHousing
Add OwnerPropertySplitAddress NVARChar(255);

Update NashHousing
SET OwnerPropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
ALTER TABLE NashHousing
Add OwnderPropertySplitCity NVARChar(255);

Update NashHousing
SET OwnderPropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashHousing
Add OwnderPropertySplitState NVARChar(255);

Update NashHousing
SET OwnderPropertySplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT OwnerPropertySplitAddress,
OwnderPropertySplitCity,
OwnderPropertySplitState
FROM NashHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashHousing
Group by SoldAsVacant
order by 2

SELECT SoldasVacant,
CASE When SoldasVacant = 'Y' Then 'Yes'
	When Soldasvacant = 'N' Then 'No'
	ELSE SoldasVacant
	END
	From NashHousing

Update NashHousing
Set SoldasVacant = CASE When SoldasVacant = 'Y' Then 'Yes'
	When Soldasvacant = 'N' Then 'No'
	ELSE SoldasVacant
	END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNUMCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY ParcelID
				) row_num 
From NashHousing
)
DELETE*
FROM RowNUMCTE
WHERE Row_num > 1
--Order by PropertyAddress

SELECT*
FROM RowNUMCTE
WHERE Row_num > 1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Alter TABLE  NashHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
FROM NashHousing