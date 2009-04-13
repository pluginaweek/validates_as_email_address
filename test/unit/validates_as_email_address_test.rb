require File.dirname(__FILE__) + '/../test_helper'

class ValidatesAsEmailAddressByDefaultTest < ActiveSupport::TestCase
  def setup
    User.validates_as_email_address :email
  end
  
  def test_should_not_allow_email_addresses_shorter_than_3_characters
    user = new_user(:email => 'a@')
    assert !user.valid?
    assert user.errors.invalid?(:email)
    assert_equal 'is an invalid email address', user.errors.on(:email).first
    
    user.email = 'a@a'
    assert user.valid?
  end
  
  def test_should_not_allow_email_addresses_longer_than_320_characters
    user = new_user(:email => 'a@' + 'a' * 318)
    assert user.valid?
    
    user.email += 'a'
    assert !user.valid?
    assert user.errors.invalid?(:email)
  end
  
  def test_should_allow_legal_rfc822_formats
    [
      'test@example',
      'test@example.com', 
      'test@example.co.uk',
      '"J. Smith\'s House, a.k.a. Home!"@example.com',
      'test@123.com',
    ].each do |address|
      user = new_user(:email => address)
      assert user.valid?, "#{address} should be legal."
    end
  end
  
  def test_should_not_allow_illegal_rfc822_formats
    [
      'test@Monday 1:00', 
      'test@Monday the first',
      'J. Smith\'s House, a.k.a. Home!@example.com',
    ].each do |address|
      user = new_user(:email => address)
      assert !user.valid?, "#{address} should be illegal."
      assert user.errors.invalid?(:email)
    end
  end
  
  def test_should_not_allow_illegal_rfc1035_formats
    [
      'test@[127.0.0.1]',
      'test@-domain-not-starting-with-letter.com',
      'test@domain-not-ending-with-alphanum-.com'
    ].each do |address|
      user = new_user(:email => address)
      assert !user.valid?, "#{address} should be illegal."
    end
  end
  
  def teardown
    User.class_eval do
      @validate_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_create_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_update_callbacks = ActiveSupport::Callbacks::CallbackChain.new
    end
  end
end

