------------------------------------------------
--1. 
/*
Kreirati bazu podataka pod vlastitim brojem indeksa
i aktivirati je.
*/

create database Ispit_24_06_2021
go
use Ispit_24_06_2021

---------------------------------------------------------------------------
--Prilikom kreiranja tabela voditi računa o njihovom međusobnom odnosu.
---------------------------------------------------------------------------
/*
a) 
Kreirati tabelu prodavac koja će imati sljedeću strukturu:
	- prodavac_id, cjelobrojni tip, primarni ključ
	- naziv_posla, 50 unicode karaktera
	- dtm_rodj, datumski tip
	- bracni_status, 1 karakter
	- prod_kvota, novčani tip
	- bonus, novčani tip
*/

create table prodavac
(
	prodavac_id int constraint PK_prodavac primary key,
	naziv_posla nvarchar(50),
	dtm_rodj date,
	bracni_status varchar(1),
	prod_kvota money,
	bonus money
)

/*
b) 
Kreirati tabelu prodavnica koja će imati sljedeću strukturu:
	- prodavnica_id, cjelobrojni tip, primarni ključ
	- naziv_prodavnice, 50 unicode karaktera
	- prodavac_id, cjelobrojni tip
*/

create table prodavnice
(
	prodavnica_id int constraint PK_prodavnice primary key,
	naziv_prodavnice nvarchar(50),
	prodavac_id int constraint FK_prodavnice_prodavac foreign key references prodavac(prodavac_id)
)
/*
c) 
Kreirati tabelu kupac_detalji koja će imati sljedeću strukturu:
	- detalj_id, cjelobrojni tip, primarni ključ, automatsko punjenje sa početnom vrijednošću 1 i inkrementom 1
	- kupac_id, cjelobrojni tip, primarni ključ
	- prodavnica_id, cjelobrojni tip
	- br_rac, 10 karaktera
	- dtm_narudz, datumski tip
	- kolicina, skraćeni cjelobrojni tip
	- cijena, novčani tip
	- popust, realni tip
*/
--10 bodova

create table kupac_detalji
(
	detalj_id int identity(1,1),
	kupac_id int,
	prodavnica_id int constraint FK_kupac_detalji foreign key references prodavnice(prodavnica_id),
	br_rac varchar(10),
	dtm_narudz date,
	kolicina smallint,
	cijena money,
	popust real

	constraint PK_kupac_detalji primary key (detalj_id, kupac_id)
)

--2.
/*
a)
Koristeći tabele HumanResources.Employee i Sales.SalesPerson
baze AdventureWorks2017 zvršiti insert podataka u 
tabelu prodavac prema sljedećem pravilu:
	- BusinessEntityID -> prodavac_id
	- JobTitle -> naziv_posla
	- BirthDate -> dtm_rodj
	- MaritalStatus -> bracni_status
	- SalesQuota -> prod_kvota
	- Bonus -> nžbonus
*/

insert into prodavac
select e.BusinessEntityID, e.JobTitle, e.BirthDate, e.MaritalStatus, sp.SalesQuota, sp.Bonus
from AdventureWorks2017.HumanResources.Employee as e
	inner join AdventureWorks2017.Sales.SalesPerson as sp on sp.BusinessEntityID = e.BusinessEntityID

/*
b)
Koristeći tabelu Sales.Store baze AdventureWorks2017 
izvršiti insert podataka u tabelu prodavnica 
prema sljedećem pravilu:
	- BusinessEntityID -> prodavnica_id
	- Name -> naziv_prodavnice
	- SalesPersonID -> prodavac_id
*/

insert into prodavnice
select st.BusinessEntityID, st.Name, st.SalesPersonID
from AdventureWorks2017.Sales.Store as st

/*
b)
Koristeći tabele Sales.Customer, Sales.SalesOrderHeader i SalesOrderDetail
baze AdventureWorks2017 izvršiti insert podataka u tabelu kupac_detalji
prema sljedećem pravilu:
	- CustomerID -> kupac_id
	- StoreID -> prodavnica_id
	- AccountNumber -> br_rac
	- OrderDate -> dtm_narudz
	- OrderQty -> kolicina
	- UnitPrice -> cijena
	- UnitPriceDiscount -> popust
Uslov je da se ne dohvataju zapisi u kojima su 
StoreID i PersonID NULL vrijednost
*/
--60919
insert into kupac_detalji
select c.CustomerID, c.StoreID, c.AccountNumber, soh.OrderDate, sod.OrderQty, sod.UnitPrice, sod.UnitPriceDiscount
from AdventureWorks2017.Sales.SalesOrderHeader as soh
	inner join AdventureWorks2017.Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
