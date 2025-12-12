require "net/http"
require "json"

module Blockchain
  class PriceService
    COINGECKO_API = "https://api.coingecko.com/api/v3"

    # Price cache to avoid hitting rate limits
    @price_cache = {}
    @cache_expiry = {}
    CACHE_DURATION = 5.minutes

    class << self
      attr_accessor :price_cache, :cache_expiry
    end

    def initialize
      # CoinGecko free tier doesn't require API key
      # For paid tier, you can add: @api_key = Rails.application.credentials.dig(:coingecko, :api_key)
    end

    # Get current price for a token by contract address
    def get_token_price(contract_address, platform: "ethereum")
      cache_key = "#{platform}:#{contract_address.downcase}"

      # Check cache first
      if cached_price = get_from_cache(cache_key)
        return cached_price
      end

      url = "#{COINGECKO_API}/simple/token_price/#{platform}"
      params = {
        contract_addresses: contract_address.downcase,
        vs_currencies: "usd",
        include_24hr_change: true
      }

      response = make_request(url, params)
      return 0.0 unless response

      price = response.dig(contract_address.downcase, "usd")
      price = price.to_f if price

      # Cache the result
      set_cache(cache_key, price) if price

      price || 0.0
    rescue => e
      Rails.logger.error("Price fetch error for #{contract_address}: #{e.message}")
      0.0
    end

    # Get current price for native tokens (ETH, SOL, etc.)
    def get_native_price(symbol)
      cache_key = "native:#{symbol.downcase}"

      # Check cache first
      if cached_price = get_from_cache(cache_key)
        return cached_price
      end

      coin_id = symbol_to_coingecko_id(symbol)
      return 0.0 unless coin_id

      url = "#{COINGECKO_API}/simple/price"
      params = {
        ids: coin_id,
        vs_currencies: "usd",
        include_24hr_change: true
      }

      response = make_request(url, params)
      return 0.0 unless response

      price = response.dig(coin_id, "usd")
      price = price.to_f if price

      # Cache the result
      set_cache(cache_key, price) if price

      price || 0.0
    rescue => e
      Rails.logger.error("Price fetch error for #{symbol}: #{e.message}")
      0.0
    end

    # Get multiple token prices at once
    # Note: CoinGecko free tier has rate limits - use sparingly
    def get_multiple_prices(contract_addresses, platform: "ethereum")
      return {} if contract_addresses.empty?

      prices = {}

      # Limit to avoid rate limiting - only price first 10 tokens per chain
      # For DeFi tokens, we'll use estimated peg prices instead
      limited_addresses = contract_addresses.first(10)

      limited_addresses.each_with_index do |address, index|
        # Add small delay to avoid rate limiting
        sleep(0.5) if index > 0

        price = get_token_price(address, platform: platform)
        prices[address] = price if price && price > 0
      end

      prices
    rescue => e
      Rails.logger.error("Batch price fetch error: #{e.message}")
      {}
    end

    private

    def symbol_to_coingecko_id(symbol)
      # Map common symbols to CoinGecko IDs
      mapping = {
        "eth" => "ethereum",
        "btc" => "bitcoin",
        "sol" => "solana",
        "matic" => "matic-network",
        "bnb" => "binancecoin",
        "avax" => "avalanche-2",
        "arb" => "arbitrum",
        "op" => "optimism"
      }

      mapping[symbol.downcase]
    end

    def make_request(url, params)
      uri = URI(url)
      uri.query = URI.encode_www_form(params)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # For development only
      http.read_timeout = 30

      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        Rails.logger.error("CoinGecko API error: #{response.code} - #{response.body}")
        nil
      end
    rescue => e
      Rails.logger.error("CoinGecko API request failed: #{e.message}")
      nil
    end

    # Simple in-memory cache
    def get_from_cache(key)
      expiry = self.class.cache_expiry[key]
      if expiry && expiry > Time.current
        self.class.price_cache[key]
      else
        # Clear expired entry
        self.class.price_cache.delete(key)
        self.class.cache_expiry.delete(key)
        nil
      end
    end

    def set_cache(key, value)
      self.class.price_cache[key] = value
      self.class.cache_expiry[key] = Time.current + CACHE_DURATION
    end
  end
end
