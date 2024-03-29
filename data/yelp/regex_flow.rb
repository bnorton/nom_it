
all = ['berkeley', 'boston', 'chicago' 'dc', 'denver', 'losangeles', 'seattle', 'vegas']
current = 'berkeley'

BASE = File.join(Rails.root, 'data', 'yelp', current)

Dir.glob("#{BASE}*.txt").each do |file_name|
  File.open(file_name) { |ff|
    ff.each { |f|
      
    }
  }
end

# remove all Photo + description lines and replace with ==========
/\bPhoto.+\.\n.+[\.!?…]/ => ==========

# check to see if Photo is there again
/Photo.+/ => capture the next line => ==========

# make sure that each phone number is followed by ========== and inject where needed
/(\([0-9]+\) [0-9\-]+\n)([^=])/ => $1==========\n$2

# remove all of the things after the equals if missed
(==========).+ => $1
