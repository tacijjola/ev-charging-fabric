CREATE TABLE [gold].[fact_sessions] (
    [session_id]          VARCHAR (64)    NOT NULL,
    [date_key]            INT             NOT NULL,
    [hour_of_day]         INT             NOT NULL,
    [station_key]         INT             NOT NULL,
    [site_key]            INT             NOT NULL,
    [user_key]            INT             NOT NULL,
    [end_reason_key]      INT             NOT NULL,
    [duration_band]       VARCHAR (6)     NOT NULL,
    [energy_kwh]          FLOAT (53)      NOT NULL,
    [fee_usd]             DECIMAL (10, 2) NOT NULL,
    [ghg_kg]              FLOAT (53)      NULL,
    [total_min]           DECIMAL (9, 1)  NOT NULL,
    [charging_min]        DECIMAL (9, 1)  NOT NULL,
    [idle_min]            DECIMAL (9, 1)  NOT NULL,
    [is_paid]             BIT             NOT NULL,
    [is_duration_anomaly] BIT             NOT NULL,
    [is_long_session]     BIT             NOT NULL
);


GO