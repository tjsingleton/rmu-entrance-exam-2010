abort("I like to hang in macruby") if defined? MACRUBY_VERSION
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
["timeout", "yaml", "rubygems", "terminal-table", "terminal-table/import"].each {|f| require f }

def sorted_table(title, headings, _results, &sort_block)
  results = _results.dup.sort!(&sort_block)
  results_table = table do |t|
    t.headings = headings
    results.each{|result| t << result }
    (1..ITTERATIONS.length).each {|i| t.align_column(i, :right)}
  end

  puts title
  puts results_table
  puts
end

def format_result(file, result)
  name       = file[/lib\/(.*)\.rb/, 1]
  start_mem  = result[:start_mem]
  mem_growth = ITTERATIONS.map {|i| result[:readings][i] - start_mem  }
  final_mem  = result[:readings][ITTERATIONS.last]
  elapsed    = result[:elapsed]

  [name, start_mem, mem_growth, final_mem, elapsed].flatten
end

def run_test(file)
  print "Running #{file}... "
  result = YAML.load(`ruby memory_test.rb #{file}`)
  puts result.inspect
  result
end

ITTERATIONS = [100, 1_000, 10_000, 100_000]
ignored_files = ["lib/text_edit_naive.rb"]
table_headings = ['Name', 'Start Mem', ITTERATIONS, 'Final Mem', 'Time'].flatten
STDOUT.sync = true

rows = Dir["lib/*.rb"].inject([]) do |accum, file|
  unless ignored_files.include?(file)
    accum << format_result(file, run_test(file))
  end
  accum
end

puts
sorted_table("By elasped time", table_headings, rows) {|a, b| a[7] <=> b[7] }
sorted_table("By final mem", table_headings, rows) {|a, b| a[6] <=> b[6] }