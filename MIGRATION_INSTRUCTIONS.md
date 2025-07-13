# Migration Instructions

## Issue Description

There are 8 pending migrations that need to be run:

```
Migrations are pending. To resolve this issue, run:
bin/rails db:migrate
You have 8 pending migrations:
db/migrate/20250713101854_create_komplex_services.komplex.rb
db/migrate/20250713101855_create_komplex_promotions.komplex.rb
db/migrate/20250713101856_create_komplex_advertisements.komplex.rb
db/migrate/20250713101857_create_komplex_commissions.komplex.rb
db/migrate/20250713101858_create_komplex_payouts.komplex.rb
db/migrate/20250713101859_create_komplex_reviews.komplex.rb
db/migrate/20250713101860_create_komplex_conversations.komplex.rb
db/migrate/20250713101861_create_komplex_messages.komplex.rb
```

## Ruby Environment Issues

Attempts to run the migrations directly encountered Ruby environment issues. The system is trying to use Ruby 3.3.8 as specified in the project, but this version is not installed in the RVM environment.

## Resolution Steps

### Option 1: Install Required Ruby Version

1. Install Ruby 3.3.8 using RVM:
   ```bash
   rvm install 3.3.8
   ```

2. Use the setup script to run migrations:
   ```bash
   bin/setup_with_rvm
   ```

### Option 2: Run Migrations with Current Ruby Version

If you prefer not to install Ruby 3.3.8, you can modify the `bin/migrate_with_rvm` script to use your current Ruby version:

1. Open the script:
   ```bash
   nano bin/migrate_with_rvm
   ```

2. Change the Ruby version to match your installed version:
   ```bash
   # Use your installed Ruby version
   rvm use 2.7.1  # Replace with your version
   ```

3. Make the script executable:
   ```bash
   chmod +x bin/migrate_with_rvm
   ```

4. Run the script:
   ```bash
   ./bin/migrate_with_rvm
   ```

### Option 3: Run Migrations Directly

If you have a working Ruby environment, you can run the migrations directly:

```bash
bin/rails db:migrate
```

## Verification

After running the migrations, you can verify that they were applied successfully by checking the schema version:

```bash
bin/rails db:version
```

Or by running:

```bash
bin/rails db:migrate:status
```

This should show that all migrations have been applied.