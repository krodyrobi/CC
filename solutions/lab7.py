#                                               r
# A PDA that accepts a string under the form wcw
# w = {a,b}*

class Palindrome(object):
    def __init__(self):
        self.stack = []
        self.state = 'w1'

    def accepts(self, word):
        if self.state == 'w1':
            if not word:
                return False

            if word[0] == 'a': self.stack.append('a')
            elif word[0] == 'b': self.stack.append('b')
            elif word[0] == 'c': self.state = 'w2'
            else: self.state = 'reject'

            return self.accepts(word[1:])
        elif self.state == 'w2':
            if not self.stack and not word:
                self.state = 'accept'
            elif not self.stack or not word or self.stack.pop() != word[0]:
                self.state = 'reject'

            return self.accepts(word[1:])
        elif self.state == 'accept':
            return True
        elif self.state == 'reject':
            return False

print Palindrome().accepts('abcba')
print Palindrome().accepts('abcb')
print Palindrome().accepts('abcbab')
print Palindrome().accepts('c')
print Palindrome().accepts('')
