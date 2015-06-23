require 'set'

class NFA
  attr_accessor :states, :start

  #dummy implementation only holds states and end state / no acceptance logic see lab3 for a working NFA machine
  def initialize(states, start)
    @states = states
    @start = start
  end
end

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
    #get all states that can be reached by Epsilons
    return Set.new if line.empty?

    next_line = line.flatten.select { |s| s.key? nil }.map { |s| s[nil] }.flatten.to_set

    next_line + nils(next_line)
  end

  def get_states(letter, state)
    # states to process apply epsilons and then filter only those that have a state transition with the give input letter
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

q0 = {}
q1 = {}
q2 = {}

q0['b'] = [q1]
q0[nil] = [q2]
q0[:final] = true
q0[:n] = 'q0'

q1['a'] = [q1, q2]
q1['b'] = [q2]
q1[:n] = 'q1'

q2['a'] = [q0]
q2[:n] = 'q2'

nfa = NFA.new [q0, q1, q2], q0

dfa = DFA.new nfa

puts dfa.accept? 'aaaabaa'
