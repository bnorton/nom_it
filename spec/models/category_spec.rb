require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "category" do
  describe "input validations" do
    before do
      Category.collection.remove
    end
    
    # METHODS AVAILABLE
    # find_by_name(name)
    # find_by_id(id)
    # find_or_create_by_id(id,opt={}) # opt must have name and can have alias
    # find_or_create_by_name(name) # opt must have name and can have alias
    # destroy_by_id(id)

    it "should reject an empty hash for create (since no primary name)" do
      Category.find_or_create_by_id('4e223',{}).should be_false
    end
    it "should reject a location Category if the text is not present" do
      Category.find_or_create_by_name('',{:odd=>'opts'}).should be_false
    end
    it "should reject a search if none of the correct parameters are not specified" do
      Category.find_by_id('').should == false
    end
    it "should reject a search if the id cannot be parsed to a BSON::ObjectId" do
      id = BSON::ObjectId.new.to_s[0..10] # make it invalid
      Category.find_by_id(id).should be_nil
    end
  end
  describe "create" do
    before do
      Category.collection.remove
    end
    before :each do
      @before = Category.collection.count
    end
    it "should normalize all inputs downcase" do
      item = 'Food'
      Category.normalize!(item)
      item.should == 'food'
      item = 'Food Truck'
      Category.normalize!(item)
      item.should == 'food truck'
      items = {:primary => 'Top Level Category',
               :secondary => 'A non-Top lEveL'}
      Category.normalize!(items)
      items.keys.length.should == 2
      items[:primary].should == 'top level category'
      items[:secondary].should == 'a non-top level'
    end
    it "should create a new top-level Category" do
      Category.find_or_create_by_name('food').class.should == BSON::ObjectId
      (Category.collection.count - @before).should == 1
    end
    it "should create multiple top-level Categories" do
      Category.find_or_create_by_name('bars').class.should == BSON::ObjectId
      Category.find_or_create_by_name('nightlife').class.should == BSON::ObjectId
      Category.find_or_create_by_name('hiking').class.should == BSON::ObjectId
      (Category.collection.count - @before).should == 3
    end
    it "should create a new secondary-level Category" do
      Category.find_or_create_by_name('food',{:secondary=>'pizza'}).class.should == BSON::ObjectId
      (Category.collection.count - @before).should == 1
    end
    it "should create multiple secondary-level Categories" do
      Category.find_or_create_by_name('food',{:secondary=>'pizza'}).class.should == BSON::ObjectId
      Category.find_or_create_by_name('food',{:secondary=>'sushi'}).class.should == BSON::ObjectId
      Category.find_or_create_by_name('food',{:secondary=>'asian fusion'}).class.should == BSON::ObjectId
      (Category.collection.count - @before).should == 3
    end
    it "should create top level and secondery categories if needed" do
      top_level = 'eat'
      arr = ['Food Truck','Hot Dogs','Indian']
      Category.new_categories(top_level,arr).should == true
      (Category.collection.count - @before).should == 4
      puts "++++++++++++++++++++++++++++!!!!!!!!!!!!!"
      c = Category.collection.find()
      while f = c.next
        puts f.inspect
      end
      top_level = 'Eat' # same as above
      arr = ['hot dogs','Crepes']
      Category.new_categories(top_level,arr).should == true
      # (Category.collection.count - @before).should == 5 # only add 1 in this case
      puts "++++++++++++++++++++++++++++"
      c = Category.collection.find()
      while f = c.next
        puts f.inspect
      end
    end
    it "should not create a new item if the ID is already present" do
      iid = '4ergh9q39vm'
      Category.find_or_create_by_id(iid,{:primary => 'eat'})
      (Category.collection.count - @before).should == 1
      Category.find_or_create_by_id(iid,{:primary => 'something random'})
      (Category.collection.count - @before).should == 1 # stay the same
    end
    it "should not create a new item if the NAME is already present" do
      iid = 'blah_blah'
      Category.find_or_create_by_name(iid).class.should == BSON::ObjectId
      (Category.collection.count - @before).should == 1
      Category.find_or_create_by_name(iid).should == false
      (Category.collection.count - @before).should == 1 # same as before
      
    end
    it "should not create a new item if the NAME is already present as an alias" do
      
    end
    it "should then find the created Categorys based on the criteria" do
      
    end
    it "should store the alias if the parameter is given" do
      
    end
  end
  describe "destroy" do
    before do
      Category.collection.remove
    end
    it "should remove any categories that were specified for delete" do
    end
    it "should remove any categories that were specified for delete by id" do
    end
    it "should remove any categories that were specified for delete by name" do
    end
  end
  describe "search" do
    before do
      Category.collection.remove
    end
    describe "name" do
      it "should find Category by name" do
      end
      it "should find Category by alias" do
      end
      it "should find Category by id only if the id is a valid BSON::ObjectId" do
      end
    end
  end
end
