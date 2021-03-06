
/* Table to store the attributes master data like color, size etc */
CREATE TABLE dbo.ATTRIBUTE_INFO
(
    ATTRIBUTE_ID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ATTRIBUTE_NAME NVARCHAR(50) NOT NULL,
    CREATED_BY BIGINT NOT NULL,
    CREATED_ON DATETIME NOT NULL
        FOREIGN KEY (CREATED_BY) REFERENCES dbo.USER_INFO (USERID)
);

