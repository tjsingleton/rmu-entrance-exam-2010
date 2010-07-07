module TextEditor
  class Document
    def initialize
      @contents = ""
      @snapshots = []
    end

    attr_accessor :contents

    def add_text(text, position=-1)
      @reverted = false
      @snapshots << AddEvent.new(@contents, text, position)
    end

    def remove_text(first=0, last=contents.length)
      @reverted = false
      @snapshots << RemoveEvent.new(@contents, first, last)
    end

    def undo
      @reverted ||= []
      swap_tail(@snapshots, @reverted)
    end

    def redo
      @reverted ||= []
      swap_tail(@reverted, @snapshots)
    end

    private
    def swap_tail(a,b)
      if last = a.pop
        b << last.undo(@contents)
      end
    end
  end

  class AddEvent
    def initialize(buffer, text, position=-1)
      @offset = buffer.length + 1
      @position = position
      if position == -1
        buffer << text # slightly faster than insert
      else
        buffer.insert(position, text)
      end
    end

    def undo(buffer)
      first = @position < 0 ? @position + @offset : @position
      last = first + @offset
      RemoveEvent.new(buffer, first, last)
    end
  end

  class RemoveEvent
    def initialize(buffer, first=0, last=length)
      @position = first
      @text = buffer.slice!(first...last)
    end

    def undo(buffer)
      AddEvent.new(buffer, @text, @position)
    end
  end
end