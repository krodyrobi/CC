#
#
# Regex to NFA
#
#

class Expression

  def initialize(expr = '')
    @start_state = nil
    @states      = []
    @language    = []
    @end_states  = []
    @sigma       = {}
  end

  def dup
    Marsal.load Marshal.dump(self)
  end

  def +(other)
  end

  def |(other)
  end

  def *
  end

end
