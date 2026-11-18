CREATE TABLE [gold].[dim_end_reason] (
    [end_reason_key]   INT          NOT NULL,
    [ended_by]         VARCHAR (40) NOT NULL,
    [end_reason_group] VARCHAR (10) NOT NULL,
    [is_fault]         BIT          NOT NULL
);


GO

ALTER TABLE [gold].[dim_end_reason]
    ADD CONSTRAINT [pk_dim_end_reason] PRIMARY KEY NONCLUSTERED ([end_reason_key] ASC) NOT ENFORCED;


GO