nedbmgr
================================

`nedbmgr` or NeDB Manager is a basic and scriptable/customizable database manager for NeDB databases (NeDB, he JavaScript Database, for Node.js, nw.js, electron and the browser, find more in https://github.com/louischatriot/nedb)

## Concept

The management of a noSQL database or a non-relational database is rather different than a traditional mySQL-esque database. Since there is no fixed schema, it is impossible (without external schema managers) to validate/conform to the type/length etc of properties of collections.

`nedbmgr` solved this problem by bypassing the strict query interface altogether. Rather it aims at enabling a very versatile query interface that allows storing and tagging of JSON queries and quickly switching between them.

## Features

1. Query Interface, full support for Searching, Insertion, Update, Deletetion
2. Storing and Tagging Queries and Filtering Queries by Tag
3. Safe $where. Refer to external function by ID and so disallowing code injection.
4. In UI individual data editing
5. Validating JSON queries
6. Validating queries (checking compliance with nedb)
7. Aggregate Coffee-script/Javascript Code to JSON

