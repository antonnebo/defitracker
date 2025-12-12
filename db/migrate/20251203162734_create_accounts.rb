class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true

      # User inputs
      t.string :address, null: false
      t.string :name

      # Auto-detected fields
      t.string :account_type # "Ethereum & EVM EOA", "Solana & SVM", etc
      t.string :blockchain # "ethereum", "solana", "polygon", etc
      t.string :ens_name # Resolved ENS name if available
      t.decimal :balance_usd, precision: 18, scale: 2, default: 0.0

      # Optional fields
      t.string :group
      t.text :description
      t.json :extensions # Array of extensions like "HyperCore"
      t.string :status, default: "active", null: false

      # Enrichment tracking
      t.datetime :last_synced_at
      t.string :sync_status # "pending", "syncing", "synced", "error"
      t.text :sync_error

      t.timestamps
    end

    add_index :accounts, [:user_id, :address], unique: true
    add_index :accounts, :blockchain
    add_index :accounts, :status
  end
end
