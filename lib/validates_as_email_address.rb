require 'validates_as_email_address/rfc_822'
require 'validates_as_email_address/rfc_1035'

module PluginAWeek #:nodoc:
  # Adds validations for email addresses
  module ValidatesAsEmailAddress
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
    # * +minimum+ - The minimum size of the attribute
    # * +maximum+ - The maximum size of the attribute
    # * +is+ - The exact size of the attribute
    # * +within+ - A range specifying the minimum and maximum size of the attribute
    # * +in+ - A synonym(or alias) for :within
    # * +too_long+ - The error message if the attribute goes over the maximum (default is: "is too long (maximum is %d characters)")
    # * +too_short+ - The error message if the attribute goes under the minimum (default is: "is too short (minimum is %d characters)")
    # * +wrong_length+ - The error message if using the :is method and the attribute is the wrong size (default is: "is the wrong length (should be %d characters)")
    # 
    # Configuration options for format:
    # * +wrong_format+ - A custom error message (default is: "is an invalid email address")
    # 
    # Miscellaneous configuration options:
    # * +allow_nil+ - Attribute may be nil; skip validation.
    # * +on+ - Specifies when this validation is active (default is :save, other options :create, :update)
    # * +if+ - Specifies a method, proc or string to call to determine if the validation should
    # occur (e.g. :if => :allow_validation, or :if => lambda { |user| user.signup_step > 2 }).  The
    # method, proc or string should return or evaluate to a true or false value.
    # * +strict+ - Specifies if the domain part of the email should be compliant to RFC 1035 (default is true). If set to false domains such as '-online.com', '[127.0.0.1]' become valid.
    def validates_as_email_address(*attr_names)
      configuration = attr_names.last.is_a?(Hash) ? attr_names.pop : {}
      configuration.reverse_merge!(
        :wrong_format => ActiveRecord::Errors.default_error_messages[:invalid_email],
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
end

ActiveRecord::Base.class_eval do
  extend PluginAWeek::ValidatesAsEmailAddress
end

# Add error messages specific to this validation
ActiveRecord::Errors.default_error_messages.update(
  :invalid_email => 'is an invalid email address'
)
