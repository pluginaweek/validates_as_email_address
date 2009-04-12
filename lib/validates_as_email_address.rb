require 'validates_as_email_address/rfc_822'
require 'validates_as_email_address/rfc_1035'

# Adds validations for email addresses
module ValidatesAsEmailAddress
  # The default error message to use for improperly formatted e-mail addresses
  mattr_accessor :invalid_email_message
  self.invalid_email_message = 'is an invalid email address'
  
  # Validates whether the value of the specific attribute matches against the
  # RFC822/RFC1035 specification.
  # 
  #   class Person < ActiveRecord::Base
  #     validates_as_email_address :email, :on => :create
  #   end
  # 
  # This will also validate that the email address is within the specification
  # limits, i.e. between 3 and 320 characters in length.
  # 
  # Configuration options for length:
  # * <tt>:minimum</tt> - The minimum size of the attribute
  # * <tt>:maximum</tt> - The maximum size of the attribute
  # * <tt>:is</tt> - The exact size of the attribute
  # * <tt>:within</tt> - A range specifying the minimum and maximum size of the
  #   attribute
  # * <tt>:in</tt> - A synonym (or alias) for <tt>:within</tt>
  # * <tt>:too_long</tt> - The error message if the attribute goes over the
  #   maximum (default is: "is too long (maximum is %d characters)")
  # * <tt>:too_short</tt> - The error message if the attribute goes under the
  #   minimum (default is: "is too short (minimum is %d characters)")
  # * <tt>:wrong_length</tt> - The error message if using the <tt>:is</tt>
  #   method and the attribute is the wrong size (default is:
  #   "is the wrong length (should be %d characters)")
  # * <tt>:tokenizer</tt> - Specifies how to split up the attribute string.
  #   (e.g. <tt>:tokenizer => lambda {|str| str.scan(/\w+/)}</tt> to count
  #   words.) Defaults to <tt>lambda {|value| value.split(//)}</tt> which
  #   counts individual characters. 
  # 
  # Configuration options for format:
  # * <tt>:wrong_format</tt> - A custom error message (default is:
  #   "is an invalid email address")
  # 
  # Miscellaneous configuration options:
  # * <tt>:allow_nil</tt> - Attribute may be nil; skip validation.
  # * <tt>:allow_blank</tt> - Attribute may be blank; skip validation.
  # * <tt>:on</tt> - Specifies when this validation is active (default is
  #   :save, other options :create, :update)
  # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if
  #   the validation should occur (e.g. :if => :allow_validation, or
  #   :if => lambda { |user| user.signup_step > 2 }).  The method, proc or
  #   string should return or evaluate to a true or false value.
  # * <tt>:strict</tt> - Specifies if the domain part of the email should be
  #   compliant to RFC 1035 (default is true). If set to false domains such as
  #   '-online.com', '[127.0.0.1]' become valid.
  def validates_as_email_address(*attr_names)
    configuration = attr_names.last.is_a?(Hash) ? attr_names.pop : {}
    configuration.reverse_merge!(
      :wrong_format => Object.const_defined?(:I18n) ? :invalid_email : ActiveRecord::Errors.default_error_messages[:invalid_email],
      :strict => true
    )
    
    # Add format validation
    format_configuration = configuration.dup
    format_configuration[:message] = configuration.delete(:wrong_format)
    format_configuration[:with] = configuration[:strict] ? RFC1035::EmailAddress : RFC822::EmailAddress
    validates_format_of attr_names, format_configuration
    
    # Add length validation
    length_configuration = configuration.dup
    length_configuration.reverse_merge!(:within => 3..320) unless ([:minimum, :maximum, :is, :within, :in] & configuration.keys).any?
    validates_length_of attr_names, length_configuration
  end
end

ActiveRecord::Base.class_eval do
  extend ValidatesAsEmailAddress
end


# Load default error messages
if Object.const_defined?(:I18n) # Rails >= 2.2
  I18n.load_path << "#{File.dirname(__FILE__)}/validates_as_email_address/locale.rb"
else
  ActiveRecord::Errors.default_error_messages.update(
    :invalid_email => ValidatesAsEmailAddress.invalid_email_message
  )
end
