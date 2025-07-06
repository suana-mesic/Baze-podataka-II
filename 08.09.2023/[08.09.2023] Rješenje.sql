--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa. 

create database Ispit_08_09_2023
go
use Ispit_08_09_2023


--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom: 
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Ime, 50 UNICODE karaktera (obavezan unos)
--• Prezime, 50 UNICODE karaktera (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE 

create table Prodavaci
(
	ProdavacID int constraint PK_Prodavaci primary key identity(1,1),
	Ime nvarchar (50) not null,
	Prezime nvarchar (50) not null,
	OpisPosla nvarchar (50) not null,
	EmailAdresa nvarchar (50)
)
--b) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)

create table Proizvodi
(
	ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
	Naziv nvarchar (50) not null,
	SifraProizvoda nvarchar (25) not null,
	Boja  nvarchar (15),
	NazivKategorije  nvarchar (50) not null
)

--c) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• KreditnaKarticaID, cjelobrojna vrijednost
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivGrada, 30 UNICODE (obavezan unos)
--• ProdavacID, cjelobrojna vrijednost i strani ključ
--• NacinIsporuke, 50 UNICODE (obavezan unos)

create table ZaglavljeNarudzbe
(
	NarudzbaID int constraint PK_ZaglavljeNarudzbe primary key identity(1,1),
	DatumNarudzbe datetime not null,
	DatumIsporuke datetime,
	KreditnaKarticaID int,
	ImeKupca nvarchar (50) not null,
	PrezimeKupca nvarchar (50) not null,
	NazivGrada nvarchar (30) not null,
	ProdavacID int constraint FK_ZaglavljeNarudzbe_Prodavaci foreign key references Prodavaci(ProdavacID),
	NacinIsporuke nvarchar (50) not null
)

--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)

--**Jedan proizvod se može više puta naručiti, dok jedna narudžba može sadržavati više proizvoda. 
--U okviru jedne narudžbe jedan proizvod se može naručiti više puta.
--7 bodova
create table DetaljiNarudzbe
(
	DetaljiNarudzbeID int constraint PK_DetaljiNarudzbe primary key identity(1,1),
	NarudzbaID int not null constraint FK_DetaljiNarudzbe_ZaglavljeNarudzbe foreign key references ZaglavljeNarudzbe(NarudzbaID),
	ProizvodID int not null constraint FK_DetaljiNarudzbe_Proizvodi foreign key references Proizvodi(ProizvodID),
	Cijena money not null,
	Kolicina smallint not null,
	Popust money not null,
	OpisSpecijalnePonude nvarchar(255) not null
)

--3a. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Prodavaci dodati :
--• BusinessEntityID (SalesPerson) -> ProdavacID
--• FirstName -> Ime
--• LastName -> Prezime
--• JobTitle (Employee) -> OpisPosla
--• EmailAddress (EmailAddress) -> EmailAdresa

set identity_insert Prodavaci on
insert into Prodavaci(ProdavacID, Ime, Prezime, OpisPosla, EmailAdresa)
select sp.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle, ea.EmailAddress
from AdventureWorks2017.Sales.SalesPerson as sp
	inner join AdventureWorks2017.HumanResources.Employee as e on sp.BusinessEntityID = e.BusinessEntityID
	inner join AdventureWorks2017.Person.Person as p on e.BusinessEntityID = p.BusinessEntityID
	inner join AdventureWorks2017.Person.EmailAddress as ea on ea.BusinessEntityID = p.BusinessEntityID
set identity_insert Prodavaci off

--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--3b) U tabelu Proizvodi dodati sve proizvode
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije

set identity_insert Proizvodi on
insert into Proizvodi(ProizvodID, Naziv, SifraProizvoda, Boja, NazivKategorije)
select p.ProductID, p.Name, p.ProductNumber, p.Color, pc.Name
from AdventureWorks2017.Production.Product as p
	inner join AdventureWorks2017.Production.ProductSubcategory as ps on ps.ProductSubcategoryID = p.ProductSubcategoryID
	inner join AdventureWorks2017.Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
set identity_insert Proizvodi off

