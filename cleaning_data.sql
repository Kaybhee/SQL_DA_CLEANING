select *
from portfolioproject..NashvilleData


SELECT  CAST(SaleDate AS DATE) AS date_column
FROM PortfolioProject.dbo.NashvilleData

---To extract and update the date from a datetime column

SELECT *,conv_SaleDate --conv_SaleDate
FROM PortfolioProject.dbo.NashvilleData

alter TABLE portfolioproject..NashvilleData
ADD conv_SaleDate DATE

UPDATE PortfolioProject..NashvilleData
SET conv_SaleDate = CAST(SaleDate AS DATE);

-------------
select *
from PortfolioProject..NashvilleData
where PropertyAddress is null
order by propertyaddress desc

---There are null values for the property address 

select f_join.propertyaddress, s_join.PropertyAddress, f_join.ParcelID, s_join.ParcelID, isnull(f_join.propertyaddress,s_join.PropertyAddress)
from PortfolioProject.dbo.NashvilleData as f_join
join PortfolioProject.dbo.NashvilleData as s_join
on f_join.parcelid = s_join.parcelid and f_join.[UniqueID ] != s_join.[UniqueID ] 
where f_join.PropertyAddress is null

update f_join
set f_join.propertyaddress = isnull(f_join.propertyaddress,s_join.PropertyAddress)
from PortfolioProject.dbo.NashvilleData as f_join
join PortfolioProject.dbo.NashvilleData as s_join
on f_join.parcelid = s_join.parcelid and f_join.[UniqueID ] != s_join.[UniqueID ] 
where f_join.PropertyAddress is null

select *
from PortfolioProject..NashvilleData

---Breaking property address into address/city
select SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress) - 1) as prop_address,
SUBSTRING(propertyaddress,charindex(',',propertyaddress) +1, len(propertyaddress) )as  city
from PortfolioProject..NashvilleData

--updating table
alter TABLE portfolioproject..NashvilleData
ADD split_prop_address nvarchar(200)

UPDATE PortfolioProject..NashvilleData
SET split_prop_address = SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress) - 1) 

alter TABLE portfolioproject..NashvilleData
ADD split_city nvarchar(200)

UPDATE PortfolioProject..NashvilleData
SET split_city = SUBSTRING(propertyaddress,charindex(',',propertyaddress) +1, len(propertyaddress) )
----------

select OwnerAddress,OwnerName, landuse
from PortfolioProject..NashvilleData



-- Breaking Owner address into state/address/city

select PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as owner_address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as owner_city,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as owner_state
--SUBSTRING(OwnerAddress,charindex(',',OwnerAddress) +1,len(OwnerAddress) )as  owner_city
from PortfolioProject..NashvilleData
where OwnerAddress is not null and OwnerAddress is not null


---Updating splitted owner address
alter TABLE portfolioproject..NashvilleData
ADD split_owner_address nvarchar(200)

UPDATE PortfolioProject..NashvilleData
SET split_owner_address = PARSENAME(REPLACE(OwnerAddress,',','.'), 3) 

alter TABLE portfolioproject..NashvilleData
ADD split_owner_city nvarchar(200)

UPDATE PortfolioProject..NashvilleData
SET split_owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'), 2) 


alter TABLE portfolioproject..NashvilleData
ADD split_owner_state nvarchar(200)

UPDATE PortfolioProject..NashvilleData
SET split_owner_state = PARSENAME(REPLACE(OwnerAddress,',','.'), 1) 

select *
from PortfolioProject..NashvilleData

-----

---To set Y/N to Yes or No
select distinct(SoldAsVacant), count(*)
from PortfolioProject..NashvilleData
group by SoldAsVacant

select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from PortfolioProject..NashvilleData
--where SoldAsVacant = 'N' or SoldAsVacant = 'Y'

update PortfolioProject..NashvilleData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

select *,
ROW_NUMBER() OVER (PARTITION BY ParcelId,propertyaddress,SalePrice,SaleDate, legalreference
order by uniqueid
) AS row_num

from PortfolioProject..NashvilleData
order by ParcelID
 
---Creating a CTE
with row_num_table AS (
select *,
ROW_NUMBER() OVER (PARTITION BY ParcelId,propertyaddress,SalePrice,SaleDate, legalreference
order by uniqueid
) AS row_num

from PortfolioProject..NashvilleData
--order by ParcelID
) 


--Delete the duplicated rows
DELETE 
from row_num_table
where row_num > 1



