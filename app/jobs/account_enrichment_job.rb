class AccountEnrichmentJob < ApplicationJob
  queue_as :default

  def perform(account_id)
    account = Account.find(account_id)
    AccountEnrichmentService.new(account).call
  end
end
