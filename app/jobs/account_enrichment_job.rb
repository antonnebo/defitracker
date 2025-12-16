class AccountEnrichmentJob < ApplicationJob
  queue_as :default

  def perform(account_id)
    # Defensive checks
    account = Account.find_by(id: account_id)
    return if account.nil? # Account was deleted

    return if account.sync_status == "syncing" # Already syncing (idempotency guard)

    # Proceed with enrichment
    AccountEnrichmentService.new(account).call
  end
end
