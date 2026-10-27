set serveroutput on
spool off

declare
    l_client_creds  ords_types.t_client_credentials;

    l_priv_roles    owa.vc_arr;
    l_priv_patterns owa.vc_arr;
    l_priv_modules  owa.vc_arr;
begin

    -- create the role first
    ords.create_role(p_role_name => 'photon_api_role');

    -- followed by the privileges
    l_priv_roles(1) := 'photon_api_role';
    l_priv_modules(1) := 'file_uploads';
    l_priv_modules(2) := 'photon_api';
    ords.define_privilege(
        p_privilege_name => 'photon.api.privilege',
        p_roles          => l_priv_roles,
        p_patterns       => l_priv_patterns,
        p_modules        => l_priv_modules,
        p_label          => 'photon api privilege',
        p_description    => 'A privilege covering the /uploads and /photos endpoints',
        p_comments       => ''
    );

    -- cumulating in the OAuth2 client creation
    l_client_creds := ords_metadata.ords_security.register_client(
        p_name                       => 'photon_api_client',
        p_grant_type                 => 'client_credentials',
        p_support_email              => 'someone@example.com',
        p_description                => 'a client permitted to access both /uploads and /photos endpoints',
        p_client_secret              => ords_constants.oauth_client_secret_default,
        p_privilege_names            => 'photon.api.privilege',
        p_origins_allowed            => '',
        p_redirect_uri               => '',
        p_support_uri                => '',
        p_token_endpoint_auth_method => 'CLIENT_SECRET_BASIC'
    );

    -- client secret and ID can only be displayed _once_, secret
    -- must be rotated should it get lost
    dbms_output.put_line('CLIENT_ID: ' || l_client_creds.client_key.client_id);
    dbms_output.put_line('CLIENT_SECRET: ' || l_client_creds.client_secret.secret);

    /**
     * in case the client secret gets lost, rotate it
     *
     * set serveroutput on
     * spool off
     * 
     * declare
     *     l_credentials ords_types.t_client_credentials;
     * begin
     *     l_credentials := ords_security.rotate_client_secret(
     *         p_client_key => ords_types.oauth_client_key(
     *             p_name => 'photon_api_client'
     *         )
     *     );
     *     commit;
     * 
     *     dbms_output.put_line('CLIENT_ID: ' ||
     *         l_credentials.client_key.client_id);
     *     dbms_output.put_line('CLIENT_SECRET: ' ||
     *         l_credentials.client_secret.secret);
     * end;
     */
    
    -- add the role to the client
    ords_metadata.ords_security.grant_client_role(
        p_client_name => 'photon_api_client',
        p_role_name   => 'photon_api_role'
    );

    -- with everything in place, enable the endpoints
    ords.publish_module(
        p_module_name => 'file_uploads',
        p_status      => 'PUBLISHED'
    );

    ords.publish_module(
        p_module_name => 'photon_api',
        p_status      => 'PUBLISHED'
    );

    commit;
end;
/

-- IMPORTANT! note down both client ID and client secret

/**
 * get the bearer token like so (or use Database Actions)
 * curl \
 * --user ${CLIENT_ID}:${CLIENT_SECRET} \
 * --data 'grant_type=client_credentials' \
 * https:/example.com/ords/emily/oauth/token
 */