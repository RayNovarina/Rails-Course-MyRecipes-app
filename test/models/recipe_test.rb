require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  
  def setup
    @recipe = Recipe.new(name: "chicken soup", 
                         summary: "hearty soup", 
                         description: "veggies, chicken, cook 2 hours")
  end
  
# TDD: Test Driven Development
# 1) Spec it out
# 2) Define a test method with descriptive name
# 3) Create a failure case
# 4) Test for success
# 5) Implement the production code/functionality to make the test pass.

  test "0) recipe should be valid" do
    assert @recipe.valid?
  end
 
  test "1) name must be present" do
    @recipe.name = ""
    assert_not @recipe.valid?
  end

# 2) name must be between 5 and 100 characters
  test "2a) name must be more than 4 characters" do
    @recipe.name = "a" * 4
    assert_not @recipe.valid?
  end
  
  test "2b) name must be less than 101 characters" do
    @recipe.name = "a" * 101
    assert_not @recipe.valid?
  end
  
  test "3) summary must be present" do
    @recipe.summary = ""
    assert_not @recipe.valid?
  end
  
# 4) summary must be between 10 and 150 characters
  test "4a) summary must be more than 9 characters" do
        @recipe.summary = "a" * 8
    assert_not @recipe.valid?
  end
  
  test "4b) summary must be less than 151 characters" do
        @recipe.summary = "a" * 151
    assert_not @recipe.valid?
  end
  
  test "5) description must be present" do
    @recipe.description = ""
    assert_not @recipe.valid?
  end
  
# 6) description must be between 20 and 500 characters
  test "6a) description must be more than 19 characters" do
      @recipe.description = "a" * 19
    assert_not @recipe.valid?
  end

  test "6b) description must be less than 501 characters" do
        @recipe.description = "a" * 501
    assert_not @recipe.valid?
  end
  
  test "7) chef_id must be present" do
    
  end
  
 
  
end

