# from https://gist.github.com/922147

# Must have Nokogiri gem installed and save this file in your spec/support dir
# Allows you to write cleaner/faster specs in your views (50% faster than css_select)
# Increased readability in your spec doc
# ex.
# rendered.should contain('my heading').within('h1') # searches all H1 tags for 'my heading'
# or 
# rendered.should contain('my string') # searches entire rendered string for 'my string'
class Within
  def initialize(expected, css_selector)
    @expected = expected
    @selector = css_selector
  end

  def matches?(actual)
    @html = Nokogiri.HTML(actual)
    @html.css(@selector).to_s.include?(@expected)
  end

  def failure_message_for_should
    "#{@html.to_s} should have located #{@expected} within '#{@selector}'"
  end

  def failure_message_for_should_not
    "#{@html.to_s} should not have located #{@expected} within '#{@selector}'"
  end

  def description
    "contain #{@expected} within #{@selector}"
  end
end


class Contain
  def initialize(expected)
    @expected = expected
  end  
  
  def matches?(actual)
    @actual = actual
    @actual.include?(@expected)
  end

  def within(selector)
    Within.new(@expected, selector)
  end

  def failure_message_for_should
    "#{@actual} should contain #{@expected}"
  end

  def failure_message_for_should_not
    "#{@actual} should not contain #{@expected}"
  end

  def description
    "contain #{@expected}"
  end
end

def contain(expected)
  Contain.new(expected)
end