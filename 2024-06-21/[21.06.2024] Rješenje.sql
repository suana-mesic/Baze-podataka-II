--1. Kroz SQL kod kreirati bazu podataka sa imenom vaseg broja indeksa
create database Ispit_21_06_2024
go
use Ispit_21_06_2024

--4 b
--2. U kreiranoj bazi podataka kreirati tabele sa sljedecom strukturom:
--a)	Uposlenici
--•	UposlenikID, cjelobrojni tip i primarni kljuc, autoinkrement,
--•	Ime 10 UNICODE karaktera obavezan unos,
--•	Prezime 20 UNICODE karaktera obavezan unos
--•	DatumRodjenja polje za unos datuma i vremena obavezan unos
--•	UkupanBrojTeritorija, cjelobrojni tip

create table Uposlenici
(
	UposlenikID int constraint PK_Uposlenici primary key identity(1,1),
	Ime nvarchar(10) not null, 
	Prezime nvarchar(20) not null, 
	DatumRodjenja datetime not null,
	UkupanBrojTeritorija int
)

--b)	Narudzbe
--•	NarudzbaID, cjelobrojni tip i primarni kljuc, autoinkrement
--•	UposlenikID, cjelobrojni tip, strani kljuc,
--•	DatumNarudzbe, polje za unos datuma i vremena,
--•	ImeKompanijeKupca, 40 UNICODE karaktera,
--•	AdresaKupca, 60 UNICODE karaktera


create table Narudzbe
(
	NarudzbaID int constraint PK_Narudzbe primary key identity(1,1),
	UposlenikID int constraint FK_Narudzbe_Uposlenici foreign key references Uposlenici (UposlenikID),
	DatumNarudzbe datetime,
	ImeKompanijeKupca nvarchar(40),
	AdresaKupca nvarchar(60)
)


--c) Proizvodi
--•	ProizvodID, cjelobrojni tip i primarni ključ, autoinkrement
--•	NazivProizvoda, 40 UNICODE karaktera (obavezan unos)
--•	NazivKompanijeDobavljaca, 40 UNICODE karaktera
--•	NazivKategorije, 15 UNICODE karaktera

create table Proizvodi
(
	ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
	NazivProizvoda nvarchar(40) not null,
	NazivKompanijeDobavljaca nvarchar(40),
	NazivKategorije nvarchar(15)
)

--d) StavkeNarudzbe
--•	NarudzbalD, cjelobrojni tip strani i primami ključ
--•	ProizvodlD, cjelobrojni tip strani i primami ključ
--•	Cijena, novčani tip (obavezan unos)
--•	Kolicina, kratki cjelobrojni tip (obavezan unos)
--•	Popust, real tip podatka (obavezan unos)

create table StavkeNarudzbe
(
	NarudzbalD int constraint FK_StavkeNarudzbe_Narudbe foreign key references Narudzbe(NarudzbaID),
	ProizvodlD int constraint FK_StavkeNarudzbe_Proizvodi foreign key references Proizvodi(ProizvodID),
	Cijena money not null,
	Kolicina tinyint not null,
	Popust real not null
	
	constraint PK_StavkeNarudzbe primary key(NarudzbalD, ProizvodlD)
)

--5 bodova
--3. 
--Iz baze podataka Northwind u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Uposlenici dodati sve uposlenike
--•	EmployeelD -> UposlenikID
--•	FirstName -> Ime
--•	LastName -> Prezime
--•	BirthDate -> DatumRodjenja
--•	lzračunata vrijednost za svakog uposlenika na osnovu EmployeeTerritories-:----UkupanBrojTeritorija

set identity_insert Uposlenici on
insert into Uposlenici (UposlenikID, Ime, Prezime, DatumRodjenja, UkupanBrojTeritorija)
select e.EmployeeID, e.FirstName, e.LastName, e.BirthDate, COUNT(*)
from Northwind.dbo.Employees as e 
	inner join Northwind.dbo.EmployeeTerritories as et on et.EmployeeID = e.EmployeeID
group by e.EmployeeID, e.FirstName, e.LastName, e.BirthDate
set identity_insert Uposlenici off

