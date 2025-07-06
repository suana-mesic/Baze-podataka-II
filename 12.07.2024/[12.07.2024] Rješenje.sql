--1.Kreirati bazu podataka sa imenom vaseg broja indeksa
create database Ispit_12_07_2024
go
use Ispit_12_07_2024

--2.U kreiranoj bazi tabelu sa strukturom : 
--a) Uposlenici 
-- UposlenikID cjelobrojni tip i primarni kljuc autoinkrement,
-- Ime 10 UNICODE karaktera (obavezan unos)
-- Prezime 20 UNICODE karaktera (obaveznan unos),
-- DatumRodjenja polje za unos datuma i vremena (obavezan unos)
-- UkupanBrojTeritorija cjelobrojni tip

create table Uposlenici
(
	UposlenikID int constraint PK_Uposlenici primary key identity(1,1),
	Ime nvarchar(10) not null, 
	Prezime nvarchar(20) not null, 
	DatumRodjenja datetime not null,
	UkupanBrojTeritorija int
)

--b) Narudzbe
-- NarudzbaID cjelobrojni tip i primarni kljuc autoinkrement,
-- UposlenikID cjelobrojni tip i strani kljuc,
-- DatumNarudzbe polje za unos datuma i vremena,
-- ImeKompanijeKupca 40 UNICODE karaktera,
-- AdresaKupca 60 UNICODE karaktera,
-- UkupanBrojStavkiNarudzbe cjelobrojni tip

create table Narudzbe
(
	NarudzbaID int constraint PK_Narudzbe primary key identity(1,1),
	UposlenikID int constraint FK_Narudzbe_Uposlenici foreign key references Uposlenici (UposlenikID),
	DatumNarudzbe datetime,
	ImeKompanijeKupca nvarchar(40),
	AdresaKupca nvarchar(60),
	UkupanBrojStavkiNarudzbe int
)

--c) Proizvodi
-- ProizvodID cjelobrojni tip i primarni kljuc autoinkrement,
-- NazivProizvoda 40 UNICODE karaktera (obaveznan unos),
-- NazivKompanijeDobavljaca 40 UNICODE karaktera,
-- NazivKategorije 15 UNICODE karaktera

create table Proizvodi
(
	ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
	NazivProizvoda nvarchar(40) not null,
	NazivKompanijeDobavljaca nvarchar(40),
	NazivKategorije nvarchar(15)
)

--d) StavkeNarudzbe
-- NarudzbaID cjelobrojni tip strani i primarni kljuc,
-- ProizvodID cjelobrojni tip strani i primarni kljuc,
-- Cijena novcani tip (obavezan unos),
-- Kolicina kratki cjelobrojni tip (obavezan unos),
-- Popust real tip podataka (obavezno)

create table StavkeNarudzbe
(
	NarudzbalD int constraint FK_StavkeNarudzbe_Narudbe foreign key references Narudzbe(NarudzbaID),
	ProizvodlD int constraint FK_StavkeNarudzbe_Proizvodi foreign key references Proizvodi(ProizvodID),
	Cijena money not null,
	Kolicina tinyint not null,
	Popust real not null
	
	constraint PK_StavkeNarudzbe primary key(NarudzbalD, ProizvodlD)
)
--(4 boda)


--3.Iz baze Northwind u svoju prebaciti sljedece podatke :
--a) U tabelu uposlenici sve uposlenike , Izracunata vrijednost za svakog uposlenika
-- na osnovnu EmployeeTerritories -> UkupanBrojTeritorija

set identity_insert Uposlenici on
insert into Uposlenici (UposlenikID, Ime, Prezime, DatumRodjenja, UkupanBrojTeritorija)
select e.EmployeeID, e.FirstName, e.LastName, e.BirthDate, COUNT(*)
from Northwind.dbo.Employees as e 
	inner join Northwind.dbo.EmployeeTerritories as et on et.EmployeeID = e.EmployeeID
group by e.EmployeeID, e.FirstName, e.LastName, e.BirthDate
set identity_insert Uposlenici off

--b) U tabelu narudzbe sve narudzbe, Izracunata vrijensot za svaku narudzbu pojedinacno 
-- ->UkupanBrojStavkiNarudzbe

set identity_insert Narudzbe on
insert into Narudzbe (NarudzbaID, UposlenikID, DatumNarudzbe, ImeKompanijeKupca, AdresaKupca)
select o.OrderID, e.EmployeeID, o.OrderDate, c.CompanyName, c.Address
from Northwind.dbo.Orders as o
	inner join Northwind.dbo.Employees as e on o.EmployeeID = e.EmployeeID
	inner join Northwind.dbo.Customers as c on o.CustomerID = c.CustomerID
