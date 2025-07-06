--Ispit 20.06.2025. Grupa B :: Rješenje

--Baza: AdventureWorks2017
--a) (5 bodova) Prikazati sve narudžbe iz 2011. godine koje sadrže tačno jedan proizvod. Zaglavlje (kolone): ID narudžbe

USE AdventureWorks2017
SELECT sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID
having COUNT(distinct sod.ProductID)=1
	
--b) (7 bodova) Prikazati ukupni prihod (količina * cijena) i broj narudžbi po kupcu i godini kupovine. Zaglavlje: Kupac, Godina kupovine, Prihod, Broj narudžbi

USE AdventureWorks2017
SELECT
	CONCAT(p.FirstName, ' ', p.LastName) AS 'Kupac',
	YEAR(soh.OrderDate) AS 'Godina kupovine',
	SUM(sod.UnitPrice*sod.OrderQty) AS 'Prihod',
	(
		SELECT COUNT(*)
		FROM Sales.SalesOrderHeader AS soh1
		WHERE soh1.CustomerID = c.CustomerID
	) AS 'Broj narudžbi'
FROM Sales.SalesOrderHeader AS soh
	INNER JOIN Sales.Customer AS c on soh.CustomerID = c.CustomerID
	INNER JOIN Person.Person AS p on c.PersonID = p.BusinessEntityID
	INNER JOIN Sales.SalesOrderDetail AS sod on sod.SalesOrderID = soh.SalesOrderID
GROUP BY CONCAT(p.FirstName, ' ', p.LastName), c.CustomerID, YEAR(soh.OrderDate)

--c) (8 bodova) Prikazati sve proizvode koji nisu nikada naručeni, imaju cijenu veću od 100 i nalaze se u skladištu u količini većoj od 800 komada. Rezultate sortirati po cijeni u opadajućem redoslijedu- Zaglavlje: Naziv proizvoda, Cijena, Količina

USE AdventureWorks2017
SELECT 
	podqProizvodi.Name AS 'Naziv proizvoda', 
	podqProizvodi.ListPrice AS 'Cijena', 
	SUM(piProizvodi.Quantity) AS 'Količina'
FROM
(
		SELECT p.ProductID, p.Name, p.ListPrice --proizvodi koji nisu nikada naručeni
		FROM Production.Product AS p
			LEFT JOIN Sales.SalesOrderDetail AS sod on sod.ProductID = p.ProductID
		WHERE sod.SalesOrderID is null
	INTERSECT
		SELECT p.ProductID, p.Name, p.ListPrice --proizvodi koji imaju cijenu veću od 100
		FROM Production.Product AS p
		WHERE p.ListPrice>100
	INTERSECT
		SELECT p.ProductID, p.Name, p.ListPrice --proizvodi kojih ima na skladištu u količini većoj od 800 komada
		FROM Production.Product AS p
			INNER JOIN Production.ProductInventory AS pi on pi.ProductID = p.ProductID
		GROUP BY p.ProductID, p.Name, p.ListPrice
		having SUM(pi.Quantity)>800
) AS podqProizvodi
	INNER JOIN Production.ProductInventory AS piProizvodi on piProizvodi.ProductID = podqProizvodi.ProductID
GROUP BY podqProizvodi.Name, podqProizvodi.ListPrice
ORDER BY 2 DESC

--Baza: Northwind
--a) (4 boda) Prikazati državu iz koje su narudbe isporučene najbrže (najmanje prosječno vrijeme isporuke) Zaglavlje: Država, Prosječan broj dana.
USE Northwind

SELECT TOP 1 WITH TIES
	o.ShipCountry AS 'Država', 
	AVG(DATEDIFF(DAY, o.OrderDate, o.ShippedDate)) AS 'Prosječan broj dana'
FROM Orders AS o
GROUP BY o.ShipCountry
ORDER BY 2 

--b) (7 bodova) Prikazati kupce čije su sve narudžbe isporučene u roku kraćem od 5 dana. Zaglavlje: Naziv kompanije kupca
USE Northwind

--I način - niti jedna narudžba mu nije isporučena u roku od 5 ili više dana
SELECT distinct cQ.CompanyName AS 'Naziv kompanije kupca' --kupci koji su imali narudžbe (ne svi kupci)
FROM Orders AS oQ
	INNER JOIN Customers AS cQ on cQ.CustomerID = oQ.CustomerID
