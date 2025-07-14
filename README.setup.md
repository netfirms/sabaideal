# Setup Instructions

## Issue with bin/setup

When running `bin/setup`, you might encounter errors related to Ruby version compatibility. The project now requires Ruby 3.3.8 with Rails 8.0.2.

## Solution

We've provided two scripts to help with the setup process:

### 1. Repair Ruby Installation (if needed)

If you encounter errors related to missing Ruby executables or incompatible library versions, run:

```bash
bin/repair_ruby
```

This script will:
- Remove the existing Ruby 3.3.8 installation
- Install Ruby 3.3.8 again
- Set Ruby 3.3.8 as the default
- Install bundler
- Run bundle install

### 2. Setup with RVM

After repairing your Ruby installation (if needed), run:

```bash
bin/setup_with_rvm
```

This script ensures that RVM's Ruby 3.3.8 is used for the setup process, avoiding compatibility issues with the system Ruby.

## Manual Setup

If you prefer to set up manually, follow these steps:

1. Ensure you have Ruby 3.3.8 installed via RVM:
   ```bash
   rvm install 3.3.8
   rvm use 3.3.8
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Prepare the database:
   ```bash
   bin/rails db:prepare
   ```

4. Seed the database:
   ```bash
   bin/rails db:seed
   ```

5. Set up environment variables:
   ```bash
   cp .env.example .env  # If .env.example exists
   ```

6. Start the development server:
   ```bash
   bin/dev
   ```

## Changes Made

- Updated Ruby version in Gemfile from 2.7.1 to 3.3.8
- Rails version remains at 6.1.0
- Created bin/setup_with_rvm script to ensure RVM's Ruby is used
- Created bin/repair_ruby script to fix Ruby installation issues
