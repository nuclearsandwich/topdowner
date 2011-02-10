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
#


# Define all my token types using a standard Ruby hash.
TokenTypes = { :start => /^program$/, :assignment => /^set$/,
	:math_op => /^[-\*+]$/, :return => /^return$/, :definition => /^define$/,
	:lparen => /^\($/, :rparen => /^)$/, :ident => /^[a-zA-Z][a-zA-Z0-9_]*$/,
	:int_lit => /^[0-9]+$/,	:eof => /\$/
}

Recognizers = { :Program => :NonReturnStatement, :*, :ReturnStatement ],
	:NonReturnStatement => [ :AssignmentStateMent, :or, :DefineStatement ],
	:AssignmentStatement => [ :set, :ident, "Expr" ],
	:DefineStatement => [ :define, :ident, :ArgList, :Program ],
	:Arglist => [ :lparen, :ident, :+, :rparen ],
	:Expr => [ :int_lit, :or, :ident, :or, :Application ],
	:Application => [ :lparen, :Fname, :Expr, :*, :rparen ],
	:Fname => [ :ident, :or, :math_op ],
	:ReturnStatement => [ :return, :Expr ]
}

# Blow up on invalid args
raise ArgumentError.new "too many arguments" if ARGV.length > 1
raise ArgumentError.new "no string given" if ARGV.empty?

# A Token Type Detector
def detector(token)
	TokenTypes.each do |type, matcher|
		if bitch =~ matcher
			return {bitch => type}
		end
	end
	nil
end

# Tokenize and scan. 
str = ARGV.shift
tokens = str.gsub!(/[\n\t ]+/,' ').split(' ').map {|t| t.to_sym}
parsed_tokens = tokens.map do |token|
	recognize(token)
end
