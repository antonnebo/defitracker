# DeFi Tracker - Product Roadmap

**Last Updated**: 2025-12-01
**Current Phase**: Phase 1 ✅ Complete

---

## 🎯 Overview

This roadmap outlines the development plan for DeFi Tracker, a crypto portfolio tracking application targeting active DeFi users managing diversified portfolios across multiple wallets, exchanges, and chains.

---

## ✅ Phase 1: Authentication & Foundation (Week 1-2) - **COMPLETE**

### Status: ✅ Done

### Completed Features:
- [x] Rails 8.1 native authentication system
- [x] Email/password registration and login
- [x] Password reset flow with email
- [x] Session management with secure cookies
- [x] Rate limiting (10 attempts per 3 minutes)
- [x] User model with validations
- [x] Beautiful auth pages matching landing page design
- [x] Landing page with CTAs linking to registration
- [x] Dashboard placeholder for logged-in users
- [x] Russian language UI

### Technical Stack:
- Ruby 3.3.0
- Rails 8.1.1
- SQLite3 (multi-database setup)
- Hotwire (Turbo + Stimulus)
- bcrypt for password hashing

---

## 📋 Phase 2: User Profile & Settings (Week 2)

### Status: 🔄 Up Next

### Goals:
- Allow users to manage their account settings
- Build foundation for wallet/exchange management

### Tasks:
- [ ] Create user profile page
  - [ ] Display user email and account info
  - [ ] Show account creation date
  - [ ] Display current plan (Free/Plus/Pro)
- [ ] Add profile edit functionality
  - [ ] Change email address
  - [ ] Change password
  - [ ] Delete account (with confirmation)
- [ ] Create settings page
  - [ ] Notification preferences
  - [ ] Currency preference (USD, EUR, RUB)
  - [ ] Time zone settings
  - [ ] Theme toggle (dark mode default)
- [ ] Add navigation to dashboard
  - [ ] Sidebar with menu items
  - [ ] Profile dropdown
  - [ ] Responsive mobile menu

### Acceptance Criteria:
- Users can update their email and password
- Users can set currency and timezone preferences
- Settings are persisted and used across the app
- All forms have proper validation and error messages

---

## 🔗 Phase 3: Wallet Management (Week 3)

### Status: 📅 Planned

### Goals:
- Allow users to add cryptocurrency wallet addresses
- Support multiple blockchain networks
- Read-only access (no private keys)

### Tasks:
- [ ] Create Wallet model
  - [ ] Fields: address, label, chain, user_id
  - [ ] Validations: address format per chain
  - [ ] Support chains: Ethereum, Bitcoin, Solana, Polygon, Arbitrum, BSC
- [ ] Build wallet management UI
  - [ ] "Add Wallet" button on dashboard
  - [ ] Wallet creation form with chain selector
  - [ ] Wallet list with edit/delete actions
  - [ ] Address validation on frontend
- [ ] Implement address validation
  - [ ] Ethereum address validation (0x...)
  - [ ] Bitcoin address validation
  - [ ] Solana address validation
  - [ ] Custom labels for wallets
- [ ] Security features
  - [ ] Display warning: "Never enter private keys"
  - [ ] Confirm wallet ownership via signature (optional)
  - [ ] Rate limit wallet additions

### Acceptance Criteria:
- Users can add up to 5 wallets on Free plan
- Each wallet has a label and chain type
- Address format is validated before saving
- Users can edit labels and delete wallets
- Clear security messaging displayed

---

## 💱 Phase 4: Exchange Integration (Week 3-4)

### Status: 📅 Planned

### Goals:
- Connect to centralized exchanges via API
- Fetch balances securely (read-only API keys)
- Support major exchanges

### Tasks:
- [ ] Create Exchange model
  - [ ] Fields: name, api_key_encrypted, api_secret_encrypted, user_id
  - [ ] Encrypt API credentials using ActiveRecord encryption
  - [ ] Support exchanges: Binance, Coinbase, Bybit, Kraken, OKX
