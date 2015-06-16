# M2 = ({q1, q1}, {0, 1}, s, q1, {q2})
#
# s =
#     0 | 1
# q1  q1  q2
# q2  q1  q2
#
# L(M2) = {w | w ends in 1}
#

class DFA
  def initialize(states, language, sigma, start_state, end_states)
    @states = states.uniq
    @start_state = start_state
		@language = language
		@end_states = @states & end_states

    raise ArgumentError, 'Start state can\'t be nil' if @start_state.nil? 
    raise ArgumentError, 'Start state is not in the available states' unless @states.include? start_state
    
    # { state => {input_symbol => next_state} }
    @sigma = sigma
  end

  def accept?(string)
    puts "Processing string: #{string} \n"

    current_state = @start_state
    end_state = string.chars.inject(current_state) do |state, input|
      begin
        next_state = @sigma.fetch(state).fetch(input)
        puts "\t #{next_state} = Sigma( #{state} x #{input} )"
        state = next_state
      rescue KeyError
        puts "String #{string} is rejected => invalid/missing Sigma( #{state} x #{input} )"
        return false
      end
    end
		
    if @end_states.include? end_state
      puts "String #{string} is accepted"
			return true
    else
      puts "String #{string} is rejected"
      return false
    end
  end
end


sigma = {
 :q1 => {
	 '0' => :q1,
	 '1' => :q2
 },
 :q2 => {
   '0' => :q1,
	 '1' => :q2
 }
}

dfa = DFA.new [:q1, :q2], ['0', '1'], sigma, :q1, [:q2]

dfa.accept? '0'
puts
dfa.accept? ''
puts
dfa.accept? '01'
puts
dfa.accept? '0011'
puts
dfa.accept? '2'
