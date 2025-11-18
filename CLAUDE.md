# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **DeFi Tracker**, a Rails 8.1 application for crypto portfolio tracking. The product allows users to track their cryptocurrency holdings across multiple wallets, exchanges, and chains in a single unified interface. The application is designed to be mobile-first and targets active crypto users managing diversified portfolios.

### Tech Stack
- **Framework**: Ruby on Rails 8.1
- **Ruby Version**: 3.3.0
- **Database**: SQLite3 (with separate databases for primary, cache, queue, and cable in production)
- **Asset Pipeline**: Propshaft
- **Frontend**: Hotwire (Turbo + Stimulus), Importmap for JavaScript
- **Server**: Puma
- **Deployment**: Kamal (Docker-based)
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable

### Key Dependencies
- **Testing**: Capybara, Selenium WebDriver
- **Security**: Brakeman, Bundler Audit
- **Code Quality**: RuboCop Rails Omakase
- **Image Processing**: image_processing gem
- **Build/Deploy**: Thruster (HTTP caching/compression)

## Development Commands

### Initial Setup
```bash
bin/setup
```
This will:
- Install dependencies with `bundle install`
- Prepare the database with `bin/rails db:prepare`
- Clear logs and temp files
- Start the development server

To setup without starting server:
```bash
bin/setup --skip-server
```

To reset the database during setup:
```bash
bin/setup --reset
```

### Running the Application
```bash
bin/dev
```
This starts the Rails server (wraps `bin/rails server`).

### Testing
```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/some_model_test.rb

# Run specific test by line number
bin/rails test test/models/some_model_test.rb:12

# Run system tests
bin/rails test:system
```

### Database Operations
```bash
# Create database
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Reset database (drop, create, migrate, seed)
bin/rails db:reset

# Prepare database (create if doesn't exist, then migrate)
bin/rails db:prepare

# Open database console
bin/rails dbconsole
```

### Code Quality & Security
```bash
# Run RuboCop linter
bin/rubocop

# Auto-fix RuboCop violations
bin/rubocop -A

# Run security audit on gems
bin/bundler-audit

# Update bundler-audit database
bin/bundler-audit update

# Run Brakeman security scanner
bin/brakeman
```

### Continuous Integration
```bash
bin/ci
```
This runs the CI suite (defined in `config/ci.rb`).

### Rails Console & Other Tools
```bash
# Open Rails console
bin/rails console

# Open Rails console in sandbox mode (rollback changes on exit)
bin/rails console --sandbox

# View routes
bin/rails routes

# View routes for specific controller
bin/rails routes -c users

# Generate migration
bin/rails generate migration AddFieldToModel field:type
```

### Deployment (Kamal)
```bash
# Deploy application
bin/kamal deploy

# Check deployment status
bin/kamal app details

# View logs
bin/kamal app logs

# SSH into production container
bin/kamal app exec -i bash
```

## Code Architecture

### Multi-Database Configuration (Production)

Rails is configured with **four separate SQLite databases** in production:

1. **Primary** (`storage/production.sqlite3`) - Main application data
2. **Cache** (`storage/production_cache.sqlite3`) - Solid Cache storage (migrations in `db/cache_migrate/`)
3. **Queue** (`storage/production_queue.sqlite3`) - Solid Queue background jobs (migrations in `db/queue_migrate/`)
4. **Cable** (`storage/production_cable.sqlite3`) - Solid Cable WebSockets (migrations in `db/cable_migrate/`)

When creating migrations, ensure they target the correct database:
- Default migrations go to `db/migrate/` for the primary database
- Cache-related migrations go to `db/cache_migrate/`
- Queue-related migrations go to `db/queue_migrate/`
- Cable-related migrations go to `db/cable_migrate/`

### Frontend Architecture

This application uses **Hotwire** (Turbo + Stimulus) for a modern, SPA-like experience without complex JavaScript frameworks:

- **Turbo Drive**: Accelerates page navigation
- **Turbo Frames**: Allows partial page updates
- **Turbo Streams**: Enables real-time updates over WebSockets
- **Stimulus**: Lightweight JavaScript for interactive components
- **Importmap**: JavaScript module management without bundling

