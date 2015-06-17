# M3 = ({q1, q2, q3}, {a, b, Eps}, sigma, q1, {q1})
#
# sigma =
#      a      b  Eps
#    |------------
# q1 | -      q2  q3
# q2 | q2,q3  q3  -
# q3 | q1      -  -
#

class NFA
  def initialize(states, language, sigma, start_state, end_states)
    @states = states.uniq
    @start_state = start_state
		@language = language
		@end_states = @states & end_states	
    
		raise ArgumentError, 'Start state can\'t be nil' if @start_state.nil? 
    raise ArgumentError, 'Start state is not in the available states' unless @states.include? start_state

		@sigma = sigma
  end
  
	def accept?(string)
		states = [@start_state]

		puts "Processing string: #{string} \n"
		puts "\tStarting states: " + states.to_s
		puts "\t FORMAT: current states & epsilon transitions expanded  + input character  =>  new states"

		string.chars.each do |c|
			new_states = []

			valid_char = @language.include? c
			unless valid_char
				puts "#{c} is not in language #{@language} REJECTED"
				return false
			end

			states = expand_epsilon(states)
			states.each do |state|
				transitions = @sigma.fetch(state, [])
				transitions = transitions.fetch(c, [])

				new_states += transitions
				new_states.uniq!
			end
			puts "\t #{states} + #{c} => #{new_states}"

			states = new_states
		end

		if (states & @end_states).empty?
			puts "REJECTED"
			return false
		else
			puts "ACCEPTED"
			return true
		end
	end

  private
  def expand_epsilon(states)
		loop do
			new_states = []
			states.each do |state|
				transitions = @sigma.fetch(state, [])
				break if transitions.empty?
				
				epsilon_transitions = transitions.fetch(:epsilon, [])

				# Remove already parsed states, avoid circular Epsilons
				epsilon_transitions = epsilon_transitions - states - new_states
				epsilon_transitions.uniq!
					
				new_states += epsilon_transitions
			end
			break if new_states.empty?
			
			states += new_states
		end

		states.uniq
  end
end

# sigma =
#      a      b  Eps
#    |------------
# q1 | -      q2  q3
# q2 | q2,q3  q3  -
# q3 | q1      -  -
sigma = {
	:q1 => {
		'b'      => [:q2],
		:epsilon => [:q3],
	},
	:q2 => {
		'a'      => [:q2, :q3],
		'b'      => [:q3],
		:epsilon => [],
	},
	:q3 => {
		'a'      => [:q1],
		'b'      => [],
		:epsilon => []
	}
}


nfa = NFA.new [:q1, :q2, :q3], ['a', 'b', :epsilon], sigma, :q1, [:q1]

nfa.accept? ''
puts
nfa.accept? 'a'
puts
nfa.accept? 'baba'
puts
nfa.accept? 'baa'
puts
nfa.accept? 'b'
puts
nfa.accept? 'bb'
puts
nfa.accept? 'babba'
