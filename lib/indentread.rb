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
	
	class Parser < MiniLisp::Parser
		# write the indent-handling additions
	end
end

