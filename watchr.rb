require "haml"
require "sass"

# Finds the line of the source template
# on which an exception was raised.
#
# @param exception [Exception] The exception
# @return [String] The line number
def get_line(exception)
  # SyntaxErrors have weird line reporting
  # when there's trailing whitespace,
  # which there is for Haml documents.
  return (exception.message.scan(/:(\d+)/).first || ["??"]).first if exception.is_a?(::SyntaxError)
  (exception.backtrace[0].scan(/:(\d+)/).first || ["??"]).first
end

# Haml plugin to convert .haml to .html
watch '(.*)\.haml' do |match_data|
  file = match_data[0]
  puts "Haml Converting `#{file}`"
  
  begin
    engine = Haml::Engine.new(File.read(file), :format => :html5)
    File.open("#{match_data[1]}.html", 'w') do |f|
      f.write engine.render
    end
  rescue Exception => e
    case e
    when ::Haml::SyntaxError
      puts "Syntax error on line #{get_line e}: #{e.message}"
    else
      puts "Exception on line #{get_line e}: #{e.message}"
    end
  end
end

# Sass plugin to convert .scss to .css
watch '(.*)\.scss' do |match_data|
  file = match_data[0]
  puts "Sass Converting `#{file}`"
  
  begin
    engine = Sass::Engine.new(File.read(file), :syntax => :scss)
    File.open("#{match_data[1]}.css", 'w') do |f|
      f.write engine.render
    end
  rescue Exception => e
    case e
    when ::Sass::SyntaxError
      puts "Syntax error on line #{get_line e}: #{e.message}"
    else
      puts "Exception on line #{get_line e}: #{e.message}"
    end
  end
end