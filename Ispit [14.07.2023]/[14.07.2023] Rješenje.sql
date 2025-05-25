--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

create database Ispit_14_07_2023
go
use Ispit_14_07_2023


--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Ime, 50 UNICODE (obavezan unos)
--• Prezime, 50 UNICODE (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE karaktera

create table Prodavaci
(
	ProdavacID int constraint PK_Prodavaci primary key identity(1,1),
	Ime nvarchar(50) not null,
	Prezime nvarchar(50) not null,
	OpisPosla nvarchar(50) not null,
	EmailAdresa nvarchar(50)
)

--b) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivPodkategorije, 50 UNICODE (obavezan unos)

create table Proizvodi
(
	ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
	Naziv nvarchar(50) not null,
	SifraProizvoda nvarchar(25) not null,
	Boja nvarchar(15),
	NazivPodkategorije nvarchar(50) not null
)

--c) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• KreditnaKarticaID, cjelobrojna vrijednost
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivGradaIsporuke, 30 UNICODE (obavezan unos)
--• ProdavacID, cjelobrojna vrijednost, strani ključ
--• NacinIsporuke, 50 UNICODE (obavezan unos)

create table ZaglavljeNarudzbe
(
	NarudzbaID int constraint PK_ZaglavljeNarudzbe primary key identity(1,1),
	DatumNarudzbe datetime not null,
	DatumIsporuke datetime, 
	KreditnaKarticaID int,
	ImeKupca nvarchar(50) not null,
	PrezimeKupca nvarchar(50) not null,
	NazivGradaIsporuke nvarchar(30) not null,
	ProdavacID int constraint FK_ZaglavljeNarudzbe_Prodavaci foreign key references Prodavaci(ProdavacID),
	NacinIsporuke nvarchar(50) not null
)

--d) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)
--**Jedan proizvod se može više puta naručiti, dok jedna narudžba može sadržavati više proizvoda. U okviru jedne
--narudžbe jedan proizvod se može naručiti više puta.


create table DetaljiNarudzbe
(
	DetaljiNarudzbeID int constraint PK_DetaljiNarudzbe primary key identity(1,1),
	NarudzbaID int not null constraint FK_DetaljiNarudzbe_ZaglavljeNarudzbe foreign key references ZaglavljeNarudzbe(NarudzbaID),
	ProizvodID  int not null constraint FK_DetaljiNarudzbe_Proizvodi foreign key references Proizvodi(ProizvodID),
	Cijena money not null,
	Kolicina smallint not null,
	Popust money not null,
	OpisSpecijalnePonude nvarchar(255) not null,
)

--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Prodavaci dodati sve prodavače
--• BusinessEntityID (SalesPerson) -> ProdavacID
--• FirstName (Person) -> Ime
--• LastName (Person) -> Prezime
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

--b) U tabelu Proizvodi dodati sve proizvode
--• ProductID (Product)-> ProizvodID
--• Name (Product)-> Naziv
--• ProductNumber (Product)-> SifraProizvoda
--• Color (Product)-> Boja
--• Name (ProductSubategory) -> NazivPodkategorije


set identity_insert Proizvodi on
insert into Proizvodi(ProizvodID, Naziv, SifraProizvoda, Boja, NazivPodkategorije)
select p.ProductID, p.Name, p.ProductNumber, p.Color, ps.Name
from AdventureWorks2017.Production.Product as p
	inner join AdventureWorks2017.Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
set identity_insert Proizvodi off

--c) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID (SalesOrderHeader) -> NarudzbaID
--• OrderDate (SalesOrderHeader)-> DatumNarudzbe
--• ShipDate (SalesOrderHeader)-> DatumIsporuke
--• CreditCardID(SalesOrderID)-> KreditnaKarticaID
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• City (Address) -> NazivGradaIsporuke
--• SalesPersonID (SalesOrderHeader)-> ProdavacID
--• Name (ShipMethod)-> NacinIsporuke