--b) U tabelu Narudzbe dodati sve narudzbe
--•	OrderlD -> NarudzbalD
--•	EmployeelD -> UposlenikID
--•	OrderDate -> DatumNarudzbe
--•	CompanyName -> ImeKompanijeKupca
--•	Address -> AdresaKupca

set identity_insert Narudzbe on
insert into Narudzbe (NarudzbaID, UposlenikID, DatumNarudzbe, ImeKompanijeKupca, AdresaKupca)
select o.OrderID, e.EmployeeID, o.OrderDate, c.CompanyName, c.Address
from Northwind.dbo.Orders as o
	inner join Northwind.dbo.Employees as e on o.EmployeeID = e.EmployeeID
	inner join Northwind.dbo.Customers as c on o.CustomerID = c.CustomerID
set identity_insert Narudzbe off

--c) U tabelu Proizvodi dodati sve proizvode
--•	ProductID -> ProizvodlD
--•	ProductName -> NazivProizvoda
--•	CompanyName -> NazivKompanijeDobavljaca
--•	CategoryName -> NazivKategorije

set identity_insert Proizvodi on
insert into Proizvodi (ProizvodID, NazivProizvoda, NazivKompanijeDobavljaca, NazivKategorije)
select p.ProductID, p.ProductName, s.CompanyName, c.CategoryName
from Northwind.dbo.Products as p
	inner join Northwind.dbo.Suppliers as s on s.SupplierID = p.SupplierID
	inner join Northwind.dbo.Categories as c on p.CategoryID = c.CategoryID
set identity_insert Proizvodi off

--d) U tabelu StavkeNarudzbe dodati sve stavke narudzbe
--•	OrderlD -> NarudzbalD
--•	ProductID -> ProizvodlD
--•	UnitPrice -> Cijena
--•	Quantity -> Kolicina
--•	Discount -> Popust

insert into StavkeNarudzbe (NarudzbalD, ProizvodlD, Cijena, Kolicina, Popust)
select od.OrderID, od.ProductID, od.UnitPrice, od.Quantity, od.Discount
from Northwind.dbo.[Order Details] as od



--4. 
--a) (4 boda) U tabelu StavkeNarudzbe dodati 2 nove izračunate kolone: vrijednostNarudzbeSaPopustom i vrijednostNarudzbeBezPopusta. 
--Izračunate kolonc već čuvaju podatke na osnovu podataka iz kolona! 

alter table StavkeNarudzbe
add 
	vrijednostNarudzbeSaPopustom as Cijena*Kolicina*(1-Popust),
	vrijednostNarudzbeBezPopusta as Cijena*Kolicina

--b) (5 bodom) Kreirati pogled v_select_orders kojim ćc se prikazati ukupna zarada po uposlenicima od narudzbi kreiranih u zadnjem kvartalu 1996. godine. Pogledom je potrebno prikazati spojeno ime i prezime uposlenika, ukupna zarada sa popustom zaokrzena na dvije decimale i ukupna zarada bez popusta. Za prikaz ukupnih zarada koristiti OBAVEZNO koristiti izračunate kolone iz zadatka 4a. (Novokreirana baza)

go
create view v_select_orders
as
select 
	CONCAT(u.Ime, ' ', u.Prezime) as 'ime i prezime uposlenika',
	CAST(SUM(sn.vrijednostNarudzbeSaPopustom) as decimal(18,2)) as 'Zarada sa popustom',
	CAST(SUM(sn.vrijednostNarudzbeBezPopusta) as decimal(18,2)) as 'Zarada bez popusta'
from StavkeNarudzbe as sn
	inner join Narudzbe as n on sn.NarudzbalD = n.NarudzbaID
	inner join Uposlenici as u on n.UposlenikID = u.UposlenikID
where YEAR(n.DatumNarudzbe)=1996 and DATEPART(QUARTER, n.DatumNarudzbe) = 4
group by CONCAT(u.Ime, ' ', u.Prezime)
go

--c) (5 boda) Kreirati funkciju f_starijiUposleici koja će vraćati podatke u formi tabele na osnovu proslijedjenog parametra godineStarosti, cjelobrojni tip. Funkcija će vraćati one zapise u kojima su godine starosti kod uposlenika veće od unesene vrijednosti parametra. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalaze sve kolone tabele uposlenici, zajedno sa izračunatim godinama starosti. Provjeriti ispravnost funkcije unošenjem kontrolnih vrijednosti. (Novokreirana baza) 

