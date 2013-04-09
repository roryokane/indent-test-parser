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
		end
		
		context "reading s-exps" do
			it "reads a basic expression" do
				expect_reads_as(
					"(print a b)",
					[:print, :a, :b]
				)
			end
			
			it "reads a single-nesting expression" do
				expect_reads_as(
					"(print a b (add a b))",
					[:print, :a, :b, [:add, :a, :b]]
				)
			end
			
			it "reads a single-line let-like expression" do
				expect_reads_as(
					"(let (group (a 1) (b 2)) (add a b))",
					[:let,
						[:group, [:a, 1], [:b, 2]],
						[:add, :a, :b]]
				)
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
		end
		
		context "reading i-exps" do
			it "reads an i-exp with a basic child" do
				expect_reads_as(
					"abc\n\tdef",
					[:abc, :def]
				)
			end
			
			it "reads an i-exp with an s-exp child" do
				expect_reads_as(
					"abc\n\t(def ghi)",
					[:abc, [:def, :ghi]]
				)
			end
			
			it "reads an i-exp with an i-exp child" do
				expect_reads_as(
					"abc\n\tdef\n\t\tghi",
					[:abc, [:def, :ghi]]
				)
			end
		end
	end
	
	context "Transform" do
		def expect_transforms_to(parsed, structure)
			xform = IndentRead::Transform.new
			expect(xform.apply(parsed)).to eq(structure)
		end
		
		context "transforming strings" do
			it "transforms a basic string" do
				expect_transforms_to(
					{:string => "abc"},
					'abc'
				)
			end
			
			it "transforms a string with a backslash-escape" do
				expect_transforms_to(
					{:string => 'abc \" def'},
					'abc \" def'
				)
			end
		end
	end
	
	context "Parser" do
		def parse(text)
			IndentRead::Parser.new.parse(text)
		end
		
		def expect_parsed_equals(input, expected_parsed)
			expect(parse(input)).to eq(expected_parsed)
		end
		
		context "parses s-exps" do
			it "parses a two-item s-exp" do
				expect_parsed_equals(
					"(abc def)",
					{:exp => [
						{:identifier => "abc"},
						{:identifier => "def"}
					]}
				)
			end
		end
		
		context "parses indentation" do
			it "parses a two-level tree" do
				# no tests yet in anticipation of churn
			end
		end
		
		context "parsing strings" do
			def parse(string)
				IndentRead::Parser.new.string.parse(string)
			end
			
			it "recognizes a basic string" do
				string = '"abc"'
				expect(parse(string)).to eq(
					{:string => "abc"}
				)
			end
			
			it "allows backslash-escaping quotes" do
				string = '"abc \" def"'
				expect(parse(string)).to eq(
					{:string => 'abc \" def'}
				)
			end
			
			it "allows an empty string" do
				string = '""'
				expect(parse(string)).to eq(
					{:string => []}
				)
			end
		end
		
		context "parsing identifiers" do
			def parse(identifier)
				IndentRead::Parser.new.identifier.parse(identifier)
			end
			
			it "recognizes an identifier" do
				identifier = "foobar"
				expect(parse(identifier)).to eq(
					{:identifier => "foobar"}
				)
			end
		end
	end

end
