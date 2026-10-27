begin
    ords.define_module(
        p_module_name => 'photon_api',
        p_base_path   => '/photon/',
        p_status      => 'NOT_PUBLISHED',
        p_comments    => 'Photo inspection and resizing with Photon WASM'
    );

    ords.define_template(
        p_module_name => 'photon_api',
        p_pattern     => 'photos/:id'
    );

    ords.define_handler(
        p_module_name    => 'photon_api',
        p_pattern        => 'photos/:id',
        p_method         => 'GET',
        -- ORDS GET uses a SQL media handler to return the PL/SQL result as JSON.
        p_source_type    => ords.source_type_media,
        p_items_per_page => 0,
        p_source         => q'~
select
    'application/json' as content_type,
    json_serialize(
        photon_api.photo_details(to_char(f.id, 'TM9')) returning clob
    ) as response_body
from
    uploaded_files f
where
    f.id = :id;
~'
    );

    ords.define_template(
        p_module_name => 'photon_api',
        p_pattern     => 'photos/:id/resize'
    );

    ords.define_handler(
        p_module_name    => 'photon_api',
        p_pattern        => 'photos/:id/resize',
        p_method         => 'POST',
        p_source_type    => ords.source_type_plsql,
        p_items_per_page => 0,
        p_source         => q'~
declare
    l_id         varchar2(4000) := trim(:id);
    l_numeric_id number;
    l_new_id     number;
    l_response   varchar2(4000);

    procedure send_json(p_status pls_integer, p_body varchar2) is
    begin
        :status_code := p_status;
        owa_util.mime_header('application/json', false);
        owa_util.http_header_close;
        htp.prn(p_body);
    end;
begin
    l_numeric_id := to_number(l_id default null on conversion error);
    if l_id is null or not regexp_like(l_id, '^[0-9]+$')
       or l_numeric_id is null
       or l_numeric_id < 1 or l_numeric_id > 1e9 then
        send_json(400, '{"error":"A positive integer photo ID is required"}');
        return;
    end if;

    select
        id into l_numeric_id
    from
        uploaded_files
    where
        id = l_numeric_id;

    l_new_id := photon_api.resize_photo(to_char(l_numeric_id, 'TM9'));

    l_response := json_object('id' value l_new_id returning varchar2);
    
    commit;
    send_json(201, l_response);
exception
    when no_data_found then
        rollback;
        send_json(404, '{"error":"Photo not found"}');
    when others then
        rollback;
        -- Keep database exception details out of the HTTP response.
        send_json(500, '{"error":"The resized photo could not be created"}');
end;
~'
    );

    commit;
exception
    when others then
        rollback;
        raise;
end;
/