set identity_insert Narudzbe off

--c) U tabelu proizvodi sve proizvode
set identity_insert Proizvodi on
insert into Proizvodi (ProizvodID, NazivProizvoda, NazivKompanijeDobavljaca, NazivKategorije)
select p.ProductID, p.ProductName, s.CompanyName, c.CategoryName
from Northwind.dbo.Products as p
	inner join Northwind.dbo.Suppliers as s on s.SupplierID = p.SupplierID
	inner join Northwind.dbo.Categories as c on p.CategoryID = c.CategoryID
set identity_insert Proizvodi off

--d) U tabelu StavkeNrudzbe sve narudzbe
insert into StavkeNarudzbe (NarudzbalD, ProizvodlD, Cijena, Kolicina, Popust)
select od.OrderID, od.ProductID, od.UnitPrice, od.Quantity, od.Discount
from Northwind.dbo.[Order Details] as od

--(5 bodova)


--4. 
--a) (4 boda) Kreirati indeks kojim ce se ubrzati pretraga po nazivu proizvoda, OBEVAZENO kreirati testni slucaj (Nova baza)

create index ix_Proizvodi_NazivProizvoda
on Proizvodi (NazivProizvoda)

select *
from Proizvodi as p
where lower(p.NazivProizvoda) like 'a%'

--b) (4 boda) Kreirati proceduru sp_update_proizvodi kojom ce se izmjeniti podaci o proizvodima u tabeli. Korisnici mogu poslati jedan ili vise parametara te voditi računa da ne dodje do gubitka podataka.(Nova baza)

use Ispit_12_07_2024
go
create procedure sp_update_proizvodi
(
	@ProizvodID int,
	@NazivProizvoda nvarchar(40) = null,
	@NazivKompanijeDobavljaca nvarchar(40) = null,
	@NazivKategorije nvarchar(15) = null
)
as
begin 
	update Proizvodi
	set
		NazivProizvoda = ISNULL(@NazivProizvoda, NazivProizvoda),
		NazivKompanijeDobavljaca = ISNULL(@NazivKompanijeDobavljaca, NazivKompanijeDobavljaca),
		NazivKategorije = ISNULL(@NazivKategorije, NazivKategorije)
	where ProizvodID = @ProizvodID
end
go

--Provjera
--1		Chai	Exotic Liquids		Beverages
--Mijenjamo u  -> 1		Čaj		Egzotična pića	Pića
select * 
from Proizvodi

exec sp_update_proizvodi @ProizvodID = 1, @NazivProizvoda = 'Čaj'
exec sp_update_proizvodi @ProizvodID = 1, @NazivKompanijeDobavljaca = 'Egzotična pića', @NazivKategorije = 'Pića'

exec sp_update_proizvodi @ProizvodID = 1, @NazivProizvoda = 'Chai', @NazivKompanijeDobavljaca = 'Exotic Liquids', @NazivKategorije = 'Beverages'

--c) (5 bodova) Kreirati funckiju f_4c koja ce vratiti podatke u tabelarnom obliku na osnovnu prosljedjenog parametra idNarudzbe cjelobrojni tip. Funckija ce vratiti one narudzbe ciji id odgovara poslanom parametru. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalazi id narudzbe, ukupna vrijednost bez popusta. OBAVEZNO testni slucaj (Nova baza)

go
create function f_4c(@idNarudzbe int)
returns table
as
return
	(
	select n.NarudzbaID, SUM(sn.Cijena * sn.Kolicina) as 'Vrijednost bez popusta'
	from Narudzbe as n
		inner join StavkeNarudzbe as sn on sn.NarudzbalD = n.NarudzbaID
	where n.NarudzbaID = @idNarudzbe
	group by n.NarudzbaID
	)
go

--Provjera
--Rezultat 10248	440,00
select *
from f_4c(10248)

--Rezultat 10248	440,00
select n.NarudzbaID, SUM(sn.Cijena * sn.Kolicina) as 'Vrijednost bez popusta'
from Narudzbe as n
	inner join StavkeNarudzbe as sn on sn.NarudzbalD = n.NarudzbaID
where n.NarudzbaID = 10248
group by n.NarudzbaID


--d) (6 bodova) Pronaci najmanju narudzbu placenu karticom i isporuceno na porducje Europe, uz id narudzbe prikazati i spojeno ime i prezime kupca te grad u koji je isporucena narudzba (AdventureWorks2017)

use AdventureWorks2017

select top 1
	soh.SalesOrderID, 
	CONCAT(p.FirstName,' ', p.LastName) as 'ime i prezime kupca',
	a.City
