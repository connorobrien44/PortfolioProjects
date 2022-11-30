-- Cleaning Data in SQL Project 
--		The purpose of this project is to clean this dataset and make it more usuable and easier to follow for stakeholders
Select *
From [Nashville Housing Project]..[Nas Housing]


-- Refromating Date Column 
-- The objective here is to remove the Date/Time format from the date column so that we do not see the default time that SQL automatically places into the column

Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Nashville Housing Project]..[Nas Housing]

Update [Nas Housing]
SET SaleDate = CONVERT(Date,SaleDate)

-- --			Had issues with these so decided to use ALTER TABLE instead

ALTER TABLE [Nas Housing] 
Add SaleDateConverted Date;


Update [Nas Housing]
SET  SaleDateConverted  = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Column 
--		Propety Address is fixed so in order to fill the null values I need to find a reference point
--		By using order by on ParcelID, I am able to see that when the address is repeated, ParcelID does not change


Select *
From [Nashville Housing Project]..[Nas Housing]
--WHERE PropertyAddress is null 
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing Project]..[Nas Housing] a
JOIN [Nashville Housing Project]..[Nas Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> B.[UniqueID ] 
WHERE a.PropertyAddress is null 

-- --			This join gives a representation of which null values need to be occupied by a repeat of an address 



Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing Project]..[Nas Housing] a
JOIN [Nashville Housing Project]..[Nas Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> B.[UniqueID ] 
WHERE a.PropertyAddress is null 


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking Address Into Multiple Columns (Address, City, State)
--		Substring Using Delimeters to seperate columns (Substring and CHARINDEX) 
--      Here we are going to start with the substring method of seperation in order to seperate our property address
--		We are going to end with the PARSENAME method to seperate the owner address
--      Use ALTER TABLE to update table and add the 6 new columns


Select PropertyAddress
From [Nashville Housing Project]..[Nas Housing]


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City 

From [Nashville Housing Project]..[Nas Housing]

ALTER TABLE [Nas Housing] 
Add PropertySplitAddress Nvarchar(255);


Update [Nas Housing]
SET  PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE [Nas Housing] 
Add PropertySplitCity Nvarchar(255);


Update [Nas Housing]
SET  PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select * 
From [Nashville Housing Project]..[Nas Housing]




Select OwnerAddress
From [Nashville Housing Project]..[Nas Housing]

-- --			PARSENAME (Looks for Periods). Also does thinks backwards compared to substring

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [Nashville Housing Project]..[Nas Housing]





ALTER TABLE [Nas Housing] 
Add OwnerSplitAddress Nvarchar(255);


Update [Nas Housing]
SET  OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE [Nas Housing] 
Add OwnerSplitCity Nvarchar(255);


Update [Nas Housing]
SET  OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE [Nas Housing] 
Add OwnerSplitState Nvarchar(255);


Update [Nas Housing]
SET  OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" column
--		First Use Distinct to find out how many cells have Y or N
--		Use CASE to Replace Y and N 

Select Distinct(SoldAsVacant), Count(SoldasVacant)
From [Nashville Housing Project]..[Nas Housing]
Group by SoldAsVacant
Order by 2 

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant
		END
From [Nashville Housing Project]..[Nas Housing]


Update [Nas Housing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant
		END 


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 
--			We will delete the PropertyAddress, and OwnerAddress column because we no longer need them after we have seperated the columns
--			We will delete the TaxDistrict column
--			We will delete the SaleDate column because it was reformatted to a new column earlier. It is important to not that when we tried this before using CONVERT, the table was not changed


Select * 
From [Nashville Housing Project]..[Nas Housing] 


ALTER TABLE [Nas Housing] 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 



ALTER TABLE [Nas Housing] 
DROP COLUMN SaleDate

