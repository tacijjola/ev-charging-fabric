CREATE TABLE [stg].[qa_rejected] (
    [session_id]       VARCHAR (8000) NULL,
    [plug_in_event_id] VARCHAR (8000) NULL,
    [station_name_raw] VARCHAR (8000) NULL,
    [start_date]       VARCHAR (8000) NULL,
    [currency]         VARCHAR (8000) NULL,
    [reject_reason]    VARCHAR (8000) NULL,
    [load_year]        INT            NULL,
    [_source_file]     VARCHAR (8000) NULL,
    [_rejected_at]     DATETIME2 (6)  NULL
);


GO