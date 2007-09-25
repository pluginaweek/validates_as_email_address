# The standard describing the format of email addresses
module RFC822
  EmailAddress = begin
    qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]'
    dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]'
    atom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
    quoted_pair = '\\x5c[\\x00-\\x7f]'
    domain_literal = "\\x5b(?:#{dtext}|#{quoted_pair})*\\x5d"
    quoted_string = "\\x22(?:#{qtext}|#{quoted_pair})*\\x22"
    domain_ref = atom
    sub_domain = "(?:#{domain_ref}|#{domain_literal})"
    word = "(?:#{atom}|#{quoted_string})"
    domain = "#{sub_domain}(?:\\x2e#{sub_domain})*"
    local_part = "#{word}(?:\\x2e#{word})*"
    addr_spec = "(#{local_part})\\x40(#{domain})"
    pattern = /\A#{addr_spec}\z/
  end
end

module PluginAWeek #:nodoc:
  module Validates #:nodoc:
    # Adds validations for email addresses
    module EmailAddress
      # The options that can be used when validating the format of the email address
      EMAIL_FORMAT_OPTIONS = [
        :wrong_format,
        :allow_nil,
        :on,
        :if
      ]
      
      # The options that can be used when validating the length of the email address
      EMAIL_LENGTH_OPTIONS = [
        :minimum,
        :maximum,
        :is,
        :within,
        :in,
        :too_long,
        :too_short,
        :wrong_length,
        :allow_nil,
        :on,
        :if
      ]
      
      # Validates whether the value of the specific attribute matches against the
      # RFC822 specificiation.
      # 
      #   class Person < ActiveRecord::Base
      #     validates_as_email_address :email, :on => :create
      #   end
      # 
      # This will also validate that the email address is within the specification
      # limits, specifically between 3 and 320 characters in length.
      # 
      # Configuration options for length:
      # * <tt>minimum</tt> - The minimum size of the attribute
      # * <tt>maximum</tt> - The maximum size of the attribute
      # * <tt>is</tt> - The exact size of the attribute
      # * <tt>within</tt> - A range specifying the minimum and maximum size of the attribute
      # * <tt>in</tt> - A synonym(or alias) for :within
      # * <tt>too_long</tt> - The error message if the attribute goes over the maximum (default is: "is too long (maximum is %d characters)")
      # * <tt>too_short</tt> - The error message if the attribute goes under the minimum (default is: "is too short (minimum is %d characters)")
      # * <tt>wrong_length</tt> - The error message if using the :is method and the attribute is the wrong size (default is: "is the wrong length (should be %d characters)")
      # 
      # Configuration options for format:
      # * <tt>wrong_format</tt> - A custom error message (default is: "is an invalid email address")
      # 
      # Configuration options for both length and format:
      # * <tt>allow_nil</tt> - Attribute may be nil; skip validation.
      # * <tt>on</tt> - Specifies when this validation is active (default is :save, other options :create, :update)
      # * <tt>if</tt> - Specifies a method, proc or string to call to determine if the validation should
      # occur (e.g. :if => :allow_validation, or :if => Proc.new { |user| user.signup_step > 2 }).  The
      # method, proc or string should return or evaluate to a true or false value.
      def validates_as_email_address(*attr_names)
        configuration = attr_names.last.is_a?(Hash) ? attr_names.pop : {}
        configuration.assert_valid_keys(EMAIL_FORMAT_OPTIONS | EMAIL_LENGTH_OPTIONS)
        configuration.reverse_merge!(
          :wrong_format => ActiveRecord::Errors.default_error_messages[:invalid_email]
        )
        
        # Add format validation
        format_configuration = configuration.reject {|key, value| !EMAIL_FORMAT_OPTIONS.include?(key)}
        format_configuration[:message] = format_configuration.delete(:wrong_format)
        format_configuration[:with] = RFC822::EmailAddress
        validates_format_of attr_names, format_configuration
        
        # Add length validation
        length_configuration = configuration.reject {|key, value| !EMAIL_LENGTH_OPTIONS.include?(key)}
        length_configuration.reverse_merge!(:within => 3..320)
        validates_length_of attr_names, length_configuration
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  extend PluginAWeek::Validates::EmailAddress
end

ActiveRecord::Errors.default_error_messages.update(
  :invalid_email => 'is an invalid email address'
)
