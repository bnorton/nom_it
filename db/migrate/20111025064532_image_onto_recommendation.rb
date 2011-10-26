class ImageOntoRecommendation < ActiveRecord::Migration
  def up
    add_column :recommendations, :image, :string
  end

  def down
    remove_column :recommendations, :image
  end
end