--3c) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• CreditCardID -> KreditnaKarticaID
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• City (Address) -> NazivGrada
--• SalesPersonID (SalesOrderHeader) -> ProdavacID
--• Name (ShipMethod) -> NacinIsporuke

set identity_insert ZaglavljeNarudzbe on
insert into ZaglavljeNarudzbe(NarudzbaID, DatumNarudzbe, DatumIsporuke, KreditnaKarticaID, ImeKupca, PrezimeKupca, NazivGrada, ProdavacID, NacinIsporuke)
select soh.SalesOrderID, soh.OrderDate, soh.ShipDate, soh.CreditCardID, p.FirstName, p.LastName, a.City, soh.SalesPersonID, sm.Name
from AdventureWorks2017.Sales.SalesOrderHeader as soh
	inner join AdventureWorks2017.Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join AdventureWorks2017.Person.Person as p on c.PersonID = p.BusinessEntityID
	inner join AdventureWorks2017.Person.Address as a on soh.ShipToAddressID = a.AddressID
	inner join AdventureWorks2017.Purchasing.ShipMethod as sm on soh.ShipMethodID = sm.ShipMethodID
set identity_insert ZaglavljeNarudzbe off

--3d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude

--121317
insert into DetaljiNarudzbe (NarudzbaID, ProizvodID, Cijena, Kolicina, Popust, OpisSpecijalnePonude)
select sod.SalesOrderID, sod.ProductID, sod.UnitPrice, sod.OrderQty, sod.UnitPriceDiscount, so.Description
from AdventureWorks2017.Sales.SalesOrderDetail as sod
	inner join AdventureWorks2017.Sales.SpecialOfferProduct as sop on sop.SpecialOfferID = sod.SpecialOfferID and sop.ProductID = sod.ProductID
	inner join AdventureWorks2017.Sales.SpecialOffer as so on sop.SpecialOfferID = so.SpecialOfferID

--4.
--a)(6 bodova) kreirati pogled v_detalji gdje je korisniku potrebno prikazati --identifikacijski broj narudzbe,
--spojeno ime i prezime kupca, grad isporuke, ukupna vrijednost narudzbe sa popustom i- -bez popusta, te u dodatnom polju informacija da li je narudzba placena karticom --("Placeno karticom" ili "Nije placeno karticom").
--Rezultate sortirati prema vrijednosti narudzbe sa popustom u opadajucem redoslijedu.
--OBAVEZNO kreirati testni slucaj.(Novokreirana baza)

use Ispit_08_09_2023
go
create view v_detalji
as
	select 
		zn.NarudzbaID
		,CONCAT(zn.ImeKupca,' ',zn.PrezimeKupca) as 'Ime i prezime kupca'
		,zn.NazivGrada
		,SUM(dn.Cijena*dn.Kolicina*(1-dn.Popust)) as 'Vrijednost narudžbe sa popustom'
		,SUM(dn.Cijena*dn.Kolicina) as 'Vrijednost narudžbe bez popusta'
		,IIF(zn.KreditnaKarticaID is null, 'Nije plaćeno karticom','PLaćeno karticom') as 'Plaćanje'
	from DetaljiNarudzbe as dn
		inner join ZaglavljeNarudzbe as zn on dn.NarudzbaID = zn.NarudzbaID
	group by zn.NarudzbaID, CONCAT(zn.ImeKupca,' ',zn.PrezimeKupca), zn.NazivGrada, IIF(zn.KreditnaKarticaID is null, 'Nije plaćeno karticom','PLaćeno karticom')
go

select *
from v_detalji
order by [Vrijednost narudžbe sa popustom] desc


--b)( 4 bodova) U kreiranoj bazi kreirati wproceduru sp_insert_ZaglavljeNarudzbe kojom- -ce se omoguciti kreiranje nove narudzbe. OBAVEZNO kreirati testni slucaj.--(Novokreirana baza).