class ValidatesAsEmailAddressTest < ActiveSupport::TestCase
  def test_should_allow_minimum_length
    User.validates_as_email_address :email, :minimum => 8
    
    user = new_user(:email => 'a@' + 'a' * 6)
    assert user.valid?
    
    user.email.chop!
    assert !user.valid?
  end
  
  def test_should_not_check_maximum_length_if_minimum_length_defined
    User.validates_as_email_address :email, :minimum => 10
    
    user = new_user(:email => 'a@' + 'a' * 319)
    assert user.valid?
  end
  
  def test_should_allow_maximum_length
    User.validates_as_email_address :email, :maximum => 8
    
    user = new_user(:email => 'a@' + 'a' * 6)
    assert user.valid?
    
    user.email += 'a'
    assert !user.valid?
  end
  
  def test_should_not_check_minimum_length_if_maximum_length_defined
    User.validates_as_email_address :email, :maximum => 8
    
    user = new_user(:email => 'a@')
    assert !user.valid?
    assert user.errors.invalid?(:email)
  end
  
  def test_should_allow_exact_length
    User.validates_as_email_address :email, :is => 8
    
    user = new_user(:email => 'a@' + 'a' * 6)
    assert user.valid?
    
    user.email.chop!
    assert !user.valid?
    
    user.email += 'aa'
    assert !user.valid?
  end
  
  def test_should_allow_within_range
    User.validates_as_email_address :email, :within => 8..9
    
    user = new_user(:email => 'a@' + 'a' * 5)
    assert !user.valid?
    
    user.email += 'a'
    assert user.valid?
    
    user.email += 'a'
    assert user.valid?
    
    user.email += 'a'
    assert !user.valid?
  end
  
  def test_should_allow_in_range
    User.validates_as_email_address :email, :in => 8..9
    
    user = new_user(:email => 'a@' + 'a' * 5)
    assert !user.valid?
    
    user.email += 'a'
    assert user.valid?
    
    user.email += 'a'
    assert user.valid?
    
    user.email += 'a'
    assert !user.valid?
  end
  
  def test_should_allow_too_long_message
    User.validates_as_email_address :email, :too_long => 'custom'
    
    user = new_user(:email => 'a@' + 'a' * 319)
    user.valid?
    
    assert_equal 'custom', Array(user.errors.on(:email)).last
  end
  
  def test_should_allow_too_short_message
    User.validates_as_email_address :email, :too_short => 'custom'
    
    user = new_user(:email => 'a@')
    user.valid?
    
    assert_equal 'custom', Array(user.errors.on(:email)).last
  end
  
  def test_should_allow_wrong_length_message
    User.validates_as_email_address :email, :is => 8, :wrong_length => 'custom'
    
    user = new_user(:email => 'a@a.com')
    user.valid?
    
    assert_equal 'custom', Array(user.errors.on(:email)).last
  end
  
  def test_should_allow_wrong_format_message
    User.validates_as_email_address :email, :wrong_format => 'custom'
    
    user = new_user(:email => 'a@!')
    user.valid?
    
    assert_equal 'custom', Array(user.errors.on(:email)).first
  end
  
  def test_should_validate_if_if_is_true
    User.validates_as_email_address :email, :if => lambda {|user| true}
    
    user = new_user(:email => 'a')
    assert !user.valid?
  end
  
  def test_should_not_validate_if_if_is_false
    User.validates_as_email_address :email, :if => lambda {|user| false}
    
    user = new_user(:email => 'a')
    assert user.valid?
  end
  
  def test_should_validate_if_unless_is_false
    User.validates_as_email_address :email, :unless => lambda {|user| false}
    
    user = new_user(:email => 'a')
    assert !user.valid?
  end
  
  def test_should_not_validate_if_unless_is_true
    User.validates_as_email_address :email, :unless => lambda {|user| true}
    
    user = new_user(:email => 'a')
    assert user.valid?
  end
  
  def test_should_validate_if_on_event
    User.validates_as_email_address :email, :on => :update
    
    user = create_user
    user.email = 'a'
    assert !user.valid?
  end
  
  def test_should_not_validate_if_not_on_event
    User.validates_as_email_address :email, :on => :create
    
    user = create_user
    user.email = 'a'
    assert user.valid?
  end
  
  def test_should_not_validate_if_allow_nil_and_nil
    User.validates_as_email_address :email, :allow_nil => true
    
    user = create_user
    user.email = nil
    assert user.valid?
  end
  
  def test_should_validate_if_allow_nil_and_not_nil
    User.validates_as_email_address :email, :allow_nil => true
    
    user = create_user
    user.email = 'a'
    assert !user.valid?
  end
  
  def test_should_validate_if_not_allow_nil_and_nil
    User.validates_as_email_address :email, :allow_nil => false
    
    user = create_user
    user.email = nil
    assert !user.valid?
  end
  
  def test_should_validate_if_not_allow_nil_and_not_nil
    User.validates_as_email_address :email, :allow_nil => false
    
    user = create_user
    user.email = 'a'
    assert !user.valid?
  end
  
  def test_should_not_validate_if_allow_blank_and_blank
    User.validates_as_email_address :email, :allow_blank => true
    
    user = create_user
    user.email = ''
    assert user.valid?
  end
  
  def test_should_validate_if_allow_blank_and_not_blank
    User.validates_as_email_address :email, :allow_blank => true
    
    user = create_user
    user.email = 'a'
    assert !user.valid?
  end
  
  def test_should_validate_if_not_allow_blank_and_blank
    User.validates_as_email_address :email, :allow_blank => false
    
    user = create_user
    user.email = ''
    assert !user.valid?
  end
  
  def test_should_validate_if_not_allow_nil_and_not_nil
    User.validates_as_email_address :email, :allow_blank => false
    
    user = create_user
    user.email = 'a'
    assert !user.valid?
  end
  
  def teardown
    User.class_eval do
      @validate_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_create_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_update_callbacks = ActiveSupport::Callbacks::CallbackChain.new
    end
  end
end

class ValidatesAsEmailAddressUnrestrictedTest < ActiveSupport::TestCase
  def setup
    User.validates_as_email_address :email, :strict => false
  end
  
  def test_should_allow_illegal_rfc1035_formats
    [
      'test@[127.0.0.1]',
      'test@-domain-not-starting-with-letter.com',
      'test@domain-not-ending-with-alphanum-.com'
    ].each do |address|
      user = new_user(:email => address)
      assert user.valid?, "#{address} should be legal."
    end
  end
  
  def teardown
    User.class_eval do
      @validate_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_create_callbacks = ActiveSupport::Callbacks::CallbackChain.new
      @validate_on_update_callbacks = ActiveSupport::Callbacks::CallbackChain.new
    end
  end
end
