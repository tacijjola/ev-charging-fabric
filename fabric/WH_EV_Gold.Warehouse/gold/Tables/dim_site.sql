CREATE TABLE [gold].[dim_site] (
    [site_key]           INT           NOT NULL,
    [site_code]          VARCHAR (30)  NOT NULL,
    [site_name]          VARCHAR (50)  NOT NULL,
    [address]            VARCHAR (100) NULL,
    [postal_code]        VARCHAR (10)  NULL,
    [latitude]           FLOAT (53)    NULL,
    [longitude]          FLOAT (53)    NULL,
    [port_count]         INT           NULL,
    [first_session_date] DATE          NULL,
    [fee_policy]         VARCHAR (10)  NOT NULL,
    [valid_from]         DATE          NOT NULL,
    [valid_to]           DATE          NOT NULL,
    [is_current]         BIT           NOT NULL
);


GO