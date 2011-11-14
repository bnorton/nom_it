class RemoveLimitFromZip < ActiveRecord::Migration
  def up
    change_column :locations, :area_code, :string
  end

  def down
    change_column :locations, :area_code, :string, :limit => 7
  end
end
