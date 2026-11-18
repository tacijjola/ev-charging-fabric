CREATE TABLE [gold].[dim_station] (
    [station_key]        INT          NOT NULL,
    [station_name]       VARCHAR (60) NOT NULL,
    [port_label]         VARCHAR (30) NOT NULL,
    [site_code]          VARCHAR (30) NOT NULL,
    [port_type]          VARCHAR (10) NULL,
    [plug_type]          VARCHAR (10) NULL,
    [latitude]           FLOAT (53)   NULL,
    [longitude]          FLOAT (53)   NULL,
    [first_session_date] DATE         NOT NULL,
    [in_service_days]    INT          NOT NULL
);


GO

ALTER TABLE [gold].[dim_station]
    ADD CONSTRAINT [pk_dim_station] PRIMARY KEY NONCLUSTERED ([station_key] ASC) NOT ENFORCED;


GO