--24.03.2023. prvi parcijalni BP2 :: rješenje

--1.
create database Ispit_24_03_2023
go
use Ispit_24_03_2023

--2.
--a)
create table Izdavaci
(
	IzdavacID char(4) constraint PK_Izdavaci primary key,
	Naziv varchar(40),
	Grad varchar(20),
	Drzava varchar(40),
	DodatneInformacije text
)

--b)
create table Naslovi
(
	NaslovID varchar(6) constraint PK_Naslovi primary key,
	Naslov varchar(80) not null,
	Tip char(12) not null,
	Cijena money,
	IzdavacID char(4) constraint FK_Naslovi_Izdavaci foreign key references Izdavaci(IzdavacID)
)

--d)
create table Prodavnice
(
	ProdavnicaID char(4) constraint PK_Prodavnice primary key,
	NazivProdavnice varchar(40),
	Grad varchar(40)
)

--c)
create table Prodaja
(
	ProdavnicaID char(4) constraint FK_Prodaja_Prodavnice foreign key references Prodavnice(ProdavnicaID),
	BrojNarudzbe varchar(30),
	NaslovID varchar(6) constraint FK_Prodaja_Naslovi foreign key references Naslovi(NaslovID),
	DatumNarudzbe datetime not null,
	Kolicina smallint not null

	constraint PK_Prodaja primary key(ProdavnicaID,BrojNarudzbe, NaslovID)
)

--3.
--a

insert into Izdavaci 
select p.pub_id, p.pub_name, p.city, p.country, pi.pr_info
from pubs.dbo.publishers as p
	inner join  pubs.dbo.pub_info as pi on pi.pub_id = p.pub_id

--b

insert into Naslovi
select t.title_id, t.title, t.type, t.price, t.pub_id
from pubs.dbo.titles as t

--d
insert into Prodavnice (ProdavnicaID, NazivProdavnice, Grad)
select s.stor_id, s.stor_name, s.city
from pubs.dbo.stores as s

--c
insert into Prodaja (ProdavnicaID, BrojNarudzbe, NaslovID, DatumNarudzbe, Kolicina)
select s.stor_id, s.ord_num, s.title_id, s.ord_date, s.qty
from pubs.dbo.sales as s

--------------------------------------------
--4
--a

go
create procedure sp_edi_izdavac
(
	@IzdavacID char(4),
	@Naziv varchar(40)=null,
	@Grad varchar(20)=null,
	@Drzava varchar(40)=null,
	@DodatneInformacije text =null
)
as
begin
	update Izdavaci
	set
	Naziv = ISNULL(@Naziv, Naziv),
	Grad = ISNULL(@Grad, Grad),
	Drzava = ISNULL(@Drzava, Drzava),
	DodatneInformacije = ISNULL(@DodatneInformacije, DodatneInformacije)
	where IzdavacID = @IzdavacID
end
go

--4
--b
create table Prodavnice_log
(
	ProdavnicaID char(4),
	Naziv varchar(40),
	Grad varchar(40),
	Datum datetime,
	Opis varchar(10)
)

--4
--c
--OKIDAČI

use Ispit_24_03_2023
go
create trigger t_del_Prodavnice
on Prodavnice
after delete
as
	insert into Prodavnice_log
	select ProdavnicaID, NazivProdavnice, Grad, GETDATE(), 'delete'
	from deleted
go

select * from Prodavnice

insert into Prodavnice (ProdavnicaID, NazivProdavnice, Grad)
values (77, 'Bingo Hipermarket', 'Mostar')

delete from Prodavnice
where ProdavnicaID = 77

select * from Prodavnice_log


--4
--d

use pubs

select top 10 with ties s.ord_num, t.title, s.ord_date, s.qty 
from sales as s
	inner join titles as t on s.title_id = t.title_id
order by s.qty desc

--4
--e

use Northwind

select 
	od.OrderID, 
	SUM(od.Quantity) as 'Naručena količina',
	CAST(SUM(od.UnitPrice*od.Quantity) as decimal(18,2)) as 'Vrijednost bez popusta',
	CAST(SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) as decimal(18,2)) as'Vrijednost sa popustom'
from [Order Details] as od
	inner join Orders as o on od.OrderID = o.OrderID
where DATEDIFF(DAY, o.OrderDate, o.ShippedDate)<=7 and o.ShipCity in ('Seattle', 'Madrid', 'München')
group by od.OrderID
order by 2 desc

--4
--f
use prihodi

select
	o.Ime,
	o.PrezIme,
	p.Naziv,
	rp.Godina,
	trp.NazivRedovnogPrihoda,
	rp.Neto
from Osoba as o
	inner join RedovniPrihodi as rp on rp.OsobaID = o.OsobaID
	inner join Poslodavac as p on o.PoslodavacID = p.PoslodavacID
	inner join TipRedovnogPrihoda as trp on rp.TipRedovnogPrihodaID = trp.TipRedovnogPrihodaID
where 
o.Spol like 'F' and
o.OsobaID in
(
	select o.OsobaID
	from Osoba as o
		left join VanredniPrihodi as vp on vp.OsobaID = o.OsobaID
	where vp.VanredniPrihodiID is null
)
order by rp.Godina desc, trp.NazivRedovnogPrihoda, rp.Neto desc 

-----------------------------------------------------
--5
--a

use AdventureWorks2017

select top 1 d.Name
from HumanResources.Department as d
	inner join HumanResources.EmployeeDepartmentHistory as edh on edh.DepartmentID = d.DepartmentID
	inner join HumanResources.Employee as e on edh.BusinessEntityID = e.BusinessEntityID
where DATEDIFF(YEAR,e.BirthDate, GETDATE())>65
group by d.Name
order by COUNT(*)desc

--5
--b
use AdventureWorks2017

select top 1 p.ProductID, p.Name, SUM(sod.OrderQty) as 'Broj komada'
from Production.Product as p	
	inner join Sales.SalesOrderDetail as sod on sod.ProductID = p.ProductID
	inner join Sales.SalesOrderHeader as soh on soh.SalesOrderID = sod.SalesOrderID
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where YEAR(soh.OrderDate)=2011 and pc.Name like 'Components'
group by p.ProductID, p.Name
order by SUM(sod.OrderQty) desc


--5
--c
use AdventureWorks2017

--Prosječan broj ukupno kreiranih narudžbi od strane svih uposlenika
DECLARE @Prosjek int
SET @Prosjek =
(
	select AVG(podq.[Broj narudžbi])
	from
	(
		select soh.SalesPersonID, COUNT(*) as 'Broj narudžbi'
		from Sales.SalesOrderHeader as soh
			inner join Sales.SalesPerson as sp on soh.SalesPersonID = sp.BusinessEntityID
		group by soh.SalesPersonID
	) as podq
)
--1748

select 
	p.FirstName,
	p.LastName, 
	DATEDIFF(YEAR, e.HireDate, GETDATE()) as 'Godine staža',
	COUNT(*) as 'Broj narudžbi',
	CASE
		WHEN COUNT(*)>@Prosjek THEN 'Iznadprosječan'
		WHEN COUNT(*)<@Prosjek THEN 'Ispodprosječan'
	END AS 'Opis'
from Sales.SalesOrderHeader as soh
	inner join Sales.SalesPerson as sp on soh.SalesPersonID = sp.BusinessEntityID
	inner join Person.Person as p on sp.BusinessEntityID = p.BusinessEntityID
	inner join HumanResources.Employee as e on e.BusinessEntityID = sp.BusinessEntityID
group by p.FirstName, p.LastName, e.HireDate