- [ ] Build exchange connection UI
  - [ ] "Connect Exchange" flow
  - [ ] Step-by-step guide with screenshots
  - [ ] API key input with encryption notice
  - [ ] Test connection before saving
- [ ] Implement exchange API clients
  - [ ] Binance API client (read-only)
  - [ ] Coinbase API client
  - [ ] Generic adapter pattern for other exchanges
  - [ ] Rate limiting per exchange
- [ ] Security measures
  - [ ] Verify API keys are read-only
  - [ ] Display permissions required
  - [ ] Encrypt credentials at rest
  - [ ] Never log API keys

### Acceptance Criteria:
- Users can connect 2 exchanges on Free plan
- API keys are encrypted in database
- Connection is tested before saving
- Clear instructions for creating read-only API keys
- Error handling for invalid/expired keys

---

## 💰 Phase 5: Portfolio Fetching (Week 4-5)

### Status: 📅 Planned

### Goals:
- Fetch real-time balances from wallets and exchanges
- Display aggregated portfolio value
- Support multiple tokens and chains

### Tasks:
- [ ] Integrate blockchain data providers
  - [ ] Alchemy API for Ethereum/Polygon
  - [ ] Helius API for Solana
  - [ ] Blockchain.com API for Bitcoin
  - [ ] QuickNode as backup
- [ ] Create Asset model
  - [ ] Fields: symbol, name, amount, value_usd, source (wallet/exchange)
  - [ ] Track per wallet/exchange
- [ ] Build portfolio sync jobs
  - [ ] Background job to fetch wallet balances
  - [ ] Background job to fetch exchange balances
  - [ ] Update frequency: Free (30 min), Plus (30 sec), Pro (5 sec)
  - [ ] Use Solid Queue for job processing
- [ ] Build portfolio dashboard
  - [ ] Total portfolio value (all sources)
  - [ ] Breakdown by wallet/exchange
  - [ ] Breakdown by chain
  - [ ] Top 10 holdings
  - [ ] 24h change
- [ ] Add caching layer
  - [ ] Cache portfolio data in Solid Cache
  - [ ] Invalidate on manual refresh
  - [ ] Show last update timestamp

### Acceptance Criteria:
- Portfolio displays accurate balances from all sources
- Updates automatically based on user plan
- Manual refresh button available
- Shows loading states during sync
- Handles API errors gracefully

---

## 📊 Phase 6: Analytics & P&L (Week 5-6)

### Status: 📅 Planned

### Goals:
- Calculate profit/loss for each asset
- Show historical performance
- Provide insights and recommendations

### Tasks:
- [ ] Create Transaction model
  - [ ] Track buys, sells, transfers
  - [ ] Calculate cost basis (FIFO)
  - [ ] Support manual transaction entry
- [ ] Build P&L calculation engine
  - [ ] Calculate unrealized gains/losses
  - [ ] Calculate realized gains (from sells)
  - [ ] ROI per asset, chain, wallet
- [ ] Create analytics dashboard
  - [ ] Performance chart (7d, 30d, 90d, 1y, all)
  - [ ] Asset allocation pie chart
  - [ ] Chain distribution
  - [ ] Best/worst performers
- [ ] Add insights
  - [ ] Portfolio diversification score
  - [ ] Risk level assessment
  - [ ] Rebalancing suggestions

### Acceptance Criteria:
- Accurate P&L calculations
- Visual charts for portfolio performance
- Historical data stored and displayed
- Insights are helpful and actionable

---

## 🖼️ Phase 7: NFT Support (Week 6-7)

### Status: 📅 Planned

### Goals:
- Track NFT holdings across wallets
- Display floor prices and rarity
- Show collection stats

### Tasks:
- [ ] Integrate NFT data providers
  - [ ] OpenSea API
  - [ ] Alchemy NFT API
  - [ ] Magic Eden (for Solana)
