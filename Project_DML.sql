Use LMSDB
GO
--==============================================
--Insert Values
--==============================================
Insert Into LIB.Books Values('Accounting','StevenSandarson','6thEdition','NCTB',12541),
						('Management','CHETANBHAGAT','7thEdition','OnoAlo',12542),
						('English','RaymondMurphy','3rdEdition','NCTB',12543),
						('Mathematics','PCDAS','4thEdition','NCTB',12544),
						('FELUDA','SatyajitRay','2ndEdition','OnoAlo',12545)
						
GO
Insert Into LIB.Borrower Values('Mannan','CHITTAGONG','01843 585 092','Male',9),
							('Hannan','Dhaka','01977 585 092','Male',10),
							('Sadia','Syhlet','01671 870 552','Female',11),
							('Towrin','Rajshahi','01813 953 979','Female',11),
							('Mannan','CHITTAGONG','01843 585 092','Male',10)
GO
Insert Into LIB.Branch Values('ABC Library','GEC'),
							('Univaesal Book Land','Chawakbazar'),
							('Islamia Library','Muradpur')
GO
Insert Into LIB.Staff Values('Raihan','Dhaka','01843 585 092'),
							('Karim','Borishal','01943 586 092'),
							 ('Rahim','Chittagong','01743 575 093')
GO
GO
Insert Into LIB.Issue Values('01-01-2000',500,4,4,1),
						('05-06-2019',180,5,5,2),
						('09-09-2018',150,6,6,3),
						('08-01-2019',150,7,7,1),
						('07-12-2020',200,8,8,2)
GO
Insert Into LIB.Returnss Values('01-01-2000',2),
							('06-07-2020',2),
							('05-08-2019',3),
							('09-02-2019',2),
							('05-012-2018',1)
GO
--================================================
--Select Statement
--================================================
Select * from LIB.Books
Select * from LIB.Borrower
Select * from LIB.Issue
Select * from LIB.Branch
Select * from LIB.Staff
Select * from LIB.Returnss
GO
--====================================================
--Update and Delete
--====================================================
UPDATE LIB.Staff
SET [StaffName]='Salma',[StaffPhone]='01864 599 562'
WHERE StaffID=2
Go
Select * from LIB.Staff
Go
DELETE from LIB.Staff WHERE StaffID=2
Go
--==============================================
--Truncate Table
--==============================================  
 Truncate Table LIB.Staff
 Go
 --==============================================
 --Select INTO AND Copy Data From Another Table
 --=============================================
 Select * 
Into LIB.Branch
From LIB.Staff
 --==============================================
 --Six Clouse
 --==============================================
 SELECT *
FROM LIB.Books
WHERE BookName='Accounting'

--Group by
SELECT BookPublisher,COUNT(BookID)as [no. of. books]
FROM LIB.Books
GROUP BY BookPublisher
GO
--HAVING
SELECT COUNT(BookID) AS  [no. of. books],BookPublisher
FROM LIB.Books
GROUP BY BookPublisher
HAVING COUNT(BookID)<3
-- ORDER BY
SELECT COUNT(BookID) AS  [no. of. books],BookPublisher
FROM LIB.Books
GROUP BY BookPublisher
HAVING COUNT(BookID)<3
ORDER BY BookPublisher DESC
Go
--=================================================
--Distinct
--================================================
Select Distinct BookAuthar,BookName
From LIB.Books
GO
--=======================================
--Create Sub Query 
--=======================================
Select Sum(Vat) as TotalVat
From LIB.Issue
Where Vat in(Select Vat From LIB.Issue Where BookID=4)
GO
--=================================================
--With Cube,Rollup,Grouping Sets
--=================================================
--with cube
SELECT BookName, BookPublisher, sum(BookID) as [sum]
FROM LIB.Books
group by BookName,BookPublisher WITH CUBE
---ROLL UP
SELECT BookName, BookPublisher, sum(BookID) as [sum]
FROM LIB.Books
group by BookName,BookPublisher With ROLLUP
--grouping set
SELECT BookName, BookPublisher, sum(BookID) as [sum]
FROM LIB.Books
group by GROUPING SETS(
  ( BookName,BookPublisher)
  ,(BookName)
  )
GO
 --=============================================
 --Inner JOIN
 --=============================================
 Select *
 From LIB.Books
 Inner join LIB.Issue
 ON Issue.BookID =Books.BookID 
 Go
 --=============================================
 -- Left Outer JOIN
 --=============================================
  Select *
 From LIB.Books
  Left Outer join LIB.Issue
 ON Issue.BookID =Books.BookID 
 --===============================================
 --Right Outer Join 
 --===============================================
 Select * 
 From LIB.Books
 Right Outer Join LIB.Issue
 ON Books.BookID=Issue.BookID
 GO
 --===============================================
 --Full Join
 --===============================================
 Select *
 From LIB.Books
 full join LIB.Issue
 On Books.BookID=Issue.BookID
 GO
 --===============================================
 --Cross Join
 --===============================================
 Select BookName,BookEdition,BookPublisher,BookISBN,IssueID,Vat,Total
 From LIB.Books
 Cross join LIB.Issue
 --==============================================
 --Self Join
 --==============================================
 SELECT x.BookName,y.BookPublisher
