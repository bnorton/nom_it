require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "YelpParseSpec" do
  before do
    @example1 = "1. SF Grill
Categories: Farmers Market, Food Stands
Neighborhood: Western Addition/NOPA
4.5 star rating
34 reviews
Grove and Divisadero St
San Francisco, CA 94117
(415) 235-4022
=========="
    @example2 = "1. SF Grill
Categories: Farmers Market, Food Stands
Neighborhood: Western Addition/NOPA
4.5 star rating
34 reviews
Grove and Divisadero St
San Francisco, CA 94117
(415) 235-4022
==========
2. The Codmother Fish and Chips
Categories: British, Fish & Chips, Seafood
Neighborhood: Fisherman's Wharf
4.5 star rating
98 reviews
2824 Jones St
San Francisco, CA 94133
(415) 606-9349
==========
3. Gorilla Pete's Hot Dogs
Categories: Hot Dogs, Caterers, Food Stands
Neighborhood: SOMA
4.5 star rating
31 reviews
Folsom St
San Francisco, CA 94105
(415) 793-0105
==========
4. M & L Market
Category: Sandwiches
Neighborhood: Castro
4.5 star rating
170 reviews
691 14th St
San Francisco, CA 94114
(415) 431-7044
=========="
    @filename1 = "$.txt"
    @filename2 = "$$$.txt"
    @filename3 = "$$_dessert.txt"
    @filename4 = "$_breakfast.txt"
    @example_s1 = "4. The Market<^&Category: Sandwiches<^&Neighborhood: Castro<^&4.5 star rating<^&170 reviews<^&691 14th St<^&San Francisco, CA 94114<^&(415) 431-7044<^&"
    @example_s2 = "3. Gorilla Pete's Hot Dogs<^&Categories: Hot Dogs, Caterers, Food Stands<^&Neighborhood: SOMA<^&4.5 star rating<^&31 reviews<^&Folsom St<^&San Francisco, CA 94105<^&(415) 793-0105<^&"
    @example_s3 = "2. The Codmother Fish and Chips<^&Categories: British, Fish & Chips, Seafood<^&Neighborhood: Fisherman's Wharf<^&4.5 star rating<^&98 reviews<^&2824 Jones St<^&San Francisco, CA 94133<^&(415) 606-9349<^&"
  end
  describe "initial parsing" do
    it "should stub File and parse an item into the serialized form" do
      tmp_file = "/Users/nort/Dropbox/git/nom_it/spec/tmp/_tmp.txt"
      File.open(tmp_file, 'w+') { |f| 
          f.write(@example2)    # NOTE EXAMPLE 2
      }
      tmp = File.open(tmp_file)
      File.stub!(:open).and_return(tmp)
      lines = File.open('blah')
      while (line = Geocode.build_item(lines)).present?
        Geocode.name(line).should_not be_blank
        Geocode.categories(line).should_not be_blank
        Geocode.neighborhood(line).should_not be_blank
        Geocode.rating(line).should_not be_blank
        Geocode.rating_count(line).should_not be_blank
        Geocode.address(line).should_not be_blank
        Geocode.digits(line).should_not be_blank
      end
      
    end
    it "should move through the whole flow for multiple items" do
      tmp_file = "/Users/nort/Dropbox/git/nom_it/spec/tmp/_tmp.txt"
      File.open(tmp_file, 'w+') { |f| 
          f.write(@example1)
      }
      tmp = File.open(tmp_file)
      File.stub!(:open).and_return(tmp)
      line = File.open('blah')
      item = Geocode.build_item(line)
      Geocode.categories(item).should == ['Farmers Market', 'Food Stands']
      Geocode.digits(item).should == "415-235-4022"
      Geocode.rating(item).should == 4.5
      Geocode.rating_count(item).should == 34
      Geocode.address(item).should == "Grove and Divisadero St San Francisco, CA 94117"
    end
    it "should extract the name field" do
      Geocode.name(@example_s1).should == "The Market"
      Geocode.name(@example_s2).should == "Gorilla Pete's Hot Dogs"
      Geocode.name(@example_s3).should == "The Codmother Fish and Chips"
    end
    it "should extract the categories field" do
      Geocode.categories(@example_s1).should == ["Sandwiches"]
      Geocode.categories(@example_s2).should == ["Hot Dogs", "Caterers", "Food Stands"]
      Geocode.categories(@example_s3).should == ["British", "Fish & Chips", "Seafood"]
    end
    it "should extract the neighborhood field" do
      Geocode.neighborhood(@example_s1).should == "Castro"
      Geocode.neighborhood(@example_s2).should == "SOMA"
      Geocode.neighborhood(@example_s3).should == "Fisherman's Wharf"
    end
    it "should extract the rating field" do
      Geocode.rating(@example_s1).should == 4.5
      Geocode.rating(@example_s2).should == 4.5
      Geocode.rating(@example_s3).should == 4.5
    end
    it "should extract the rating total field" do
      Geocode.rating_count(@example_s1).should == 170
      Geocode.rating_count(@example_s2).should == 31
      Geocode.rating_count(@example_s3).should == 98
    end
    it "should extract the address field" do
      Geocode.address(@example_s1).should == "691 14th St San Francisco, CA 94114"
      Geocode.address(@example_s2).should == "Folsom St San Francisco, CA 94105"
      Geocode.address(@example_s3).should == "2824 Jones St San Francisco, CA 94133"
    end
    it "should extract the digits field" do
      Geocode.digits(@example_s1).should == "415-431-7044"
      Geocode.digits(@example_s2).should == "415-793-0105"
      Geocode.digits(@example_s3).should == "415-606-9349"
    end
    it "should extract the cost field" do
      Geocode.cost(@filename1).should == "$"
      Geocode.cost(@filename2).should == "$$$"
      Geocode.cost(@filename3).should == "$$"
      Geocode.cost(@filename4).should == "$"
    end
    it "should extract the timeofday field" do
      Geocode.timeofday(@filename1).should == "lunch|dinner"
      Geocode.timeofday(@filename2).should == "lunch|dinner"
      Geocode.timeofday(@filename3).should == "dessert|latenight"
      Geocode.timeofday(@filename4).should == "breakfast|brunch"
    end
    it "should fetch the data for an address" do
      addr = '691 14th St San Francisco, CA 94114'
      yahoo = Geocode.fetch_yahoo_data(addr)
      yahoo.class.should == OpenStruct
      yahoo.should_not be_blank
    end
    # def name(item) # 1. SF Grill
    # def categories(item) # Categories: Farmers Market, Food Stands
    # def neighborhood(item) # Neighborhood: Western Addition/NOPA
    # def rating(item) # 4.5 star rating
    # def rating_count(item) # 34 reviews
    # def address(item) # Grove and Divisadero St
    # def digits(item) # (415) 235-4022
    # def timeofday(file_name) # filenames are ($)+_?[(breakfast)|(dessert)]?\.txt
    # def cost(file_name)  # filenames are ($)+_?[(breakfast)|(dessert)]?\.txt
  end
end
