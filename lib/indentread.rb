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
	
	class Transform < MiniLisp::Transform
		# write the indent-handling additions
	end
	
	# TODO I think to stop the MiniLisp parser from gobbling up all of the whitespace, I will have to copy and edit it, not just subclass and add to it.
	# TODO After getting it basically working, copy prevous code that was removed that is still applicable.
	class Parser < MiniLisp::Parser
		# write the indent-handling additions
	end
end