- [ ] Create NFT model
  - [ ] Fields: token_id, contract_address, name, image, floor_price
  - [ ] Link to wallet
- [ ] Build NFT gallery UI
  - [ ] Grid view with images
  - [ ] Collection grouping
  - [ ] Floor price display
  - [ ] Rarity indicators
- [ ] NFT analytics
  - [ ] Total NFT portfolio value
  - [ ] Collections owned
  - [ ] Top collections by value

### Acceptance Criteria:
- NFTs are fetched and displayed with images
- Floor prices are accurate
- Collections are grouped properly
- Beautiful gallery UI

---

## 🔔 Phase 8: Alerts & Notifications (Week 7-8)

### Status: 📅 Planned

### Goals:
- Notify users of important portfolio changes
- Price alerts for specific assets
- DeFi health factor warnings

### Tasks:
- [ ] Create Alert model
  - [ ] Types: price_above, price_below, portfolio_change, health_factor
  - [ ] User preferences: email, browser push, telegram
- [ ] Build alert management UI
  - [ ] Create new alert flow
  - [ ] Active alerts list
  - [ ] Alert history
- [ ] Implement notification workers
  - [ ] Check alert conditions periodically
  - [ ] Send email notifications (ActionMailer)
  - [ ] Browser push notifications (Web Push API)
  - [ ] Telegram bot integration (optional)
- [ ] Add alert triggers
  - [ ] Price alerts (above/below threshold)
  - [ ] Portfolio value change (% or absolute)
  - [ ] New transactions detected
  - [ ] Low health factor in DeFi positions

### Acceptance Criteria:
- Users can create and manage alerts
- Notifications are sent reliably
- Users can choose notification channels
- No spam (rate limiting on notifications)

---

## 🏦 Phase 9: DeFi Protocol Integration (Week 8-10)

### Status: 📅 Planned

### Goals:
- Auto-detect DeFi positions (lending, staking, LP)
- Track health factors and APY
- Support 400+ protocols

### Tasks:
- [ ] Integrate DeFi data providers
  - [ ] DeBank API (multi-protocol)
  - [ ] Zapper API
  - [ ] DeFiLlama API
  - [ ] Direct protocol integrations (Aave, Compound, Uniswap)
- [ ] Create DeFiPosition model
  - [ ] Fields: protocol, type (lending/staking/LP), amount, apy, health_factor
  - [ ] Link to wallet
- [ ] Build DeFi dashboard
  - [ ] Active positions list
  - [ ] Total value in DeFi
  - [ ] APY overview
  - [ ] Health factors with warnings
- [ ] Add DeFi analytics
  - [ ] Rewards earned
  - [ ] Impermanent loss calculator
  - [ ] Protocol risk scores

### Acceptance Criteria:
- DeFi positions are auto-detected
- Health factors are monitored
- Alerts for risky positions
- Supports top 50 protocols at minimum

---

## 💸 Phase 10: Tax Reporting (Week 10-12)

### Status: 📅 Planned (Pro/Ultimate only)

### Goals:
- Generate tax reports for crypto transactions
- Support multiple countries (US, EU, Russia)
- Export to accountant-friendly formats

### Tasks:
- [ ] Build transaction export
  - [ ] CSV export with all transactions
  - [ ] PDF report generation
  - [ ] Support formats: IRS 8949, EU tax forms
- [ ] Create tax report generator
  - [ ] Calculate capital gains/losses
  - [ ] Cost basis tracking (FIFO, LIFO, HIFO)
  - [ ] Income from staking/rewards
- [ ] Tax settings UI
  - [ ] Select country and tax year
  - [ ] Choose cost basis method
  - [ ] Generate report
  - [ ] Download/email report
- [ ] Compliance features
  - [ ] Disclaimer about tax advice
  - [ ] Link to tax professional resources

