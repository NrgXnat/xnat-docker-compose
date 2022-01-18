#!/bin/sh

psql -U postgres -h localhost < reset-tables.sql
