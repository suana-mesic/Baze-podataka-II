--4. b), c) prepisati u word
--Ispitni zadatak 29.06.2022 moje rješenje rađeno 17.05.2025.

--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
create database IB230022_Ispit_29_06_2022
go
use IB230022_Ispit_29_06_2022

---------------------------------------------------------------------------------------------------------------------

--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)
--• Tezina, decimalna vrijednost sa 2 znaka iza zareza

create table Proizvodi
(
ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
Naziv nvarchar(50) not null,
SifraProizvoda nvarchar(25) not null,
Boja nvarchar(15),
NazivKategorije nvarchar(50) not null,
Tezina decimal(18,2)
)

--b) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivTeritorije, 50 UNICODE (obavezan unos)
--• NazivRegije, 50 UNICODE (obavezan unos)
--• NacinIsporuke, 50 UNICODE (obavezan unos)

create table ZaglavljeNarudzbe
(
	NarudzbaID int constraint PK_ZaglavljeNarudzbe primary key identity(1,1),
	DatumNarudzbe datetime not null,
	DatumIsporuke datetime,
	ImeKupca nvarchar(50) not null,
	PrezimeKupca nvarchar(50) not null,
	NazivTeritorije nvarchar(50) not null,
	NazivRegije nvarchar(50) not null,
	NacinIsporuke nvarchar(50) not null
)

--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
--**Jedan proizvod se može više puta naručiti, dok jedna narudžba može sadržavati više proizvoda. U okviru jedne
--narudžbe jedan proizvod se može naručiti više puta.

create table DetaljiNarudzbe
(
	NarudzbaID int not null constraint FK_DetaljiNarudzbe_ZaglavljeNarudzbe foreign key references ZaglavljeNarudzbe(NarudzbaID),
	ProizvodID int not null constraint FK_DetaljiNarudzbe_Proizvodi foreign key references Proizvodi(ProizvodID),
	Cijena money not null,
	Kolicina smallint not null,
	Popust money not null,
	DetaljiNarudzbeID int constraint PK_DetaljiNarudzbe primary key identity(1,1),
)

---------------------------------------------------------------------------------------------------------------------

--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Proizvodi dodati sve proizvode, na mjestima gdje nema pohranjenih podataka o težini
--zamijeniti vrijednost sa 0
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije
--• Weight -> Tezina

use IB230022_Ispit_29_06_2022

--295 zapisa
set identity_insert Proizvodi on
insert into Proizvodi (ProizvodID, Naziv, SifraProizvoda, Boja,	NazivKategorije, Tezina)
select p.ProductID, p.Name, p.ProductNumber, p.Color, pc.Name, ISNULL(p.Weight,0)
from AdventureWorks2017.Production.Product as p
	inner join AdventureWorks2017.Production.ProductSubcategory as ps on ps.ProductSubcategoryID = p.ProductSubcategoryID
	inner join AdventureWorks2017.Production.ProductCategory as pc on pc.ProductCategoryID = ps.ProductCategoryID
set identity_insert Proizvodi off

--b) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• Name (SalesTerritory) -> NazivTeritorije
--• Group (SalesTerritory) -> NazivRegije
--• Name (ShipMethod) -> NacinIsporuke

--31465
set identity_insert ZaglavljeNarudzbe on
insert into ZaglavljeNarudzbe  (NarudzbaID, DatumNarudzbe, DatumIsporuke, ImeKupca, PrezimeKupca, NazivTeritorije, NazivRegije, NacinIsporuke)
select
	soh.SalesOrderID,
	soh.OrderDate,
	soh.ShipDate,
	p.FirstName,
	p.LastName,
	st.Name,
	st.[Group],
	sm.Name
from AdventureWorks2017.Sales.SalesOrderHeader as soh
	inner join AdventureWorks2017.Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join AdventureWorks2017.Person.Person as p on c.PersonID = p.BusinessEntityID
	inner join AdventureWorks2017.Sales.SalesTerritory as st on soh.TerritoryID = st.TerritoryID
	inner join AdventureWorks2017.Purchasing.ShipMethod as sm on soh.ShipMethodID = sm.ShipMethodID
set identity_insert ZaglavljeNarudzbe off

--c) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust

--121317
insert into DetaljiNarudzbe(NarudzbaID, ProizvodID, Cijena, Kolicina, Popust)
select sod.SalesOrderID, sod.ProductID, sod.UnitPrice, sod.OrderQty, sod.UnitPriceDiscount
from AdventureWorks2017.Sales.SalesOrderDetail as sod