go
create procedure sp_insert_ZaglavljeNarudzbe
(
	@DatumNarudzbe datetime,
	@DatumIsporuke datetime = null,
	@KreditnaKarticaID int = null,
	@ImeKupca nvarchar (50),
	@PrezimeKupca nvarchar (50),
	@NazivGrada nvarchar (30),
	@ProdavacID int = null,
	@NacinIsporuke nvarchar (50)
)
as begin
	insert into ZaglavljeNarudzbe
	values (@DatumNarudzbe, @DatumIsporuke, @KreditnaKarticaID, @ImeKupca, @PrezimeKupca, @NazivGrada, @ProdavacID, @NacinIsporuke)
end
go


exec sp_insert_ZaglavljeNarudzbe @DatumNarudzbe='2025-06-17', @ImeKupca='Ime 1', @PrezimeKupca='Prezime 1',@NazivGrada='Mostar', @NacinIsporuke='/'

select * from ZaglavljeNarudzbe

--c)(6 bodova) Kreirati upit kojim ce se prikazati ukupan broj proizvoda po kategorijama. Uslov je da se prikazu samo one kategorije kojima ne pripada vise od 30 proizvoda, a sadrze broj u bilo kojoj od rijeci i ne nalaze se u prodaji.--(AdventureWorks2017)

use AdventureWorks2017

select pc.Name, COUNT(*) as 'Broj proizvoda'
from Production.Product as p
	inner join Production.ProductSubcategory as ps on ps.ProductSubcategoryID = p.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where p.SellEndDate is not null and p.Name like '%[0-9]%'
group by pc.Name
having COUNT(*)<=30

--d)(7 bodova) Kreirati upit koji ce prikazati uposlenike koji imaju iskustva (radilli su na jednom odjelu) a trenutno rade na marketing ili odjelu za nabavku. Osobama po prestanku rada na odjelu se upise podatak datuma prestanka rada.
--Rezultat upita treba prikazati ime i prezime uposlenika, odjel na kojem rade.
--(AdventureWorks2017)

use AdventureWorks2017

select 
	CONCAT(p.FirstName, ' ', p.LastName) as 'Ime i prezime uposlenika'
	,d.Name as 'Odjel'
from HumanResources.Employee as e
	inner join HumanResources.EmployeeDepartmentHistory as edh on edh.BusinessEntityID = e.BusinessEntityID
	inner join Person.Person as p on e.BusinessEntityID = p.BusinessEntityID
	inner join HumanResources.Department as d on edh.DepartmentID = d.DepartmentID
where 
	d.Name in ('Marketing','Purchasing') and
	edh.EndDate is null and 
	CONCAT(p.FirstName, ' ', p.LastName) in --Radili su na minimalno jednom odjelu prije odjela marketinga ili nabavke
	(
		select CONCAT(p.FirstName, ' ', p.LastName) as 'Ime i prezime uposlenika'
		from HumanResources.Employee as e
			inner join HumanResources.EmployeeDepartmentHistory as edh on edh.BusinessEntityID = e.BusinessEntityID
			inner join Person.Person as p on e.BusinessEntityID = p.BusinessEntityID
		where edh.EndDate is not null
		group by CONCAT(p.FirstName, ' ', p.LastName)
		having COUNT(*)>=1
	)

--e)(7 bodova) 
--Kreirati upit kojim ce se prikazati proizvod koji je najvise dana bio u prodaji (njegova prodaja je prestala) a pripada kategoriji bicikala. Proizvodu se pocetkom i po prestanku prodaje biljezi datum.
--Ukoliko postoji vise proizvoda sa istim vremenskim periodom kao i prvi prikazati ih u rezultatima upita.(AdventureWorks2017)

use AdventureWorks2017

select top 1 with ties p.Name
from Production.Product as p
	inner join AdventureWorks2017.Production.ProductSubcategory as ps on ps.ProductSubcategoryID = p.ProductSubcategoryID
	inner join AdventureWorks2017.Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where pc.Name like 'Bikes' and p.SellEndDate is not null --prodaja mu je prestala
order by DATEDIFF(DAY, p.SellStartDate, p.SellEndDate) desc

--5.)
--
--a) (9 bodova) Prikazati nazive odjela na kojima TRENUTNO radi najmanje, odnosno najvise uposlenika (AdventureWorks2017)

