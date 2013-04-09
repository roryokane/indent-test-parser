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
		root(:expression)
		rule(:expression) {
			s_expression | i_expression
		}
		
		rule(:i_expression) {
			i_body >> inline_space? >> newline
		}
		
		rule(:i_body) {
			# FIXME right now, there is infinite left recursion
			# but before rushing into fixing it, finish making the expression grammars actually plausible
			(i_expression >> inline_space?) >> ((s_expression | value) >> inline_space?).repeat.as(:exp)
		}
		
		rule(:newline) {
			str("\n")
		}
		rule(:inline_space) {
			match[' '].repeat(1)
		}
		rule(:inline_space?) {
			inline_space.maybe
		}
		rule(:any_space) {
			match('\s').repeat(1)
		}
		rule(:any_space?) {
			any_space.maybe
		}
		
		rule(:s_expression) {
			str('(') >> any_space? >> s_body >> str(')')
		}
		
		rule(:s_body) {
			((s_expression | value) >> any_space?).repeat.as(:exp)
		}
		
		rule(:value) {
			identifier | float | integer | string
		}
		
		rule(:identifier) { 
			(match('[a-zA-Z=*]') >> match('[a-zA-Z=*_]').repeat).as(:identifier)
		}
		
		rule(:float) { 
			(
				integer >> (
					str('.') >> match('[0-9]').repeat(1) |
					str('e') >> match('[0-9]').repeat(1)
				).as(:e)
			).as(:float)
		}
		
		rule(:integer) {
			((str('+') | str('-')).maybe >> match("[0-9]").repeat(1)).as(:integer)
		}
		
		rule(:string) {
			str('"') >> (
				str('\\') >> any |
				str('"').absent? >> any 
			).repeat.as(:string) >> str('"')
		}
	end
end