When adding frontend interactivity:
1. Prefer Turbo Frames/Streams for server-rendered updates
2. Use Stimulus controllers for client-side behavior
3. Keep JavaScript minimal and focused

### Background Jobs

Use **Solid Queue** for background processing. Jobs are stored in the SQLite queue database.

```ruby
# Example job
class SomeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Job logic
  end
end

# Enqueue a job
SomeJob.perform_later(arg1, arg2)
```

### Caching Strategy

The application uses **Solid Cache** backed by SQLite for caching. Cache storage is in a separate database to avoid bloating the primary database.

```ruby
# Cache usage
Rails.cache.fetch("key", expires_in: 12.hours) do
  # Expensive operation
end
```

### Styling & Code Conventions

This project follows **Rails Omakase** conventions via `rubocop-rails-omakase`:
- Ruby styling follows Rails community standards
- Run `bin/rubocop -A` to auto-fix violations before committing
- Configuration in `.rubocop.yml`

## Product Context

### Target Users
- **Active DeFi Users**: Managing assets across 3-8 protocols on 2-4 chains
- **Multi-Exchange Traders**: Using 3-6 centralized exchanges
- **NFT Collectors**: Tracking NFT and crypto holdings
- **Crypto Earners**: Freelancers/remote workers paid in crypto

### Core Features (from business docs)
1. **Portfolio Aggregation**: Unified view of wallets + exchanges
2. **Multi-Chain Support**: Ethereum, Solana, Polygon, Arbitrum, etc.
3. **DeFi Protocol Tracking**: Auto-detect positions across 400+ protocols
4. **Real-Time Updates**: Portfolio value updates (30s for Plus, 5s for Pro)
5. **Analytics & P&L**: Performance tracking, ROI calculation, cost basis
6. **Tax Reporting**: Transaction exports, tax report generation
7. **Alerts**: Price alerts, portfolio changes, DeFi health factors
8. **NFT Tracking**: Floor prices, rarity, collection stats

### Pricing Tiers (from business docs)
- **Free**: 5 wallets, 2 CEX connections, basic features
- **Plus ($9.99/mo)**: 15 wallets, 5 CEX, real-time updates, mobile app
- **Pro ($29.99/mo)**: 50 wallets, unlimited CEX, advanced analytics
- **Ultimate ($79.99/mo)**: Unlimited wallets, team collaboration, tax reporting

## Testing Strategy

When writing tests:
1. Use fixtures for test data
2. System tests for end-to-end user flows (Capybara + Selenium)
3. Integration tests for controller actions
4. Unit tests for models and business logic
5. Test security-critical features thoroughly (API key encryption, read-only access)

## Security Considerations

This is a **financial application** dealing with sensitive data:

1. **Never request private keys** - Only read-only wallet addresses
2. **Never request withdrawal permissions** - API keys must be read-only
3. **Encrypt all API keys** - Use Rails encrypted credentials or Active Record encryption
4. **Validate all external API data** - Don't trust blockchain/exchange data blindly
5. **Rate limit external requests** - Avoid hitting API limits
6. **Run security audits regularly** - Use `bin/brakeman` and `bin/bundler-audit`

## Deployment Architecture

**Kamal** handles Docker-based deployment:
- Application runs in Docker containers
- SQLite databases are mounted as persistent volumes
- Configuration in `.kamal/` directory
- Use `bin/kamal` for deployment operations

## Important Files

- **Business Requirements**: `ai_docs/business/gtm_manifest.md` - Complete product, pricing, and GTM strategy
- **Database Config**: `config/database.yml` - Multi-database setup
- **Routes**: `config/routes.rb` - Application routing (currently minimal)
- **Deployment**: `.kamal/` - Kamal deployment configuration
- **Docker**: `Dockerfile`, `.dockerignore` - Container configuration

## Development Workflow

1. Create feature branch from `main`
2. Write tests first (TDD approach recommended)
3. Implement feature
4. Run `bin/rubocop -A` to fix style issues
5. Run `bin/ci` to ensure all checks pass
6. Run security tools: `bin/brakeman` and `bin/bundler-audit`
7. Commit and push
8. Deploy with `bin/kamal deploy` when ready for production
