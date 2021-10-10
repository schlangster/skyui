dump_table = require('inspect')

function path_split(path)
    local steps = {}
    local idx = 1
    for str in string.gmatch(path, "([^/]+)") do
        steps[idx] = str
        idx = idx + 1
    end
    return steps
end

-- Given a (tree of) tables, starting at `root`...
-- Iteratively walk through the `path`, creating tables/nodes if required,
-- to set the given 'val'
--
-- See clojure's `assoc-in`
--
-- For example, the call
--  table_set_by_path({}, "hello/world", 1)
--
-- Should give us
--  { hello =
--    { world = 1 }
--  }
--
--  Returns:
--      root - on success
--      nil, err_msg - on failure
function table_set_by_path(root, path, val)
    local steps = path_split(path)
    local step_cnt = #steps

    -- Assuming we're dealing with a tree of tables
    -- Start walking at the passed root
    local cur = root
    for i, k in ipairs(steps) do
        if i == step_cnt then
            break
        end

        -- Try to get the table that's next level down
        local candidate = cur[k]

        -- Create the table right now, if it isn't present
        if not candidate then
            candidate = {}
            cur[k] = candidate

        -- If we reached a leaf node in the tree when we expected to be able to go further...
        -- Abort the walk with an error messsage
        elseif type(candidate) ~= "table" then
            return nil, string.format("[set_by_path] Path '%s' reached a val of type '%s' unexpectedly", table.concat(steps, "/", 1, i), type(candidate))
        end

        -- Update the cursor so we can walk deeper into the tree
        cur = candidate
    end

    cur[steps[step_cnt]] = val
    return root
end

-- Given a (tree of) tables, starting at `root`...
-- Iteratively walk through the `path` to fetch a value
-- If the item is not present, return the `default`
--
-- See clojure's `get-in`
--
--  Returns:
--      root - on success
--      nil, err_msg - on failure
function table_get_by_path(root, path, default)
    local steps = path_split(path)
    local step_cnt = #steps

    -- Assuming we're dealing with a tree of tables
    -- Start walking at the passed root
    local cur = root
    for i, k in ipairs(steps) do
        if i == step_cnt then
            break
        end

        -- Try to get the table that's next level down
        local candidate = cur[k]

        -- If we arrived at some leaf value or 'nil' (anything that is not a table)...
        -- Abort the walk with an error messsage
        if candidate == nil then
            return default
        elseif type(candidate) ~= "table" then
            return default, string.format("[get_by_path] Path '%s' reached a val of type '%s' unexpectedly", table.concat(steps, "/", 1, i), type(candidate))
        end

        -- Update the cursor so we can walk deeper into the tree
        cur = candidate
    end

    return cur[steps[step_cnt]] or default
end

function Form_FetchDataLazyInit(formID)
    local o = FormDB[formID]
    if not o then
        o = {}
        FormDB[formID] = o
    end
    return o
end

function Form_SetVal(formID, field_path, val)
    local o = Form_FetchDataLazyInit(formID)
    return table_set_by_path(o, field_path, val)
end

function Form_GetVal(formID, field_path, default_val)
    -- Fetch the table that stores the data associated with the form
    local o = FormDB[formID]
    if not o then
        return default_val
    end

    return table_get_by_path(o, field_path, default_val)
end

function Form_RemoveField(formID, field_path)
    return Form_SetVal(formID, field_path, nil)
end

function Form_RemoveAllFields(formID)
    FormDB[formID] = nil
end

function FormDB_init()
    FormDB = {}
end

-- Do no reinitialize the FormDB if already present
if not _G["FormDB"] then
    FormDB_init()
end
