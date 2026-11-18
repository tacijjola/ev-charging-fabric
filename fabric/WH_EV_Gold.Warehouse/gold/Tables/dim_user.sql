CREATE TABLE [gold].[dim_user] (
    [user_key]      INT          NOT NULL,
    [user_id]       VARCHAR (20) NOT NULL,
    [session_count] INT          NOT NULL,
    [user_band]     VARCHAR (10) NOT NULL
);


GO

ALTER TABLE [gold].[dim_user]
    ADD CONSTRAINT [pk_dim_user] PRIMARY KEY NONCLUSTERED ([user_key] ASC) NOT ENFORCED;


GO