-- EXEC SP_HELP NASHVILLEHOUSING;
SELECT *
FROM NASHVILLEHOUSING;

------------------------------------------------------------------------------------------------------------

-- standardize the date format

SELECT SaleDate, CAST(SALEDATE AS date), CONVERT(DATE, SALEDATE)
FROM NASHVILLEHOUSING;

ALTER TABLE NASHVILLEHOUSING
ADD SALEDATECONVERTED DATE;

UPDATE NASHVILLEHOUSING
SET SALEDATECONVERTED = CONVERT(DATE, SALEDATE);

SELECT SALEDATECONVERTED
FROM NASHVILLEHOUSING;

-----------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADRESS

SELECT *
FROM NASHVILLEHOUSING
-- WHERE PropertyAddress IS NULL;

-- records with same parcelId have same address so we can use it as a refrence to populate the unpopulated records

UPDATE N1
SET PROPERTYADDRESS = ISNULL(N1.PROPERTYADDRESS, N2.PROPERTYADDRESS)
FROM NASHVILLEHOUSING N1
JOIN NASHVILLEHOUSING N2
	ON N1.ParcelID = N2.ParcelID AND N1.UniqueID <> N2.UniqueID
WHERE N1.PROPERTYADDRESS IS NULL;

----------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From NASHVILLEHOUSING;
--Where PropertyAddress is null
--order by ParcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NASHVILLEHOUSING;


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From NASHVILLEHOUSING;





Select OwnerAddress
From NASHVILLEHOUSING;

Select PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2), 
	   PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NASHVILLEHOUSING;



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From NASHVILLEHOUSING

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select SoldAsVacant
From NASHVILLEHOUSING;

Update NASHVILLEHOUSING
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'	
						ELSE SoldAsVacant
					END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS
(
	Select *, ROW_NUMBER() OVER (PARTITION BY ParcelID,
										  PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference
				             ORDER BY UniqueId) R_N

	From NASHVILLEHOUSING
)

Select *
From RowNumCTE
Where R_N = 1
Order by PropertyAddress;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NASHVILLEHOUSING;


ALTER TABLE NASHVILLEHOUSING
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;