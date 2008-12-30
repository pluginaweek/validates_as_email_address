module ValidatesAsEmailAddress
  # The standard describing the format of domains
  module RFC1035
    # Matches domain according to the RFC 1035 standard, with the exception
    # that domains can start with a letter *or* digit
    Domain = begin
      digit = '[\\d]'
      letter = '[\\x61-\\x7a\\x41-\\x5a]'
      let_dig = "(?:#{letter}|#{digit})"
      let_dig_hyp = "(?:#{let_dig}|[\\x2d])"
      label = "#{let_dig}(?:#{let_dig_hyp}*#{let_dig})?"
      subdomain = "(?:#{label}\\.)*#{label}"
      domain = "(?:#{subdomain}|\\x20)"
      
      /#{domain}/
    end
    
    # Matches email addresses with domains that follow the RFC 1035 standard
    EmailAddress = begin
      local_part = RFC822::LocalPart.source
      domain = Domain.source
      addr_spec = "(#{local_part})\\x40(#{domain})"
      addr_spec.force_encoding('binary') if addr_spec.respond_to?(:force_encoding)
      
      /\A#{addr_spec}\z/
    end
  end
end
