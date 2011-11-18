class Image < ActiveRecord::Base
  
  IMAGE_STYLES = {
    :thumb  => "60x60",
    :medium => "600x400",
    :large  => "1200x800"
  }
  IMAGE_KEYS = [:thumb,:medium,:large]
  
  has_attached_file :image,
  :url => ':s3_domain_url',
  :hash_secret => "244617a1862bb2bfdd1c061118e2f009e97806502a0858380f06379aa7980403",
  :styles => IMAGE_STYLES,
  :storage => :s3,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :path => "/:hash.:extension",
  :bucket => 'img.justnom',
  :use_timestamp => false
  
  def self.for_image_nid(image_nid,options={})
    Image.build_image(Image.find_by_nid(image_nid),options)
  end
  
  def self.for_location_nid(location_nid,options={})
    return {} if location_nid.blank?
    images = []
    raw_images = Image.limit(9).find_all_by_location_nid(location_nid)
    raw_images.each do |img|
      images << Image.build_image(img,options)
    end
    images
  end
  
  private
  
  def self.build_image(image,options)
    return false unless image = image.image
    size = options[:size] if IMAGE_KEYS.include? options[:size]
    size ||= :medium
    img = {
      :url => image.url(size),
      :size => IMAGE_STYLES[size]
    }
    img.merge!({:thumb => image.url(:thumb)}) unless size == :thumb
    img
  end
end

# [
#   {
#     :size=>"600x400", 
#     :thumb=>"http://img.justnom.s3.amazonaws.com/dbaf88d72995229bde76535c4771c3a9c2976179.jpg", 
#     :url=>"http://img.justnom.s3.amazonaws.com/343ed82d4b2a5b0dfc49a96aff843e7234f85962.jpg"
#   }, 
#   {
#     :size=>"600x400", 
#     :thumb=>"http://img.justnom.s3.amazonaws.com/1a215a5aad85357ae4c4691e3e253f716af70eb5.jpg", 
#     :url=>"http://img.justnom.s3.amazonaws.com/840c821fb09f93a4d3bbd4ca19a794b2019de88d.jpg"
#   }
# ]

