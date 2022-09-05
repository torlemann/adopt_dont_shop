class CreateAppPets < ActiveRecord::Migration[5.2]
  def change
    create_table :app_pets do |t|
      t.references :app, foreign_key: true
      t.references :pet, foreign_key: true
      t.string :status, default: "pending" 
      t.timestamps
    end
  end
end