use AdventureWorks2017
select *
from
(
	select top 1 d.Name
	from HumanResources.EmployeeDepartmentHistory as edh
		inner join HumanResources.Department as d on edh.DepartmentID = d.DepartmentID
	where edh.EndDate is null
	group by d.Name
	order by COUNT(*)
) as podq
UNION
select *
from
(
	select top 1 d.Name
	from HumanResources.EmployeeDepartmentHistory as edh
		inner join HumanResources.Department as d on edh.DepartmentID = d.DepartmentID
	where edh.EndDate is null
	group by d.Name
	order by COUNT(*) desc
) as podq2

--b)(10 bodova) Kreirati upit kojim ce se prikazati ukupan broj obradjenih narudzbi i ukupna vrijednost narudzbi sa popustom za svakog uposlenika pojedinacno, i to od zadnje 30% kreiranih datumski kreiranih narudzbi.
--Rezultate sortirati prema ukupnoj vrijednosti u opadajucem redoslijedu.(AdventureWorks2017)

use AdventureWorks2017

--17 zapisa
select 
	CONCAT(p.FirstName, ' ', p.LastName) as 'Ime i prezime uposlenika'
	,COUNT(*) as 'Broj obrađenih narudžbi'
	,SUM(soh.SubTotal) as 'Vrijednost narudžbi sa popustom'
from Sales.SalesOrderHeader as soh
	inner join Sales.SalesPerson as sp on soh.SalesPersonID = sp.BusinessEntityID
	inner join Person.Person as p on sp.BusinessEntityID = p.BusinessEntityID
where soh.SalesOrderID in 
(
	select top 30 percent soh.SalesOrderID
	from Sales.SalesOrderHeader as soh
	order by soh.OrderDate desc
)
group by CONCAT(p.FirstName, ' ', p.LastName)
order by 3 desc

--f)(12 bodova) Upitom prikazati id autora, ime i prezime, napisano djelo i šifra. 
--Prikazati samo one zapise gdje adresa autora pocinje sa ISKLJUCIVO 2 broja (Pubs)
--Šifra se sastoji od sljedeći vrijednosti: 
--	1.Prezime po pravilu (prezime od 6 karaktera -> uzeti prva 4 karaktera; prezime -od- 10 karaktera-> uzeti prva 6 karaktera, za sve ostale slucajeve uzeti prva dva --karaktera)
--	2.Ime prva 2 karaktera
--	3.Karakter /
--	4.Zip po pravilu( 2 karaktera sa desne strane ukoliko je zadnja cifra u opsegu --0-5; u suprotnom 2 karaktera sa lijeve strane)
--	5.Karakter /
--	6.State(obrnuta vrijednost)
--	7.Phone(brojevi između space i karaktera -)
--	Primjer : za autora sa id-om 486-29-1786 šifra je LoCh/30/AC585
--			  za autora sa id-om 998-72-3567 šifra je RingAl/52/TU826

use pubs
select a.au_id, a.au_fname, a.au_lname, t.title, a.address,
	CONCAT
	(
	IIF(
		LEN(a.au_lname)=6,
		LEFT(a.au_lname,4),
		IIF(
			LEN(a.au_lname)=10,
			LEFT(a.au_lname,6),
			LEFT(a.au_lname,2)
			)
		),
	LEFT(a.au_fname,2),
	'/',
	IIF(
		RIGHT(a.zip,1)like'[0-5]',
		RIGHT(a.zip,2),
		LEFT(a.zip,2)
		),
	'/',
	REVERSE(a.state),
	SUBSTRING(a.phone, CHARINDEX(' ',a.phone,1)+1,CHARINDEX('-',a.phone,1)-CHARINDEX(' ',a.phone,1)-1)
	) as 'Šifra'
from authors as a
	inner join titleauthor as ta on ta.au_id = a.au_id
	inner join titles as t on ta.title_id = t.title_id
where a.address like '[0-9][0-9][^0-9]%' --adresa počinje sa 2 broja, a nastavlja se sa bilo čime što nije broj
										--adresa ne može početi sa 3 broja, jer je napisano da mora početi sa isključivo 2 broja



