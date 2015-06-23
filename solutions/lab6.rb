
require 'set'

# A simple merge between lab 5 and 4 see explanations in the respective labs

class DFA
  def initialize(nfa)
    @states = []
    states = Set.new
    alphabet = Set.new

    start = nils([nfa.start].to_set)
    start << nfa.start unless nfa.start.keys.compact.empty?

    states << start
    @start = 0

    nfa.states.each do |state|
      state.each do |k, _|
        alphabet << k if k && k.is_a?(String)
      end
    end

    nfa.states.each do |state|
      alphabet.each do |letter|
        states << get_states(letter, state)
      end
    end

    new_states = get_new_states(states, alphabet)

    until (new_states - states).empty?
      states += new_states
      new_states = get_new_states(states, alphabet)
    end

    states.each do |batch|
      new_state = {}

      alphabet.each do |letter|
        current = Set.new

        batch.each do |state|
          current += get_states(letter, state)
        end

        new_state[letter] = states.to_a.index current.flatten
      end

      new_state[:final] = true if batch.any? { |s| s[:final] }

      @states << new_state
    end
  end

  def nils(line)
    return Set.new if line.empty?

    next_line = line.flatten.select { |s| s.key? nil }.map { |s| s[nil] }.flatten.to_set

    next_line + nils(next_line)
  end

  def get_states(letter, state)
    new_states = nils([state].to_set).select { |s| s.key? letter }.to_set

    if state[letter]
      new_states << state[letter].to_set
    else
      new_states += new_states.map { |s| get_states(letter, s) }.flatten
    end

    (new_states + nils(new_states)).flatten
  end

  def get_new_states(batches, alphabet)
    new_states = Set.new

    batches.each do |batch|
      alphabet.each do |letter|
        current = Set.new

        batch.each do |state|
          current += get_states(letter, state)
        end

        new_states << current
      end
    end

    new_states
  end

  def accept?(word, i = 0)
    return @states[i].key? :final if word == ''

    accept? word[1..-1], @states[i][word[0]]
  end
end

class Exp
  attr_accessor :start, :finish, :states

  def initialize(word = '')
    @start = {}
    @finish = { final: true }

    @states = word == '' ? [] : Array.new(word.length - 1) { Hash.new }

    @states.unshift @start
    @states << @finish

    word.chars.each_with_index do |c, i|
      @states[i][c] = [@states[i + 1]]
    end
  end

  def dup
    Marshal.load Marshal.dump(self)
  end

  def *
    copy = dup

    copy.start[:final] = true
    copy.finish[nil] = [copy.start]

    copy
  end

  def +(other)
    left = dup
    right = other.dup

    left.finish[nil] = [right.start]

    left.finish = right.finish

    left.states = left.states + right.states

    left
  end

  def |(other)
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
    return [] if line.empty?

    next_line = line.select { |s| s.key? nil }.map { |s| s[nil] }.flatten

    next_line + nils(next_line)
  end

  def accept?(word, states = [@start])
    return states.any? { |s| s[:final] } if word == ''

    states += nils states

    new_states = []

    states.each do |state|
      new_states << state[word[0]] if state[word[0]]
    end

    new_states += nils new_states.flatten

    accept? word[1..-1], new_states.flatten.uniq
  end
end

class Rng < Exp
  def initialize(word)
    @start = {}
    @finish = { final: true }

    @states = [@start]

    if word == ''
      @start[nil] = [@finish]
    else
      word.chars.each do |c|
        state = {}

        @start[c] = [state]
        state[nil] = [@finish]

        @states << state
      end
    end

    @states << @finish
  end
end

def e(word)
  Exp.new word
end

def r(word)
  Rng.new word
end

puts (e('ab') | e('cd')).accept? 'cd'
puts (e('ab') | e('cd')).*.accept? 'ababcd'
puts (r('ab') | r('cd')).*.accept? 'aad'

puts DFA.new(e('ab') | e('cd')).accept? 'cd'
puts DFA.new((e('ab') | e('cd')).*).accept? 'ababcd'
puts DFA.new((r('ab') | r('cd')).*).accept? 'aad'
