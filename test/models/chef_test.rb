require "test_helper"

class ChefTest < ActiveSupport::TestCase

  def setup
    @chef = Chef.new(name: "TestChef", email: "testChef@gmail.com")
  end
    
  test "0) test chef object must be valid" do
    assert @chef.valid?
  end
  
  test "1) name must be present" do
    @chef.name = ""
    assert_not @chef.valid? 
  end
  
  test "2a) name must be more than 2 characters" do
    @chef.name = "a" * 2
    assert_not @chef.valid? 
  end
  
  test "2b) name must be less than 41 characters" do
    @chef.name = "a" * 41
    assert_not @chef.valid? 
  end

  test "3) email must be present" do
    @chef.email = ""
    assert_not @chef.valid? 
  end
  
  #  4) email must be between 3 and 100 characters 
  test "4a) email must be more than 2 characters" do
    @chef.email = "a" * 2
    assert_not @chef.valid?
  end
  
  test "4b) email must be less than 101 characters" do
    @chef.email = "a" * 101
    assert_not @chef.valid?
  end
  
  test "5) email must be unique" do
    dup_chef = @chef.dup
    dup_chef.email = @chef.email.upcase
    @chef.save
    assert_not dup_chef.valid?
  end
  
  test "6a) email must be valid - validation should accept valid addresses" do
    valid_addresses = [ "valid1@gmail.com", "valid2@gmail.com", "valid3@gmail.com"]
    valid_addresses.each do |addr|
      @chef.email = addr
      assert @chef.valid? '#{addr.inspect} should be valid'
    end
  end
  
  test "6b) email must be valid - validation should reject invalid addresses" do
    invalid_addresses = [ "noDot", ".onlyDot" ]
    invalid_addresses.each do |addr|
      @chef.email = addr
      assert_not @chef.valid? '#{addr.inspect} should be invalid'
    end
  end
  
end