class AccountEnrichmentService
  # Chains to scan for EVM addresses
  # Note: Optimism and Polygon require enabling in Alchemy dashboard
  EVM_CHAINS = [:ethereum, :base, :arbitrum]

  def initialize(account)
    @account = account
    @debank_client = Blockchain::DebankClient.new
    @price_service = Blockchain::PriceService.new
  end

  def call
    return false unless @account.persisted?

    @account.update(sync_status: "syncing")

    begin
      detect_blockchain_type
      fetch_complete_portfolio
      resolve_ens_name if ethereum_based?
      detect_extensions

      @account.update(
        sync_status: "synced",
        last_synced_at: Time.current,
        sync_error: nil
      )

      true
    rescue => e
      Rails.logger.error("Account enrichment failed for #{@account.id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      @account.update(
        sync_status: "error",
        sync_error: "#{e.class}: #{e.message}"
      )
      false
    end
  end

  private

  def detect_blockchain_type
    blockchain, account_type = case @account.address
    when /^0x[a-fA-F0-9]{40}$/
      ["ethereum", "Ethereum & EVM EOA"]
    when /^[1-9A-HJ-NP-Za-km-z]{32,44}$/
      ["solana", "Solana & SVM"]
    when /^bnb1[a-z0-9]{38}$/
      ["binance", "Binance Chain"]
    when /^cosmos1[a-z0-9]{38}$/
      ["cosmos", "Cosmos"]
    else
      ["ethereum", "Ethereum & EVM EOA"]
    end

    @account.update(
      blockchain: blockchain,
      account_type: account_type
    )
  end

  def fetch_complete_portfolio
    case @account.blockchain
    when "ethereum"
      fetch_debank_portfolio
    when "solana"
      fetch_solana_balances
    else
      @account.update(
        balance_usd: 0.0,
        wallet_balance_usd: 0.0,
        protocol_balance_usd: 0.0
      )
    end
  end

  def fetch_debank_portfolio
    Rails.logger.info("\n" + "="*70)
    Rails.logger.info("🔍 Fetching Portfolio from DeBank Cloud API")
    Rails.logger.info("="*70)
    Rails.logger.info("📍 Address (stored): #{@account.address}")
    Rails.logger.info("📍 Address (querying): #{@account.address.downcase}")
    Rails.logger.info("🔗 Blockchain: #{@account.blockchain}")

    begin
      # Use get_portfolio_breakdown which combines total_balance + protocol_positions + token_balances
      portfolio = @debank_client.get_portfolio_breakdown(@account.address)

      unless portfolio
        Rails.logger.error("DeBank API returned no data")
        return fallback_to_alchemy
      end

      # 🔍 LOG RAW DEBANK RESPONSE STRUCTURE
      Rails.logger.info("\n📊 DeBank API Response:")
      Rails.logger.info("  total_usd: $#{portfolio[:total_usd]}")
      Rails.logger.info("  wallet_balance: $#{portfolio[:wallet_balance]}")
      Rails.logger.info("  protocol_balance: $#{portfolio[:protocol_balance]}")
      Rails.logger.info("  protocols count: #{(portfolio[:protocols] || []).length}")
      Rails.logger.info("  tokens count: #{(portfolio[:tokens] || []).length}")

      # Parse DeBank portfolio_breakdown response (returns hash with symbols)
      total_usd = portfolio[:total_usd] || 0.0
      wallet_balance = portfolio[:wallet_balance] || 0.0
      protocol_balance = portfolio[:protocol_balance] || 0.0

      # Extract DeFi positions from protocols array
      defi_positions = []

      (portfolio[:protocols] || []).each_with_index do |protocol, idx|
        protocol_name = protocol["name"]
        protocol_type = protocol["site_url"]&.include?("aave") ? "lending" : "defi"

        # 🔍 LOG PROTOCOL DETAILS
        Rails.logger.info("\n  📦 Protocol #{idx + 1}: #{protocol_name}")
        Rails.logger.info("     Type: #{protocol_type}")
        Rails.logger.info("     Chain: #{protocol['chain'] || 'multi-chain'}")
        Rails.logger.info("     Items: #{protocol['portfolio_item_list']&.length || 0}")

        positions = []
        protocol_value = 0.0

        if protocol["portfolio_item_list"]
          protocol["portfolio_item_list"].each do |item|
            item_chain = item["chain"] || "unknown"
            detail = item["detail"] || {}

            # Process SUPPLY positions from supply_token_list
            supply_list = detail["supply_token_list"] || []
            supply_list.each do |token|
              token_amount = token["amount"]&.to_f || 0.0
              token_price = token["price"]&.to_f || 0.0
              token_usd_value = token_amount * token_price

              protocol_value += token_usd_value

              position = {
                token_symbol: token["symbol"] || token["optimized_symbol"] || "Unknown",
                token_name: token["name"] || protocol_name,
                balance: token_amount,
                usd_value: token_usd_value.round(2),
                protocol: protocol_name,
                chain: item_chain,
                is_debt: false
              }

              positions << position
            end

            # Process BORROW positions from borrow_token_list
            borrow_list = detail["borrow_token_list"] || []
            borrow_list.each do |token|
              token_amount = token["amount"]&.to_f || 0.0
              token_price = token["price"]&.to_f || 0.0
              token_usd_value = -(token_amount * token_price) # Negative because it's debt

              protocol_value += token_usd_value

              position = {
                token_symbol: token["symbol"] || token["optimized_symbol"] || "Unknown",
                token_name: token["name"] || "Borrowed #{token['symbol']}",
                balance: token_amount,
                usd_value: token_usd_value.round(2),
                protocol: protocol_name,
                chain: item_chain,
                is_debt: true
              }

              Rails.logger.info("     🚨 BORROW TOKEN PARSED:")
              Rails.logger.info("        Symbol: #{position[:token_symbol]}")
              Rails.logger.info("        Name: #{position[:token_name]}")
              Rails.logger.info("        Amount: #{token_amount}")
              Rails.logger.info("        Price: $#{token_price}")
              Rails.logger.info("        USD Value: $#{token_usd_value.round(2)}")
              Rails.logger.info("        Chain: #{item_chain}")

              positions << position
            end

            # Process DEBT positions from debt_token_list (alternative field)
            debt_list = detail["debt_token_list"] || []
            debt_list.each do |token|
              token_amount = token["amount"]&.to_f || 0.0
              token_price = token["price"]&.to_f || 0.0
              token_usd_value = -(token_amount * token_price) # Negative because it's debt

              protocol_value += token_usd_value

              position = {
                token_symbol: token["symbol"] || token["optimized_symbol"] || "Unknown",
                token_name: token["name"] || "Debt #{token['symbol']}",
                balance: token_amount,
                usd_value: token_usd_value.round(2),
                protocol: protocol_name,
                chain: item_chain,
                is_debt: true
              }

              Rails.logger.info("     🚨 DEBT TOKEN PARSED:")
              Rails.logger.info("        Symbol: #{position[:token_symbol]}")
              Rails.logger.info("        Name: #{position[:token_name]}")
              Rails.logger.info("        Amount: #{token_amount}")
              Rails.logger.info("        Price: $#{token_price}")
              Rails.logger.info("        USD Value: $#{token_usd_value.round(2)}")
              Rails.logger.info("        Chain: #{item_chain}")

              positions << position
            end

            # Fallback: If no borrow/debt tokens found but debt_usd_value exists, create synthetic position
            if borrow_list.empty? && debt_list.empty?
              debt_usd_value = item["stats"]&.dig("debt_usd_value")&.to_f
              if debt_usd_value && debt_usd_value > 0
                protocol_value -= debt_usd_value

                position = {
                  token_symbol: item["name"] || "Unknown",
                  token_name: "Borrowed (Synthetic)",
                  balance: 0.0,
                  usd_value: -debt_usd_value.round(2),
                  protocol: protocol_name,
                  chain: item_chain,
                  is_debt: true
                }

                Rails.logger.info("     🚨 SYNTHETIC DEBT POSITION (from stats.debt_usd_value):")
                Rails.logger.info("        USD Value: $#{-debt_usd_value.round(2)}")
                Rails.logger.info("        Chain: #{item_chain}")

                positions << position
              end
            end
          end
        end

        # Keep protocols with non-zero value OR any positions (including debt)
        if protocol_value != 0 || positions.any?
          borrowed_count = positions.count { |p| p[:is_debt] }
          supplied_count = positions.count { |p| !p[:is_debt] }

          Rails.logger.info("     Total value: $#{protocol_value.round(2)}")
          Rails.logger.info("     Positions: #{supplied_count} supplied, #{borrowed_count} borrowed")

          defi_positions << {
            name: protocol_name,
            type: protocol_type,
            positions: positions
          }
        end
      end

      # 🔍 LOG SUMMARY OF ALL DEBT POSITIONS
      total_debt_positions = defi_positions.sum { |p| p[:positions].count { |pos| pos[:is_debt] } }
      Rails.logger.info("\n🎯 DEBT POSITIONS SUMMARY:")
      Rails.logger.info("  Total debt positions found: #{total_debt_positions}")
      if total_debt_positions == 0
        Rails.logger.warn("  ⚠️  NO DEBT POSITIONS FOUND - this may indicate a parsing issue")
      end

      Rails.logger.info("\n💰 DeBank Portfolio Summary:")
      Rails.logger.info("  Total Value: $#{total_usd.round(2)}")
      Rails.logger.info("  Wallet Balance: $#{wallet_balance.round(2)}")
      Rails.logger.info("  Protocol Balance: $#{protocol_balance.round(2)}")
      Rails.logger.info("  DeFi Protocols: #{defi_positions.length}")

      # Update account
      @account.update(
        balance_usd: total_usd.round(2),
        wallet_balance_usd: wallet_balance.round(2),
        protocol_balance_usd: protocol_balance.round(2),
        defi_positions: defi_positions
      )

      total_usd
    rescue => e
      Rails.logger.error("DeBank API error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      fallback_to_alchemy
    end
  end

  def fallback_to_alchemy
    Rails.logger.warn("⚠️  Falling back to Alchemy for portfolio data")
    fetch_ethereum_portfolio_with_defi_detection
  end

  def fetch_ethereum_portfolio_with_defi_detection
    Rails.logger.info("\n" + "="*70)
    Rails.logger.info("🔍 Multi-Chain Portfolio Scan for #{@account.address}")
    Rails.logger.info("="*70)

    total_wallet_balance = 0.0
    total_protocol_balance = 0.0
    all_defi_positions = {}

    # Scan each EVM chain
    EVM_CHAINS.each do |chain|
      Rails.logger.info("\n📡 Scanning #{chain.to_s.upcase}...")

      chain_wallet, chain_protocol, chain_defi = scan_chain(chain)

      total_wallet_balance += chain_wallet
      total_protocol_balance += chain_protocol

      # Merge DeFi positions
      chain_defi.each do |protocol_name, protocol_data|
        if all_defi_positions[protocol_name]
          all_defi_positions[protocol_name][:positions] += protocol_data[:positions]
        else
          all_defi_positions[protocol_name] = protocol_data
        end
      end
    end

    total_balance = total_wallet_balance + total_protocol_balance

    # Convert defi_positions hash to array for storage
    defi_positions_array = all_defi_positions.values

    # Update account
    @account.update(
      balance_usd: total_balance.round(2),
      wallet_balance_usd: total_wallet_balance.round(2),
      protocol_balance_usd: total_protocol_balance.round(2),
      defi_positions: defi_positions_array
    )

    log_portfolio_summary(total_balance, total_wallet_balance, total_protocol_balance, defi_positions_array)

    total_balance
  end

  def scan_chain(chain)
    alchemy = Blockchain::AlchemyClient.new(chain: chain)
    defi_detector = Blockchain::DefiProtocolDetector.new(alchemy)

    wallet_balance = 0.0
    protocol_balance = 0.0
    defi_positions = {}

    # 1. Fetch native token balance (ETH for Ethereum/Base/Arbitrum/Optimism)
    native_balance = alchemy.get_balance(@account.address)
    if native_balance && native_balance > 0
      native_symbol = chain == :polygon ? "matic" : "eth"
      native_price = @price_service.get_native_price(native_symbol)
      native_value = native_balance * native_price
      wallet_balance += native_value

      Rails.logger.info("  💰 #{native_symbol.upcase}: #{native_balance.round(6)} = $#{native_value.round(2)}")
    end

    # 2. Fetch all ERC-20 tokens
    tokens = alchemy.get_token_balances(@account.address)

    if tokens.any?
      Rails.logger.info("  📊 Found #{tokens.length} tokens")

      # First pass: identify DeFi tokens (don't need prices yet)
      tokens_with_metadata = []
      tokens.each do |token|
        metadata = alchemy.get_token_metadata(token["contractAddress"])
        next unless metadata

        protocol_info = defi_detector.detect_protocol(metadata)

        # Debug logging for Base and Arbitrum tokens
        if chain.in?([:base, :arbitrum])
          balance_raw = token["tokenBalance"].to_i(16)
          decimals = metadata[:decimals] || 18
          balance = balance_raw / (10 ** decimals).to_f

          # Log all tokens (no balance filter) to catch Aave tokens
          Rails.logger.info("  🔍 DEBUG [#{chain.to_s.upcase}] Token: #{metadata[:symbol]} | Name: #{metadata[:name]} | Balance: #{balance.round(10)} | DeFi: #{!protocol_info.nil?}")
        end

        tokens_with_metadata << {
          token: token,
          metadata: metadata,
          protocol_info: protocol_info,
          is_defi: !protocol_info.nil?
        }
      end

      # Sort: DeFi tokens first (they're high value), then regular tokens
      tokens_with_metadata.sort_by! { |t| t[:is_defi] ? 0 : 1 }

      # Get prices for top tokens only (rate limit friendly)
      contract_addresses = tokens_with_metadata.first(20).map { |t| t[:token]["contractAddress"] }
      prices = @price_service.get_multiple_prices(contract_addresses)

      Rails.logger.info("  ℹ️  Processing #{tokens_with_metadata.length} tokens (#{tokens_with_metadata.count { |t| t[:is_defi] }} DeFi)")

      tokens_with_metadata.each do |token_data|
        token = token_data[:token]
        metadata = token_data[:metadata]
        protocol_info = token_data[:protocol_info]

        contract_address = token["contractAddress"]
        balance_hex = token["tokenBalance"]

        balance_raw = balance_hex.to_i(16)
        decimals = metadata[:decimals] || 18
        balance = balance_raw / (10 ** decimals).to_f

        next if balance <= 0

        # Get price from CoinGecko or use estimated peg
        price = prices[contract_address]

        # If no price from CoinGecko and it's a stablecoin-pegged token, use $1
        if (!price || price == 0) && protocol_info && protocol_info[:estimated_peg]
          price = protocol_info[:estimated_peg]
        end

        price ||= 0.0
        token_value = balance * price

        if protocol_info
          # This is a DeFi receipt token
          # Debt tokens are liabilities and should be subtracted
          if protocol_info[:is_debt]
            protocol_balance -= token_value
            token_value = -token_value  # Store as negative for display
          else
            protocol_balance += token_value
          end

          protocol_name = protocol_info[:protocol_name]
          defi_positions[protocol_name] ||= {
            name: protocol_name,
            type: protocol_info[:type],
            positions: []
          }

          defi_positions[protocol_name][:positions] << {
            token_symbol: metadata[:symbol],
            token_name: metadata[:name],
            balance: balance.round(6),
            usd_value: token_value.round(2),
            contract_address: contract_address,
            chain: chain.to_s,
            is_debt: protocol_info[:is_debt] || false
          }

          if token_value.abs > 1.0
            debt_indicator = protocol_info[:is_debt] ? " (debt)" : ""
            Rails.logger.info("  🏦 #{protocol_name} - #{metadata[:symbol]}: #{balance.round(4)} = $#{token_value.round(2)}#{debt_indicator}")
          end
        else
          # Regular wallet token
          wallet_balance += token_value

          if token_value > 1.0
            Rails.logger.info("  💵 #{metadata[:symbol]}: #{balance.round(4)} = $#{token_value.round(2)}")
          end
        end
      end
    else
      Rails.logger.info("  ℹ️  No tokens found")
    end

    [wallet_balance, protocol_balance, defi_positions]
  end

  def log_portfolio_summary(total_balance, wallet_balance, protocol_balance, defi_positions)
    Rails.logger.info("\n" + "="*70)
    Rails.logger.info("📊 PORTFOLIO SUMMARY")
    Rails.logger.info("="*70)
    Rails.logger.info("💵 Total Value: $#{total_balance.round(2)}")
    Rails.logger.info("  📱 Wallet (direct): $#{wallet_balance.round(2)}")
    Rails.logger.info("  🏦 DeFi Protocols: $#{protocol_balance.round(2)}")

    if defi_positions.any?
      Rails.logger.info("\n🔗 DeFi Positions:")
      defi_positions.each do |protocol|
        protocol_value = protocol[:positions].sum { |p| p[:usd_value] }
        Rails.logger.info("  • #{protocol[:name]}: $#{protocol_value.round(2)} (#{protocol[:positions].length} positions)")
      end
    end

    Rails.logger.info("="*70 + "\n")
  end

  def fetch_solana_balances
    Rails.logger.info("Solana balance fetching not yet implemented")
    @account.update(
      balance_usd: 0.0,
      wallet_balance_usd: 0.0,
      protocol_balance_usd: 0.0
    )
  end

  def resolve_ens_name
    # Placeholder for ENS resolution
  end

  def detect_extensions
    # Placeholder for detecting special features
    extensions = []
    @account.update(extensions: extensions) if extensions.any?
  end

  def ethereum_based?
    @account.blockchain.in?(["ethereum", "polygon", "arbitrum", "optimism", "base"])
  end
end
