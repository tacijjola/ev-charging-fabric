CREATE TABLE [gold].[load_log] (
    [run_id]        VARCHAR (64)  NOT NULL,
    [step]          VARCHAR (50)  NOT NULL,
    [rows_affected] BIGINT        NULL,
    [logged_at]     DATETIME2 (6) NOT NULL
);


GO