------------------------------------------------------------------------------------------------------------
--4.
--a) (6 bodova) Kreirati upit koji će prikazati ukupan broj uposlenika po odjelima. Potrebno je prebrojati
--samo one uposlenike koji su trenutno aktivni, odnosno rade na datom odjelu. Također, samo uzeti u obzir
--one uposlenike koji imaju više od 10 godina radnog staža (ne uključujući graničnu vrijednost).
--Rezultate sortirati preba broju uposlenika u opadajućem redoslijedu. (AdventureWorks2017)use AdventureWorks2017 select d.Name, COUNT(*) as 'Broj aktivnih uposlenika'from HumanResources.Employee as e	inner join HumanResources.EmployeeDepartmentHistory as edh on edh.BusinessEntityID = e.BusinessEntityID	inner join HumanResources.Department as d on edh.DepartmentID = d.DepartmentIDwhere edh.EndDate IS NULL and DATEDIFF(YEAR, e.HireDate, GETDATE())>10group by d.Nameorder by 2 desc--b) (10 bodova) Kreirati upit koji prikazuje po mjesecima ukupnu vrijednost poručene robe za skladište, te
--ukupnu količinu primljene robe, isključivo u 2012 godini. Uslov je da su troškovi prevoza bili između
--500 i 2500, a da je dostava izvršena CARGO transportom. Također u rezultatima upita je potrebno
--prebrojati stavke narudžbe na kojima je odbijena količina veća od 100. (AdventureWorks2017)

use AdventureWorks2017

select
	MONTH(poh.OrderDate) as 'Mjesec',
	SUM(pod.UnitPrice*pod.OrderQty) as 'Ukupna poručena vrijednost',
	SUM(pod.ReceivedQty) as 'Ukupno primljene robe',
	SUM(IIF(pod.RejectedQty>100,1,0)) as 'Broj stavki koje su odbijene'
from Purchasing.PurchaseOrderDetail as pod
	inner join Purchasing.PurchaseOrderHeader as poh on poh.PurchaseOrderID = pod.PurchaseOrderID
	inner join Purchasing.ShipMethod as sm on poh.ShipMethodID = sm.ShipMethodID
where
	YEAR(poh.OrderDate) = 2012 and 
	(poh.Freight between 500 and 2500) and 
	lower(sm.Name) like '%cargo%' 
group by MONTH(poh.OrderDate)


--c) (10 bodova) Prikazati ukupan broj narudžbi koje su obradili uposlenici, za svakog uposlenika
--pojedinačno. Uslov je da su narudžbe kreirane u 2011 ili 2012 godini, te da je u okviru jedne narudžbe
--odobren popust na dvije ili više stavki. Također uzeti u obzir samo one narudžbe koje su isporučene u
--Veliku Britaniju, Kanadu ili Francusku. (AdventureWorks2017)

use AdventureWorks2017

select 
	CONCAT(p.FirstName, ' ', p.LastName) as 'Uposlenik', 
	COUNT(*) as 'Broj narudžbi'
from Sales.SalesPerson as sp
	inner join Person.Person as p on sp.BusinessEntityID = p.BusinessEntityID
	inner join Sales.SalesOrderHeader as soh on soh.SalesPersonID = sp.BusinessEntityID
	inner join Person.Address as a on soh.ShipToAddressID = a.AddressID
	inner join Person.StateProvince as stp on a.StateProvinceID = stp.StateProvinceID
	inner join Sales.SalesTerritory as st on stp.TerritoryID = st.TerritoryID
where 
	YEAR(soh.OrderDate) in (2011, 2012) and  
	st.Name in ('Canada', 'France', 'United Kingdom') and
	soh.SalesOrderID in
		(
			select distinct soh2.SalesOrderID
			from Sales.SalesOrderHeader as soh2
				inner join Sales.SalesOrderDetail as sod2 on sod2.SalesOrderID = soh2.SalesOrderID
			where sod2.UnitPriceDiscount > 0
			group by  soh2.SalesOrderID
			having COUNT(*)>=2
		)
group by CONCAT(p.FirstName, ' ', p.LastName)

--José Saraiva	6, 6 narudžbi koje su po datim kriterijima
--Provjera

select soh.SalesOrderID
from Sales.SalesPerson as sp
	inner join Person.Person as p on sp.BusinessEntityID = p.BusinessEntityID
	inner join Sales.SalesOrderHeader as soh on soh.SalesPersonID = sp.BusinessEntityID
	inner join Sales.SalesTerritory as st on soh.TerritoryID = st.TerritoryID
