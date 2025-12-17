class PortfolioAggregationService
  def initialize(user)
    @user = user
    @accounts = user.accounts.active
    @positions = NormalizedPosition.all_for_user(user)
  end

  def call
    {
      total_value: calculate_total_value,
      idle_value: calculate_idle_value,
      deployed_value: calculate_deployed_value,
      category_breakdown: calculate_category_breakdown,
      top_assets: calculate_top_assets(limit: 10),
      protocol_breakdown: calculate_protocol_breakdown,
      last_synced: calculate_last_synced,
      sync_status_summary: calculate_sync_status_summary
    }
  end

  private

  def calculate_total_value
    @accounts.sum(:balance_usd) || 0.0
  end

  def calculate_idle_value
    @accounts.sum(:wallet_balance_usd) || 0.0
  end

  def calculate_deployed_value
    @accounts.sum(:protocol_balance_usd) || 0.0
  end

  def calculate_category_breakdown
    # Minimal breakdown for MVP - just totals
    # If token classification exists, can add stables/majors/tokens later
    {
      idle: {
        total: calculate_idle_value
        # Future: stablecoins, majors, tokens
      },
      deployed: {
        total: calculate_deployed_value
        # Future: lending, liquidity_pool, yield (if protocol_type available)
      },
      futures: 0.0
    }
  end

  def calculate_top_assets(limit: 10)
    return [] if @positions.empty?

    # Group by token symbol, sum values
    grouped = @positions.group_by(&:token_symbol).map do |symbol, positions|
      total = positions.sum(&:usd_value)
      {
        symbol: symbol,
        name: positions.first.token_name,
        icon_url: positions.first.token_icon_url,
        total_value: total,
        balance: positions.sum(&:balance)
      }
    end

    # Sort by absolute value (so debt shows up too)
    sorted = grouped.sort_by { |asset| -asset[:total_value].abs }
    top = sorted.first(limit)

    # Add percentage
    total_abs = calculate_total_value.abs
    if total_abs > 0
      top.each do |asset|
        asset[:percentage] = (asset[:total_value].abs / total_abs * 100).round(2)
      end
    end

    top
  end

  def calculate_protocol_breakdown
    return [] if @positions.empty?

    @positions.group_by(&:protocol_key).map do |key, positions|
      supplied = positions.select(&:supplied?)
      borrowed = positions.select(&:borrowed?)

      {
        protocol_id: positions.first.protocol_id,
        name: positions.first.protocol_name,
        type: positions.first.protocol_type,
        chain: positions.first.chain,
        icon_url: positions.first.protocol_icon_url,
        net_value: positions.sum(&:usd_value),
        supplied_value: supplied.sum(&:usd_value),
        borrowed_value: borrowed.sum(&:abs_value),
        health_rate: positions.find { |p| p.health_rate }&.health_rate,
        position_count: positions.size
      }
    end.sort_by { |p| -p[:net_value] }
  end

  def calculate_last_synced
    @accounts.maximum(:last_synced_at)
  end

  def calculate_sync_status_summary
    {
      synced: @accounts.where(sync_status: "synced").count,
      syncing: @accounts.where(sync_status: "syncing").count,
      error: @accounts.where(sync_status: "error").count,
      pending: @accounts.where(sync_status: "pending").count
    }
  end
end
