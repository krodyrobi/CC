#
#
# Man wolf cabbage goat problem
#
#

require 'set'

$illegals = [Set.new([:G, :C]), Set.new([:W, :G])]
$movables = Set.new [:G, :W, :C, nil]

#context = {
# :shores => {
#		:left  => Set,
#		:right => Set
# },
#	:description => String
#}
#

def print(context)
	shores = context[:shores]
	left, right = shores[:left], shores[:right]

  verdict = '(OK)'
	if invalid? context
		verdict = '(ILLEGAL)'
	end

	puts "#{left.to_a.join + '-' + right.to_a.join} #{verdict}"
end

def invalid?(context)
	context[:shores].each_value do |shore|
		next if shore.include? :M

		$illegals.each do |i|
			return true if shore.superset? i
		end
	end

	return false
end


def done?(context)
	context[:shores][:left] == Set.new
end


def move(context, item)
	shores = context[:shores].clone

	farmer_on_left = shores[:left].include? :M
	if farmer_on_left
		src, dst = shores[:left], shores[:right]
	else
		src, dst= shores[:right], shores[:left]
	end

	return false unless src.include? item
	
	src.delete :M
	dst.add :M
	
	if item.nil?
		item = ''
	else
		src.delete item
		dst.add item
	end
	string = "#{:M} + #{item} " + ((farmer_on_left) ? '-->' : '<--')
	
	return {
		:shores => {
			:left  => shores[:left],
			:right => shores[:right]},
		:description => string
	}	
end


def one_generation(context)
	next_generations = []
	
	$movables.each do |m|
		generation = move context, m
		next_generations << generation if generation
	end
	
	return next_generations
end


$start_context = {
	:shores   => {
		:left   => Set.new([:M, :G, :W, :C]),
		:right  => Set.new
	},
	:description => ''
}

$solutions = []
$previous_contexts = [$start_context]
def generate(context)
	#print context
	next_generations = one_generation context
	#puts next_generations
	
	next_generations.each do |generation|
		next if invalid? generation
		next if $previous_contexts.include? generation

		$previous_contexts << generation
		generate generation
	end
end



generate($start_context)

$solutions.each { |step| puts step }
