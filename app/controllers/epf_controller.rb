class EpfController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin_account

  def load_incremental
    date = params['date']
    EpfV3Worker.perform_async(:load_incremental, date)
  end

  def load_full
    date = params['date']
    EpfV3Worker.perform_async(:load_full, date)
  end
end
