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
		
		it "reads the mini-Lisp example input" do
			expect_reads_as(
				%Q{
  (define test (lambda ()
    (begin
      (display "something")
      (display 1)
      (display 3.08))))
},
				[:define,
					:test,
					[:lambda,
						[],
						[:begin,
							[:display, "something"],
							[:display, 1],
							[:display, 3.08]]]]
			)
		end
		
		context "reading single things" do
		end
		
		context "reading paren nodes" do
		end
		
		context "reading line nodes" do
			it "reads a line node with a basic child" do
				#expect_reads_as(
					#"abc\n\tdef",
					#{:abc => :def}
				#)
			end
			it "reads a line node with a paren-node child" do
				#expect_reads_as(
					#"abc\n\tdef\n\t\t\"ghi\"",
					#{:abc => {:def => "ghi"}}
				#)
			end
		end
	end
	
	context "Transform" do
		def expect_transforms_to(parsed, structure)
			xform = IndentRead::Transform.new
			expect(xform.apply(parsed)).to eq(structure)
		end
		
		it "transforms a basic string" do
		end
		
		it "transforms a string with a backslash-escape" do
		end
	end
	
	context "Parser" do
		def parse(text)
			IndentRead::Parser.new.parse(text)
		end
		
		def expect_parsed_equals(input, expected_parsed)
			expect(parse(input)).to eq(expected_parsed)
		end
		
		context "parses indentation" do
			it "parses a two-level tree" do
			end
		end
		
		context "parsing strings" do
			def parse(string)
				IndentRead::Parser.new.string.parse(string)
			end
			
			it "recognizes a basic string" do
				string = '"abc"'
				#expect(parse(string)).to eq(
					#{:string_contents => [{:str_chars=>"abc"}]}
				#)
			end
			
			it "allows backslash-escaping quotes" do
				string = '"abc \" def"'
				#expect(parse(string)).to eq(
					#{:string_contents => [{:str_chars=>"abc "}, {:str_escaped_char=>"\""}, {:str_chars=>" def"}]}
				#)
			end
			
			it "allows an empty string" do
				string = '""'
				#expect(parse(string)).to eq(
					#{:string_contents => []}
				#)
			end
		end
		
		context "parsing symbols" do
			def parse(symbol)
				IndentRead::Parser.new.symbol.parse(symbol)
			end
			
			it "recognizes a symbol" do
				symbol = "foobar"
				#expect(parse(symbol)).to eq(
					#{:symbol => "foobar"}
				#)
			end
		end
	end

end

