require File.dirname(__FILE__) + '/../test_helper'

class ValidatesAsEmailAddressTest < Test::Unit::TestCase
  def test_should_be_valid_with_a_valid_set_of_attributes
    user = new_user
    assert user.valid?
  end
  
  def test_should_allow_legal_rfc822_formats
    [
      'test@example',
      'test@example.com', 
      'test@example.co.uk',
      '"J. P. \'s-Gravezande, a.k.a. The Hacker!"@example.com',
      'me@[187.223.45.119]',
      'someone@123.com',
    ].each do |address|
      user = new_user(:email => address)
      assert user.valid?, "#{address} should be legal."
    end
  end
  
  def test_should_not_allow_illegal_rfc822_formats
    [
      'Max@Job 3:14', 
      'Job@Book of Job',
      'J. P. \'s-Gravezande, a.k.a. The Hacker!@example.com',
    ].each do |address|
      user = new_user(:email => address)
      assert !user.valid?, "#{address} should be illegal."
      assert_equal 1, Array(user.errors.on(:email)).size
    end
  end
  
  def test_not_allow_emails_longer_than_320_characters
    user = new_user(:email => 'a' * 313 + '@a.com')
    assert user.valid?
    
    user.email = 'a' + user.email
    assert user.valid?
    
    user.email = 'a' + user.email
    assert !user.valid?
    assert_equal 1, Array(user.errors.on(:email)).size
  end
end
