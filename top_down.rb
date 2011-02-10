#!/usr/bin/env ruby
# ::Author:: Steven! Ragnarök
# The beginnings of a Recursive Descent Parser.
# Two-pass parse. First pass scanning, second pass parsing.

# Define all my token types using a standard Ruby hash.
TokenTypes = { :start => /^program$/, :assignment => /^set$/,
	:int_lit => /^[0-9]+$/,
	:definition => /^define$/, :math_op => /^[-\*+]$/, :return => /^return$/,
	:identifier => /^[a-zA-Z][a-zA-Z0-9_]*$/ }

# Blow up on invalid args
raise ArgumentError.new "too many arguments" if ARGV.length > 1
raise ArgumentError.new "no string given" if ARGV.empty?

# A Token Recognizer
def recognize(bitch)
	TokenTypes.each do |type, matcher|
		if bitch =~ matcher
			return {bitch => type}
		end
	end
	nil
end

# Tokenize and scan. 
str = ARGV.shift
tokens = str.split(' ').map {|t| t.to_sym}
parsed_tokens = tokens.map do |token|
	recognize(token)
end

puts parsed_tokens.class