#!/bin/bash

# восстановление БД из скрипта в файле
#psql -h server1 -p 5432 -U postgres -f metadict-1.sql
psql -h server1 -p 5432 -U postgres -d metadict -f metadict.sql > metadict.log 2>&1
