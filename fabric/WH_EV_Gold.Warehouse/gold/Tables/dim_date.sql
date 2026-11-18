CREATE TABLE [gold].[dim_date] (
    [date_key]        INT         NOT NULL,
    [date]            DATE        NOT NULL,
    [year]            INT         NOT NULL,
    [quarter]         VARCHAR (2) NOT NULL,
    [month_no]        INT         NOT NULL,
    [month_name]      VARCHAR (3) NOT NULL,
    [year_month]      VARCHAR (7) NOT NULL,
    [year_month_sort] INT         NOT NULL,
    [weekday_no]      INT         NOT NULL,
    [weekday_name]    VARCHAR (3) NOT NULL,
    [is_weekend]      BIT         NOT NULL,
    [season]          VARCHAR (6) NOT NULL
);


GO

ALTER TABLE [gold].[dim_date]
    ADD CONSTRAINT [pk_dim_date] PRIMARY KEY NONCLUSTERED ([date_key] ASC) NOT ENFORCED;


GO