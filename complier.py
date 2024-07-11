import re

class token:
    def __init__(self,Source_Code) -> None:
        self.Source_Code = Source_Code
        self.pos = 0 
    
    def tokenize(self):
        CurrentWord = [[]]
        for Char in self.Source_Code:
            if Char == ":":





