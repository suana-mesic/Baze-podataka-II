--1 Kreirati bazu za svojim brojm indeksa

create database Ispit_09_09_2023
go
use Ispit_09_09_2023


--2 U kreiranoj bazi podataka kreirati tabele slijedecom strukturom
--a)	Uposlenici
--•	UposlenikID, 9 karaktera fiksne duzine i primarni kljuc,
--•	Ime 20 karaktera obavezan unos,
--•	Prezime 20 karaktera obavezan unos
--•	DatumZaposlenja polje za unos datuma i vremena obavezan unos
--•	Opis posla 50 karaktera obavezan unos

create table Uposlenici
(
	UposlenikID char(9) constraint PK_Uposlenici primary key,
	Ime varchar(20) not null,
	Prezime  varchar(20) not null,
	DatumZaposlenja datetime not null,
	[Opis posla] varchar(50) not null
)

--b)	Naslovi
--•	NaslovID 6 karaktera primarni kljuc,
--•	Naslov 80 karaktera obavezan unos,
--•	Tip 12 karaktera fiksne duzine obavezan unos
--•	Cijena novcani tip podatka,
--•	NazivIzdavaca 40 karaktera,
--•	GradIzdavaca 20 karaktera,
--•	DrzavaIzdavaca 30 karaktera

create table Naslovi
(
	NaslovID varchar(6) constraint PK_Naslovi primary key,
	Naslov varchar(80) not null, 
	Tip char(12) not null, 
	Cijena money,
	NazivIzdavaca varchar(40),
	GradIzdavaca varchar(20),
	DrzavaIzdavaca varchar(30)
)

--)
--d)	Prodavnice
--•	ProdavnicaID 4 karaktera fiksne duzine primarni kljuc
--•	NazivProdavnice 40 karaktera
--•	Grad 40 karaktera

create table Prodavnice
(
	ProdavnicaID char(4) constraint PK__Prodavnice primary key,
	NazivProdavnice varchar(40),
	Grad varchar(40)
)

--c)	Prodaja
--•	ProdavnicaID 4 karktera fiksne duzine, strani i primarni kljuc
--•	Broj narudzbe 20 karaktera primarni kljuc,
--•	NaslovID 6 karaktera strani i primarni kljuc
--•	DatumNarudzbe polje za unos datuma i vremena obavezan unos
--•	Kolicina skraceni cjelobrojni tip obavezan unos


create table Prodaja
(
	ProdavnicaID char(4) constraint FK_Prodaja_Prodavnice foreign key references Prodavnice(ProdavnicaID),
	[Broj narudzbe] varchar(20),
	NaslovID varchar(6) constraint FK_Prodaja_Naslovi foreign key references Naslovi(NaslovID),
	DatumNarudzbe  datetime not null,
	Kolicina smallint not null

	constraint PK_Prodaja primary key (ProdavnicaID,[Broj narudzbe],NaslovID)
)

--3 Iz baze podataka pubs u svoju bazu prebaciti slijedece podatke
--a)	U tabelu Uposlenici dodati sve uposlenike
--•	emp_id -> UposlenikID
--•	fname -> Ime
--•	lname -> Prezime
--•	hire_date - > DatumZaposlenja
--•	job_desc - > Opis posla

insert into Uposlenici
select e.emp_id, e.fname, e.lname, e.hire_date, j.job_desc
from pubs.dbo.employee as e
	inner join pubs.dbo.jobs as j on e.job_id = j.job_id

--b)	U tabelu naslovi dodati sve naslove, na mjestu gdje nema pohranjenih podataka o 
--nazivima izdavaca zamijeniti vrijednost sa nepoznat izdavac
--•	Title_id -> NaslovID
--•	Title->Naslov
--•	Type->Tip
--•	Price->Cijena
--•	Pub_name->NazivIzdavaca
--•	City->GradIzdavaca
--•	Country-DrzavaIzdavaca

insert into Naslovi
select t.title_id, t.title, t.type, t.price, ISNULL(p.pub_name,'nepoznat izdavac'), p.city, p.country
from pubs.dbo.titles as t
	inner join pubs.dbo.publishers as p on t.pub_id = p.pub_id

--d)	U tabelu prodavnice dodati sve prodavnice
--•	Stor_id->prodavnicaID
--•	Store_name->NazivProdavnice
--•	City->Grad

insert into Prodavnice
select st.stor_id, st.stor_name, st.city
from pubs.dbo.stores as st

--c)	U tabelu prodaja dodati sve stavke iz tabele prodaja
--•	Stor_id->ProdavnicaID
--•	Order_num->BrojNarudzbe
--•	titleID->NaslovID,
--•	ord_date->DatumNarudzbe
--•	qty->Kolicina

