require "net/http"
require "json"

module Blockchain
  class AlchemyClient
    # Alchemy API endpoints for different chains
    CHAIN_ENDPOINTS = {
      ethereum: "https://eth-mainnet.g.alchemy.com/v2",
      base: "https://base-mainnet.g.alchemy.com/v2",
      arbitrum: "https://arb-mainnet.g.alchemy.com/v2",
      optimism: "https://opt-mainnet.g.alchemy.com/v2",
      polygon: "https://polygon-mainnet.g.alchemy.com/v2"
    }

    def initialize(api_key: nil, chain: :ethereum)
      @api_key = api_key || Rails.application.credentials.dig(:alchemy, :api_key)
      @chain = chain
      raise "Alchemy API key not configured" unless @api_key
      raise "Unsupported chain: #{chain}" unless CHAIN_ENDPOINTS.key?(chain)
    end

    # Get native ETH balance for an address
    def get_balance(address)
      response = make_request("eth_getBalance", [address, "latest"])
      return nil unless response

      # Convert hex to decimal (wei) then to ETH
      wei = response["result"].to_i(16)
      wei / 1e18
    end

    # Get all ERC-20 token balances for an address
    def get_token_balances(address)
      response = make_request("alchemy_getTokenBalances", [address])
      return [] unless response

      token_balances = response.dig("result", "tokenBalances") || []

      # Filter out tokens with zero balance
      token_balances.select do |token|
        balance_hex = token["tokenBalance"]
        balance_hex && balance_hex != "0x0" && balance_hex.to_i(16) > 0
      end
    end

    # Get metadata for a token (name, symbol, decimals, logo)
    def get_token_metadata(contract_address)
      response = make_request("alchemy_getTokenMetadata", [contract_address])
      return nil unless response

      metadata = response["result"]
      {
        name: metadata["name"],
        symbol: metadata["symbol"],
        decimals: metadata["decimals"],
        logo: metadata["logo"]
      }
    end

    # Get NFTs owned by an address
    def get_nfts(address)
      url = "#{api_url}/getNFTs"
      params = { owner: address, withMetadata: true }

      response = make_get_request(url, params)
      return [] unless response

      response.dig("ownedNfts") || []
    end

    # Resolve ENS name for an address
    def resolve_ens(address)
      # This requires a reverse lookup - we'll implement this if needed
      # For now, return nil
      nil
    end

    private

    def api_url
      base_url = CHAIN_ENDPOINTS[@chain]
      "#{base_url}/#{@api_key}"
    end

    def chain_name
      @chain.to_s.capitalize
    end

    def make_request(method, params)
      uri = URI(api_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # For development only
      http.read_timeout = 30

      request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      request.body = {
        jsonrpc: "2.0",
        id: 1,
        method: method,
        params: params
      }.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        Rails.logger.error("Alchemy API error: #{response.code} - #{response.body}")
        nil
      end
    rescue => e
      Rails.logger.error("Alchemy API request failed: #{e.message}")
      nil
    end

    def make_get_request(url, params)
      uri = URI(url)
      uri.query = URI.encode_www_form(params) if params.any?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # For development only
      http.read_timeout = 30

      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        Rails.logger.error("Alchemy API error: #{response.code} - #{response.body}")
        nil
      end
    rescue => e
      Rails.logger.error("Alchemy API request failed: #{e.message}")
      nil
    end
  end
end
