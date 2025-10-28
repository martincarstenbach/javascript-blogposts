
--
        
DECLARE
  l_roles     OWA.VC_ARR;
  l_modules   OWA.VC_ARR;
  l_patterns  OWA.VC_ARR;

BEGIN
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'demouser',
      p_auto_rest_auth      => FALSE);

  ORDS.DEFINE_MODULE(
      p_module_name    => 'mle_mock_validation_api',
      p_base_path      => '/api/v1/',
      p_items_per_page => 25,
      p_status         => 'PUBLISHED',
      p_comments       => 'mock validation API using MLE');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'mle_mock_validation_api',
      p_pattern        => 'validate/',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => 'a quick mock-up of a validation for a product''s status');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'mle_mock_validation_api',
      p_pattern        => 'validate/',
      p_method         => 'POST',
      p_source_type    => 'mle/javascript',
      p_mle_env_name   => 'BLOGPOST_ENV',
      p_items_per_page => 0,
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         => 
'
(req, resp) => {

    const { validate } = await import ("rest");

    const result = validate(req.body);

    resp.content_type("application/json");
    resp.status = 400;
    resp.json({ message: result.message });
}
');

  ORDS.CREATE_ROLE(
      p_role_name=> 'oracle.dbtools.role.autorest.DEMOUSER');
  ORDS.CREATE_ROLE(
      p_role_name=> 'oracle.dbtools.role.autorest.any.DEMOUSER');
  l_roles(1) := 'oracle.dbtools.autorest.any.schema';
  l_roles(2) := 'oracle.dbtools.role.autorest.DEMOUSER';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.dbtools.autorest.privilege.DEMOUSER',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'DEMOUSER metadata-catalog access',
      p_description    => 'Provides access to the metadata catalog of the objects in the DEMOUSER schema.',
      p_comments       => NULL); 

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;

  l_roles(1) := 'SODA Developer';
  l_patterns(1) := '/soda/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.soda.privilege.developer',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => NULL,
      p_description    => NULL,
      p_comments       => NULL); 

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;


COMMIT;

END;
/


-- sqlcl_snapshot {"hash":"a8d5f5819b7bf15eca2ae080395366a2a3963cd6","type":"ORDS_SCHEMA","name":"ords","schemaName":"DEMOUSER","sxml":""}