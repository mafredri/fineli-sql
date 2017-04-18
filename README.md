# fineli-sql
This project takes Fineli, the [Finnish Food Composition Database](http://www.fineli.fi/index.php?lang=en), and converts it into SQL format.

Currently it creates a sqlite3 database and a sql dump that can be imported into PostgreSQL.

Sample queries are included in [queries.sql](queries.sql).

Included database version: Fineli Release 16.0

Much work could be put into processing the data and turning this into a more proper relational database structure with naming conventions that make more sense. Contributions to improve the database format are welcome.
