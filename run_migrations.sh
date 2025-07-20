#!/bin/bash
echo "Running migrations..."
bundle exec rails db:migrate
echo "Migrations completed."