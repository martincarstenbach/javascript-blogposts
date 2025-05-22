set serveroutput on;
declare
    l_ctx           dbms_mle.context_handle_t;
    l_source_code   clob;
begin
    -- Create execution context for MLE execution and provide an environment_
    l_ctx    := dbms_mle.create_context('JIMP_ENV');
	
    -- using q-quotes to avoid problems with unwanted string termination
    l_source_code := 
q'~

// dynamic imports require the use of an IIFE. See
// https://developer.mozilla.org/en-US/docs/Glossary/IIFE
(async() => {

    // the "application"
    const { image2Greyscale } = await import ('jimp');

    // required polyfills for JIMP. In this case they must be added to the global scope
    const { setTimeout, clearTimeout, setInterval, clearInterval } = await import ('polyfill');
    globalThis.setTimeout = setTimeout;
    globalThis.clearTimeout = clearTimeout;
    globalThis.setInterval = setInterval;
    globalThis.clearInterval = clearInterval;

    // this query reads the first image from the table as a UInt8Array
    let result = session.execute(
        'select IMAGE from demo_images where id = :id',
        [ 1 ], 
        {
            fetchInfo: {
                IMAGE: {
                    type: oracledb.UINT8ARRAY
                }
            }
        }
    );

    console.log(`fetched ${result.rows.length} rows`);

    if (result.rows.length !== 1) {
        throw new Error('something went wrong fetching the image from the table');
    }

    // let's pretend the BLOB is a file and transform it
    const file = result.rows[0].IMAGE.buffer;
    const transformedFile = await image2Greyscale(file);
    console.log('file successfully transformed');

    // let's start the preparations for storing the converted PNG in the database
    // the first step is to allocate a BLOB.
    let theBLOB = OracleBlob.createTemporary(false);
    console.log('new blob allocated');

    theBLOB.open(OracleBlob.LOB_READWRITE);
    console.log('blob opened r/w');

    theBLOB.write(1, transformedFile);
    console.log('blob successfully populated');

    // database insert
    result = session.execute(
        `insert into demo_images(
            image
        ) values(
            :theBLOB
        )
        returning id into :id`,
        {
            theBLOB:{
                type: oracledb.ORACLE_BLOB,
                dir: oracledb.BIND_IN,
                val: theBLOB
            }, id: {
                type: oracledb.NUMBER,
                dir: oracledb.BIND_OUT
            }
        }
    );

    // clean up
    theBLOB.close();

    console.log(
        `transformed image successfully saved with ID ${result.outBinds.id[0]}`
    );
})()
~';
    dbms_mle.eval(
        context_handle => l_ctx,
        language_id => 'JAVASCRIPT',
        source => l_source_code
    );

    dbms_mle.drop_context(l_ctx);

    commit;
exception
    when others then
        dbms_mle.drop_context(l_ctx);
        raise;
end;
/

commit;