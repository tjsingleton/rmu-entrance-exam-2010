module TextEditor
  class Document
    def initialize
      @contents   = ''
      @op_stack   = []
      @undo_stack = []
    end


    def add_text(text, position=-1)
      stash [:insert, position, text]
    end

    def remove_text(first=0, last=contents.length)
      stash [:slice!, (first...last)]
    end

    def stash(command)
      @op_stack.push command
      @undo_stack.clear
    end


    def undo
      return if @op_stack.empty?

      @undo_stack << @op_stack.pop
    end

    def redo
      return if @undo_stack.empty?

      @op_stack << @undo_stack.pop
    end


    def contents
      @contents = ""

      @op_stack.each do |op|
        op[2].nil? ?
          @contents.send( op[0], op[1] ) : @contents.send( op[0], op[1], op[2] )
      end

      @contents
    end
  end
end
