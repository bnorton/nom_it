require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "category" do
  describe "input validations" do
    before :each do
      Category.collection.remove
    end
    it "should reject a location Category if the text is not present" do
      Category.find_or_create_by_name('',{:odd=>'opts'}).should be_false
    end
    it "should reject a search if none of the correct parameters are not specified" do
      Category.find_by_nid('').should == nil
    end
    it "should reject a search if the id cannot be parsed to a BSON::ObjectId" do
      nid = BSON::ObjectId.new.to_s[0..10] # make it invalid
      Category.find_by_nid(nid).should be_nil
    end
  end
  describe "create" do
    before :each do
      Category.collection.remove
      @before = Category.collection.count
    end
    it "should normalize all inputs downcase" do
      item = 'Food'
      Category.normalize!(item)
      item.should == 'food'
      item = 'Food Truck'
      Category.normalize!(item)
      item.should == 'food truck'
      items = {:p => 'Top Level Category',
               :s => 'A non-Top lEveL'}
      Category.normalize!(items)
      items.keys.length.should == 2
      items[:p].should == 'top level category'
      items[:s].should == 'a non-top level'
    end
    it "should create a new top-level Category" do
      Category.find_or_create_by_name('food').class.should == String
      (Category.collection.count - @before).should == 1
    end
    it "should create multiple top-level Categories" do
      Category.find_or_create_by_name('bars').class.should == String
      Category.find_or_create_by_name('nightlife').class.should == String
      Category.find_or_create_by_name('hiking').class.should == String
      (Category.collection.count - @before).should == 3
    end
    it "should create a new secondary-level Category" do
      Category.find_or_create_by_name('food',{:s=>'pizza'}).class.should == String
      (Category.collection.count - @before).should == 1
    end
    it "should create multiple secondary-level Categories" do
      Category.find_or_create_by_name('food',{:s=>'pizza'}).class.should == String
      Category.find_or_create_by_name('food',{:s=>'sushi'}).class.should == String
      Category.find_or_create_by_name('food',{:s=>'asian fusion'}).class.should == String
      (Category.collection.count - @before).should == 3
    end
    it "should create top level and secondery categories if needed" do
      top_level = 'eat'
      arr = ['Food Truck','Hot Dogs','Indian']
      top_level_nid, category_ids = Category.new_categories(top_level,arr)
      top_level_nid.should_not be_blank
      category_ids.length.should == 3
      (Category.collection.count - @before).should == 4
      category_ids.each do |c|
        c.should_not be_blank
        c.class.should == String
      end
      top_level = 'Eat' # same as above
      arr = ['hot dogs','Crepes']
      top_level_nid, category_ids = Category.new_categories(top_level,arr)
      top_level_nid.should_not be_blank
      category_ids.each do |c|
        c.should_not be_blank
        c.class.should == String
      end
      category_ids.length.should == 2
      (Category.collection.count - @before).should == 5 # only add 1 in this case
    end
    it "should not create a new item if the NAME is already present" do
      iid = 'blah_blah'
      Category.find_or_create_by_name(iid).class.should == String
      (Category.collection.count - @before).should == 1
      Category.find_or_create_by_name(iid).class.should == String
      (Category.collection.count - @before).should == 1 # same as before
    end
    it "should have the same parent when two child categories are of one parent" do
      top_level = 'eat'
      childs = ['child 1', 'child 2']
      top_level_nid, category_ids = Category.new_categories(top_level,childs)
      category_ids.each do |c|
        Category.find_by_nid(c)['parent'].should == top_level_nid
      end
    end
    it "should then find the created Categorys based on the criteria" do
      
    end
    it "should store the alias if the parameter is given" do
      
    end
  end
  describe "destroy" do
    before :each do
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
    before :each do
      Category.collection.remove
      Category.new_categories('eAt',['Food Truck','Hot Dogs','Indian'])
    end
    describe "name" do
      it "should find Category by name" do
        Category.find_by_name('eat').should_not be_blank
        Category.find_by_name('food truCK').should_not be_blank
        Category.find_by_name('food truck').should_not be_blank
        Category.find_by_name('EAT').should_not be_blank
        Category.find_by_name('hot dogs').should_not be_blank
        Category.find_by_name('Indian').should_not be_blank
        Category.find_by_name('InDIan').should_not be_blank
      end
      it "should have the sam parent" do
        c1 = Category.find_by_name('hot dogs')
        c1.should_not be_blank
        Category.find_by_nid(c1['_id'])['parent'].should == Category.find_by_name('eat')['_id']
        c2 = Category.find_by_name('Indian')
        c2.should_not be_blank
        Category.find_by_nid(c2['_id'])['parent'].should == Category.find_by_name('eat')['_id']
      end
      it "should find Category by alias" do
      end
    end
  end
end
