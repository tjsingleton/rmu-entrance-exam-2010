# try to ensure String#each_char is available.
unless "".respond_to?('each_char')
  begin
    require 'jcode'
  rescue
    class String
      def each_char(*args, &block)
        self.each(*args, &block)
      end
    end
  end
end

module TextEditor
  class SensibleDocument
    def initialize
      @contents = []
      @snapshots = []
      @reverted  = []
    end

    def contents
      @contents.join ''
    end

    def process_text(text)
      text.length > 1 ?
        text.each_char.map {|x| x.intern } :
        text.intern
    end

    def add_text(_text, position=-1)
      text = process_text(_text)
      taint
      @snapshots << AddEvent.new(self, text, position)
    end

    def remove_text(first=0, last=contents.length)
      taint
      @snapshots << RemoveEvent.new(self, first, last)
    end

    def add(text, position=-1)
      @contents.insert(position, *text)
    end

    def remove(first=0, last=contents.length)
      @contents.slice!(first...last)
    end

    def taint
      @reverted = [] if @reverted.any?
    end

    def undo
      stack_swap(@snapshots, @reverted)
      @reverted.last.undo
    end

    def redo
      stack_swap(@reverted, @snapshots)
      @snapshots.last.run
    end

    def stack_swap(from, to)
      return if from.empty?
      to << from.pop
    end

    def length
      @contents.length
    end
  end

  class AddEvent
    def initialize(document, text, position)
      @document = document
      @text = text
      @position = position
      @document_length = @document.length
      run
    end

    def run
      @document.add(@text, @position)
    end

    def undo
      @document.remove(start, last)
    end

    def start
      @start_position ||= @position < 0 ?
         @position + @document_length + 1 :
         @position
    end

    def last
      @last_position ||= start + @text.length
    end
  end

  class RemoveEvent
    def initialize(document, first, last)
      @document = document
      @first = first
      @last = last
      run
    end


    def run
      @text = @document.remove(@first, @last)
    end

    def undo
      @document.add(@text, @first)
    end
  end
end