WHERE not exists 
	(
		SELECT o.OrderID, DATEDIFF(DAY, o.OrderDate, o.ShippedDate) AS 'Broj dana isporuke'
		FROM Orders AS o
		WHERE o.CustomerID = oQ.CustomerID and DATEDIFF(DAY, o.OrderDate, o.ShippedDate)>=5 and o.ShippedDate is not null
	)

--II način - broj njegovih narudžbi mora biti jednak broju narudžbi koje su ISPORUČENE u roku manjem od 5 dana
SELECT distinct cQ.CompanyName AS 'Naziv kompanije kupca' --kupci koji su imali narudžbe i čije su narudžbe isporučene (ne svi kupci)
FROM Orders AS oQ
	INNER JOIN Customers AS cQ on cQ.CustomerID = oQ.CustomerID
WHERE IIF
	(
		(
			SELECT COUNT(*) AS 'Broj isporučenih narudžbi'
			FROM Orders AS o
			WHERE o.CustomerID = oQ.CustomerID and o.ShippedDate is not null
		)
		=
		(
			SELECT COUNT(*)
				FROM
				(
					SELECT o.OrderID, DATEDIFF(DAY, o.OrderDate, o.ShippedDate) AS 'Broj dana' --Broj narudžbi koje su ISPORUČENE u roku manje od 5 dana
					FROM Orders AS o
					WHERE o.CustomerID = oQ.CustomerID and DATEDIFF(DAY, o.OrderDate, o.ShippedDate)<5 and o.ShippedDate is not null
				) AS podq
			),1,0	
	)=1

--c) (7 bodova) Prikazati kupce koji su naručili samo jednom, i to proizvode kojih ima na stanju u količini manjoj od 20. Zaglavlje: Naziv kompanije kupca.

USE Northwind
--Broj naručenih proizvoda mora biti jednak broju proizvoda kojih ima na stanju u količini manjoj od 20
SELECT podqKupci.CompanyName
FROM
(
	SELECT o.CustomerID, c.CompanyName
	FROM Orders AS o
		INNER JOIN Customers AS c on o.CustomerID = c.CustomerID
	GROUP BY o.CustomerID, c.CompanyName
	having COUNT(o.OrderID)=1
) AS podqKupci
	INNER JOIN Orders AS podqNarudžbe on podqKupci.CustomerID = podqNarudžbe.CustomerID
WHERE IIF
	(
		(
			SELECT COUNT(*) --Broj proizvoda u toj narudžbi
			FROM [Order Details] AS od
			WHERE od.OrderID = podqNarudžbe.OrderID
		)
		=
		(
			SELECT COUNT(*) --Broj proizvoda te narudžbe kojih na stanju ima manje od 20
			FROM [Order Details] AS od
				INNER JOIN Products AS p on od.ProductID = p.ProductID
			WHERE od.OrderID = podqNarudžbe.OrderID and p.UnitsInStock<20
		),1,0
	)=1

---------------------------------Provjera---------------------------------
--Da li kupac ima jednu narudžbu?
SELECT c.CompanyName, o.OrderID
FROM Customers AS c
	INNER JOIN Orders AS o on c.CustomerID = o.CustomerID
WHERE c.CompanyName like 'Centro comercial Moctezuma'

--Proizvodi te narudžbe
--ProductID: 21
--ProductID: 37
SELECT c.CompanyName, o.OrderID, od.ProductID
FROM Customers AS c
	INNER JOIN Orders AS o on c.CustomerID = o.CustomerID
	INNER JOIN [Order Details] AS od on od.OrderID = o.OrderID
WHERE c.CompanyName like 'Centro comercial Moctezuma'

--Da li se ProductID 21 i 37 nalaze u skladištu u količini manjoj od 20 komada?
SELECT p.ProductID, p.UnitsInStock
FROM Products AS p
WHERE p.ProductID in (21,37)
--Proizvodi sa ID=21 i ID=37 se nalaze u količini 3 kg i 11 kg.


--Baza: pubs
--a) (10 bodova) Prikazati naslove koji se nisu prodali nijednom u trgovinama koje su prodale više od 5 različitih naslova. Zaglavlje: Naslov knjige

USE pubs
--Trgovine koje su prodale više od 5 različitih naslova
SELECT sa.stor_id
FROM sales AS sa
GROUP BY sa.stor_id
having COUNT(distinct sa.title_id)>5

