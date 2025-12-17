class DashboardController < ApplicationController
  def index
    # Aggregate portfolio data with caching
    @portfolio = Rails.cache.fetch("portfolio_overview_user_#{Current.user.id}", expires_in: 5.minutes) do
      PortfolioAggregationService.new(Current.user).call
    end
  end

  def sync_all
    # Enqueue enrichment job for all active accounts
    Current.user.accounts.active.each(&:enqueue_enrichment)

    # Invalidate cache
    Rails.cache.delete("portfolio_overview_user_#{Current.user.id}")

    redirect_to dashboard_path, notice: "Syncing all accounts. Data will update shortly."
  end
end
