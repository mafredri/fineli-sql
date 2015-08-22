#!/usr/bin/env zsh

BUILD=build
FINELI_DB=Fineli_Rel16_open
DATABASE=$BUILD/fineli.db

[[ -f $DATABASE ]] && rm $DATABASE

print "Importing csv files into database..."

typeset -a tables
skip=(_FI _SV _TX)
for table in data/${FINELI_DB}/*.csv; do
    for s in $skip; do
        if [[ $table =~ $s ]]; then
            continue 2
        fi
    done

    local name=${table:t:r}
    name="${name//_EN/}_csv"
    tables+=($name)

    print ".separator \";\"\n.import $table $name" | sqlite3 $DATABASE \
        2>&1 | grep -v "/publication.csv:"
done

print "\nProcessing tables..."
sqlite3 $DATABASE <process_tables.sql

print "\nDropping unused tables..."
for table in $tables; do
    sqlite3 $DATABASE "DROP TABLE ${table};"
done

print "\nCreating postgres dump..."
sqlite3 $DATABASE .dump \
    | grep -v "^PRAGMA" \
    | awk '{ gsub(/integer PRIMARY KEY/, "SERIAL PRIMARY KEY"); print }' \
    >| $BUILD/postgres_iso-8859-1.sql

iconv -f iso-8859-1 -t utf-8 $BUILD/postgres_iso-8859-1.sql \
    >| $BUILD/postgres_utf8.sql

rm $BUILD/postgres_iso-8859-1.sql

print "\nAll done!"

exit 0
