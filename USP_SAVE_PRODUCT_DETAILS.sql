
/*
	<Products>        
		<Product CATEGORY_NAME="CN_1" PRODUCT_NAME="PN_1" ATTRIBUTE_NAME="AN_1" ATTRIBUTE_VALUE="AV_1" PRICE="10.00" />
		<Product CATEGORY_NAME="CN_2" PRODUCT_NAME="PN_2" ATTRIBUTE_NAME="AN_2" ATTRIBUTE_VALUE="AV_2" PRICE="20.00" />
		<Product CATEGORY_NAME="CN_3" PRODUCT_NAME="PN_3" ATTRIBUTE_NAME="AN_3" ATTRIBUTE_VALUE="AV_3" PRICE="30.00" />
		<Product CATEGORY_NAME="CN_4" PRODUCT_NAME="PN_4" ATTRIBUTE_NAME="AN_4" ATTRIBUTE_VALUE="AV_4" PRICE="10.00" />
		<Product CATEGORY_NAME="CN_5" PRODUCT_NAME="PN_5" ATTRIBUTE_NAME="AN_5" ATTRIBUTE_VALUE="AV_5" PRICE="5.00" />
	</Products>
*/
CREATE PROCEDURE dbo.USP_SAVE_PRODUCT_DETAILS
    @PRODUCTS XML,
    @LOGGED_IN_ADMIN NVARCHAR(20)
AS
BEGIN
    BEGIN TRY
        /*Variables declaration*/
        DECLARE @CREATED_BY BIGINT, --to store id value of logged in admin
                @CREATED_ON DATETIME = GETDATE();

        /*Fetch the ID of logged in admin*/
        SELECT @CREATED_BY = USERID
        FROM dbo.USER_INFO
        WHERE USERNAME = @LOGGED_IN_ADMIN;

        /*Store products xml data into a temp table to process further*/
        SELECT doc.col.value('@CATEGORY_NAME', 'NVARCHAR(50)') CATEGORY_NAME,
               doc.col.value('@PRODUCT_NAME', 'NVARCHAR(50)') PRODUCT_NAME,
               doc.col.value('@ATTRIBUTE_NAME', 'NVARCHAR(50)') ATTRIBUTE_NAME,
               doc.col.value('@ATTRIBUTE_VALUE', 'NVARCHAR(50)') ATTRIBUTE_VALUE,
               doc.col.value('@PRICE', 'DECIMAL(10,2)') PRICE
        INTO #PRODUCTS_TEMP
        FROM @PRODUCTS.nodes('/Products/Product') doc(col);

        /*Add ID columns for category, product and attribute in the temp table
	  to be used in the Product_Attribute_Details table*/

        ALTER TABLE #PRODUCTS_TEMP ADD CATEGORY_ID BIGINT;
        ALTER TABLE #PRODUCTS_TEMP ADD PRODUCT_ID BIGINT;
        ALTER TABLE #PRODUCTS_TEMP ADD ATTRIBUTE_ID BIGINT;


        /* Insert the product categories*/
        INSERT INTO dbo.PRODUCT_CATEGORY
        (
            CATEGORY_NAME,
            CREATED_BY,
            CREATED_ON
        )
        SELECT DISTINCT
               P.CATEGORY_NAME,
               @CREATED_BY,
               @CREATED_ON
        FROM #PRODUCTS_TEMP P
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.PRODUCT_CATEGORY PC
            WHERE P.CATEGORY_NAME = PC.CATEGORY_NAME
        );

        UPDATE P
        SET P.CATEGORY_ID = PC.CATEGORY_ID
        FROM #PRODUCTS_TEMP P
            INNER JOIN dbo.PRODUCT_CATEGORY PC
                ON PC.CATEGORY_NAME = P.CATEGORY_NAME;


        /* Insert the products details */
        INSERT INTO dbo.PRODUCT_INFO
        (
            PRODUCT_NAME,
            CATEGORY_ID,
            CREATED_BY,
            CREATED_ON
        )
        SELECT DISTINCT
               P.PRODUCT_NAME,
               P.CATEGORY_ID,
               @CREATED_BY,
               @CREATED_ON
        FROM #PRODUCTS_TEMP P
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.PRODUCT_INFO PDI
            WHERE PDI.PRODUCT_NAME = P.PRODUCT_NAME
                  AND PDI.CATEGORY_ID = P.CATEGORY_ID
        );

        UPDATE P
        SET P.PRODUCT_ID = PDI.PRODUCT_ID
        FROM #PRODUCTS_TEMP P
            INNER JOIN dbo.PRODUCT_INFO PDI
                ON PDI.PRODUCT_NAME = P.PRODUCT_NAME
                   AND PDI.CATEGORY_ID = P.CATEGORY_ID;


        /* Insert the attributes */
        INSERT INTO dbo.ATTRIBUTE_INFO
        (
            ATTRIBUTE_NAME,
            CREATED_BY,
            CREATED_ON
        )
        SELECT DISTINCT
               P.ATTRIBUTE_NAME,
               @CREATED_BY,
               @CREATED_ON
        FROM #PRODUCTS_TEMP P
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.ATTRIBUTE_INFO AI
            WHERE AI.ATTRIBUTE_NAME = P.ATTRIBUTE_NAME
        );

        UPDATE P
        SET P.ATTRIBUTE_ID = AI.ATTRIBUTE_ID
        FROM #PRODUCTS_TEMP P
            INNER JOIN dbo.ATTRIBUTE_INFO AI
                ON AI.ATTRIBUTE_NAME = P.ATTRIBUTE_NAME;


        /* If product exists, update the price */
        UPDATE PAD
        SET PAD.PRICE = P.PRICE
        FROM dbo.PRODUCT_ATTRIBUTE_DETAILS PAD
            INNER JOIN #PRODUCTS_TEMP P
                ON P.PRODUCT_ID = PAD.PRODUCT_ID
                   AND P.ATTRIBUTE_ID = PAD.ATTRIBUTE_ID
                   AND P.ATTRIBUTE_VALUE = PAD.ATTRIBUTE_VALUE;

        /* Insert the new products information */
        INSERT INTO dbo.PRODUCT_ATTRIBUTE_DETAILS
        (
            PRODUCT_ID,
            ATTRIBUTE_ID,
            ATTRIBUTE_VALUE,
            PRICE,
            CREATED_BY,
            CREATED_ON
        )
        SELECT DISTINCT
               P.PRODUCT_ID,
               P.ATTRIBUTE_ID,
               P.ATTRIBUTE_VALUE,
               P.PRICE,
               @CREATED_BY,
               @CREATED_ON
        FROM #PRODUCTS_TEMP P
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.PRODUCT_ATTRIBUTE_DETAILS PAD
            WHERE PAD.PRODUCT_ID = P.PRODUCT_ID
                  AND PAD.ATTRIBUTE_ID = P.ATTRIBUTE_ID
                  AND PAD.ATTRIBUTE_VALUE = P.ATTRIBUTE_VALUE
        );
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO

