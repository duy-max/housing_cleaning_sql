use housing_db

select * from housing

-- Standardize Date Format

select SaleDate, CONVERT(date, Saledate)
from housing

alter table Housing
add SaleDateConvert Date

update Housing
SET SaleDateConvert = CONVERT(Date,SaleDate)

-- Populate Property Address data

select *
from housing
where propertyaddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing a
join Housing b
on 
	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set  a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing a
join Housing b
on 
	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)
--split PropertyAddress
select PropertyAddress
from Housing

select 
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
       SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from Housing

alter table Housing
add PropertySplitAddress nvarchar(255)

update Housing
set  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table Housing
add PropertySplitCity nvarchar(255)

update Housing
set  PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


select * 
from housing


--split OwnerAddress

select OwnerAddress
from housing

select 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

from housing

alter table Housing
add OwnerSplitAddress nvarchar(255)

update Housing
set  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

alter table Housing
add OwnerSplitCity nvarchar(255)

update Housing
set  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

alter table Housing
add OwnerSplitState nvarchar(255)

update Housing
set  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

select *
from housing


-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from housing
group by SoldAsVacant
order by SoldAsVacant


select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from housing

update housing
set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end



-- Remove Duplicates
with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by UniqueID
	) row_num


from housing
)

delete 
from RowNumCTE
where row_num > 1



-- Delete Unused Columns

alter table housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


select * from housing