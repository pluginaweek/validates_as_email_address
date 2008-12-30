module ValidatesAsEmailAddress
  # The standard describing the format of email addresses
  module RFC822
    # Matches the two parts of an email address (before/after @)
    LocalPart, Domain = begin
      # Shared
      qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]'
      dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]'
      atom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
      quoted_pair = '\\x5c[\\x00-\\x7f]'
      domain_literal = "\\x5b(?:#{dtext}|#{quoted_pair})*\\x5d"
      quoted_string = "\\x22(?:#{qtext}|#{quoted_pair})*\\x22"
      
      # Local part
      word = "(?:#{atom}|#{quoted_string})"
      local_part = "#{word}(?:\\x2e#{word})*"
      local_part.force_encoding('binary') if local_part.respond_to?(:force_encoding)
      
      # Domain
      domain_ref = atom
      sub_domain = "(?:#{domain_ref}|#{domain_literal})"
      domain = "#{sub_domain}(?:\\x2e#{sub_domain})*"
      domain.force_encoding('binary') if domain.respond_to?(:force_encoding)
      
      [/#{local_part}/, /#{domain}/]
    end
    
    # Matches email addresses according to the RFC822 standard
    EmailAddress = begin
      local_part = LocalPart.source
      domain = Domain.source
      addr_spec = "(#{local_part})\\x40(#{domain})"
      addr_spec.force_encoding('binary') if addr_spec.respond_to?(:force_encoding)
      
      /\A#{addr_spec}\z/
    end
  end
end
