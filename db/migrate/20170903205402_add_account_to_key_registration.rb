class AddAccountToKeyRegistration < ActiveRecord::Migration
  def change
    add_column :key_registrations, :account, :string
  end
end
