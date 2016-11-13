class AddResidenceToResult < ActiveRecord::Migration
  def change
    add_column :results, :residence, :string
  end
end
