
require 'set'

class Set  
  def to_s
    # add to_s functionality to the Set class
    self.to_a.to_s
  end
end

class State
  attr_reader :parent, :left, :right

  def initialize(left=[:m, :g, :c, :w], right=[], parent=nil)
    @left = left.to_set
    @right = right.to_set

    #backlink for easy printout
    @parent = parent
  end

  def move(obj)
    left, right = [@left, @right].map(&:dup) # duplicate works here since we use symbols which are singletons
    # see where the object lies and determine where it is supposed to go
    from, to = @left.include?(obj) ? [left, right] : [right, left]

    # if we are moving the man we simply remove it and place it on the other bank
    if obj == :m
      from.delete :m
      to.add :m
    elsif from.include? :m  # we are moving the man as well
      from.delete :m
      from.delete obj
      
      to.add :m
      to.add obj
    end
    
    State.new(left, right, self).legal    
  end

  def legal()
    [@left, @right].each do |bank|
      next if bank.include? :m

      return nil if bank.include?(:g) && bank.include?(:c)
      return nil if bank.include?(:w) && bank.include?(:g)
    end

    self
  end

  def accept?
    @left.empty? && @right == Set.new([:m, :w, :g, :c])
  end


  def eql?(o)
    return false unless o.kind_of? State
    @left == o.left && @right == o.right  # used for set comparison when hash is not unique
  end

  def hash
    [@left.hash, @right.hash].hash        # used for set comparison
  end

  def to_s
    banks = [@left, @right].map do |bank|
      arr = bank.to_a
      # converted to an array so I can sort the elements on a bank      
      arr.sort.to_s
    end

    #join the 2 strings with - in between and remove : from the symbolic link output
    banks.join(' - ').gsub(/:/, '')
  end
end


def generate(moves)
  # parsed states
  states = [].to_set

  # a queue for the states to be processed
  new_states = [State.new].to_set



  until new_states.empty?
    # process only the states different than nil 
    new_states = new_states.to_a.compact
    states += new_states.to_set # record that we processed these states so we don't take them again

    #apply all permutations(moves) on a given state
    new_states = new_states.map { |state| moves.map { |a| state.move(a) } }
                 .flatten.to_set

    #removed all processed states from the new list
    new_states -= states
  end

  accepted_states = states.keep_if { |state| state.accept? }

  accepted_states.each do |state|
    trace = [state]
    until state.parent.nil?
        trace << state.parent       
        state = state.parent
    end
    trace << state.parent
    puts trace.reverse
    puts
  end
end

#available moves
moves = [:g, :c, :w, :m]
generate(moves)
generate(moves.reverse)



