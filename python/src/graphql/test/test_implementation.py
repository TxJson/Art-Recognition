import unittest
import graphene

from tests.tests_base import TestBase

class TestImplementationBase(TestBase):
    def init(self):
       super(self).init(name="GraphQL Implementation")

class TestImplementation(TestImplementationBase):
    def init(self):
        super(self).init()

    def TestHello(self):
        class Query(graphene.ObjectType):
            hello = graphene.String(name=graphene.String(default_value="World"))

            def resolve_hello(self, info, name):
                return 'Hello ' + name
        
        schema = graphene.Schema(query=Query)
        result = schema.execute('{ hello }')
        self.assertEqual(result.data['hello'], "Hello World")

if __name__ == '__main__':
    unittest.main()