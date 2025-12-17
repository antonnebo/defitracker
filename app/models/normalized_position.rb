# Plain Ruby object (not ActiveRecord) representing a DeFi position
# Extracted from account.defi_positions JSON for clean aggregation
class NormalizedPosition
  attr_reader :account_id, :address, :chain, :protocol_id, :protocol_name,
              :protocol_type, :protocol_icon_url, :token_symbol, :token_name,
              :token_icon_url, :balance, :usd_value, :is_debt, :health_rate

  def initialize(account_id:, address:, chain:, protocol_id:, protocol_name:,
                 protocol_type:, token_symbol:, token_name:, balance:,
                 usd_value:, is_debt: false, protocol_icon_url: nil,
                 token_icon_url: nil, health_rate: nil)
    @account_id = account_id
    @address = address
    @chain = chain
    @protocol_id = protocol_id
    @protocol_name = protocol_name
    @protocol_type = protocol_type
    @protocol_icon_url = protocol_icon_url
    @token_symbol = token_symbol
    @token_name = token_name
    @token_icon_url = token_icon_url
    @balance = balance.to_f

    # DEFENSIVE: If is_debt=true and usd_value is positive, flip the sign
    raw_value = usd_value.to_f
    @usd_value = (is_debt && raw_value > 0) ? -raw_value : raw_value
    @is_debt = is_debt
    @health_rate = health_rate&.to_f
  end

  # Class method to extract all positions for a user from JSON storage
  # DEFENSIVE: accounts.defi_positions is stored as t.text (may be JSON string)
  def self.all_for_user(user)
    positions = []

    user.accounts.active.each do |account|
      # Defensively parse defi_positions
      # Could be: nil, String (JSON), Array, or Hash
      defi_positions = parse_defi_positions(account.defi_positions)
      next if defi_positions.nil? || defi_positions.empty?

      defi_positions.each_with_index do |protocol, protocol_idx|
        protocol["positions"]&.each do |pos|
          # Derive chain: use position chain, fallback to account blockchain
          # Normalize "unknown" to actual blockchain
          position_chain = pos["chain"]
          chain = if position_chain.nil? || position_chain.to_s.downcase == "unknown"
                    account.blockchain
                  else
                    position_chain
                  end

          # Derive protocol_id: use id if present, fallback to name
          # If duplicate names exist, append index to distinguish them
          protocol_id = protocol["id"] || protocol["name"] || "protocol_#{protocol_idx}"

          positions << new(
            account_id: account.id,
            address: account.address,
            chain: chain,
            protocol_id: protocol_id,
            protocol_name: protocol["name"] || "Unknown Protocol",
            protocol_type: protocol["type"],
            protocol_icon_url: protocol["logo_url"] || protocol["icon_url"],
            token_symbol: pos["token_symbol"],
            token_name: pos["token_name"],
            token_icon_url: pos["logo_url"] || pos["icon_url"],
            balance: pos["balance"],
            usd_value: pos["usd_value"],
            is_debt: pos["is_debt"] || false,
            health_rate: protocol["health_rate"]
          )
        end
      end
    rescue => e
      # Log error but don't break aggregation for this account
      Rails.logger.error("NormalizedPosition: Failed to parse account #{account.id}: #{e.message}")
      next
    end

    positions
  end

  # Parse defi_positions which could be String (JSON), Array, Hash, or nil
  def self.parse_defi_positions(data)
    return [] if data.nil?

    case data
    when String
      # Parse JSON string, return empty array on error
      begin
        JSON.parse(data)
      rescue JSON::ParserError => e
        Rails.logger.warn("NormalizedPosition: Invalid JSON in defi_positions: #{e.message}")
        []
      end
    when Array
      data
    when Hash
      [data] # Wrap single hash in array
    else
      Rails.logger.warn("NormalizedPosition: Unexpected defi_positions type: #{data.class}")
      []
    end
  end

  # Convenience methods
  def supplied?
    !is_debt
  end

  def borrowed?
    is_debt
  end

  def abs_value
    usd_value.abs
  end

  def protocol_key
    "#{protocol_id}_#{chain}"
  end

  # Safe fallback for missing icons
  def protocol_icon
    protocol_icon_url.presence || default_protocol_icon
  end

  def token_icon
    token_icon_url.presence || default_token_icon
  end

  private

  def default_protocol_icon
    # Return path to default SVG or use CSS to show first letter in colored circle
    nil # Let view handle fallback with CSS
  end

  def default_token_icon
    nil # Let view handle fallback with CSS
  end
end