set identity_insert ZaglavljeNarudzbe on
insert into ZaglavljeNarudzbe(NarudzbaID, DatumNarudzbe, DatumIsporuke, KreditnaKarticaID, ImeKupca, PrezimeKupca, NazivGradaIsporuke, ProdavacID, NacinIsporuke)
select soh.SalesOrderID, soh.OrderDate, soh.ShipDate, soh.CreditCardID, p.FirstName, p.LastName, a.City, soh.SalesPersonID, sm.Name
from AdventureWorks2017.Sales.SalesOrderHeader as soh
	inner join AdventureWorks2017.Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join AdventureWorks2017.Person.Person as p on c.PersonID = p.BusinessEntityID
	inner join AdventureWorks2017.Person.Address as a on soh.ShipToAddressID = a.AddressID
	inner join AdventureWorks2017.Purchasing.ShipMethod as sm on soh.ShipMethodID = sm.ShipMethodID
set identity_insert ZaglavljeNarudzbe off


--d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID (SalesOrderDetail)-> NarudzbaID
--• ProductID (SalesOrderDetail)-> ProizvodID
--• UnitPrice (SalesOrderDetail)-> Cijena
--• OrderQty (SalesOrderDetail)-> Kolicina
--• UnitPriceDiscount (SalesOrderDetail)-> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude


--121317 zapisa
insert into DetaljiNarudzbe(NarudzbaID, ProizvodID, Cijena, Kolicina, Popust, OpisSpecijalnePonude)
select sod.SalesOrderID, sod.ProductID, sod.UnitPrice, sod.OrderQty, sod.UnitPriceDiscount, so.[Description]
from AdventureWorks2017.Sales.SalesOrderDetail as sod
	inner join AdventureWorks2017.Sales.SpecialOfferProduct as sop on sop.ProductID = sod.ProductID and sod.SpecialOfferID = sop.SpecialOfferID
	inner join AdventureWorks2017.Sales.SpecialOffer as so on sop.SpecialOfferID = so.SpecialOfferID


--4.
--a) (6 bodova) Kreirati funkciju f_detalji u formi tabele gdje korisniku slanjem parametra identifikacijski
--broj narudžbe će biti ispisano spojeno ime i prezime kupca, grad isporuke, ukupna vrijednost narudžbe
--sa popustom, te poruka da li je narudžba plaćena karticom ili ne. Korisnik može dobiti 2 poruke „Plaćeno
--karticom“ ili „Nije plaćeno karticom“.
--OBAVEZNO kreirati testni slučaj. (Novokreirana baza)

go
create function f_detalji(@NarudzbaID int)
returns table
as
return 
	(
	select
		CONCAT(zn.ImeKupca, ' ', zn.PrezimeKupca) as 'Ime i prezime kupca',
		zn.NazivGradaIsporuke,
		CAST(SUM(dn.Cijena * dn.Kolicina*(1-dn.Popust)) as decimal(18,2)) as 'Vrijednost narudžbe sa popustom',
		IIF(zn.KreditnaKarticaID is null, 'Nije plaćena karticom', 'Plaćena karticom') as 'Kartica da/ne'
	from ZaglavljeNarudzbe as zn
		inner join DetaljiNarudzbe as dn on dn.NarudzbaID = zn.NarudzbaID
	where zn.NarudzbaID = @NarudzbaID
	group by CONCAT(zn.ImeKupca, ' ', zn.PrezimeKupca), zn.NazivGradaIsporuke, zn.KreditnaKarticaID
	)
go

select zn.ImeKupca, zn.PrezimeKupca, zn.NazivGradaIsporuke, CAST(SUM(dn.Cijena * dn.Kolicina*(1-dn.Popust)) as decimal(18,2)), zn.KreditnaKarticaID
from ZaglavljeNarudzbe as zn
inner join DetaljiNarudzbe as dn on dn.NarudzbaID = zn.NarudzbaID
where zn.KreditnaKarticaID is null and zn.NarudzbaID = 43737
group by zn.ImeKupca, zn.PrezimeKupca, zn.KreditnaKarticaID, zn.NazivGradaIsporuke

--Lindsey	Andersen	Paderborn	1055589.65	Nije plaćena karticom

--Lindsey Andersen	Paderborn	1055589.65	Nije plaćena karticom
select *
from f_detalji(43737)

--b) (4 bodova) U kreiranoj bazi kreirati proceduru sp_insert_DetaljiNarudzbe kojom će se omogućiti insert
--nove stavke narudžbe. OBAVEZNO kreirati testni slučaj. (Novokreirana baza)

