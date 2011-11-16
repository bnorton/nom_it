class Image < ActiveRecord::Base
  has_attached_file :image,
  :url => ':s3_domain_url',
  :hash_secret => "244617a1862bb2bfdd1c061118e2f009e97806502a0858380f06379aa7980403",
  :styles =>{
    :thumb  => "60x60",
    :small  => "180x120",
    :medium => "600x400",
    :large  => "1200x800"
  },
  :storage => :s3,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :path => "/:hash.:extension",
  :bucket => 'img.justnom',
  :use_timestamp => false
  
  
  def new_image
    
  end
  
end