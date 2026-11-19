CREATE TABLE [stg].[site_reference] (
    [site_code]          VARCHAR (8000) NULL,
    [site_name]          VARCHAR (8000) NULL,
    [address]            VARCHAR (8000) NULL,
    [postal_code]        BIGINT         NULL,
    [latitude]           FLOAT (53)     NULL,
    [longitude]          FLOAT (53)     NULL,
    [port_count]         BIGINT         NULL,
    [first_session_date] DATE           NULL,
    [fee_policy]         VARCHAR (8000) NULL
);


GO