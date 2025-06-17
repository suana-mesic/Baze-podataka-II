--II parcijalni : moje rješenje
--BAZE PODATAKA II – II parcijalni

--1.	Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

create database Parcijalni_2024
go
use Parcijalni_2024

--2.	Kreirati tabelu Kupci, te prilikom kreiranja uraditi insert podataka iz tabele Customers baze Northwind.

select *
into Kupci
from Northwind.dbo.Customers
--3.	(3 boda) Kreirati proceduru sp_insert_customers kojom će se izvršiti insert podataka u tabelu Kupci. OBAVEZNO kreirati testni slučaj.
go
create or alter procedure sp_insert_customers
(
	@CustomerID nchar(5), 
	@CompanyName nvarchar(40), 
	@ContactName nvarchar(30)= null, 
	@ContactTitle nvarchar(30)=null, 
	@Address nvarchar(60)=null, 
	@City nvarchar(15)=null, 
	@Region nvarchar(15)=null, 
	@PostalCode nvarchar(10)=null, 
	@Country nvarchar(15)=null, 
	@Phone nvarchar(24)=null, 
	@Fax nvarchar(24)=null
)
as begin
	insert into Kupci
	values (@CustomerID, @CompanyName, @ContactName, @ContactTitle, @Address, @City, @Region, @PostalCode, @Country, @Phone, @Fax)
end
go

exec sp_insert_customers @CustomerID=1, @CompanyName='Custom insert', @ContactName='Custom', @Fax = 'Nema'

select *
from Kupci
where CustomerID = '1'

--4.	(3 boda) Kreirati index koji je ubrzati pretragu po nazivu kompanije kupca i kontakt imenu. OBAVEZNO kreirati testni slučaj.

go
create index IX_Kupci_KompanijaKupca_KontaktIme
on Kupci (CompanyName, ContactName)

select *
from Kupci
where CompanyName like 'B%' and ContactName like 'F%'

--5.	(5 boda) Kreirati funkciju f_satnice unutar novokreirane baze koja će vraćati podatke u vidu tabele iz baze AdventureWorks2017. Korisniku slanjem parametra satnica će biti ispisani uposlenici (ime, prezime, starost, staž i email) čija je satnica manja od vrijednosti poslanog parametra. Korisniku pored navedenih podataka treba prikazati razliku unesene i stvarne satnice.

use AdventureWorks2017
go
create function f_satnice(@Satnica decimal(18,2))
returns table
as return
	select 
		p.FirstName, p.LastName, DATEDIFF(YEAR,e.BirthDate,GETDATE())as 'Starost', ea.EmailAddress, @Satnica-eph.Rate as 'Razlika'
	from HumanResources.Employee as e
		inner join HumanResources.EmployeePayHistory as eph on eph.BusinessEntityID = e.BusinessEntityID
		inner join Person.Person as p on e.BusinessEntityID = p.BusinessEntityID
		inner join Person.EmailAddress as ea on ea.BusinessEntityID = p.BusinessEntityID
	where eph.Rate<@Satnica
go

select *
from f_satnice(94.45)
order by 5 desc

--6.	(6 boda) Prikazati ime i prezime kupaca čiji je ukupan iznos potrošnje(ukupna vrijednost sa troškovima prevoza i taksom) veći od prosječnog ukupnog iznosa potrošnje svih kupaca. U obzir uzeti samo narudžbe koje su isporučene kupcima. (AdventureWorks2019)

use AdventureWorks2017
select 
	p.FirstName
	,p.LastName
from Sales.SalesOrderHeader as soh
	inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
where soh.ShipDate is not null 
group by p.FirstName, p.LastName
having SUM(soh.TotalDue)>
(
	select AVG(podq.[Potrošnja po kupcu])
	from
	(
		select soh1.CustomerID, SUM(soh1.TotalDue) as 'Potrošnja po kupcu'
		from Sales.SalesOrderHeader as soh1
		where soh1.ShipDate is not null 
		group by soh1.CustomerID
	)as podq
)


--7.	(6 bodova) Prikazati prosječnu vrijednost od svih kreiranih narudžbi bez popusta (jedno polje) (AdventureWorks2019)

use AdventureWorks2017
select AVG(podq.vrijednost) as 'Prosjek'
from
(
	select soh.SalesOrderID, SUM(sod.UnitPrice*sod.OrderQty) as 'vrijednost'
	from Sales.SalesOrderHeader as soh
		inner join Sales.SalesOrderDetail as sod on soh.SalesOrderID = sod.SalesOrderID
	group by soh.SalesOrderID
) as podq


