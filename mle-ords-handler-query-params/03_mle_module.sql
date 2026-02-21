--liquibase formatted sql
--changeset queryparams:03 endDelimiter:/

create or replace mle module JAVASCRIPT_IMPL_MODULE language javascript as

/**
 * Get a single action item - handler. This function is invoked by ORDS
 * 
 * The actual work is done by getActionItem() below.
 * 
 * @param {object} req the request object, as provided by ORDS
 * @param {object} resp the corresponding response object 
 */
export function getActionItemHandler(req, resp) {
    try {
        const input = {
            id: req.uri_parameters.id
        }

        const data = getActionItem(input);

        if (! data) {
            resp.status(404);
        } else {
            resp.status(200);
            resp.content_type('application/json');
            resp.json(data);
        }
    } catch (err) {
        resp.status(500);
    }
}

function getActionItem({id}) {

    const result = session.execute(
        `select 
            json_arrayagg(
                json{
                    'actionId':      a.id,
                    'actionName':    a.name,
                    'status':        a.status,
                    'team' value (
                        select json_arrayagg(
                            json{
                                'assignmentId': tm.id,
                                'role':         tm.role,
                                'staffId':      tm.user_id,
                                'staffName':    s.name
                            }
                            order by tm.role desc, s.name
                        )
                        from
                            action_item_team_members tm
                            join staff s on s.id = tm.user_id
                        where
                            tm.action_id = a.id
                    )
                }
            ) as action_items_json
        from
            action_items a
        where
            a.id = :id`,
        [ id ]
    );

    return result.rows[0].ACTION_ITEMS_JSON;
}

/**
 * Get all action items - handler. This function is invoked by ORDS.
 * 
 * Enables pagination. In order to do so this function parses the request
 * object's query_parameters object and assigns sensible defaults
 * 
 * The actual work is done by getAllActionItems() below.
 * 
 * @param {object} req the request object, as provided by ORDS
 * @param {object} resp the corresponding response object 
 */
export function getAllActionItemsHandler(req, resp) {
    
    // no console.log() in production!
    console.log('req: ' + JSON.stringify(req));

    try {
        let searchPattern = req.query_parameters?.search;

        if (! searchPattern) {
            searchPattern = '%';
        } else if (! /^[A-Za-z0-9]+$/.test(searchPattern)) {
            resp.status(400);
            resp.content_type("application/json");
            resp.json({
                error: 'Invalid query parameter (search)',
                message: 'search pattern must only contain letters and numbers'
            });
            return;
        } else {
            searchPattern = `%${searchPattern}%`;
        }

        let saneLimit = Number.parseInt(req.query_parameters?.limit ?? "25", 10);
        if (saneLimit <= 1 || saneLimit > 100 || !Number.isInteger(saneLimit)) {
            resp.status(400);
            resp.content_type("application/json");
            resp.json({
                error: 'Invalid query parameter (limit)',
                message: 'limit must be an integer in the range [1,100]'
            });
            return;
        }

        let saneOffset = Number.parseInt(req.query_parameters?.offset ?? "0", 10);
        if (saneOffset < 0 || saneOffset > 100 || !Number.isInteger(saneOffset)) {
            resp.status(400);
            resp.content_type("application/json");
            resp.json({
                error: 'Invalid query parameter (offset)',
                message: 'offset must be an integer in the range [0,100]'
            });
            return;
        }

        const input = {
            search: searchPattern,
            limit: saneLimit,
            offset: saneOffset
        }

        console.log('input: ' + JSON.stringify(input));

        const data = getAllActionItems(input);

        resp.status(200);
        resp.content_type('application/json');
        resp.json(data);
        
    } catch (err) {
        // use more robust error handling in production
        console.log(err);
        resp.status(500);
    }
}

function getAllActionItems({search, limit, offset}) {

    const result = session.execute(
        `select
            count(*) over () as total_count,
            json{
                'actionId':      a.id,
                'actionName':    a.name,
                'status':        a.status,
                'team' value (
                    select json_arrayagg(
                        json{
                            'assignmentId': tm.id,
                            'role':         tm.role,
                            'staffId':      tm.user_id,
                            'staffName':    s.name
                        }
                        order by tm.role desc, s.name
                    )
                    from
                        action_item_team_members tm
                        join staff s on s.id = tm.user_id
                    where
                        tm.action_id = a.id
                )
            } as actionItem
        from
            action_items a
        where
            upper(a.name) like upper(:search)
        offset :offset rows fetch first :limit rows only`,
        {
            search: {
                dir: oracledb.BIND_IN,
                val: search
            },
            offset: {
                dir: oracledb.BIND_IN,
                val: offset
            },
            limit: {
                dir: oracledb.BIND_IN,
                val: limit
            }
        },
        {
            fetchTypeHandler: (metaData) => {
                // convert every column name to lower case
                metaData.name = metaData.name.toLowerCase();
            }
        }
    );

    // just in case the search didn't reveal anything
    if (result.rows?.length === 0)
        return {
            "items": [],
            "hasMore": false,
            "totalRows": 0
    };

    // column names are lower case thanks to the fetch type handler
    const totalRows = result.rows[0].total_count;
    const rowCount = result.rows.length;

    return {
        "items": result.rows,
        "hasMore": (offset + rowCount < totalRows),
        "totalRows": totalRows
    }
}
/
