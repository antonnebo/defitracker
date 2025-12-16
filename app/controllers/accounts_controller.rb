class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    @accounts = Current.user.accounts.order(created_at: :desc)
  end

  def show
    # Parse defi_positions JSON for view
    @defi_positions = parse_defi_positions(@account.defi_positions)

    # Calculate portfolio percentages
    if @account.balance_usd.to_f > 0
      @wallet_percentage = (@account.wallet_balance_usd.to_f / @account.balance_usd.to_f * 100).round(1)
      @protocol_percentage = (@account.protocol_balance_usd.to_f / @account.balance_usd.to_f * 100).round(1)
    else
      @wallet_percentage = 0
      @protocol_percentage = 0
    end
  end

  def new
    @account = Current.user.accounts.build
  end

  def create
    @account = Current.user.accounts.build(account_params)

    if @account.save
      redirect_to accounts_path, notice: "Account added successfully. Syncing data..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to accounts_path, notice: "Account updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_path, notice: "Account removed successfully."
  end

  private

  def set_account
    @account = Current.user.accounts.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:address, :name, :group, :description, :status)
  end

  def parse_defi_positions(defi_positions)
    return [] if defi_positions.blank?

    # If it's already an Array, return as-is
    return defi_positions if defi_positions.is_a?(Array)

    # If it's a String, parse the JSON
    if defi_positions.is_a?(String)
      begin
        JSON.parse(defi_positions)
      rescue JSON::ParserError
        []
      end
    else
      # If it's some other type (Hash, etc.), convert to array
      Array(defi_positions)
    end
  end
end