use Ispit_21_06_2024
go
create function f_starijiUposleici(@godineStarosti int)
returns table
as
return
	(
	select u.UposlenikID, u.Ime, u.Prezime, u.DatumRodjenja, u.UkupanBrojTeritorija, DATEDIFF(YEAR,u.DatumRodjenja, GETDATE()) as 'Godine starosti'
	from Uposlenici as u
	where DATEDIFF(YEAR,u.DatumRodjenja, GETDATE())> @godineStarosti
	)
go

--Provjera
select *
from f_starijiUposleici(70)

select u.UposlenikID, u.Ime, u.Prezime, u.DatumRodjenja, u.UkupanBrojTeritorija, DATEDIFF(YEAR,u.DatumRodjenja, GETDATE()) as 'Godine starosti'
from Uposlenici as u
where DATEDIFF(YEAR,u.DatumRodjenja, GETDATE())> 70



--d) (7 bodova) Pronaći najprodavaniji proizvod u 2011 godini. Ulogu najprodavanijeg nosi onaj kojeg je najveći broj komada prodat. (AdventureWorks2017)

use AdventureWorks2017
select TOP 1 p.ProductID, p.Name, SUM(sod.OrderQty) as 'Prodata količina'
from Production.Product as p
	inner join Sales.SalesOrderDetail as sod on sod.ProductID = p.ProductID
	inner join Sales.SalesOrderHeader as soh on soh.SalesOrderID = sod.SalesOrderID
where YEAR(soh.OrderDate)=2011
group by p.ProductID, p.Name
order by SUM(sod.OrderQty) desc

--e) (6 bodova) Prikazati ukupan broj proizvoda prema specijalnim ponudama. Potrebno je prebrojati samo one proizvode koji pripadaju kategoriji odjeće. (AdventureWorks2017) 

use AdventureWorks2017
select sp.SpecialOfferID, so.Description, COUNT(*) as 'Broj proizvoda'
from Sales.SpecialOfferProduct as sp
	inner join Production.Product as p on sp.ProductID = p.ProductID
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
	inner join Sales.SpecialOffer as so on so.SpecialOfferID = sp.SpecialOfferID
where lower(pc.Name) like 'clothing'
group by sp.SpecialOfferID, so.Description

--f) (8 bodova) Prikazati najskuplji proizvod (List Price) u svakoj kategoriji. (AdventureWorks2017) 

use AdventureWorks2017
select pc.ProductCategoryID, pc.Name, MAX(p.ListPrice) as 'Vrijednost najskupljeg proizvoda'
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
group by pc.ProductCategoryID, pc.Name

--FINALNI UPIT
select pc.ProductCategoryID, pc.Name, p.Name
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where CONCAT(pc.ProductCategoryID, pc.Name, p.ListPrice) in
	(
	select CONCAT(pc.ProductCategoryID, pc.Name, MAX(p.ListPrice)) 
	from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
	group by pc.ProductCategoryID, pc.Name
	)
order by 1

--2	Components	HL Road Frame - Black, 62
--2	Components	HL Road Frame - Black, 44
--2	Components	HL Road Frame - Black, 48
--2	Components	HL Road Frame - Black, 52
--2	Components	HL Road Frame - Black, 58
--2	Components	HL Road Frame - Red, 58
--2	Components	HL Road Frame - Red, 62
--2	Components	HL Road Frame - Red, 44
--2	Components	HL Road Frame - Red, 48
--2	Components	HL Road Frame - Red, 52
--2	Components	HL Road Frame - Red, 56

--kat 2 max cijena 1431,50
select distinct p.Name, p.ListPrice
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where p.ListPrice = 1431.50 and pc.ProductCategoryID = 2

--g) (8 bodova) Prikazati proizvode čija je maloprodajna cijena (List Price) manja od prosječne maloprodajne cijene kategorije proizvoda kojoj pripada. (AdventureWorks2017) 

