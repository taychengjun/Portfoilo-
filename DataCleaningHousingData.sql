--Cleaning Data in SQL Queries 

Select * 
From PortfolioE.dbo.NashvilleHousing

--Modifying the Date Format 

Select SaleDateConverted, CONVERT (Date,SaleDate)
From PortfolioE.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate= CONVERT (Date,SaleDate)


--Altering the table and updating it 

Alter Table NashvilleHousing 
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted= CONVERT (Date,SaleDate)


--Populate Property Address Date where they are null

Select *
From PortfolioE.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From PortfolioE.dbo.NashvilleHousing a
JOIN PortfolioE.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From PortfolioE.dbo.NashvilleHousing a
JOIN PortfolioE.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address,City, States) 

Select PropertyAddress
From PortfolioE.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--Removing the comma by adding '-1'

Select 
Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) as Address
, Substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as Address 

From PortfolioE.dbo.NashvilleHousing


--Update the table with the latest change of Address
Alter Table NashvilleHousing 
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitAddress= Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 )


Alter Table NashvilleHousing 
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitCity= Substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))


--Another Method to modify the address

Select OwnerAddress
From PortfolioE.dbo.NashvilleHousing


Select 
PARSENAME(Replace(OwnerAddress,',','.'),3) 
, PARSENAME(Replace(OwnerAddress,',','.'),2) 
, PARSENAME(Replace(OwnerAddress,',','.'),1) 

From PortfolioE.dbo.NashvilleHousing


--Update the table with the latest change of Address
Alter Table NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitAddress= PARSENAME(Replace(OwnerAddress,',','.'),3)


Alter Table NashvilleHousing 
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitCity= PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing 
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitState= PARSENAME(Replace(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No under "Sold as Vacant" column 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant) 
From PortfolioE.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant
,Case	when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No' 
		Else SoldAsVacant
		End
From PortfolioE.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant= Case	when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No' 
		Else SoldAsVacant
		End


--remove Duplicates 

--Finding the duplicates
With RowNumCTE As(
Select * , 
	ROW_NUMBER() Over( 
	Partition by ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID 
					) row_num

From PortfolioE.dbo.NashvilleHousing
--order by ParcelID
)

Select * 
From RowNumCTE
Where row_num > 1 
Order by PropertyAddress


--Deleting the duplicates
With RowNumCTE As(
Select * , 
	ROW_NUMBER() Over( 
	Partition by ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID 
					) row_num

From PortfolioE.dbo.NashvilleHousing
)

Delete 
From RowNumCTE
Where row_num > 1 



--Delete Unused Columns
Select * 
From PortfolioE.dbo.NashvilleHousing


Alter Table PortfolioE.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table PortfolioE.dbo.NashvilleHousing
Drop Column SaleDate