insert into Prodaja
select sa.stor_id, sa.ord_num, sa.title_id, sa.ord_date, sa.qty
from pubs.dbo.sales as sa

--4
--a)	Kreirati proceduru sp_delete_uposlenik kojom ce se obrisati odredjeni zapis iz 
--tabele uposlenici. OBAVEZNO kreirati testni slucaj na kreiranu proceduru

go
create procedure sp_delete_uposlenik
(
	@UposlenikID char(9)
)
as begin
	delete from Uposlenici
	where UposlenikID = @UposlenikID
end
go

select * from Uposlenici as u --43 uposlenika

exec sp_delete_uposlenik @UposlenikID='Y-L77953M'

select * from Uposlenici as u --42 uposlenika

--b)	Kreirati tabelu Uposlenici_log slijedeca struktura
--Uposlenici_log
--•	UposlenikID 9 karaktera fiksne duzine
--•	Ime 20 karaktera
--•	Prezime 20 karakera,
--•	DatumZaposlenja polje za unos datuma i vremena
--•	Opis posla 50 karaktera

create table Uposlenici_log
(
	UposlenikID char(9),
	Ime varchar(20),
	Prezime varchar(20),
	DatumZaposlenja datetime,
	[Opis posla] varchar(50)
)

--c)	Nad tabelom uposlenici kreirati okidac t_ins_Uposlenici koji ce prilikom --birsanja podataka iz tabele Uposlenici izvristi insert podataka u tabelu --Uposlenici_log. OBAVEZNO kreirati tesni slucaj

go
create trigger t_ins_Uposlenici
on Uposlenici after delete
as begin
	insert into Uposlenici_log
	select UposlenikID, Ime, Prezime, DatumZaposlenja, [Opis posla]
	from deleted
end
go

delete from Uposlenici
where UposlenikID = 'A-C71970F'

select * from Uposlenici

select * from Uposlenici_log

--d)	Prikazati sve uposlenike zenskog pola koji imaju vise od 10 godina radnog staza, a rade na Production ili Marketing odjelu. Upitom je potrebno pokazati spojeno ime i prezime uposlenika, godine radnog staza, te odjel na kojem rade uposlenici. Rezultate upita sortirati u rastucem redoslijedu prema nazivu odjela, te opadajucem prema godinama radnog staza (AdventureWorks2019)

use AdventureWorks2017

select 
	CONCAT(p.FirstName, ' ', p.LastName) as 'Ime i prezime'
	,DATEDIFF(YEAR, e.HireDate, GETDATE()) as 'Staž'
	,d.Name as 'Odjel'
from HumanResources.Employee as e
	inner join HumanResources.EmployeeDepartmentHistory as edh on edh.BusinessEntityID = e.BusinessEntityID
	inner join HumanResources.Department as d on edh.DepartmentID = d.DepartmentID
	inner join Person.Person as p on e.BusinessEntityID = p.BusinessEntityID
where DATEDIFF(YEAR, e.HireDate, GETDATE())>10 and d.Name in ('Production', 'Marketing') and edh.EndDate is null 
order by d.Name, DATEDIFF(YEAR, e.HireDate, GETDATE()) desc


--e)	Kreirati upit kojim ce se prikazati koliko ukupno je naruceno komada proizvoda za svaku narudzbu pojedinacno, te ukupnu vrijednost narudzbe sa i bez popusta. Uzwti u obzir samo one narudzbe kojima je datum narudzbe do datuma isporuke proteklo manje od 7 dana (ukljuciti granicnu vrijednost), a isporucene su kupcima koji zive na podrucju Madrida, Minhena,Seatle. Rezultate upita sortirati po broju komada u opadajucem redoslijedu, a vrijednost je potrebno zaokruziti na dvije decimale (Northwind)

use Northwind

select 
	od.OrderID, 
	SUM(od.Quantity) as 'Broj komada proizvoda',
	CAST(SUM(od.UnitPrice * od.Quantity * (1-od.Discount))as decimal(18,2)) as 'Narudžba sa popustom',
	CAST(SUM(od.UnitPrice * od.Quantity)as decimal(18,2)) as 'Narudžba bez popusta'
from [Order Details] as od
	inner join Orders as o on od.OrderID = o.OrderID
where DATEDIFF(DAY,o.OrderDate, o.ShippedDate)<=7 and o.ShipCity in ('München','Madrid','Seattle')
group by od.OrderID
order by SUM(od.Quantity) desc

--f)	Napisati upit kojim ce se prikazati brojNarudzbe,datumNarudzbe i sifra.
--Prikazati samo one zapise iz tabele Prodaja ciji broj narudzbe ISKLJICIVO POCINJE 
--jednim slovom, ili zavrsava jednim slovom (Novokreirana baza)
--Sifra se sastoji od sljedećih vrijednosti:
--•	Brojevi (samo brojevi) uzeti iz broja narudzbi,
--•	Karakter /
--•	Zadnja dva karaktera godine narudbze /
--•	Karakter /
--•	Id naslova
--•	Karakter /
--•	Id prodavnice