--Finalni upit
SELECT t.title AS 'Naslov knjige' --Naslovi koji se nisu prodali nikada + naslovi koji su se prodali, ali se nisu prodali niti jednom u trgovinama koje su prodale više od 5 različitih naslova
FROM titles AS t
WHERE not exists
	(
		SELECT *
		FROM sales AS sa
		WHERE sa.title_id = t.title_id and sa.stor_id in 
			(
				SELECT sa.stor_id
				FROM sales AS sa
				GROUP BY sa.stor_id
				having COUNT(distinct sa.title_id)>5
			)
	)
---------------------------------Provjera---------------------------------
--Ne smije se niti jednom pojaviti stor_id=7131
SELECT distinct sa.stor_id
FROM sales AS sa
	INNER JOIN titles AS t on sa.title_id = t.title_id
WHERE t.title in 
(
	'The Busy Executive''s Database Guide'
	,'Cooking with Computers: Surreptitious Balance Sheets'
	,'You Can Combat Computer Stress!'
	,'Straight Talk About Computers'
	,'Silicon Valley Gastronomic Treats'
	,'The Psychology of Computer Cooking'
	,'But Is It User Friendly?'
	,'Secrets of Silicon Valley'
	,'Net Etiquette'
	,'Onions, Leeks, and Garlic: Cooking Secrets of the Mediterranean'
	,'Fifty Years in Buckingham Palace Kitchens'
	,'Sushi, Anyone?'
)

--b) (10 bodova) Prikazati naslove koji su se prodali isključivo u onim godinama u kojima ukupna prodaja svih naslova nije prelazila 80 primjeraka. Zaglavlje: title(naslov knjige)

USE pubs

--I način
--Godina/e u kojima ukupna prodaja svih naslova nije prelazila 80 primjeraka
SELECT YEAR(sa.ord_date) AS 'Godina'
FROM sales AS sa
GROUP BY YEAR(sa.ord_date)
having SUM(sa.qty)<=80

--I način: Finalni upit
--Naslovi koji se nisu prodali niti jednom u godini u kojoj je ukupna prodaja naslova PRELAZILA 80 primjerala
--Ovim upitom zapravo dobijamo naslove koji su se prodavali samo u godinama u kojima ukupna prodaja naslova NIJE PRELAZILA 80 primjeraka

SELECT distinct tQ.title
FROM sales AS saQ
	INNER JOIN titles AS tQ on saQ.title_id = tQ.title_id
WHERE not exists
	(
		SELECT *
		FROM sales AS sa
		WHERE sa.title_id = tQ.title_id and YEAR(sa.ord_date) not in 
		(
			SELECT YEAR(sa.ord_date) AS 'Godina'
			FROM sales AS sa
			GROUP BY YEAR(sa.ord_date)
			having SUM(sa.qty)<=80)
		)

--II način - koliko se puta prodao taj naslov mora biti jednak broju puta kada se prodao u 1992. godini
SELECT tQ.title
FROM titles AS tQ
WHERE IIF
(
	(
		SELECT COUNT(*) --koliko se puta prodao taj naslov
		FROM sales AS sa
		WHERE sa.title_id = tQ.title_id
	)
	=
	(
		SELECT COUNT(*) --broj zapisa u kojima je godina prodaje u tabeli sales za taj naslov jednaka godini ili godinama u kojima ukupna prodaja svih naslova nije prelazila 80 primjeraka
		FROM sales AS sa
		WHERE sa.title_id = tQ.title_id and YEAR(sa.ord_date) in 
			(
				SELECT YEAR(sa.ord_date) AS 'Godina'
				FROM sales AS sa
				GROUP BY YEAR(sa.ord_date)
				having SUM(sa.qty)<=80
			) 
	) 
	and 
	(
		SELECT COUNT(*) --naslov se morao prodavati
		FROM sales AS sa
		WHERE sa.title_id = tQ.title_id
	)<>0
,1,0)=1

---------------------------------Provjera---------------------------------
--Naslovi iz rezultata upita:
--Fifty Years in Buckingham Palace Kitchens
--Onions, Leeks, and Garlic: Cooking Secrets of the Mediterranean
--Sushi, Anyone?

--Pored svakog naslova mora stajati 1992 godina jer samo ona zadovoljava gore postavljeni uvjet iz zadatka

SELECT t.title, YEAR(sa.ord_date) AS 'Godina prodaje'
FROM titles AS t
	INNER JOIN sales AS sa on sa.title_id = t.title_id
WHERE t.title in (
	'Fifty Years in Buckingham Palace Kitchens'
	,'Onions, Leeks, and Garlic: Cooking Secrets of the Mediterranean'
	,'Sushi, Anyone?'
)

