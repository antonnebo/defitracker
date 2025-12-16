class Account < ApplicationRecord
  belongs_to :user

  # Serialize DeFi positions as JSON
  serialize :defi_positions, coder: JSON

  validates :address, presence: true
  validates :address, uniqueness: { scope: :user_id }
  validates :status, inclusion: { in: %w[active inactive] }
  validates :sync_status, inclusion: { in: %w[pending syncing synced error] }, allow_nil: true

  after_create :enqueue_enrichment

  scope :active, -> { where(status: "active") }
  scope :synced, -> { where(sync_status: "synced") }
  scope :pending_sync, -> { where(sync_status: "pending") }

  def display_name
    name.presence || shortened_address
  end

  def shortened_address
    return address unless address.present?
    "#{address[0..5]}...#{address[-4..]}"
  end

  def needs_sync?
    sync_status.in?(["pending", "error"]) || last_synced_at.nil? || last_synced_at < 5.minutes.ago
  end

  # Enqueue enrichment job
  # Returns true if job was enqueued, false if already syncing
  def enqueue_enrichment
    return false if sync_status == "syncing" # Idempotency guard

    AccountEnrichmentJob.perform_later(id)
    update(sync_status: "pending")
    true
  end

  # Enqueue sync job only if account needs syncing
  # Returns true if job was enqueued, false otherwise
  def sync_if_needed
    return false unless needs_sync?
    enqueue_enrichment
  end

  private
end
