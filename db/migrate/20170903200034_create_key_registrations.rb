class CreateKeyRegistrations < ActiveRecord::Migration
  def change
    create_table :key_registrations do |t|
      t.string :pubkey
      t.string :document

      t.timestamps null: false
    end
  end
end
