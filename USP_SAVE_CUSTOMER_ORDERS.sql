CREATE PROCEDURE dbo.USP_SAVE_CUSTOMER_ORDERS
    @CUSTOMER_MAIL VARCHAR(255),
    @CATEGORY_NAME NVARCHAR(50),
    @PRODUCT_NAME NVARCHAR(50),
    @ATTRIBUTE_NAME NVARCHAR(50),
    @ATTRIBUTE_VALUE NVARCHAR(50),
    @QUANTITY INT
AS
BEGIN
    BEGIN TRY
        DECLARE @CUSTOMER_ID BIGINT,
                @ORDER_STATUS INT,
                @ORDER_DATE DATETIME,
                @ORDER_ID BIGINT,
                @PRODUCT_ATTRIBUTE_ID BIGINT;

        SELECT @CUSTOMER_ID = C.CUSTOMER_ID
        FROM dbo.CUSTOMER C
        WHERE C.EMAIL = @CUSTOMER_MAIL;

        SELECT @ORDER_STATUS = STATUS_ID
        FROM dbo.ORDER_STATUS
        WHERE STATUS_DESCRIPTION = 'Ordered'; --Assuming Ordered as default status during order initialization

        SET @ORDER_DATE = GETDATE();

        INSERT INTO dbo.ORDER_INFO
        (
            CUSTOMER_ID,
            ORDER_STATUS,
            ORDER_DATE
        )
        VALUES
        (@CUSTOMER_ID, @ORDER_STATUS, @ORDER_DATE);

        SET @ORDER_ID = SCOPE_IDENTITY();

        SELECT @PRODUCT_ATTRIBUTE_ID = PAD.PRODUCT_ATTRIBUTE_ID
        FROM dbo.PRODUCT_ATTRIBUTE_DETAILS PAD
            INNER JOIN dbo.PRODUCT_INFO PIN
                ON PIN.PRODUCT_ID = PAD.PRODUCT_ID
                   AND PIN.PRODUCT_NAME = @PRODUCT_NAME
            INNER JOIN dbo.ATTRIBUTE_INFO AI
                ON AI.ATTRIBUTE_ID = PAD.ATTRIBUTE_ID
                   AND AI.ATTRIBUTE_NAME = @ATTRIBUTE_NAME
        WHERE PAD.ATTRIBUTE_VALUE = @ATTRIBUTE_VALUE;

        INSERT INTO dbo.ORDER_ITEMS
        (
            ORDER_ID,
            PRODUCT_ATTRIBUTE_ID,
            QUANTITY,
            ORDER_DATE
        )
        SELECT @ORDER_ID,
               @PRODUCT_ATTRIBUTE_ID,
               @QUANTITY,
               @ORDER_DATE;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;