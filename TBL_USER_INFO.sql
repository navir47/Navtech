
/* Table to store user details (Administrators info), can be multiple admins */
CREATE TABLE dbo.USER_INFO
(
    USERID BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    USERNAME NVARCHAR(20) NOT NULL, --column used to login
    FIRST_NAME NVARCHAR(50) NOT NULL,
    LAST_NAME NVARCHAR(50) NOT NULL
);

