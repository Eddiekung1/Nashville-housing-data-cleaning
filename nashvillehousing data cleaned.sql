SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [msdb].[dbo].[Sheet1$]

    -- standardise date format

select saleDate, convert(date,saledate)
from msdb.dbo.nashvillehousing

update nashvillehousing
set saledate = convert(date,saledate)

alter table nashvillehousing
add saledateconverted date;

update nashvillehousing
set saledateconverted = convert(date,saledate)

---- property address
----- i noticed that parcels with the same parcel id went to the same property address
-- so i used that information to fill out the missing property address fields.

select*
from msdb.dbo.nashvillehousing

order by Parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from msdb.dbo.nashvillehousing a
join msdb.dbo.nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid ]
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from msdb.dbo.nashvillehousing a
join msdb.dbo.nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid ]
where a.propertyaddress is null

--

select
PARSENAME(replace(owneraddress,',','.'),3)
,parsename(replace(owneraddress,',','.'),2)
,PARSENAME(replace(owneraddress,',','.'),1)
from msdb.dbo.nashvillehousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update nashvillehousing
set OwnerSplitAddress = parsename(replace(ownerAddress,',','.'), 3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update nashvillehousing
set OwnerSplitCity = parsename(replace(ownerAddress,',','.'), 2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update nashvillehousing
set OwnerSplitState = parsename(replace(ownerAddress,',','.'), 1)

alter table nashvillehousing
add PropertySplitCity nvarchair(255);

select*
from msdb.dbo.nashvillehousing

---- changing 'n' and 'y' to 'no' and 'yes'

select distinct(soldasvacant),count(soldasvacant)
from msdb.dbo.nashvillehousing
group by soldasvacant
order by 2

select soldasvacant
, case when soldasvacant = 'y' then 'yes'
		when soldasvacant = 'n' then 'no'
		else soldasvacant
		end
from msdb.dbo.nashvillehousing

update msdb.dbo.nashvillehousing
set soldasvacant = case when soldasvacant = 'y' then 'yes'
		when soldasvacant = 'n' then 'no'
		else soldasvacant
		end

--- removing duplicates

with rownumcte as(
select *,
	row_number() over(
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by
					uniqueid
					) row_num

from msdb.dbo.nashvillehousing
)
select *
from rownumcte
where row_num > 1
order by PropertyAddress

--- deleting unsused columns

select *
from msdb.dbo.nashvillehousing

alter table msdb.dbo.nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress

alter table msdb.dbo.nashvillehousing
drop column saledate