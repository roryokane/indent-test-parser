require 'indentread'

describe IndentRead do
	
	context "Reader" do
		def expect_reads_as(string, structure)
			reader = IndentRead::Reader.new
			expect(reader.read(string)).to eq(structure)
		end
		def expect_read_error(string, error=nil)
			reader = IndentRead::Reader.new
			if error
				expect { reader.read(string) }.to raise_error(error)
			else
				expect { reader.read(string) }.to raise_error
			end
		end
		
		context "reading single things" do
			it "can read blank input" do
				expect_reads_as(
					'',
					nil
				)
			end
			it "reads a single basic string" do
				expect_reads_as(
					'"abc"',
					"abc"
				)
			end
			it "reads a single symbol" do
				expect_reads_as(
					'foo',
					:foo
				)
			end
		end
		
		context "reading paren nodes" do
			it "reads a paren node with no children" do
				expect_reads_as(
					'abc()',
					{:abc => {}}
				)
			end
			it "reads a paren node with a single basic child" do
				expect_reads_as(
					'abc(def)',
					{:abc => :def}
				)
			end
			it "reads a paren node with a paren-node child" do
				expect_reads_as(
					'abc(def("ghi"))',
					{:abc => {:def => "ghi"}}
				)
			end
			it "reads a paren node with two paren-node children" do
				expect_reads_as(
					'abc(def("ghi") lmn("opq"))',
					{:abc => {:def => "ghi", :lmn => "opq"}}
				)
			end
			it "fails to read a paren node where any of multiple children are basic" do
				expect_read_error('abc(def("ghi") jkl)')
				expect_read_error('abc("ghi" jkl)')
				expect_read_error('abc(def jkl)')
			end
		end
		
		#context "reading line nodes" do
			#it "reads a line node with a basic child" do
				#expect_reads_as(
					#"abc\n\tdef",
					#{:abc => :def}
				#)
			#end
			#it "reads a line node with a paren-node child" do
				#expect_reads_as(
					#"abc\n\tdef\n\t\t\"ghi\"",
					#{:abc => {:def => "ghi"}}
				#)
			#end
		#end
	end
	
	context "Transform" do
		def expect_transforms_to(parsed, structure)
			xform = IndentRead::Transform.new
			expect(xform.apply(parsed)).to eq(structure)
		end

		it "transforms a basic string" do
			expect_transforms_to(
				{:string_contents => [{:str_chars=>"abc"}]},
				'abc'
			)
		end

		it "transforms a string with a backslash-escape" do
			expect_transforms_to(
				{:string_contents => [{:str_chars=>"abc "}, {:str_escaped_char=>"\""}, {:str_chars=>" def"}]},
				"abc \" def"
			)
		end

		it "transforms a list of nodes into one hash" do
			expect_transforms_to(
				{:nodes => [{:abc=>""}, {:def=>""}]},
				{:abc=>"", :def=>""}
			)
		end
	end

	context "Parser" do
		def parse(text)
			IndentRead::Parser.new.parse(text)
		end
		
		def expect_parsed_equals(input, expected_parsed)
			expect(parse(input)).to eq(expected_parsed)
		end
		
		# commented out for now because I expect
		#  the parsed representation to have a lot of churn
		
		#it "parses an empty tree" do
			#expect_parsed_equals("", [])
		#end
		
		#it "parses a single-item tree" do
			#expect_parsed_equals("foobar", [{:tree => {:head => {:symbol => "foobar"}}}])
		#end
		
		context "parses indentation" do
			#it "parses a two-level tree" do
				#expect_parsed_equals(
					#"one\n\ttwo",
					#[{:tree =>
						#{
							#:head => {:symbol => "one"},
							#:children =>
								#[
									#{ :tree => {:head => {:symbol => "two"}} }
								#]
						#}
					#}]
				#)
			#end
		end
		
		context "parsing strings" do
			def parse(string)
				IndentRead::Parser.new.string.parse(string)
			end
			
			it "recognizes a basic string" do
				string = '"abc"'
				expect(parse(string)).to eq(
					{:string_contents => [{:str_chars=>"abc"}]}
				)
			end
			
			it "allows backslash-escaping quotes" do
				string = '"abc \" def"'
				expect(parse(string)).to eq(
					{:string_contents => [{:str_chars=>"abc "}, {:str_escaped_char=>"\""}, {:str_chars=>" def"}]}
				)
			end
			
			it "allows an empty string" do
				string = '""'
				expect(parse(string)).to eq(
					{:string_contents => []}
				)
			end
		end
		
		context "parsing symbols" do
			def parse(symbol)
				IndentRead::Parser.new.symbol.parse(symbol)
			end
			
			it "recognizes a symbol" do
				symbol = "foobar"
				expect(parse(symbol)).to eq(
					{:symbol => "foobar"}
				)
			end
		end
	end

end

