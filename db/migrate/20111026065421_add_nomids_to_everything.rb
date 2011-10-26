class AddNomidsToEverything < ActiveRecord::Migration
  
  TABLES = [:geolocations,:images,:locations,:rankings,:recommendations,:revisions,:statistics,:tags,:users]
  
  def up
    TABLES.each do |tab|
      add_column tab, :nid, :string
    end
  end
  
  def down
    TABLES.each do |tab|
      remove_column tab, :nid
    end
  end
end
