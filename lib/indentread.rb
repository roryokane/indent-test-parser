require 'parslet'

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
		combine_into_one_hash = lambda do |hash_array|
			hash_array.reduce({}) { |hash, next_node| hash.merge(next_node) }
		end
		
		rule(:str_chars => simple(:str_chars)) do
			str_chars
		end
		
		rule(:str_escaped_char => simple(:str_escaped_char)) do
			str_escaped_char
		end
		
		rule(:string_contents => sequence(:string_contents)) do
			string_contents.join
		end
		
		rule(:symbol => simple(:symbol)) do
			symbol.to_sym
		end
		
		rule(:children => sequence(:children)) do |dict|
			combine_into_one_hash.call(dict[:children])
		end
		
		rule(:head => simple(:head), :children => sequence(:children)) do
			{head => children}
		end
		
		rule(:nodes => subtree(:nodes)) do |dict|
			combine_into_one_hash.call(dict[:nodes])
		end
	end
	
	class Parser < Parslet::Parser
		# whitespace
		
		rule(:newline) { str("\r").maybe >> str("\n") }
		rule(:space) { str(" ") }
		rule(:whitespace) { match('\s').repeat(1) }
		
		rule(:indent) { str("\t") }
		
		rule(:line) { (newline.absent? >> any) >> newline }
		
		
		# string
		
		rule(:str_open_quote) { str('"') }
		rule(:str_close_quote) { str('"') }
		rule(:str_escape_char) { str("\\") }
		
		rule(:str_escaped_char) do
			str_escape_char >> any.as(:str_escaped_char)
		end
		
		rule(:str_inside_part) do
			(str_close_quote.absent? >> str_escape_char.absent? >> any).repeat(1).as(:str_chars) | str_escaped_char
		end
		
		rule(:string) do
			str_open_quote >> str_inside_part.repeat(0).as(:string_contents) >> str_close_quote
		end
		
		
		# symbol
		
		rule(:alpha) { match['a-zA-Z'] }
		rule(:alphanum) { alpha | match['0-9'] }
		
		rule(:symbol) do
			( alpha >> alphanum.repeat(0) ).as(:symbol)
		end
		

		# all nodes
		
		rule(:node_content) do
			symbol | string
		end
		
		
		# paren nodes
		# these simulate explicit indent/dedent tokens
		
		rule(:paren_open) { str('(') }
		rule(:paren_close) { str(')') }
		
		rule(:paren_child) do
			node_content >> space
		end
		
		rule(:paren_children) do
			space.maybe >> paren_child.repeat(0).as(:children)
		end
		
		rule(:paren_node) do
			node_content.as(:head) >> paren_open >> paren_children >> paren_close
		end
		
		
		# line nodes
		
		rule(:line_node_children) do
			
		end
		
		rule(:line_node) do
			# elaborate to allow subtrees – children
			#node_content >> (newline.absent? >> whitespace).repeat(1) >> node_children
			str('this').absent? >> str('this won’t match; use paren_node for now')
		end
		
		
		# node collection
		
		rule(:node) do
			line_node | paren_node
		end
		
		rule(:nodes) do
			node.repeat(0).as(:nodes)
		end
		
		root(:nodes)
	end
end

