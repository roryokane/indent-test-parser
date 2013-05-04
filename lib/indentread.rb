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
	
	# Actually, this project is too ambitious for a mere example of parsing indentation. This is part-way towards a real project, even though it’s simplified. A real demo of just parsing indentation would work with just a lisp calculator with no S-expressions, only I-expressions. The difference between that and this version of Lisp is having only two data types, and not supporting S-expressions.
	
	# TODO After getting this copy of MiniLisp basically working, paste back previous code that was removed that is still applicable.
	class Parser < Parslet::Parser
		root(:expression)
		rule(:expression) {
			s_expression | i_expression
		}
		
		# use scope{} to help read indents when there are nested i-exps
		
		# start by assuming I-exps are only ever at the 0th indent level. Assume 0 indents on the first line, exactly 1 indents on further lines. No nested I-exps to start with.
		rule(:i_expression) {
			# will probably add initial_indent here later
			i_body >> inline_space? >> newline
		}
		
		rule(:one_indent) {
			str("\t") | str('  ')
		} # two spaces hard-coded
		rule(:indent) {
			# match and capture indent
			one_indent.repeat.as(:indents)
		}
		rule(:dedent) {
			# dynamically match same indent as last indent in scope
		}
		# not sure if I want this rule:
		rule(:indented_something_body) {
			# match one more indent
			# maybe use scope{} inside; maybe that’s for another rule to do
		}
		
		# further plan:
		# first line consumes and captures indent
		# second and onward lines contain (indent >> value) | i_expression
		rule(:i_body) {
			(value >> inline_space?) >> ((s_expression | value) >> inline_space?).repeat.as(:exp)
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
