#!/bin/bash
echo "Checking if tables exist in the database..."
bundle exec rails runner "puts ActiveRecord::Base.connection.tables.grep(/komplex/).sort"
echo "Table check completed."