class RemoveTheNullConditionOnRevision < ActiveRecord::Migration
  def up
    change_column :locations, :revision, :integer, :null => true
  end

  def down
    change_column :locations, :revision, :integer, :null => false
  end
end
