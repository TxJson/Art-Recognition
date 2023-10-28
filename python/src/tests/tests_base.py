import unittest

class TestBase(unittest.TestCase):
    def init(self, name):
        self.name = name
        print("Executing test:", name)