go
create or alter procedure sp_insert_DetaljiNarudzbe
(
	@NarudzbaID int,
	@ProizvodID  int,
	@Cijena money,
	@Kolicina smallint,
	@Popust money,
	@OpisSpecijalnePonude nvarchar(255)
)
as
begin
	insert into DetaljiNarudzbe (NarudzbaID, ProizvodID, Cijena, Kolicina, Popust, OpisSpecijalnePonude)
	values (@NarudzbaID, @ProizvodID, @Cijena, @Kolicina, @Popust, @OpisSpecijalnePonude)
end
go

exec sp_insert_DetaljiNarudzbe @NarudzbaID = 43659, @ProizvodID=680, @Cijena=10.0 , @Kolicina=2 ,  @Popust= 0, @OpisSpecijalnePonude ='No Discount'

use Ispit_14_7_2023
select * from DetaljiNarudzbe
where NarudzbaID = 43659

select * from Proizvodi


--c) (6 bodova) Kreirati upit kojim će se prikazati ukupan broj proizvoda po kategorijama. Korisnicima se
--treba ispisati o kojoj kategoriji se radi. Uslov je da se prikažu samo one kategorije kojima pripada više
--od 30 proizvoda, te da nazivi proizvoda se sastoje od 3 riječi, a sadrže broj u bilo kojoj od riječi i još
--uvijek se nalaze u prodaji. Također, ukupan broj proizvoda po kategorijama mora biti veći od 50.
--(AdventureWorks2017)

use AdventureWorks2017
select 
	pc.ProductCategoryID,
	pc.Name, 
	COUNT(*) AS 'Broj proizvoda'
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where ABS(LEN(p.Name)-LEN(REPLACE(p.Name, ' ', '')))=2 and p.Name like '%[0-9]%' and p.SellEndDate is null
group by pc.ProductCategoryID, pc.Name
having COUNT(*)>30

--d) (7 bodova) Za potrebe menadžmenta kompanije potrebno je kreirati upit kojim će se prikazati proizvodi
--koji trenutno nisu u prodaji i ne pripada kategoriji bicikala, kako bi ih ponovno vratili u prodaju.
--Proizvodu se početkom i po prestanku prodaje zabilježi datum. Osnovni uslov za ponovno povlačenje u
--prodaju je to da je ukupna prodana količina za svaki proizvod pojedinačno bila veća od 200 komada.
--Kao rezultat upita očekuju se podaci u formatu npr. Laptop 300kom itd. (AdventureWorks2017)


--35 zapisa
use AdventureWorks2017

select 
	p.Name,
	concat((select SUM(sod.OrderQty)
	from Sales.SalesOrderDetail as sod
	where sod.ProductID = p.ProductID),' kom') as 'Prodana količina'
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where (p.SellEndDate is not null) and (pc.Name not like 'Bikes') and
	(select SUM(sod.OrderQty)
	from Sales.SalesOrderDetail as sod
	where sod.ProductID = p.ProductID)>200

--II način
select 
	p.Name,
	CONCAT(SUM(sod.OrderQty),' kom') as 'Prodana količina'
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
	inner join Sales.SalesOrderDetail as sod on sod.ProductID = p.ProductID
where (p.SellEndDate is not null) and (pc.Name not like 'Bikes')
group by p.Name
having SUM(sod.OrderQty)>200


--e) (7 bodova) Kreirati upit kojim će se prikazati identifikacijski broj narudžbe, spojeno ime i prezime kupca,
--te ukupna vrijednost narudžbe koju je kupac platio. Uslov je da je od datuma narudžbe do datuma
--isporuke proteklo manje dana od prosječnog broja dana koji je bio potreban za isporuku svih narudžbi.
--(AdventureWorks2017)

use AdventureWorks2017

select
	soh.SalesOrderID,
	CONCAT(p.FirstName, ' ', p.LastName) as 'Ime i prezime kupca',
	soh.SubTotal as 'Vrijednost narudžbe',
	DATEDIFF(DAY, soh.OrderDate, soh.ShipDate)
from Sales.SalesOrderHeader as soh
	inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
where DATEDIFF(DAY, soh.OrderDate, soh.ShipDate) <
	(select AVG(DATEDIFF(DAY, soh1.OrderDate, soh1.ShipDate))
	from Sales.SalesOrderHeader as soh1)

