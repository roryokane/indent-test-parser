require 'parslet'
require_relative 'minilisp'

module IndentRead
	
	class Reader
		def read(string)
			parser = Parser.new
			transformer = Transform.new
			parsed = parser.parse(string)
			transformer.apply(parsed)
		end
	end
	
	class Transform < Parslet::Transform
		# TODO write the indent-handling additions
		
		rule(:identifier => simple(:ident)) { ident.to_sym }
		
		rule(:string => simple(:str)) { str }
		
		rule(:integer => simple(:int)) { Integer(int) }
		
		rule(:float=>{:integer=> simple(:a), :e=> simple(:b)}) do
			Float(a + b)
		end
		
		rule(:exp => subtree(:exp)) { exp }
	end
	
	# TODO After getting this copy of MiniLisp basically working, paste back previous code that was removed that is still applicable.
	class Parser < Parslet::Parser
		# TODO write the indent-handling additions
		
		root :expression
		rule(:expression) {
			space? >> str('(') >> space? >> body >> str(')') >> space?
		}
		
		rule(:body) {
			(expression | identifier | float | integer | string).repeat.as(:exp)
		}
		
		rule(:space) {
			match('\s').repeat(1)
		}
		rule(:space?) {
			space.maybe
		}
		
		rule(:identifier) { 
			(match('[a-zA-Z=*]') >> match('[a-zA-Z=*_]').repeat).as(:identifier) >> space?
		}
		
		rule(:float) { 
			(
				integer >> (
					str('.') >> match('[0-9]').repeat(1) |
					str('e') >> match('[0-9]').repeat(1)
				).as(:e)
			).as(:float) >> space?
		}
		
		rule(:integer) {
			((str('+') | str('-')).maybe >> match("[0-9]").repeat(1)).as(:integer) >> space?
		}
		
		rule(:string) {
			str('"') >> (
				str('\\') >> any |
				str('"').absent? >> any 
			).repeat.as(:string) >> str('"') >> space?
		}
	end
end

