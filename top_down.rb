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

## ::meta-grammar:: * => 0..n, + => 1..n, or => any ONE of the following. ##
Grammar = {
	:Program => [ :*, :NonReturnStatement, :ReturnStatement ],
	:NonReturnStatement => [ :or, :AssignmentStatement, :DefineStatement ],
	:AssignmentStatement => [ :set, :ident, :Expr ],
	:DefineStatement => [ :define, :ident, :Arglist, :Program ],
	:Arglist => [ :lparen, :+, :ident, :rparen ],
	:Expr => [ :or, :int_lit, :ident, :Application ],
	:Application => [ :lparen, :Fname, :*, :Expr, :rparen ],
	:Fname => [ :or, :ident, :math_op ],
	:ReturnStatement => [ :return, :Expr ]
}

# Blow up on invalid args
raise ArgumentError.new "too many arguments" if ARGV.length > 1
raise ArgumentError.new "no argument given" if ARGV.empty?

## A Token Type Detector ##
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

## Recognizer ##
# Returns a symbol describing what is constructed by the token(bitch) 
# and lookahead. For a token :return and a lookahead :"4", it returns
# :ReturnStatement. For a token :lparen and a lookahead :ident it would
# return :Arglist.
def recognize bitch, lookahead
	@cache[:"#{bitch},#{lookahead}"] ||=
		Grammar.each do |key, val|
		# Let's assume our key is :ReturnStatement and our val is [:return, :int_lit]
			if bitch == first(val[0])

				return key
			end
		end
end

# Returns all valid token types of the first terminal in a construct.
def first construct
	return [Grammar.has_key? construct && first(Grammar[construct]) ||
		construct].flatten
end

def parse recognizer
	puts "Parsing: #{recognizer}"
	case recognizer
	# Array means nonliteral.
	when Array
		# check for meta-grammar
		if recognizer.first == :*
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

