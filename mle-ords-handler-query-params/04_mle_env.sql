--liquibase formatted sql
--changeset queryparams:04

create or replace mle env JAVASCRIPT_IMPL_ENV imports (
    'handlers' module JAVASCRIPT_IMPL_MODULE
);