from Sales.SalesOrderHeader as soh
	inner join Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
	inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
	inner join Person.Address as a on soh.ShipToAddressID = a.AddressID
	inner join Person.StateProvince as spr on a.StateProvinceID = spr.StateProvinceID
	inner join Sales.SalesTerritory as st on spr.TerritoryID = st.TerritoryID
where soh.CreditCardID is not null and st.[Group] like 'Europe'
group by soh.SalesOrderID, CONCAT(p.FirstName,' ', p.LastName), a.City
order by SUM(sod.LineTotal)


--e) (6 bodova) Prikazati ukupan broj porizvoda prema specijalnim ponudama.Potrebno je prebrojati samo one proizvode koji pripadaju kategoriji odjece ili imaju zabiljezen model (AdventureWorks2017)

use AdventureWorks2017
select sp.SpecialOfferID, so.Description, COUNT(*) as 'Broj proizvoda'
from Sales.SpecialOfferProduct as sp
	inner join Production.Product as p on sp.ProductID = p.ProductID
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
	inner join Sales.SpecialOffer as so on so.SpecialOfferID = sp.SpecialOfferID
where (pc.Name like 'Clothing') or (p.ProductModelID is not null)
group by sp.SpecialOfferID, so.Description


--f) (9 bodova) Prikazatu 5 kupaca koji su napravili najveci broj narudzbi u zadnjih 30% narudzbi iz 2011 ili 2012 god. (AdventureWorks)
use AdventureWorks2017

--zadnjih 30% narudzbi iz 2011 ili 2012 god, 1657 (ovdje ih zaokruži)
select top 30 percent soh.SalesOrderID
from Sales.SalesOrderHeader as soh
where YEAR(soh.OrderDate) in (2011, 2012)
order by soh.OrderDate desc

--FINALNI UPIT
select TOP 5 c.CustomerID, p.FirstName, p.LastName ,COUNT(*) as 'Broj narudžbi'
from Sales.Customer as c
	inner join Sales.SalesOrderHeader as soh on soh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
where soh.SalesOrderID in 
(
select podq.SalesOrderID
from
	(
		select top 30 percent soh.SalesOrderID
		from Sales.SalesOrderHeader as soh
		where YEAR(soh.OrderDate) in (2011, 2012)
		order by soh.OrderDate desc
	) as podq
) 
group by c.CustomerID, p.FirstName, p.LastName
order by COUNT(*) desc

----------------PROVJERA ZA KUPCA CUSTOMERID = 29500
--29500
select c.CustomerID, p.FirstName, p.LastName, soh.SalesOrderID
from Sales.Customer as c
	inner join Sales.SalesOrderHeader as soh on soh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
where c.CustomerID = 29500

--Sve narudzbe ovog kupca ID = 29500
--46636
--47727 --ova je u zadnjih 30%
--48793 --ova je u zadnjih 30%
--51137
--55331
--61217
--67348
select*
from
(
select top 30 percent soh.SalesOrderID
from Sales.SalesOrderHeader as soh
where YEAR(soh.OrderDate) in (2011, 2012)
order by soh.OrderDate desc
) as podq
INTERSECT
select soh.SalesOrderID
from Sales.SalesOrderHeader as soh
where soh.SalesOrderID in
(
46636,
47727,
48793,
51137,
55331,
61217,
67348
)

--48793
--47727

select TOP 5 c.CustomerID, p.FirstName, p.LastName, soh.SalesOrderID
from Sales.Customer as c
	inner join Sales.SalesOrderHeader as soh on soh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
where soh.SalesOrderID in 
(
select podq.SalesOrderID
from
	(
		select top 30 percent soh.SalesOrderID
		from Sales.SalesOrderHeader as soh
		where YEAR(soh.OrderDate) in (2011, 2012)
		order by soh.OrderDate desc
	) as podq
) and c.CustomerID = 29500


--Nepotpun zadatak (nedostaje nešto u tekstu da bi se mogao uraditi)
--g) (10 bodova) Menadzmentu kompanije potrebne su informacije o najmanje prodavanim proizvodima. ...kako bi ih eliminisali iz ponude. Obavezno prikazati naziv o kojem se proizvodu radi i kvartal i godinu i adekvatnu poruku. (AdventureWorks)

--5.
--a) (11 bodova) Prikazati kupce koji su kreirali narudzbe u minimalno 5 razlicitih mjeseci u 2012 godini.
--FINALNI UPIT
select c.CustomerID, p.FirstName, p.LastName
from Sales.Customer as c
	inner join Person.Person as p on p.BusinessEntityID = c.PersonID
