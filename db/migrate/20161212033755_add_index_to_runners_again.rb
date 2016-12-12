class AddIndexToRunnersAgain < ActiveRecord::Migration
  def change
    def change
    add_index :runners, [:first_name, :last_name, :city]
  end
  end
end
