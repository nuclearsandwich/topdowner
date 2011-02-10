#!/usr/bin/env ruby
# ::Author:: Steven! Ragnarök
# The beginnings of a Recursive Descent Parser for a Context-Free
# Grammar G given below. This is a Two-pass parse. First pass scanning,
# second pass building a parse tree.
#####################################################################
##                 ::The Grammar Being Parsed::
##      Program -> {NonreturnStatement} ReturnStatement
##      NonreturnStatement -> AssignmentStatement | DefineStatement
##      AssignmentStatement -> set Identifier Expr
##      DefineStatement -> define Identifier Arglist Program
##      Arglist -> ( Identifier {Identifier} )
##      Expr -> Integer | Identifier | Application
##      Application -> ( Fname Expr {Expr} )
##      Fname -> Identifier | + | * | -
##      ReturnStatement -> return Expr
#####################################################################
## The terminals of the grammar are +, -, *, set, define, return, (, ).
## The token types are math_op, set, define, return, int_literal, identifier,
## lparen and rparen.

# Define all my token types using a standard Ruby hash.
TokenTypes = { :start => /^program$/, :set => /^set$/,
	:math_op => /^[-\*+]$/, :return => /^return$/, :define => /^define$/,
	:lparen => /^\($/, :rparen => /^\)$/, :ident => /^[a-zA-Z][a-zA-Z0-9_]*$/,
	:int_lit => /^[0-9]+$/,	:eof => /\$/
}

#Grammar = { :Program => [ :NonReturnStatement, :*, :ReturnStatement ],
Grammar = { :Program => [ :ReturnStatement ],
	:NonReturnStatement => [ :AssignmentStatement, :or, :DefineStatement ],
	:AssignmentStatement => [ :set, :ident, :Expr ],
	:DefineStatement => [ :define, :ident, :ArgList, :Program ],
	:Arglist => [ :lparen, :ident, :+, :rparen ],
	:Expr => [ :int_lit, :or, :ident, :or, :Application ],
	:Application => [ :lparen, :Fname, :Expr, :*, :rparen ],
	:Fname => [ :ident, :or, :math_op ],
	:ReturnStatement => [ :return, :int_lit ]
}

# Blow up on invalid args
raise ArgumentError.new "too many arguments" if ARGV.length > 1
raise ArgumentError.new "no string given" if ARGV.empty?

# A Token Type Detector
def detect(token)
	TokenTypes.each do |type, matcher|
		if token =~ matcher
			return { :token => token, :type => type }
		end
	end
	raise ArgumentError.new "Unknown token type for #{token}"
end

# Tokenize and scan. 
str = ARGV.shift
tokens = str.gsub(/[\n\t ]+/,' ').split(' ').map {|t| t.to_sym}
parsed_tokens = tokens.map do |token|
	detect(token)
end

puts parsed_tokens
@enumerator = parsed_tokens.each
@tree = Hash.new

def parse recognizer
	puts "Parsing: #{recognizer}"
	case recognizer
	# Array means nonliteral.
	when Array
		return recognizer.map {|r| parse Grammar[r] || r}
	# Symbol means literal
	when Symbol
		tkn = @enumerator.next
		puts tkn
		if tkn[:type] == recognizer
			# Base step of recursion
			return tkn[:token]
		else
			raise ArgumentError.new "Got #{tkn}, expected #{recognizer}"
		end
	else raise ArgumentError.new "What the fuck?"
	end
end

@tree[:Program] = parse Grammar[:Program]
puts @tree

