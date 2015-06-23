#                                                                   n n n  
# Turing machine with 3 tapes that accepts a string under the form a b c
# I chose this type of implementation because it is the most straight forward of them all (no nasty diagrams and stuff)
#



class Tape(object):
  def __init__(self, initial = None):
    if initial is None:
      self.tape = []
    else:
      self.tape = initial

    self.index = 0
    if len(self.tape) == 0:
      self.tape.append(None)

  def left(self):
    self.index -= 1
    if self.index < 0:
      self.index = 0
      self.tape.insert(0, None)

  def right(self):
    self.index += 1
    if self.index >= len(self.tape):
      self.tape.append(None)

  def read(self):
    return self.tape[self.index]

  def write(self, value):
    self.tape[self.index] = value

  def __str__(self):
    return str(self.index) + str(self.tape)
  


class Turing(object):
  def __init__(self, input):
    self.input       = Tape(input)
    self.first_tape  = Tape()
    self.second_tape = Tape()
    self.third_tape  = Tape()
    
    self.state = 'initial'

  def accept(self):
    if self.state == 'initial':
      if self.input.read() == 'a':
        self.state = 'a'
        self.first_tape.write('a')

        return self.accept()
      else:
        return False
    elif self.state == 'a':
      self.input.right()

      if self.input.read() == 'a':
        self.state = 'a'
        self.first_tape.right()
        self.first_tape.write('a')
        
      elif self.input.read() == 'b':
        self.state = 'b'
        self.second_tape.write('b')
      else:
        return False

      return self.accept()
    elif self.state == 'b':
      self.input.right()

      if self.input.read() == 'b':
        self.state = 'b'
        self.second_tape.right()
        self.second_tape.write('b')
      elif self.input.read() == 'c':
        self.state = 'c'
        self.third_tape.write('c')
      else:
        return False

      return self.accept()
    elif self.state == 'c':
      self.input.right()

      if self.input.read() == 'c':
        self.state = 'c'
        self.third_tape.right()
        self.third_tape.write('c')
      elif self.input.read() == None:
        self.state = 'end'
      else:
        return False
      
      return self.accept()
    elif self.state == 'end':
      while True:
        a = self.first_tape.read()
        b = self.second_tape.read()
        c = self.third_tape.read()

        if a is None and b is None and c is None:
          return True
        elif a is None or b is None or c is None:
          return False
        
        self.first_tape.left()
        self.second_tape.left()
        self.third_tape.left()


print('String `` => ' + str(Turing(list('')).accept()))
print('String `abc` => ' + str(Turing(list('abc')).accept()))
print('String `aabbc` => ' + str(Turing(list('aabbc')).accept()))
print('String `aabbbcc` => ' + str(Turing(list('aabbbcc')).accept()))
print('String `abbcc` => ' + str(Turing(list('abbcc')).accept()))
print('String `aabbcc` => ' + str(Turing(list('aabbcc')).accept()))
print('String `azc` => ' + str(Turing(list('azc')).accept()))