where c.StoreID is not null and c.PersonID is not null

--II način
--60919
insert into kupac_detalji
select c.CustomerID, c.StoreID, c.AccountNumber, soh.OrderDate, sod.OrderQty, sod.UnitPrice, sod.UnitPriceDiscount
from AdventureWorks2017.Sales.SalesOrderHeader as soh
	inner join AdventureWorks2017.Sales.Customer as c on soh.CustomerID = c.CustomerID
	inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
where IIF(c.StoreID is null or c.PersonID is null,'ne','da')='da'

--10 bodova
--3.
/*
a)
U tabeli prodavac dodati izračunatu kolonu god_rodj
u koju će se smještati godina rođenja prodavca.
*/

alter table prodavac
add god_rodj as YEAR([dtm_rodj])
/*
b)
U tabeli kupac_detalji promijeniti tip podatka
kolone cijena iz novčanog u decimalni tip oblika (8,2)
*/

alter table kupac_detalji
alter column cijena decimal(8,2)

/*
c)
U tabeli kupac_detalji dodati standardnu kolonu
lozinka tipa 20 unicode karaktera.
*/

alter table kupac_detalji
add lozinka nvarchar(20)

/*
d) 
Kolonu lozinka popuniti tako da bude spojeno 
10 slučajno generisanih znakova i 
numerički dio (bez vodećih nula) iz kolone br_rac
*/

update kupac_detalji
set lozinka = 
	CONCAT(
			LEFT(NEWID(),10),
			SUBSTRING(br_rac, PATINDEX('%[1-9]%',br_rac),LEN(br_rac)-CHARINDEX('%[1-9]%',br_rac))
			)

select * from kupac_detalji

--4.
/*
Koristeći tabele prodavnica i kupac_detalji
dati pregled sumiranih količina po 
nazivu prodavnice i godini naručivanja.
Sortirati po nazivu prodavnice.
*/
--6 bodova

select pr.naziv_prodavnice, YEAR(kd.dtm_narudz) as 'Godina', SUM(kd.kolicina) as 'Količina'
from prodavnice as pr
	inner join kupac_detalji as kd on kd.prodavnica_id = pr.prodavnica_id
group by pr.naziv_prodavnice, YEAR(kd.dtm_narudz)
order by pr.naziv_prodavnice

--5.
/*
Kreirati pogled v_prodavac_cijena sljedeće strukture:
	- prodavac_id
	- bracni_status
	- sum_cijena
Uslov je da se u pogled dohvate samo oni zapisi u 
kojima je sumirana vrijednost veća od 1000000.
*/
--8 bodova

go
create view v_prodavac_cijena
as
	select p.prodavac_id, p.bracni_status, SUM(kd.cijena) as 'Suma cijena'
	from prodavac as p
		inner join prodavnice as pr on pr.prodavac_id = p.prodavac_id
		inner join kupac_detalji as kd on kd.prodavnica_id = pr.prodavnica_id
	group by  p.prodavac_id, p.bracni_status
	having SUM(kd.cijena)>1000000
go

select *
from v_prodavac_cijena

--6.
/*
Koristeći pogled v_prodavac_cijena
kreirati proceduru p_prodavac_cijena sa parametrom
bracni_status čija je zadata (default) vrijednost M.
Uslov je da se procedurom dohvataju zapisi u kojima je 
vrijednost u koloni sum_cijena veća od srednje vrijednosti kolone sum_cijena.
Obavezno napisati kod za pokretanje procedure.
*/
--8 bodova

go
create procedure p_prodavac_cijena (@bracni_status varchar(1)='M')
as begin
	select *
	from v_prodavac_cijena as vpc
	where vpc.[Suma cijena]>
	(
		select AVG(vpc1.[Suma cijena])
		from v_prodavac_cijena as vpc1
	) and
	vpc.bracni_status = @bracni_status
end
go

exec p_prodavac_cijena
exec p_prodavac_cijena @bracni_status='S'

--7.
/*
Iz tabele kupac_detalji prikazati zapise u kojima je 
vrijednost u koloni cijena jednaka 
minimalnoj, odnosno, maksimalnoj vrijednosti u ovoj koloni.
Upit treba da vraća kolone kupac_id, prodavnica_id i cijena.
Sortirati u rastućem redoslijedu prema koloni cijena.
*/
--8 bodova

