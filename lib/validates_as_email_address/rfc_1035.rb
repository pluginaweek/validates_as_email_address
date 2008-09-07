module PluginAWeek #:nodoc:
  module ValidatesAsEmailAddress
    # The standard describing the format of domains
    module RFC1035
      # Matches domain according to the RFC 1035 standard
      Domain = begin
        digit = "[\\d]"
        letter = "[\\x61-\\x7a\\x41-\\x5a]"
        let_dig = "(?:#{letter}|#{digit})"
        ldh_str = "(?:#{let_dig}|[\\x2d])+"
        label = "#{let_dig}(?:(?:#{ldh_str})*#{let_dig})"
        subdomain = "(?:#{label}\\.)*#{label}"
        domain = "(?:#{subdomain}|\\x20)"
        
        /#{domain}/
      end
      
      # Matches email addresses with domains that follow the RFC 1035 standard
      EmailAddress = begin
        local_part = RFC822::LocalPart.source
        domain = Domain.source
        addr_spec = "(#{local_part})\\x40(#{domain})"
        
        /\A#{addr_spec}\z/
      end
    end
  end
end
