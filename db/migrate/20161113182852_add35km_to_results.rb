class Add35kmToResults < ActiveRecord::Migration
  def change
    add_column :results, :split_35km, :string
  end
end
