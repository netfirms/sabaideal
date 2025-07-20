#!/bin/bash
echo "Checking migration status..."
bundle exec rails db:migrate:status
echo "Migration status check completed."