use Ispit_09_09_2023
select 
	p.[Broj narudzbe],
	p.DatumNarudzbe,
	CONCAT
		(
		SUBSTRING
			(
			p.[Broj narudzbe],
			PATINDEX('%[0-9]%',p.[Broj narudzbe]),
			IIF
				(
				PATINDEX('%[0-9][^0-9]%',p.[Broj narudzbe])=0,
				LEN(p.[Broj narudzbe])-PATINDEX('%[0-9]%',p.[Broj narudzbe])+1,
				PATINDEX('%[0-9][^0-9]%',p.[Broj narudzbe])-PATINDEX('%[0-9]%',p.[Broj narudzbe])+1
				)
			),
		'/',
		RIGHT(YEAR(p.DatumNarudzbe),2),
		'/',
		p.NaslovID,
		'/',
		p.ProdavnicaID
		) as 'Šifra'
from Prodaja as p
where lower(p.[Broj narudzbe]) like '[a-z][^a-z]%' or lower(p.[Broj narudzbe]) like '%[^a-z][a-z]' 
--Komentar: počinje ili završava jednim slovom, znači da ne može početi sa 2 slova, niti završiti sa 2 slova


--5
--a)	Prikazati nazive odjela gdje radi najmanje odnosno najvise uposlenika --(AdventureWorks2019)
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
) as podq1
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


--b)	Prikazati spojeno ime i prezime osobe,spol, ukupnu vrijednost redovnih bruto prihoda, ukupnu vrijednost vandrednih prihoda, te sumu ukupnih vandrednih prihoda i ukupnih redovnih prihoda. Uslov je da dolaze iz Latvije, Kine ili Indonezije a poslodavac kod kojeg rade je registrovan kao javno ustanova (Prihodi)

use prihodi
select podq.Osoba, podq.Spol, podq.[Suma redovnih], podq.[Suma vanrednih], podq.[Suma redovnih]+podq.[Suma vanrednih] as 'Vanredni + redovni'
from
(
	select
		CONCAT(o.Ime, ' ', o.PrezIme) as 'Osoba'
		,o.Spol
		,SUM(vp.IznosVanrednogPrihoda) as 'Suma vanrednih'
		,SUM(rp.Bruto) as 'Suma redovnih'
	from Osoba as o
		inner join VanredniPrihodi as vp on vp.OsobaID = o.OsobaID
		inner join RedovniPrihodi as rp on rp.OsobaID = o.OsobaID
		inner join Drzava as d on o.DrzavaID = d.DrzavaID
		inner join Poslodavac as p on o.PoslodavacID = p.PoslodavacID
		inner join TipPoslodavca as tp on p.TipPoslodavca = tp.TipPoslodavcaID
	where d.Drzava in ('Latvia','China', 'Indonesia') and tp.OblikVlasnistva like 'javno ustanova'
	group by CONCAT(o.Ime, ' ', o.PrezIme), o.Spol
) as podq

--c)	Modificirati prethodni upit 5_b na nacin da se prikazu samo oni zapisi kod kojih je suma ukupnih bruto i ukupnih vanderednih prihoda (SumaBruto+SumaNeto) veca od 10000KM Retultate upita sortirati prema ukupnoj vrijednosti prihoda obrnuto abecedno(Prihodi)

use prihodi
select podq.Osoba, podq.Spol, podq.[Suma redovnih], podq.[Suma vanrednih], podq.[Suma redovnih]+podq.[Suma vanrednih] as 'Vanredni + redovni'
from
(
	select
		CONCAT(o.Ime, ' ', o.PrezIme) as 'Osoba'
		,o.Spol
		,SUM(vp.IznosVanrednogPrihoda) as 'Suma vanrednih'
		,SUM(rp.Bruto) as 'Suma redovnih'
	from Osoba as o
		inner join VanredniPrihodi as vp on vp.OsobaID = o.OsobaID
		inner join RedovniPrihodi as rp on rp.OsobaID = o.OsobaID
		inner join Drzava as d on o.DrzavaID = d.DrzavaID
		inner join Poslodavac as p on o.PoslodavacID = p.PoslodavacID
		inner join TipPoslodavca as tp on p.TipPoslodavca = tp.TipPoslodavcaID
	where d.Drzava in ('Latvia','China', 'Indonesia') and tp.OblikVlasnistva like 'javno ustanova'
	group by CONCAT(o.Ime, ' ', o.PrezIme), o.Spol
) as podq
where podq.[Suma redovnih]+podq.[Suma vanrednih]>10000
order by 5 desc