create table uploaded_files (
    id           number generated always as identity primary key,
    filename     varchar2(255) not null,
    content_type varchar2(255) not null,
    file_content blob not null,
    uploaded_at  timestamp default systimestamp not null
);

begin
    ords.define_module(
        p_module_name => 'file_uploads',
        p_base_path   => '/uploads/',
        -- Publish only after its access privilege has been configured.
        p_status      => 'NOT_PUBLISHED'
    );

    ords.define_template(
        p_module_name => 'file_uploads',
        p_pattern     => ':filename'
    );

    ords.define_handler(
        p_module_name => 'file_uploads',
        p_pattern     => ':filename',
        p_method      => 'POST',
        p_mimes_allowed => 'image/jpeg,image/png,image/bmp,image/vnd.microsoft.icon,image/x-icon,image/tiff,image/webp',
        p_source_type => ords.source_type_plsql,
        p_source      => q'~
declare
    l_content blob := :body;
begin
    photon_api.save_uploaded_file(
        "p_filename"     => :filename,
        "p_content_type" => :content_type,
        "p_content"      => l_content
    );

    commit;
    :status_code := 201;
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