### Acceptance Criteria:
- Accurate tax calculations per country
- Reports are accountant-friendly
- Supports Pro/Ultimate plans only
- Clear disclaimers about professional tax advice

---

## 📱 Phase 11: Mobile App (Week 12-16)

### Status: 📅 Planned

### Goals:
- Native iOS and Android apps
- All web features available on mobile
- Push notifications
- Fast, OLED-optimized design

### Tasks:
- [ ] Choose mobile framework
  - [ ] Option 1: React Native
  - [ ] Option 2: Flutter
  - [ ] Option 3: Native Swift/Kotlin
- [ ] Set up mobile project
- [ ] Build API endpoints for mobile
  - [ ] JWT authentication
  - [ ] RESTful API for all features
- [ ] Implement mobile UI
  - [ ] Onboarding flow
  - [ ] Dashboard
  - [ ] Wallet/exchange management
  - [ ] Portfolio view
  - [ ] Settings
- [ ] Mobile-specific features
  - [ ] Biometric login (Face ID, Touch ID)
  - [ ] Push notifications
  - [ ] Offline mode (cached data)
  - [ ] Widget for portfolio value

### Acceptance Criteria:
- Apps available on iOS App Store and Google Play
- Feature parity with web app
- Fast and responsive
- 4.5+ star ratings

---

## 🚀 Phase 12: Advanced Features (Week 16+)

### Status: 📅 Future

### Potential Features:
- [ ] Team collaboration (Ultimate plan)
  - [ ] Multi-user accounts
  - [ ] Role-based permissions
  - [ ] Shared portfolios
- [ ] Portfolio rebalancing
  - [ ] Automated rebalancing suggestions
  - [ ] Execute trades via integrated DEX
- [ ] Social features
  - [ ] Share portfolio (anonymized)
  - [ ] Follow top traders
  - [ ] Community alpha sharing
- [ ] Advanced analytics
  - [ ] Correlation analysis
  - [ ] Risk metrics (VaR, Sharpe ratio)
  - [ ] Backtesting strategies
- [ ] API access (Pro/Ultimate)
  - [ ] REST API for portfolio data
  - [ ] Webhooks for events
  - [ ] Rate limits per plan

---

## 🎯 Pricing Tiers

### Free (Launch)
- 5 wallets
- 2 exchanges
- Basic analytics
- 30-minute updates
- Web access only

### Plus ($9.99/mo)
- 15 wallets
- 5 exchanges
- Real-time updates (30 sec)
- Mobile app
- Advanced analytics
- P&L tracking

### Pro ($29.99/mo)
- 50 wallets
- Unlimited exchanges
- Real-time updates (5 sec)
- Tax reporting
- API access
- Priority support

### Ultimate ($79.99/mo)
- Unlimited wallets
- Team collaboration
- White-label option
- Dedicated support
- Custom integrations

---

## 📊 Success Metrics

### Launch (Month 1-3)
- 1,000 registered users
- 100 paying subscribers (Plus/Pro)
- 80% user retention after 7 days

### Growth (Month 4-6)
- 10,000 registered users
- 1,000 paying subscribers
- $10K MRR (Monthly Recurring Revenue)

### Scale (Month 7-12)
- 50,000 registered users
- 5,000 paying subscribers
- $50K MRR
- 4.5+ star rating on mobile stores

---

## 🛠️ Technical Debt & Maintenance

### Ongoing Tasks:
- [ ] Security audits (quarterly)
- [ ] Performance optimization
- [ ] Database scaling (migrate to PostgreSQL if needed)
- [ ] Caching strategy improvements
- [ ] Test coverage (target 80%+)
- [ ] Documentation updates
- [ ] Dependency updates

---

## 📝 Notes

- This roadmap is a living document and will be updated as priorities shift
- Each phase should include comprehensive testing before moving to the next
- User feedback should be collected continuously and incorporated
- Security and data privacy are top priorities throughout development