where 
	p.LastName like 'Saraiva' and 
	YEAR(soh.OrderDate) in (2011,2012) and
	st.Name in ('Canada', 'France', 'United Kingdom')
INTERSECT
select soh.SalesOrderID
from Sales.SalesOrderHeader as soh
	inner join Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
where sod.UnitPriceDiscount > 0
group by soh.SalesOrderID
having COUNT(*)>=2

--d) (11 bodova) Napisati upit koji će prikazati sljedeće podatke o proizvodima: naziv proizvoda, naziv
--kompanije dobavljača, količinu na skladištu, te kreiranu šifru proizvoda. Šifra se sastoji od sljedećih
--vrijednosti: (Northwind)
--1) Prva dva slova naziva proizvoda
--2) Karakter /
--3) Prva dva slova druge riječi naziva kompanije dobavljača, uzeti u obzir one kompanije koje u
--nazivu imaju 2 ili 3 riječi
--4) ID proizvoda, po pravilu ukoliko se radi o jednocifrenom broju na njega dodati slovo 'a', u
--suprotnom uzeti obrnutu vrijednost broja
--Npr. Za proizvod sa nazivom Chai i sa dobavljačem naziva Exotic Liquids, šifra će btiti Ch/Li1a.use Northwindselect 	p.ProductName,	s.CompanyName, 	p.UnitsInStock,	ProductID,	CONCAT(	LEFT(p.ProductName,2),'/', 	SUBSTRING(S.CompanyName, CHARINDEX(' ', S.CompanyName)+1, 2), 	IIF(p.ProductID<10, CONCAT(p.ProductID, 'a'),REVERSE (p.ProductID))	)from Products as p	inner join Suppliers as s on p.SupplierID = s.SupplierIDwhere ABS(LEN(s.CompanyName)-LEN(REPLACE(S.CompanyName,' ',''))) in (1,2)-----------------------------------------------------------------------------------------------------------------------------

--5.
--a) (3 boda) U kreiranoj bazi kreirati index kojim će se ubrzati pretraga prema šifri i nazivu proizvoda.
--Napisati upit za potpuno iskorištenje indexa.

use IB230022_Ispit_29_06_2022
create index IX_Proizvodi_SifraProizvoda_Naziv
on Proizvodi(SifraProizvoda, Naziv)

select Naziv, SifraProizvoda
from Proizvodi
where Naziv like '%a%'

--b) (7 bodova) U kreiranoj bazi kreirati proceduru sp_search_products kojom će se vratiti podaci o
--proizvodima na osnovu kategorije kojoj pripadaju ili težini. Korisnici ne moraju unijeti niti jedan od
--parametara ali u tom slučaju procedura ne vraća niti jedan od zapisa. Korisnicima unosom već prvog
--slova kategorije se trebaju osvježiti zapisi, a vrijednost unesenog parametra težina će vratiti one
--proizvode čija težina je veća od unesene vrijednosti.

use IB230022_Ispit_29_06_2022
go
create procedure sp_search_products
	(
		@NazivKategorije nvarchar(50) = null,
		@Tezina decimal(18,2) = null
	)
as
begin
	select *
	from Proizvodi as p
	where p.NazivKategorije like @NazivKategorije + '%' or p.Tezina>@Tezina
end
go

EXEC sp_search_products @NazivKategorije = 'B'
EXEC sp_search_products

--c) (18 bodova) Zbog proglašenja dobitnika nagradne igre održane u prva dva mjeseca drugog kvartala 2013
--godine potrebno je kreirati upit. Upitom će se prikazati treća najveća narudžba (vrijednost bez popusta)
--za svaki mjesec pojedinačno. Obzirom da je u pravilima nagradne igre potrebno nagraditi 2 osobe
--(muškarca i ženu) za svaki mjesec, potrebno je u rezultatima upita prikazati pored navedenih stavki i o
--kojem se kupcu radi odnosno ime i prezime, te koju je nagradu osvojio. Nagrade se dodjeljuju po
--sljedećem pravilu:
--• za žene u prvom mjesecu drugog kvartala je stoni mikser, dok je za muškarce usisivač
--• za žene u drugom mjesecu drugog kvartala je pegla, dok je za muškarc multicooker
--Obzirom da za kupce nije eksplicitno naveden spol, određivat će se po pravilu: Ako je zadnje slovo imena
--a, smatra se da je osoba ženskog spola u suprotnom radi se o osobi muškog spola. Rezultate u formiranoj 
--tabeli dobitnika sortirati prema vrijednosti narudžbe u opadajućem redoslijedu. (AdventureWorks2017)

