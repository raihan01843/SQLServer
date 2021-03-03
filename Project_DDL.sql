Use Master
Drop Database If Exists LMSDB
GO
Create Database LMSDB
GO

ALTER DATABASE LMSDB MODIFY FILE 
(Name=N'LMSDB_Data', Size=25MB, MaxSize=100MB, FileGrowth=5% )
GO
ALTER DATABASE LMSDB MODIFY FILE 
( Name=N'LMSDB_Log', Size = 10MB, MaxSize = 100MB, FileGrowth = 1MB)

GO
--Delte Database
Use Master
Drop Database LSMDB
GO
--================================================
--Create Scema
--================================================
USE LMSDB
GO
Create Schema LIB
GO
--Create Table
Use LMSDB
Create Table LIB.Books
(
BookID INT PRIMARY KEY IDENTITY,
BookName varchar(20),
BookAuthar varchar(20),
BookEdition varchar(10) sparse null,
BookPublisher varchar(20) not null,
BookISBN INT not null
);
GO
Use LMSDB
Create Table LIB.Borrower
(
BorrowerID INT PRIMARY KEY IDENTITY,
BorrowerName varchar(20) not null,
BorrowerAddress varchar(50) not null CONSTRAINT CN_BorrowerAddress DEFAULT ('UNKHOWN'),
BorrowerPhoneNO nvarchar(15) not null  CHECK ((BorrowerPhoneNO like'[0][1][1-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]')),
Gender varchar(10) not null,
BranchID int FOREIGN KEY REFERENCES LIB.Branch(BranchID)ON UPDATE CASCADE
);
GO
Use LMSDB
Create Table LIB.Issue
(
IssueID INT Primary Key Identity,
Date_Issue Date not null default (getdate()),
Price Money,
Vat AS (Price*.15),
Total As (Price+(Price*.15)),
BookID int FOREIGN KEY REFERENCES LIB.Books(BookID),
BorrowerID int  FOREIGN KEY REFERENCES LIB.Borrower(BorrowerID),
StaffID int  FOREIGN KEY REFERENCES LIB.Staff(StaffID)
);
GO
Use LMSDB
Create Table LIB.Returnss
(
ReturnID INT PRIMARY KEY IDENTITY,
ReturnDate Datetime not null,
IssueID int  FOREIGN KEY REFERENCES LIB.Issue(IssueID) ON Delete Cascade,
);
GO
Use LMSDB
Create Table LIB.Staff
(
StaffID INT PRIMARY KEY IDENTITY,
StaffName varchar(20) not null,
StaffAddress varchar(50) not null,
StaffPhone char(15) not null CHECK ((StaffPhone like'[0][1][1-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]'))
);
GO
Use LMSDB
Create Table LIB.Branch
(
BranchID INT PRIMARY KEY IDENTITY,
BranchName varchar(20) not null,
BranchLocation varchar(20)not null
);
GO
--==================================================
-- Local Temporaray Table & Global Table
--==================================================
Create Table #BookAgent
(
BookAgentID INT PRIMARY KEY,
BookAgentName varchar(20) not null
)
Create Table ##Stock
(
StockID INT,
BookAgentID int foreign key references #BookAgent(BookAgentID)
)
--=================================================
--Create Store Procedure
--=================================================
GO
Create PROC sp_book_branch
@bookid int,
@bookname varchar(20),
@bookauther varchar(20),
@bookedition varchar(10),
@bookpublisher varchar(20),
@bookisbn int,
@branchid int,
@branchname varchar(20),
@branchlocation varchar(20),
@tablename varchar(20),
@operationname varchar(20)
AS
BEGIN

		IF @tablename='LIB.Books' and @operationname='Insert'
		Begin
		Insert into LIB.Books values(@bookname,@bookauther,@bookedition,@bookpublisher,@bookisbn)
		End
		IF @tablename='LIB.Books' and @operationname='Update'
		Begin
		update LIB.Books set BookName=@bookname where BookID=@bookid
		End
		IF @tablename='LIB.Books' and @operationname='Delete'
		Begin
		delete LIB.Books where BookID=@bookid
		End
		IF @tablename='LIB.Books' and @operationname='Select'
		Begin
		select * from LIB.Books
		End
		IF @tablename='LIB.Branch' and @operationname='Insert'
		Begin
		Insert into LIB.Branch values(@branchname,@branchlocation)
		End
		IF @tablename='LIB.Branch' and @operationname='Update'
		Begin
		update LIB.Branch set BranchName=@branchname where BranchID=@branchid
		End
		IF @tablename='LIB.Branch' and @operationname='Delete'
		Begin
		delete LIB.Branch where BranchID=@branchid
		End
		IF @tablename='LIB.Branch' and @operationname='Select'
		Begin
		select * from LIB.Branch
		End