where 
(
	select COUNT(*)
		from 
		(
		select distinct c1.CustomerID, MONTH(soh1.OrderDate) as 'Mjesec'
		from Sales.Customer as c1
			inner join Sales.SalesOrderHeader as soh1 on soh1.CustomerID = c1.CustomerID
		where YEAR(soh1.OrderDate)=2012 and c1.CustomerID = c.CustomerID
		) as podq
)>=5

--Rezultat
--29507	Phyllis	Allen
--29509	Michael	Allen

--Provjera
-- 7 zapisa = u 7 različitih mjeseci je kupovao
select distinct c.CustomerID, p.FirstName, p.LastName, MONTH(soh.OrderDate)
from Sales.Customer as c
	inner join Person.Person as p on p.BusinessEntityID = c.PersonID
	inner join Sales.SalesOrderHeader as soh on soh.CustomerID = c.CustomerID
where c.CustomerID = 29539


--b) (16 bodova) Prikazati 5 narudzbi sa najvise narucenih razlicitih proizvoda i 5 narudzbi sa najvise proizvoda koji pripadaju razlicitim potkategorijama. Upitom prikazati ime i prezime kupca, id narudzbe te ukupnu vrijednost narudzbe sa popustom zaokruzenu na 2 decimale (AdventureWorks2017)

--Zadatak je urađen na malo drugačiji način
--Kada se koristi UNION operator onda se desi da su neki proizvodi u prvom i drugom podupitu isti
--Zbog toga ih sumarno ne bude 10 već manje

use AdventureWorks2017

go
create view v_Pogled1
as
select top 5 
	sod.SalesOrderID,
	p.FirstName,
	p.LastName,
	CAST(soh.SubTotal as decimal(18,2)) as 'Vrijednost narudžbe'
from Sales.SalesOrderDetail as sod
	inner join Sales.SalesOrderHeader as soh on soh.SalesOrderID = sod.SalesOrderID
	inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
group by sod.SalesOrderID, p.FirstName, p.LastName, soh.SubTotal
order by COUNT(distinct sod.ProductID) desc
go

go
create view v_Pogled2
as
select top 5 
	sod.SalesOrderID, 
	p.FirstName, 
	p.LastName, 
	CAST(soh.SubTotal as decimal(18,2)) as 'Vrijednost narudžbe'
from Sales.SalesOrderDetail as sod 
	inner join Production.Product as pr on sod.ProductID = pr.ProductID
	inner join Production.ProductSubcategory as ps on ps.ProductSubcategoryID = pr.ProductSubcategoryID
	inner join Sales.SalesOrderHeader as soh on soh.SalesOrderID = sod.SalesOrderID
	inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
where sod.SalesOrderID not in
(
	select vp1.SalesOrderID
	from v_Pogled1 as vp1
)
group by sod.SalesOrderID, p.FirstName, p.LastName, soh.SubTotal 
order by COUNT(distinct ps.ProductSubcategoryID) desc
go

--FINALNI UPIT
select *
from v_Pogled1
UNION
select *
from v_Pogled2

--DODATNI ZADATAK SA NEKOG ISPITNOG ROKA
--Prikazati nazive odjela na kojima TRENUTNO radi najmanje, odnosno najviše uposlenika (AdventureWorks2017)

use AdventureWorks2017
go
create view v_Trenutno_Zaposlenih_Po_Odjelu
as
select d.Name, COUNT(*) as 'Broj zaposlenih'
	from HumanResources.Department as d
		inner join HumanResources.EmployeeDepartmentHistory as edh on edh.DepartmentID = d.DepartmentID
		inner join HumanResources.Employee as e on edh.BusinessEntityID = e.BusinessEntityID
	where edh.EndDate is null -- trenutno radi (znači nisu dali/dobili otkaz)
	group by d.Name
go

DECLARE @maxTrenutnoZaposlenih int 
SET @maxTrenutnoZaposlenih = 
	(select MAX(vtz.[Broj zaposlenih])
	from v_Trenutno_Zaposlenih_Po_Odjelu as vtz)

DECLARE @minTrenutnoZaposlenih int 
SET @minTrenutnoZaposlenih = 
	(select MIN(vtz.[Broj zaposlenih])
	from v_Trenutno_Zaposlenih_Po_Odjelu as vtz)

select d.Name, COUNT(*) as 'Broj uposlenika koji trenutno radi'
from HumanResources.Department as d
	inner join HumanResources.EmployeeDepartmentHistory as edh on edh.DepartmentID = d.DepartmentID
	inner join HumanResources.Employee as e on edh.BusinessEntityID = e.BusinessEntityID
where edh.EndDate is null
group by d.Name
having COUNT(*) = @maxTrenutnoZaposlenih or COUNT(*)=@minTrenutnoZaposlenih
