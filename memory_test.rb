$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
["yaml", "timeout", ARGV[0]].each {|f| require f }

def mem_use
  `ps -o rss= -p #{$$}`.to_i
end

start_time  = Time.now
start_mem   = mem_use
doc         = TextEditor::Document.new
msg         = "X"
itterations = [100, 1_000, 10_000, 100_000]
timeout     = 15

readings = itterations.inject({}) do |accum, n|
  begin
    Timeout::timeout(timeout) do
      n.times { doc.add_text(msg) }
      # n.times { doc.undo }
      # n.times { doc.redo }
    end
  rescue Timeout::Error
  end
  accum[n] = mem_use
  accum
end

puts({:elapsed => Time.now - start_time,  :start_mem => start_mem, :readings => readings}.to_yaml)