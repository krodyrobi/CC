class Exp
  attr_accessor :start, :finish, :states

  def initialize(word = '')
    @start = {}
    @finish = { final: true }

    #prepare the states length and initialize with an array of hashes
    @states = word == '' ? [] : Array.new(word.length - 1) { Hash.new }

    #prepend the start state to states
    @states.unshift @start
    #append the finishing state
    @states << @finish

    word.chars.each_with_index do |c, i|
      @states[i][c] = [@states[i + 1]]
    end
  end

  def dup
    # Default ruby dup is not DEEP CLONING so hack it
    Marshal.load Marshal.dump(self)
  end

  def *
    copy = dup

    #apply the kleen star operator rules
    copy.start[:final] = true
    copy.finish[nil] = [copy.start]  # create the epsilon transition

    copy
  end

  def +(other)
    # 1 or more logic as described in the course
    left = dup
    right = other.dup

    left.finish[nil] = [right.start]

    left.finish = right.finish

    left.states = left.states + right.states

    left
  end

  def |(other)
    # OR logic
    left = dup
    right = other.dup

    e = Exp.new

    e.start[nil] = [left.start, right.start]

    [left, right].each do |exp|
      exp.finish.delete :final
      exp.finish[nil] = [e.finish]
    end

    e.states += left.states + right.states

    e
  end

  def nils(line)
    #return all the nodes an epsilon or series transitions could reach
    return [] if line.empty?

    next_line = line.select { |s| s.key? nil }.map { |s| s[nil] }.flatten

    next_line + nils(next_line)
  end

  def accept?(word, states = [@start])
    # check if we are in a final state when the entire word is consumed 
    return states.any? { |s| s[:final] } if word == ''

    # make the union of states reachable with epsilons
    states += nils states

    # gather the states reachable by the current input character
    new_states = []
    states.each do |state|
      new_states << state[word[0]] if state[word[0]]
    end

    # run over the epsilon transitions for the newly discovered states
    new_states += nils new_states.flatten

    # run the NFA algorithm for the rest of the input
    accept? word[1..-1], new_states.flatten.uniq
  end
end

class Rng < Exp
  #Used as a range selector 'abc' means eighter a or b or c matches
  def initialize(word)
    @start = {}
    @finish = { final: true }

    @states = []

    if word == ''
      #if the word in the regular expression is '' then we can create an epsilon transition directly to the accepting state
      @start[nil] = [finish]
    else
      #otherwise for each character create an intermediate node for the character consumed and from there an epsilon to the accepting state
      word.chars.each do |c|
        state = {}

        @start[c] = [state]
        state[nil] = [@finish]

        @states << state
      end
    end
  end
end

# shorthand wrappers for easier reading/coding
def e(word)
  Exp.new word
end

def r(word)
  Rng.new word
end

puts (e('abcd') | e('cd')).accept? 'cd'
puts (e('ab') | e('cd')).*.accept? 'abcdab'
puts (r('abe') | r('cde')).*.accept? 'aade'
