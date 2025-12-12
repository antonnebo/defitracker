require "net/http"
require "json"

module Blockchain
  class DefiProtocolDetector
    PROTOCOL_PATTERNS = {
      # Aave V2 & V3
      aave: {
        token_prefix: /^a[A-Z]/,  # aUSDC, aDAI, aWETH, etc.
        name_pattern: /Aave.*(interest|Variable|Stable|Debt)/i,  # Matches V2 interest tokens and V3 debt tokens
        protocol_name: "Aave",
        type: "lending"
      },
      # Compound
      compound: {
        token_prefix: /^c[A-Z]/,  # cUSDC, cDAI, etc.
        name_pattern: /Compound/i,
        protocol_name: "Compound",
        type: "lending"
      },
      # Curve
      curve: {
        token_suffix: /-LP$/,
        name_pattern: /Curve.*LP/i,
        protocol_name: "Curve",
        type: "liquidity_pool"
      },
      # Uniswap V2 LP
      uniswap_v2: {
        name_pattern: /UNI-V2/i,
        protocol_name: "Uniswap V2",
        type: "liquidity_pool"
      },
      # Uniswap V3 positions are NFTs, handled separately

      # Stake DAO
      stakedao: {
        token_prefix: /^sd[A-Z]/,  # sdCRV, sdFRAX, etc.
        name_pattern: /Stake ?DAO/i,
        protocol_name: "Stake DAO",
        type: "staking"
      },

      # GMX V2
      gmx: {
        token_prefix: /^GM$/,  # GM is the market token for GMX V2
        name_pattern: /GMX.*Market/i,
        protocol_name: "GMX",
        type: "perpetuals"
      }
    }

    def initialize(alchemy_client)
      @alchemy = alchemy_client
    end

    # Detect if a token is a DeFi receipt token
    def detect_protocol(token_metadata)
      return nil unless token_metadata

      symbol = token_metadata[:symbol]
      name = token_metadata[:name]

      PROTOCOL_PATTERNS.each do |key, pattern|
        # Check symbol prefix
        if pattern[:token_prefix] && symbol&.match?(pattern[:token_prefix])
          info = build_protocol_info(key, pattern, token_metadata)
          info[:estimated_peg] = detect_stablecoin_peg(symbol, name)
          return info
        end

        # Check symbol suffix
        if pattern[:token_suffix] && symbol&.match?(pattern[:token_suffix])
          info = build_protocol_info(key, pattern, token_metadata)
          info[:estimated_peg] = detect_stablecoin_peg(symbol, name)
          return info
        end

        # Check name pattern
        if pattern[:name_pattern] && name&.match?(pattern[:name_pattern])
          info = build_protocol_info(key, pattern, token_metadata)
          info[:estimated_peg] = detect_stablecoin_peg(symbol, name)
          return info
        end
      end

      nil
    end

    # Detect if this is a stablecoin-pegged token
    def detect_stablecoin_peg(symbol, name)
      stablecoin_patterns = [
        /USD/i,    # Contains USD
        /DAI/i,    # DAI stablecoin
        /USDC/i,   # USDC
        /USDT/i,   # Tether
        /LUSD/i,   # Liquity USD
        /FRAX/i,   # Frax
        /BUSD/i,   # Binance USD
        /crvUSD/i  # Curve USD
      ]

      stablecoin_patterns.any? { |pattern| symbol&.match?(pattern) || name&.match?(pattern) } ? 1.0 : nil
    end

    # Get underlying value for Aave aTokens (1:1 with underlying)
    def get_aave_underlying_value(contract_address, balance, decimals)
      # Aave aTokens are 1:1 with underlying asset
      # The exchange rate is built into the growing balance
      # So balance * price of underlying = USD value

      # For now, we'll use the token's own price from metadata
      # In production, we'd query the Aave pool to get the exact underlying asset
      {
        protocol: "Aave",
        type: "lending",
        underlying_balance: balance,
        exchange_rate: 1.0
      }
    end

    # Get underlying value for Compound cTokens
    def get_compound_underlying_value(contract_address, balance, decimals)
      # cTokens have an exchange rate that grows over time
      # We would need to call exchangeRateStored() on the cToken contract

      # For MVP, estimate ~1.02 exchange rate (grows over time)
      exchange_rate = 1.02

      {
        protocol: "Compound",
        type: "lending",
        underlying_balance: balance * exchange_rate,
        exchange_rate: exchange_rate
      }
    end

    # Get underlying value for LP tokens
    def get_lp_underlying_value(contract_address, balance, decimals)
      # LP tokens require querying the pool reserves and total supply
      # This is complex and would require multiple contract calls

      # For MVP, we'll rely on price APIs that already handle this
      {
        protocol: "LP Token",
        type: "liquidity_pool",
        underlying_balance: balance,
        exchange_rate: 1.0
      }
    end

    # Calculate underlying value based on protocol type
    def calculate_underlying_value(protocol_info, contract_address, balance, decimals)
      case protocol_info[:protocol_key]
      when :aave
        get_aave_underlying_value(contract_address, balance, decimals)
      when :compound
        get_compound_underlying_value(contract_address, balance, decimals)
      when :curve, :uniswap_v2
        get_lp_underlying_value(contract_address, balance, decimals)
      when :stakedao
        # Stake DAO tokens also represent underlying assets
        get_aave_underlying_value(contract_address, balance, decimals)
      else
        {
          protocol: "Unknown",
          type: "unknown",
          underlying_balance: balance,
          exchange_rate: 1.0
        }
      end
    end

    private

    def build_protocol_info(key, pattern, metadata)
      # Detect if this is a debt token (liability)
      is_debt = metadata[:name]&.match?(/debt/i) || metadata[:symbol]&.match?(/debt/i)

      {
        protocol_key: key,
        protocol_name: pattern[:protocol_name],
        type: pattern[:type],
        token_symbol: metadata[:symbol],
        token_name: metadata[:name],
        is_debt: is_debt
      }
    end
  end
end
