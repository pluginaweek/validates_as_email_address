require File.dirname(__FILE__) + '/test_helper'

class TestRecord < ActiveRecord::Base
  def self.columns; []; end
  attr_accessor :email
  validates_as_email_address :email
end

class ValidatesAsEmailAddressTest < Test::Unit::TestCase
  def test_illegal_rfc822_email_address_should_not_be_valid
    [
      'Max@Job 3:14', 
      'Job@Book of Job',
      'J. P. \'s-Gravezande, a.k.a. The Hacker!@example.com',
    ].each do |address|
      assert !TestRecord.new(:email => address).valid?, "#{address} should be illegal."
    end
  end
  
  def test_legal_rfc822_email_address_should_be_valid
    [
      'test@example',
      'test@example.com', 
      'test@example.co.uk',
      '"J. P. \'s-Gravezande, a.k.a. The Hacker!"@example.com',
      'me@[187.223.45.119]',
      'someone@123.com',
    ].each do |address|
      assert TestRecord.new(:email => address).valid?, "#{address} should be legal."
    end
  end
end
