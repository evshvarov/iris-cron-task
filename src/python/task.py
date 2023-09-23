"""
Python wrapper for cron tasks module in iris.
"""

import iris

class Task(object):
    """
    Task class for cron tasks.
    It is a wrapper for cron tasks in iris.
    It can be used to create cron tasks.
    It can be used to get cron tasks.
    It can be used to delete cron tasks.
    """
    @classmethod
    def raise_on_error(cls,sc):
        """
        If the status code is an error, raise an exception
        
        :param sc: The status code returned by the Iris API
        """
        if iris.system.Status.IsError(sc):
            raise RuntimeError(iris.system.Status.GetOneStatusText(sc))


    @classmethod
    def create_objectscript_task(cls, name, schedule, command, run_now=True) -> int:
        """
        Create a cron task.
        """
        if run_now:
            run_now = 1
        else:
            run_now = 0

        # get byref
        tid = iris.ref(0)

        cls.raise_on_error(
            iris.cls('dc.cron.task').Start(name, schedule, command, run_now, tid)
            )

        return tid.value

    @classmethod
    def create_python_task(cls, name, schedule, command, run_now=True) -> int:
        """
        Create a cron task.
        """
        if run_now:
            run_now = 1
        else:
            run_now = 0

        # get byref
        tid = iris.ref(0)

        command = f'w ##class(%SYS.Python).Run("{command}")'

        cls.raise_on_error(iris.cls('dc.cron.task').Start(name, schedule, command, run_now, tid))

        return tid.value

    @classmethod
    def get_task(cls, tid) -> dict:
        """
        Get a cron task.
        """

        response = {}

        sql = """
        SELECT Name,Type,Namespace,Description,%ID,Suspended,DisplayFinished,DisplayNextScheduledBrief FROM %SYS.Task WHERE %ID = ?
        """

        rs = iris.sql.exec(sql, tid)

        for row in rs:
            response['name'] = row[0]
            response['type'] = row[1]
            response['namespace'] = row[2]
            response['description'] = row[3]
            response['id'] = row[4]
            response['suspended'] = row[5]
            response['display_finished'] = row[6]
            response['display_next_scheduled_brief'] = row[7]

        return response

    @classmethod
    def delete_task(cls, tid):
        """
        Delete a cron task.
        """

        cls.raise_on_error(iris.cls('dc.cron.task').Kill(tid))

    @classmethod
    def get_tasks(cls) -> list:
        """
        Get all cron tasks.
        """

        response = []

        sql = """
        SELECT Name,Type,Namespace,Description,%ID,Suspended,DisplayFinished,DisplayNextScheduledBrief FROM %SYS.Task
        """

        rs = iris.sql.exec(sql)

        for row in rs:
            response.append({
                'name': row[0],
                'type': row[1],
                'namespace': row[2],
                'description': row[3],
                'id': row[4],
                'suspended': row[5],
                'display_finished': row[6],
                'display_next_scheduled_brief': row[7]
            })

        return response

    @classmethod
    def suspend_task(cls, tid):
        """
        Suspend a cron task.
        """

        cls.raise_on_error(iris.cls('%SYS.Task').Suspend(tid))

    @classmethod
    def resume_task(cls, tid):
        """
        Resume a cron task.
        """

        cls.raise_on_error(iris.cls('%SYS.Task').Resume(tid))
