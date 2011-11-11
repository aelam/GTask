PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS "task_lists";
CREATE TABLE task_lists (
    local_list_id           INTEGER PRIMARY KEY AUTOINCREMENT,
    server_list_id          TEXT UNIQUE,
    kind                    TEXT,
    self_link               TEXT,
    title                   TEXT,
    is_default              INTEGER NOT NULL DEFAULT 0,	
    is_deleted              INTEGER NOT NULL DEFAULT 0,
    is_cleared              INTEGER NOT NULL DEFAULT 0,
    sort_type               INTEGER NOT NULL DEFAULT 0,
    
    display_order           INTEGER,

    latest_sync_timestamp   INTEGER DEFAULT 0,
    server_modify_timestamp INTEGER DEFAULT 0,
    local_modify_timestamp  INTEGER DEFAULT 0
);

DROP TABLE IF EXISTS "tasks";
CREATE TABLE tasks (
    local_task_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    server_task_id      TEXT UNIQUE,

    local_list_id       INTEGER NOT NULL,
    local_parent_id     INTEGER NOT NULL,
    display_order       INTEGER,
    removed             INTEGER DEFAULT 0,
    
    self_link           TEXT,
    title               TEXT,
    notes               TEXT,
    is_updated          INTEGER,
    is_completed        INTEGER NOT NULL DEFAULT 0,
    completed_timestamp INTEGER,
    reminder_timestamp  INTEGER,
    due                 INTEGER,
    is_hidden           INTEGER,
    is_deleted          INTEGER NOT NULL DEFAULT 0,
    is_cleared          INTEGER NOT NULL DEFAULT 0,

    server_modify_timestamp	INTEGER DEFAULT 0,
    local_modify_timestamp	INTEGER DEFAULT 0,
    
    FOREIGN KEY(local_list_id) REFERENCES task_lists(local_list_id) ON UPDATE CASCADE ON DELETE CASCADE
);
