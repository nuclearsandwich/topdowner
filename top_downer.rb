class TopDowner
	def initialize grammar, token_types
		@grammar = grammar
		@token_types = token_types
		@r_cache = Hash.new
	end

	def parse_string string
		@enumerator = tokenize(string).each
		@tree = Hash.new
		parse [@grammar[:Program]]
	end

	private
	## A Token Type Detector ##
	def detect(token)
		@token_types.each do |type, matcher|
			if token =~ matcher
				return { :token => token, :type => type }
			end
		end
		raise ArgumentError.new "Unknown token type for #{token}"
	end

	def tokenize string
		tokens = str.gsub(/[\n\t ]+/,' ').split(' ').map {|t| t.to_sym}
		tokens.map do |token|
			detect(token)
		end
	end
	#
	# Returns all valid token types of the first terminal in a construct.
	def first construct
		return [Grammar.has_key? construct && first(Grammar[construct]) ||
			construct].flatten
	end

	## Recognizer ##
	# Returns a symbol describing what is constructed by the token(bitch) 
	# and lookahead. For a token :return and a lookahead :"4", it returns
	# :ReturnStatement. For a token :lparen and a lookahead :ident it would
	# return :Arglist.
	def recognize bitch, lookahead
		@cache[:"#{bitch},#{lookahead}"] ||=
			@grammar.each do |key, val|
			# Let's assume our key is :ReturnStatement and our val is [:return, :int_lit]			
				if bitch == first(val[0])
					return key
				end
			end
	end

	def parse recognizer
		case recognizer
		# Array means nonliteral.
		when Array
			# check for meta-grammar
			return recognizer.map {|r| parse @grammar[r] || r}
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
end

