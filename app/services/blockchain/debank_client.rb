require "net/http"
require "json"

module Blockchain
  class DebankClient
    # DeBank Cloud API (paid tier)
    API_BASE_URL = "https://pro-openapi.debank.com"

    def initialize(api_key: nil)
      # Security: Read API key from environment variable only
      @api_key = api_key || ENV['DEBANK_ACCESS_KEY']
      raise "DeBank API key not configured. Set DEBANK_ACCESS_KEY environment variable." unless @api_key
    end

    # PRIMARY METHOD: Get complete portfolio with DeFi positions, balances, and pricing
    # This is the single source of truth for portfolio data
    def get_portfolio(address)
      url = "#{API_BASE_URL}/v1/user/portfolio"
      params = { id: address.downcase }

      response = make_request(url, params)
      return nil unless response

      response
    end

    # Get total balance across all chains
    def get_total_balance(address)
      url = "#{API_BASE_URL}/v1/user/total_balance"
      params = { id: address.downcase }

      response = make_request(url, params)
      return nil unless response

      {
        total_usd_value: response["total_usd_value"]&.to_f || 0.0,
        chain_list: response["chain_list"] || []
      }
    end

    # Get all DeFi protocol positions (lending, staking, LP, etc.)
    def get_protocol_positions(address)
      url = "#{API_BASE_URL}/v1/user/all_complex_protocol_list"
      params = { id: address.downcase }

      response = make_request(url, params)
      return [] unless response

      # Response is an array of protocols with positions
      response || []
    end

    # Get simple token balances across all chains
    def get_token_balances(address)
      url = "#{API_BASE_URL}/v1/user/all_token_list"
      params = {
        id: address.downcase,
        is_all: true # Get all tokens, not just verified ones
      }

      response = make_request(url, params)
      return [] unless response

      response || []
    end

    # Get NFT collection summary
    def get_nft_summary(address)
      url = "#{API_BASE_URL}/v1/user/nft_list"
      params = { id: address.downcase }

      response = make_request(url, params)
      return [] unless response

      response || []
    end

    # Get portfolio breakdown by protocol
    def get_portfolio_breakdown(address)
      total_balance = get_total_balance(address)
      protocol_positions = get_protocol_positions(address)
      token_balances = get_token_balances(address)

      total_usd = total_balance&.dig(:total_usd_value) || 0.0
      protocol_balance = calculate_protocol_balance(protocol_positions)

      # Wallet balance = total - protocol (avoid double-counting DeFi receipt tokens)
      wallet_balance = total_usd - protocol_balance

      # Verify and adjust balances
      wallet_balance = verify_balances(wallet_balance, protocol_balance, total_usd)

      {
        total_usd: total_usd,
        wallet_balance: wallet_balance,
        protocol_balance: protocol_balance,
        protocols: protocol_positions,
        tokens: token_balances
      }
    rescue => e
      Rails.logger.error("DeBank portfolio breakdown failed: #{e.message}")
      {
        total_usd: 0.0,
        wallet_balance: 0.0,
        protocol_balance: 0.0,
        protocols: [],
        tokens: []
      }
    end

    private

    # Verify and adjust balance calculations
    # total_usd is the single source of truth from DeBank API
    def verify_balances(wallet, protocol, total)
      calculated = wallet + protocol
      diff = (calculated - total).abs

      # Check for balance mismatch
      if diff > 0.01
        Rails.logger.warn("Balance mismatch: wallet=#{wallet.round(2)}, protocol=#{protocol.round(2)}, total=#{total.round(2)}, diff=#{diff.round(2)}")
      end

      # Handle negative wallet balances
      if wallet < 0 && wallet > -1
        # Small negative values likely due to rounding - clamp to 0
        Rails.logger.info("Rounding negative wallet balance #{wallet.round(2)} to 0")
        wallet = 0.0
      elsif wallet < -1
        # Large negative balance indicates a problem
        Rails.logger.error("Large negative wallet balance: #{wallet.round(2)}")
        # In production, don't raise - just log the error
        # total_usd is the source of truth, so this should self-correct
      end

      wallet
    end

    def calculate_wallet_balance(tokens)
      # Calculate USD value: price * amount for each token
      tokens.sum do |token|
        price = token["price"]&.to_f || 0.0
        amount = token["amount"]&.to_f || 0.0
        price * amount
      end
    end

    def calculate_protocol_balance(protocols)
      protocols.sum do |protocol|
        protocol.dig("portfolio_item_list")&.sum do |item|
          item.dig("stats", "net_usd_value")&.to_f || 0.0
        end || 0.0
      end
    end

    def make_request(url, params)
      uri = URI(url)
      uri.query = URI.encode_www_form(params)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # For development only
      http.read_timeout = 30

      request = Net::HTTP::Get.new(uri)
      request["AccessKey"] = @api_key if @api_key
      request["Accept"] = "application/json"

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        Rails.logger.error("DeBank API error: #{response.code} - #{response.body}")
        nil
      end
    rescue => e
      Rails.logger.error("DeBank API request failed: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      nil
    end
  end
end