--5.
--a) (9 bodova) Kreirati upit koji će prikazati one naslove kojih je ukupno prodano više od 30 komada a
--napisani su od strane autora koji su napisali 2 ili više djela/romana. U rezultatima upita prikazati naslov
--i ukupnu prodanu količinu. (Pubs)

use pubs
select t.title_id, t.title, SUM(s.qty) as 'Prodana količina'
from titles as t
	inner join sales as s on s.title_id = t.title_id
where t.title_id in 
(
	select distinct ta.title_id
	from titleauthor as ta
	where ta.au_id in
	(
		select distinct ta.au_id
		from titleauthor as ta
		group by ta.au_id
		having COUNT(*)>=2
	)
)
group by t.title, t.title_id
having SUM(s.qty)>30

--b) (10 bodova) Kreirati upit koji će u % prikazati koliko je narudžbi (od ukupnog broja kreiranih)
--isporučeno na svaku od teritorija pojedinačno. Npr Australia 20.2%, Canada 12.01% itd. Vrijednosti
--dobijenih postotaka zaokružiti na dvije decimale i dodati znak %. (AdventureWorks2017)


use AdventureWorks2017

select 
	st.Name, 
	CAST((COUNT(*)*1.0/
	(
	select COUNT(*)
	from Sales.SalesOrderHeader as soh1
	))*100 as decimal(18,2)) as 'Postotak'
from Sales.SalesOrderHeader as soh
	inner join Sales.SalesTerritory as st on soh.TerritoryID = st.TerritoryID
group by st.Name


--c) (12 bodova) Kreirati upit koji će prikazati osobe koje imaju redovne prihode a nemaju vanredne, i one
--koje imaju vanredne a nemaju redovne. Lista treba da sadrži spojeno ime i prezime osobe, grad i adresu
--stanovanja i ukupnu vrijednost ostvarenih prihoda (za redovne koristiti neto). Pored navedenih podataka
--potrebno je razgraničiti kategorije u novom polju pod nazivom Opis na način "ISKLJUČIVO
--VANREDNI" za one koji imaju samo vanredne prihode, ili "ISKLJUČIVO REDOVNI" za one koji
--imaju samo redovne prihode. Konačne rezultate sortirati prema opisu abecedno i po ukupnoj vrijednosti
--ostvarenih prihoda u opadajućem redoslijedu. (prihodi)

--Napomena: dosta osoba je više puta upisano u tabelu RedovniPrihodi, kao i u tabelu VanredniPrihodi
--Stoga je za jednu osobu potrebno uraditi grupisanje po njenim obilježjima (ime, grad, adresa) i sumirati njene prihode
--Na taj način se ni jedna osoba neće prikazati više od jednom u rezultatima upita

--422 zapisa
use prihodi
select  
	CONCAT(o.Ime, ' ', o.PrezIme) as 'Ime i prezime',
	g.Grad, 
	o.Adresa,
	SUM(rp.Neto),
	'ISKLJUČIVO REDOVNI' as 'Opis'
from Osoba as o
	inner join RedovniPrihodi as rp on rp.OsobaID = o.OsobaID
	inner join Grad as g on o.GradID = g.GradID
where o.OsobaID in
	(
		select o1.OsobaID
		from Osoba as o1
			left join VanredniPrihodi as vp1 on vp1.OsobaID = o1.OsobaID
		where vp1.VanredniPrihodiID is null
	)
group by CONCAT(o.Ime, ' ', o.PrezIme), g.Grad, o.Adresa
UNION
select
	CONCAT(o.Ime, ' ', o.PrezIme) as 'Ime i prezime',
	g.Grad, 
	o.Adresa,
	SUM(vp.IznosVanrednogPrihoda),
	'ISKLJUČIVO VANREDNI' as 'Opis'
from Osoba as o
	inner join VanredniPrihodi as vp on vp.OsobaID = o.OsobaID
	inner join Grad as g on o.GradID = g.GradID
where o.OsobaID in
	(
		select o1.OsobaID
		from Osoba as o1
			left join RedovniPrihodi as rp1 on rp1.OsobaID = o1.OsobaID
		where rp1.RedovniPrihodiID is null
	)
group by CONCAT(o.Ime, ' ', o.PrezIme), g.Grad, o.Adresa
order by 5, 4 desc