--FINALNI UPIT
select p.ProductID, p.Name
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where p.ListPrice < 
	(
	select AVG(p1.ListPrice)
	from Production.Product as p1
		inner join Production.ProductSubcategory as ps1 on p1.ProductSubcategoryID = ps1.ProductSubcategoryID
		inner join Production.ProductCategory as pc1 on ps1.ProductCategoryID = pc1.ProductCategoryID
	where pc1.ProductCategoryID = pc.ProductCategoryID
	)

--PROVJERA
--Prosjek maloprodajne cijene za kategoriju = 2 je 469,8602
select AVG(p.ListPrice)
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where pc.ProductCategoryID = 2

--Svi proizvodi koji su u kategoiji 2, a da im je cijena manja od 469,8602 -> 95 proizvoda
select p.ProductID, p.Name
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where pc.ProductCategoryID = 2 and p.ListPrice < 469.8602

--U finalnom upitu ih je također 95
select p.ProductID, p.Name
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where p.ListPrice < 
	(
	select AVG(p1.ListPrice)
	from Production.Product as p1
		inner join Production.ProductSubcategory as ps1 on p1.ProductSubcategoryID = ps1.ProductSubcategoryID
		inner join Production.ProductCategory as pc1 on ps1.ProductCategoryID = pc1.ProductCategoryID
	where pc1.ProductCategoryID = pc.ProductCategoryID
	) and pc.ProductCategoryID = 2


--5. 
--a) (12 bodova) Pronaći najprodavanije proizvode, koji nisu na lisli top 10 najprodavanijih proizvoda u zadnjih 11 godina. (AdventureWorks2017) 
--TOP 10 najprodavanijih proizvoda u zadnjih 11 godina

use AdventureWorks2017
select top 10 sod.ProductID
from Sales.SalesOrderDetail as sod
	inner join Sales.SalesOrderHeader as soh on soh.SalesOrderID = sod.SalesOrderID
where DATEDIFF(YEAR, soh.OrderDate, GETDATE())<=11
group by sod.ProductID
order by SUM(sod.OrderQty) desc

--FINALNI UPIT
select sod.ProductID, p.Name
from Sales.SalesOrderDetail as sod
	inner join Sales.SalesOrderHeader as soh on soh.SalesOrderID = sod.SalesOrderID
	inner join Production.Product as p on sod.ProductID = p.ProductID
where sod.ProductID not in 
(
	select top 10 sod.ProductID
	from Sales.SalesOrderDetail as sod
		inner join Sales.SalesOrderHeader as soh on soh.SalesOrderID = sod.SalesOrderID
	where DATEDIFF(YEAR, soh.OrderDate, GETDATE())<=11
	group by sod.ProductID
	order by SUM(sod.OrderQty) desc
)
group by sod.ProductID,  p.Name
order by SUM(sod.OrderQty) desc

--b) (16 bodova) Prikazati ime i prezime kupca, id narudzbe, te ukupnu vrijednost narudzbe sa popustom (zaokruzenu na dvije decimale), uz uslov da su na nivou pojedine narudžbe naručeni proizvodi iz svih kategorija. (AdventureWorks2017) 

--FINALNI UPIT
use AdventureWorks2017

select 
	p.FirstName, 
	p.LastName,
	soh.SalesOrderID, 
	SUM(soh.SubTotal) as 'Narudžba sa popustom'
from Sales.Customer as c 
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
	inner join Sales.SalesOrderHeader as soh on soh.CustomerID = c.CustomerID
where 
(
	select COUNT(*)
	from 
	(
	select distinct sod.SalesOrderID, pc.ProductCategoryID
	from Sales.SalesOrderDetail as sod
		inner join Production.Product as p on sod.ProductID = p.ProductID
		inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
		inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
	where sod.SalesOrderID = soh.SalesOrderID
	group by sod.SalesOrderID, pc.ProductCategoryID
	) as podq
)=4
group by p.FirstName, p.LastName, soh.SalesOrderID

--Provjera 
--Narudžbe koje ispunjavaju uvjet
--50689 
--50282
--51825
--51718
--46971
--46374

select COUNT(*)
from 
(
select distinct sod.SalesOrderID, pc.ProductCategoryID
from Sales.SalesOrderDetail as sod
	inner join Production.Product as p on sod.ProductID = p.ProductID
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where sod.SalesOrderID = 46374
group by sod.SalesOrderID, pc.ProductCategoryID
) as podq


