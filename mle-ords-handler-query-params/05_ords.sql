--liquibase formatted sql
--changeset queryparams:05

-- ORDS handlers, written entirely in JavaScript
declare
    c_module_name       constant varchar2(255) := 'js';
    c_single_pattern    constant varchar2(255) := 'actionItem/:id';
    c_all_pattern       constant varchar2(255) := 'actionItem/';
begin
    ords.enable_schema;
    ords.define_module(
        p_module_name    => c_module_name,
        p_base_path      => '/js/',
        p_status         => 'PUBLISHED',
        p_items_per_page => 25,
        p_comments       => 'ORDS handlers written in JavaScript'
    );
 
    -- template to work with a single item
    ords.define_template(
        p_module_name    => c_module_name,
        p_pattern        => c_single_pattern,
        p_priority       => 0,
        p_etag_type      => 'HASH',
        p_etag_query     => null,
        p_comments       => 'single action item'
    );

    -- work with more than 1 item/handle POST operations
    ords.define_template(
        p_module_name    => c_module_name,
        p_pattern        => c_all_pattern,
        p_priority       => 0,
        p_etag_type      => 'HASH',
        p_etag_query     => null,
        p_comments       => 'potentially multiple action items and/or POST'
    );
 
    -- get a single action item
    ords.define_handler(
        p_module_name    => c_module_name,
        p_pattern        => c_single_pattern,
        p_method         => 'GET',
        p_source_type    => 'mle/javascript',
        p_mle_env_name   => 'JAVASCRIPT_IMPL_ENV',
        p_items_per_page => 0,
        p_mimes_allowed  => null,
        p_comments       => null,
        p_source         => q'~
async (req, resp) => {
 
    const { getActionItemHandler } = await import ('handlers');
    getActionItemHandler(req, resp);
}    
    ~'
    );

    -- get all action items, with optional filtering and pagination
    ords.define_handler(
        p_module_name    => c_module_name,
        p_pattern        => c_all_pattern,
        p_method         => 'GET',
        p_source_type    => 'mle/javascript',
        p_mle_env_name   => 'JAVASCRIPT_IMPL_ENV',
        p_items_per_page => 0,
        p_mimes_allowed  => null,
        p_comments       => null,
        p_source         => q'~
(req, resp) => {
 
    const { getAllActionItemsHandler } = await import ('handlers');
    getAllActionItemsHandler(req, resp);
}    
    ~'
    );

 
    commit;
 
end;
/