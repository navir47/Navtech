
/* Master table to store the statuses, like Ordered, Pending, Processing, Completed etc */
CREATE TABLE dbo.ORDER_STATUS
(
    STATUS_ID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    STATUS_DESCRIPTION NVARCHAR(20) NOT NULL
);