--8.	(9 bodova) Prikazati naziv odjela na kojima trenutno radi najmanje, te naziv odjela na kojem radi najviše uposlenika starijih od 50 godina. Dodatni uslov je da odjeli pripadaju grupama proizvodnje, te prodaje i marketinga. (Adventureworks 2019)

use AdventureWorks2017

select podq.Name, podq.GroupName, podq.[Broj uposlenika]
from
(
	select 
		d.Name, 
		d.GroupName,
		COUNT(*) as 'Broj uposlenika', 
		ROW_NUMBER() OVER(ORDER BY COUNT(*)) as 'RowNum',
		COUNT(*) OVER () as 'Total'
	from HumanResources.EmployeeDepartmentHistory as edh
		inner join HumanResources.Department as d on edh.DepartmentID = d.DepartmentID
		inner join HumanResources.Employee as e on edh.BusinessEntityID = e.BusinessEntityID
	where edh.EndDate is null and DATEDIFF(YEAR, e.BirthDate, GETDATE())>50 and d.GroupName in ('Sales and Marketing','Manufacturing')
	group by d.Name, d.GroupName
) as podq
where podq.RowNum = podq.Total or podq.RowNum = 1

--9.	(8 bodova) Prikazati najprodavaniji proizvod za svaku godinu pojedinačno. Ulogu najprodavanijeg proizvoda ima onaj koji je u najvećoj količini prodat.(Northwind)

use Northwind
select 
	YEAR(oQ.OrderDate) as 'Godina', 
	odQ.ProductID as 'Najprodavaniji proizvod', 
	SUM(odQ.Quantity) as 'Količina'
from Orders as oQ
	inner join [Order Details] as odQ on odQ.OrderID = oQ.OrderID
group by odQ.ProductID, YEAR(oQ.OrderDate)
having CONCAT(YEAR(oQ.OrderDate),SUM(odQ.Quantity)) 
in 
(
	select CONCAT(podq1.Godina, MAX(podq1.[Količina po god i proiz]))
	from
	(
		select YEAR(o.OrderDate) as 'Godina', od.ProductID, SUM(od.Quantity) as 'Količina po god i proiz'
		from Orders as o
			inner join [Order Details] as od on od.OrderID = o.OrderID
		group by YEAR(o.OrderDate), od.ProductID
	) as podq1
	group by podq1.Godina
)

--10.	(8 bodova) Prikazati ukupan broj narudžbi i ukupnu količinu proizvoda za svaku od teritorija pojedinačno. Uslov je da je ukupna količina manja od 3000 a popust nije odobren za te stavke, te ukupan broj narudžbi 1000 i više. (Adventureworks 2019)
 
use AdventureWorks2017

select 
	st.Name,
	SUM(sod.OrderQty) as 'Ukupna količina za stavke bez odobrenog popusta',
	(
		select COUNT(*)
		from Sales.SalesOrderHeader as soh1
			inner join Sales.SalesTerritory as st1 on st1.TerritoryID = soh1.TerritoryID
		where st1.Name = st.Name
	) as 'Broj narudžbi'
 from Sales.SalesOrderHeader as soh
	inner join Sales.SalesTerritory as st on soh.TerritoryID = st.TerritoryID
	inner join Sales.SalesOrderDetail as sod on soh.SalesOrderID = sod.SalesOrderID
where sod.UnitPriceDiscount = 0 or sod.UnitPriceDiscount is null
group by st.Name
having SUM(sod.OrderQty)<30000 and 
	(
		select COUNT(*)
		from Sales.SalesOrderHeader as soh1
			inner join Sales.SalesTerritory as st1 on st1.TerritoryID = soh1.TerritoryID
		where st1.Name = st.Name
	)>=1000
order by 3

--Država | količina stavke bez popusta | br narudžbi
--Germany	11222	2623
--France	17073	2672
--United Kingdom	17562	3219
--Australia	17603	6843

--Provjera
select COUNT(*)
from Sales.SalesOrderHeader as soh1
	inner join Sales.SalesTerritory as st1 on st1.TerritoryID = soh1.TerritoryID
where st1.Name like 'Australia'

select SUM(sod1.OrderQty)
from Sales.SalesOrderHeader as soh1
	inner join Sales.SalesTerritory as st1 on st1.TerritoryID = soh1.TerritoryID
	inner join Sales.SalesOrderDetail as sod1 on sod1.SalesOrderID = soh1.SalesOrderID
where st1.Name like 'Australia' and sod1.UnitPriceDiscount = 0