FROM LIB.Books as x,LIB.Books as y
WHERE x.BookID<>y.BookID
GO
--=================================================
--Union,Union All Operator,Logical 
--=================================================
 --UNION PERATOR
 SELECT BookID FROM LIB.Books
 UNION
 SELECT BorrowerID FROM LIB.Borrower
 --UNION ALL OPERATOR
 SELECT BookID FROM LIB.Books
 UNION ALL
 SELECT BorrowerID FROM LIB.Borrower
 --LOGICALL
 if (2=3)
	print'yes, you are right'
else
	print'no, you are wrong'
GO
--========================================================
--Create SEQUNCE
--=========================================================
Create Sequence sq_books 
As Bigint
Start with 1
Increment by 2
Minvalue 1
Maxvalue 99
Cycle 
Cache 10
GO
--=================================================
--CTE
--=================================================
With Book_CTE (BookID,BookName,BookAuthar,BookEdition,BookISBN)
As
(
Select BookID,BookName,BookAuthar,BookEdition,BookISBN
From LIB.Books 
Where BookName= 'Accounting'
)

Select * From Book_CTE
GO
--===============================================
--Cast And Convert
--===============================================
Select 'Today :'+ Cast(Getdate() as varchar);
Select 'Today :'+ CONVERT(varchar,Getdate());
GO
--=============================================
--Cursor and Fetch
--=============================================
SET NOCOUNT ON;
DECLARE @branchid int, @branchname varchar(20), @branchlocation varchar(15), @message varchar(max);
PRINT 'Branch DETAILS ';
DECLARE branchcursor CURSOR FOR
	SELECT BranchID,BranchName,BranchLocation
	FROM LIB.Branch
	order by BranchID;
OPEN branchcursor
	FETCH NEXT FROM branchcursor
	INTO @branchid,@branchname,@branchlocation
	print 'BranchID  BranchName  BranchLocation'
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH NEXT FROM branchcursor
			INTO @branchid,@branchname,@branchlocation
		END


CLOSE branchcursor;
DEALLOCATE branchcursor;
GO
--=========================================================
--Operator
--=========================================================
Select 23+2 as [Sum]
Go
Select 24-4 as [Substraction]
Go
Select 50*3 as [Multiplication]
Go
Select 15/2 as [Divide]
Go
Select 16%3 as [Remainder]
Go
--========================================
--Case Function
--==========================================
Select IssueID, BranchID,
	Case BranchID
	When 9 then 'ABC Library'
	When 10 then 'Univaesal Book Land'
	When 11 then 'Islamia Library'
	When 12 then 'ABC Library'
	When 13 then 'Univaesal Book Land'
	When 14 then 'Islamia Library'
		Else 'Not In Branch'
End	 
From LIB.Issue
Go
--=================================================
--While Loop
--==================================================
DECLARE @x int
SET @x=10
WHILE @x<=20
BEGIN
	PRINT 'Your Provided Value:'+ cast(@x as varchar)
	set @x=@x+1

END
GO
--===============================================
--WILDCARD
--=================================================
SELECT *
FROM LIB.Books
WHERE BookName LIKE'%T'
--WHERE BookName LIKE'D____[]%S'
--======================================================
--Florr,Celling,Round
--======================================================
declare @x money =15.49;
select floor(@x) as FLOORRESULT, ROUND(@x,0) as ROUNDRESULT
declare @value decimal(10,2)
SET @value =21.06
SELECT ROUND(@value,0)
SELECT ROUND(@value,1)
SELECT ROUND(@value,-1)
GO
--==========================================================
-- And,OR,AVG
--========================================================
Go
SELECT AVG(DISTINCT BookID)  
FROM LIB.Issue
Go
SELECT *   
FROM LIB.Issue  
WHERE BookID=5
OR BookID=2   
AND Price > 100
ORDER BY BookID DESC
GO
--===================================
--Store Procedure Insert
--=====================================
Go
EXEC sp_book_branch 12,'Bangla','Raihan','6thEdition','NCTB',21345,4,'BookLand','Wasa','LIB.Books','Insert'
EXEC sp_book_branch 12,'Bangla','Raihan','6thEdition','NCTB',21345,4,'BookLand','Wasa','LIB.Books','Update'
GO
Declare @mess varchar(30)
EXEC sp_Staff 5,'Arif','Rangpur','01943 585 095',@mess output