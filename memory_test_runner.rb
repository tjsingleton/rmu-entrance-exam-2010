["timeout", "yaml", "rubygems", "terminal-table", "terminal-table/import"].each {|f| require f }

itterations = [100, 1_000, 10_000, 100_000]

results = Dir["lib/*.rb"].inject({}) do |accum, file|
  if file == "lib/text_edit_naive.rb"
    accum
  else
    accum[file] = YAML.load(`ruby memory_test.rb #{file}`)
  end
  accum
end

puts table do |t|
  t.headings = ['Name', 'Start Mem', *itterations, 'Final Mem', 'Time']

  results.each do |file, result|
    name       = file[/lib\/(.*)\.rb/, 1]
    start_mem  = result[:start_mem]
    mem_growth = itterations.map {|i| result[:readings][i] - start_mem  }
    final_mem  = result[:readings][itterations.last]
    elapsed    = result[:elapsed]

    t << [name, start_mem, *mem_growth, final_mem, elapsed]
  end
end