select kd.kupac_id, kd.prodavnica_id, kd.cijena
from kupac_detalji as kd
where kd.cijena =(select MIN(kd1.cijena) from kupac_detalji as kd1) or 
	kd.cijena =(select MAX(kd1.cijena) from kupac_detalji as kd1)
order by kd.cijena

--8.
/*
a)
U tabeli kupac_detalji kreirati kolonu
cijena_sa_popustom tipa decimal (8,2).
b) 
Koristeći tabelu kupac_detalji
kreirati proceduru p_popust sa parametrom 
godina koji će odgovarati godini iz datum naručivanja.
Procedura će vršiti update kolone cijena_sa_popustom
ako je vrijednost parametra veća od 2013, 
inače se daje poruka 'transakcija nije izvršena'.
Testirati funkcionisanje procedure za vrijednost 
parametra godina 2014.

Obavezno napisati kod za provjeru sadržaja tabele 
nakon što se pokrene procedura.
*/
--8 bodova

--a)
alter table kupac_detalji
add cijena_sa_popustom decimal(8,2)

--b)
go
create or alter procedure p_popust(@godina INT)
as
begin
	if(@godina<=2013)
		select 'Transakcija nije izvršena' as 'Poruka'
	else
		update kupac_detalji
		set [cijena_sa_popustom] = cijena*kolicina*(1-popust)
		where YEAR([dtm_narudz])=@godina
end
go

exec p_popust @godina=2013

exec p_popust @godina=2014

--9.
/*
a)
U tabeli prodavac kreirati kolonu min_kvota tipa decimal (8,2).
i na njoj postaviti ograničenje da se
ne može unijeti negativna vrijednost.
b)
Kreirati skalarnu funkciju f_kvota sa parametrom prod_kvota.
Funkcija će vraćati rezultat tipa decimal (8,2)
koji će se računati po pravilu:
	10% od prod_kvota
c) 
Koristeći funkciju f_kvota izvršiti update
kolone min_kvota u tabeli prodavac
*/
--8 bodova

--a
use Ispit_24_06_2021
alter table prodavac
add min_kvota decimal(8,2) check (min_kvota>=0)

--b
go
create function f_kvota(@prod_kvota decimal(8,2))
returns decimal(8,2)
as begin
	return 0.10*@prod_kvota
end
go

--c
update prodavac
set min_kvota = dbo.f_kvota(prod_kvota)

select *
from prodavac
order by prod_kvota

--10.
/*
a)
Kreirati tabelu prodavac_log strukture:
	- log_id, primarni ključ, automatsko punjenje sa početnom vrijednošću 1 i inkrementom 1 
	- prodavac_id int
	- min_kvota decimal (8,2)
	- dogadjaj varchar (3)
	- mod_date datetime
*/

create table prodavac_log
(
	log_id int constraint PK_prodavac_log primary key identity(1,1),
	prodavac_id int,
	min_kvota decimal (8,2),
	dogadjaj varchar (3),
	mod_date datetime
)
/*
b)
Nad tabelom prodavac kreirati okidač t_ins_prod
kojim će se prilikom inserta podataka u 
tabelu prodavac izvršiti insert podataka u 
tabelu prodavac_log sa naznakom aktivnosti 
(insert, update ili delete).
*/

go
create or alter trigger t_ins_prod
on prodavac after insert
as begin
	insert into prodavac_log(prodavac_id, min_kvota, dogadjaj, mod_date)
	select prodavac_id, min_kvota, 'ins',GETDATE()
	from inserted
end
go

/*
c)
U tabelu prodavac insertovati zapis
291, Sales Manager, 1985-09-30, M, 250000.00, 985.00, -20000.00
Ako je potrebno izvršiti podešavanja 
koja će omogućiti insrt zapisa. 
*/

insert into prodavac (prodavac_id, naziv_posla, dtm_rodj, bracni_status, prod_kvota, bonus, min_kvota)
values (291,'Sales Maneger','1985-09-30','M',250000.00,985.00,-20000.00)

--Podešavanje koje omogućava insert zapisa jeste uklanjanje CHECK ograničenja nad poljem min_kvota
alter table prodavac
drop constraint [CK__prodavac__min_kv__412EB0B6]

--Sada insert radi
insert into prodavac (prodavac_id, naziv_posla, dtm_rodj, bracni_status, prod_kvota, bonus, min_kvota)
values (291,'Sales Maneger','1985-09-30','M',250000.00,985.00,-20000.00)


/*
d)
Obavezno napisati kod za pregled sadržaja 
tabela prodavac i prodavac_log.
*/
--4 boda

select * from prodavac
select * from prodavac_log



