#!/bin/bash

# дамп БД в файл
pg_dump -h server1 -p 5432 -U postgres metadict > ../sql/metadict.sql

# архивация с датой в имени
#backupFName="metadict.$(date +%Y-%m-%d_%H-%M-%S)"
#pg_dump -h server1 -p 5432 -U postgres metadict | 7z a "$backupFName".7z -si"$backupFName".sql


