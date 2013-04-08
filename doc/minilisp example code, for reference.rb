parser = MiniLisp::Parser.new
transform = MiniLisp::Transform.new

result = parser.parse_with_debug %Q{
  (define test (lambda ()
    (begin
      (display "something")
      (display 1)
      (display 3.08))))
}

# Transform the result
pp transform.do(result) if result

# Thereby reducing it to the earlier problem: 
# http://github.com/kschiess/toylisp

# should output (minus ‘#’):
#[:define,
# :test,
# [:lambda,
#  [],
#  [:begin, [:display, "something"@54], [:display, 1], [:display, 3.08]]]]