use AdventureWorks2017

select podq.Mjesec, podq.[Ime i prezime], podq.[Vrijednost narudžbe], podq.Nagrada
from
(
	select
		MONTH(soh.OrderDate) as 'Mjesec',
		CONCAT(p.FirstName, ' ',p.LastName) as 'Ime i prezime', 
		SUM(sod.UnitPrice * sod.OrderQty) as 'Vrijednost narudžbe',
		ROW_NUMBER() OVER( order by SUM(sod.UnitPrice * sod.OrderQty) desc) as 'RowDesc',
		'Stoni mikser' as 'Nagrada'
	from Sales.SalesOrderHeader as soh
		inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
		inner join Person.Person as p on c.PersonID = p.BusinessEntityID
		inner join Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
	where YEAR(soh.OrderDate)=2013 and MONTH(soh.OrderDate)=4  and RIGHT(p.FirstName, 1) like 'a'
	group by CONCAT(p.FirstName, ' ',p.LastName), MONTH(soh.OrderDate)
) as podq	
where podq.RowDesc = 3
UNION 
select podq.Mjesec, podq.[Ime i prezime], podq.[Vrijednost narudžbe], podq.Nagrada
from
(
	select
		MONTH(soh.OrderDate) as 'Mjesec',
		CONCAT(p.FirstName, ' ',p.LastName) as 'Ime i prezime', 
		SUM(sod.UnitPrice * sod.OrderQty) as 'Vrijednost narudžbe',
		ROW_NUMBER() OVER( order by SUM(sod.UnitPrice * sod.OrderQty) desc) as 'RowDesc',
		'Usisivač' as 'Nagrada'
	from Sales.SalesOrderHeader as soh
		inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
		inner join Person.Person as p on c.PersonID = p.BusinessEntityID
		inner join Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
	where YEAR(soh.OrderDate)=2013 and MONTH(soh.OrderDate)=4  and RIGHT(p.FirstName, 1) not like 'a'
	group by CONCAT(p.FirstName, ' ',p.LastName), MONTH(soh.OrderDate)
) as podq	
where podq.RowDesc = 3
UNION 
select podq.Mjesec, podq.[Ime i prezime], podq.[Vrijednost narudžbe], podq.Nagrada
from
(
	select
		MONTH(soh.OrderDate) as 'Mjesec',
		CONCAT(p.FirstName, ' ',p.LastName) as 'Ime i prezime', 
		SUM(sod.UnitPrice * sod.OrderQty) as 'Vrijednost narudžbe',
		ROW_NUMBER() OVER( order by SUM(sod.UnitPrice * sod.OrderQty) desc) as 'RowDesc',
		'Pegla' as 'Nagrada'
	from Sales.SalesOrderHeader as soh
		inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
		inner join Person.Person as p on c.PersonID = p.BusinessEntityID
		inner join Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
	where YEAR(soh.OrderDate)=2013 and MONTH(soh.OrderDate)=5  and RIGHT(p.FirstName, 1) like 'a'
	group by CONCAT(p.FirstName, ' ',p.LastName), MONTH(soh.OrderDate)
) as podq	
where podq.RowDesc = 3
UNION
select podq.Mjesec, podq.[Ime i prezime], podq.[Vrijednost narudžbe], podq.Nagrada
from
(
	select
		MONTH(soh.OrderDate) as 'Mjesec',
		CONCAT(p.FirstName, ' ',p.LastName) as 'Ime i prezime', 
		SUM(sod.UnitPrice * sod.OrderQty) as 'Vrijednost narudžbe',
		ROW_NUMBER() OVER( order by SUM(sod.UnitPrice * sod.OrderQty) desc) as 'RowDesc',
		'Multicooker' as 'Nagrada'
	from Sales.SalesOrderHeader as soh
		inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
		inner join Person.Person as p on c.PersonID = p.BusinessEntityID
		inner join Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
	where YEAR(soh.OrderDate)=2013 and MONTH(soh.OrderDate)=5  and RIGHT(p.FirstName, 1) not like 'a'
	group by CONCAT(p.FirstName, ' ',p.LastName), MONTH(soh.OrderDate)
) as podq	
where podq.RowDesc = 3
order by 3 desc
