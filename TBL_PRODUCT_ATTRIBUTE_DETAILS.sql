
/* Mapping table to store the product in details along with the attributes information */
/* Can be multiple records for a single product */
CREATE TABLE dbo.PRODUCT_ATTRIBUTE_DETAILS
(
    PRODUCT_ATTRIBUTE_ID BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    PRODUCT_ID BIGINT NOT NULL,
    ATTRIBUTE_ID INT NOT NULL,
    ATTRIBUTE_VALUE NVARCHAR(10) NOT NULL,
    PRICE DECIMAL(10, 2) NOT NULL,
    CREATED_BY BIGINT NOT NULL,
    CREATED_ON DATETIME NOT NULL
        FOREIGN KEY (PRODUCT_ID) REFERENCES dbo.PRODUCT_INFO (PRODUCT_ID),
    FOREIGN KEY (ATTRIBUTE_ID) REFERENCES dbo.ATTRIBUTE_INFO (ATTRIBUTE_ID),
    FOREIGN KEY (CREATED_BY) REFERENCES dbo.USER_INFO (USERID)
);
