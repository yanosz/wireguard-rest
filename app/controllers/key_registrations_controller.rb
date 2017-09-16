class KeyRegistrationsController < ApplicationController

  # GET /key_registrations
  # GET /key_registrations.json
  def index
    data = KeyRegistration.all.map do |c|
      {id: c.id, pubkey: c.pubkey, created_at: c.created_at}
    end
    render json: data
  end
  # POST /key_registrations
  # POST /key_registrations.json

  def create
    if k = KeyRegistration.find_or_create_by(pubkey: params[:pubkey], account: params[:account])
      k.update_attribute(:updated_at, DateTime.now)
      render json: k.client_networks_str
    else
        render json: k.errors, status: :unprocessable_entity
    end
  end

  # DELETE /key_registrations/1
  # DELETE /key_registrations/1.json
  def destroy
    k = KeyRegistration.find_by_account(params[:account])
    if k
      k.destroy
      head :no_content
    else
      render json: "Not Found", status: :unprocessable_entity
    end

  end

end
