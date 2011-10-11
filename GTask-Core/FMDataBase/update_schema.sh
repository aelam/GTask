#!/bin/bash 
APP_NAME="GTask\-iOS.app"
SQL_FILE="GTaskSchema.sql" 
SQLITE_FILE_IN_BUNDLE="GTask.sqlite" 
#SQLITE_FILE_IN_SIM          = 
SDK_VERSION="5.0"
SIMULATOR_PATH="${HOME}/Library/Application Support/iPhone Simulator/${SDK_VERSION}/Applications/"

echo "$PWD"
BUNDLE_DB_PATH="$PWD/$SQLITE_FILE_IN_BUNDLE"

echo "$BUNDLE_DB_PATH"

if [ ! -f "$SQL_FILE" ]; then
    echo "$SQL_FILE" "does not exist!"
else
    echo "$SQL_FILE" "exists"
fi


if [ ! -f "$SQLITE_FILE_IN_BUNDLE" ]; then
    echo "$SQLITE_FILE_IN_BUNDLE" "does not exist!"
    exit
else
    echo "$SQLITE_FILE_IN_BUNDLE" "exists"
fi

echo "UPDATE BUNDLE SQLITE FILE..."
cat "$SQL_FILE" | sqlite3 "$SQLITE_FILE_IN_BUNDLE"
echo "DONE!"
cd "$SIMULATOR_PATH"

find "$PWD" -name "$SQLITE_FILE_IN_BUNDLE"

find "$PWD" -name "$SQLITE_FILE_IN_BUNDLE" | xargs -I ']' rm -rf "']'"

