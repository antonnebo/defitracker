class AddDeFiPositionsToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :wallet_balance_usd, :decimal, precision: 20, scale: 2, default: 0.0
    add_column :accounts, :protocol_balance_usd, :decimal, precision: 20, scale: 2, default: 0.0
    add_column :accounts, :defi_positions, :text
  end
end
