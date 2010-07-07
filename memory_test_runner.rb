["timeout", "yaml", "rubygems", "terminal-table", "terminal-table/import"].each {|f| require f }

itterations = [100, 1_000, 10_000, 100_000]
ignored_files = ["lib/text_edit_naive.rb"]

results = Dir["lib/*.rb"].inject([]) do |accum, file|
  unless ignored_files.include?(file)
    result = YAML.load(`ruby memory_test.rb #{file}`)

    name       = file[/lib\/(.*)\.rb/, 1]
    start_mem  = result[:start_mem]
    mem_growth = itterations.map {|i| result[:readings][i] - start_mem  }
    final_mem  = result[:readings][itterations.last]
    elapsed    = result[:elapsed]

    accum << [name, start_mem, *mem_growth, final_mem, elapsed]
  end
  accum
end

results.sort! do |a, b|
  a[7] <=> b[7]
end


results_table = table do |t|
  t.headings = ['Name', 'Start Mem', *itterations, 'Final Mem', 'Time']
  results.each{|result| t << result }
end

puts "By elapsed time"
puts results_table


results.sort! do |a, b|
  a[6] <=> b[6]
end


results_table = table do |t|
  t.headings = ['Name', 'Start Mem', *itterations, 'Final Mem', 'Time']
  results.each{|result| t << result }
end


puts "By elapsed time"
puts results_table