End
GO
--=========================================================================
--Store Procedure(Commit,Rollbac,Try,Catch)
--======================================================================
Create proc sp_Staff
@staffid int ,
@staffname varchar(20),
@staffadress varchar(20),
@staffphone char(15),
@message varchar(30) output	 
As
Begin
	Set Nocount On
	Begin Try
		Begin Transaction
			Insert Into LIB.Staff(StaffID,StaffName,StaffAddress,StaffPhone)
			values (@staffid,@staffname,@staffadress,@staffphone)
			set @message='Data Inserted Successfully'
			print @message
		Commit Transaction	
	End Try
	Begin Catch
		Rollback transaction	
		Print 'Something goes wrong'
	End Catch
End
GO
--==============================================================
--View WITH Schemabinding
--==============================================================
Create View vw_books
With Schemabinding
AS
Select Books.BookID,BookAuthar,BookEdition,BookName,IssueID,Price,Total
From LIB.Books
Join LIB.Issue
ON Books.BookID=Issue.BookID
GO
--==============================================
--View With Encryption
--==============================================
Create View vw_books2
With Encryption
AS
Select BookID,BookName,BookAuthar,BookPublisher,BookISBN
From LIB.Books
GO
--=====================================================
--CREATE NONCLUSTERED INDEX
--=======================================================
Create nonclustered Index booksindecx on LIB.Books(BookAuthar)
GO
--=================================================
--Create Clustered Index
--=================================================
Create Clustered Index stockindex on ##Stock(StockID)
GO
--===============================================
---Create Instaed Trigger
--===============================================
CREATE TRIGGER tr_insteadOftriger ON LIB.Books
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @rowcount int
	set @rowcount =@@ROWCOUNT 
	IF(@rowcount > 5)
		BEGIN
			RAISERROR( 'You can not insert more then 5 Books', 16, 1)
		END
	ELSE 
		PRINT 'Insert is successful'
END
Go
Create Trigger tr_CheckingInsertUpdate On LIB.Issue
For Insert, Update
AS
	If Exists
	(
	Select 'True'
	From Inserted i
	Join Issue as s
	On i.BookID = s.BookID
	)
Begin
	 RAISERROR('Data Insertion is not Allowed', 16, 1)
	 Print 'Insertion Error'
	 ROLLBACK TRAN
End
Go
Update LIB.Issue 
Set Price = 300
Where IssueID = 4
GO

Select * From LIB.Issue
GO
--Delete For Trigger
Create TRigger tr_CheckingDelete On LIB.Issue
For Delete
AS
Begin
	If Exists (Select * From Deleted d)
		Begin
			RAISERROR('Data Deletion is not Allowed', 16, 1)
			Print 'Deletion Error'
			ROLLBACK TRAN
		End
End
Go

Delete LIB.Issue Where IssueID=4
GO
--=================================================
--Function Create Scalar
--================================================
Create Function dbo.fn_TotalVat2(@bookid int)
RETURNS int
As
BEGIN
	RETURN
	(Select sum(Vat) From LIB.Issue Where BookID=@bookid)
END
GO

Print dbo.fn_TotalVat2(1)
Go
--===================================
--Tabular Function
--===================================
Create Function dbo.fn_Table(@bookpublisher varchar(20))
Returns Table 
As
Return
(Select Books.BookID,BookAuthar,BookPublisher,Price,Vat,Total
From LIB.Books
Join LIB.Issue
On Books.BookID=Issue.BookID
Where BookPublisher=@bookpublisher
)
GO

Select * From dbo.fn_Table('NCTB')
Go






