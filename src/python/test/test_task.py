import unittest

from task import Task

class TestTask(unittest.TestCase):
    
    def test_create_objectscript_task(self):
        tid = Task.create_objectscript_task('test', '0 0 1 * * *','set ^test($h) = "test"', run_now=True)
        self.assertTrue(tid > 0)

    def test_create_python_task(self):
        task = """
import time
import iris
gref = iris.gref('testpython')
gref['time'] = time.time()
        """
        tid = Task.create_python_task('test', '0 0 1 * *', task, run_now=True)
        print(tid)

    def test_get_tasks(self):
        tasks = Task.get_tasks()
        self.assertTrue(len(tasks) > 0)

