create table NashvilleHousing(
	UniqueID int,
	ParcelID varchar(40),
	LandUse varchar(80),
	PropertyAddress varchar(80),
	SaleDate date,
	SalePrice bigint,
	LegalReference varchar(40),
	SoldAsVacant varchar(40),
	OwnerName varchar(60),
	OwnerAddress varchar(80),
	Acreage float,
	TaxDistrict varchar(80),
	LandValue int,
	BuildingValue int,
	TotalValue bigint,
	YearBuilt varchar,
	Bedrooms int,
	FullBath int,
	HalfBath int
);


-- drop table NashvilleHousing;





/* 
	CLEANING DATA IN SQL QUERIES
*/

select * from NashvilleHousing;


-- Populate Property Address Data

select PropertyAddress 
from NashvilleHousing
where PropertyAddress is null;


select *
from NashvilleHousing
where PropertyAddress is null;


-- each parcelID has an address and duplicate parcelIDs have the same address
select *
from NashvilleHousing
order by ParcelID;


-- lets say for each parcelID without an address, lets use the address of parcelID identical to it to fill the address slot
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, coalesce(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a."uniqueid" <> b."uniqueid"
where a.PropertyAddress is null;


update NashvilleHousing a
set PropertyAddress = b.PropertyAddress
from NashvilleHousing b
where a.PropertyAddress is null
  and a.ParcelID = b.ParcelID
  and a."uniqueid" <> b."uniqueid"
  and b.PropertyAddress is not NULL;




---------------------------------------------







-- Breaking out Address Into Individual Columns (address, city, state)

select PropertyAddress
from NashvilleHousing;
-- order by ParcelID;

select 
substring(PropertyAddress, 1, position(',' in PropertyAddress)-1) as Address
from NashvilleHousing;

select 
substring(PropertyAddress, 1, position(',' in PropertyAddress)-1) as Address,
substring(PropertyAddress, position(',' in PropertyAddress)+1) as restOfAddress

from NashvilleHousing;


alter table NashvilleHousing
add PropertySplitAddress varchar(100);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, position(',' in PropertyAddress)-1);


alter table NashvilleHousing
add PropertySplitCity varchar(100);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, position(',' in PropertyAddress)+1);


select *
from NashvilleHousing;




select OwnerAddress
from NashvilleHousing;


select
split_part(replace(OwnerAddress,',','.'),'.',1),
split_part(replace(OwnerAddress,',','.'),'.',2),
split_part(replace(OwnerAddress,',','.'),'.',3)
from NashvilleHousing; 


alter table NashvilleHousing
add OwnerSplitAddress varchar(100);

update NashvilleHousing
set OwnerSplitAddress = split_part(replace(OwnerAddress,',','.'),'.',1);



alter table NashvilleHousing
add OwnerSplitCity varchar(100);

update NashvilleHousing
set OwnerSplitCity = split_part(replace(OwnerAddress,',','.'),'.',2);



alter table NashvilleHousing
add OwnerSplitState varchar(100);

update NashvilleHousing
set OwnerSplitState = split_part(replace(OwnerAddress,',','.'),'.',3);


select *
from NashvilleHousing;




------------------------------------------------





-- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant)
from NashvilleHousing;


select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;



select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


---------------------------------------------------





-- Remove Duplicates

with RowNumCTE as(
select *,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueId
	) row_num
from NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress;



with RowNumCTE as (
    select *,
        row_number() over (
            partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            order by UniqueId
        ) as row_num
    from NashvilleHousing
)
delete from NashvilleHousing
where (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueId) in (
    select ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueId
    from RowNumCTE
    where row_num > 1
);







----------------------------------------------------




-- Delete Unused Columns

select *
from NashvilleHousing;

alter table NashvilleHousing
drop column OwnerAddress,
drop column TaxDistrict,
drop column PropertyAddress,
drop column SaleDate;


























