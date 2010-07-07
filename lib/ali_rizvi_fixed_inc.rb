# Document class written by Ali Rizvi with
# incremental cache written by Walton Hoops
module TextEditor
  class Document
    def initialize
      @contents = ""
      @commands = []
      @reverted = []
      @current = 0
    end


    def contents
      update_cache
    end

    def update_cache
      @commands[@current...@commands.length].each {|command| command.call}
      @current=@commands.length
      @contents
    end

    def reset_cache
      @contents=''
      @current=0
    end


    def add_text(text, position=-1)
      execute { @contents.insert(position, text) }
    end

    def remove_text(first=0, last=contents.length)
      execute { @contents.slice!(first...last) }
    end

    def execute(&block)
      @commands << block
      @reverted = []
    end

    def undo
      return if @commands.empty?
      reset_cache if @commands.length-1 < @current
      @reverted << @commands.pop
    end

    def redo
      return if @reverted.empty?
      @commands << @reverted.pop
    end

  end
end
