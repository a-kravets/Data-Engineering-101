# https://airflow.apache.org/docs/apache-airflow/stable/tutorial/fundamentals.html

# this DAG pronts the greeting -> prints the current date & time
# scheduled to repeat the process every 5 sec

# import libs
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
import datetime as dt

# define DAG arguments
default_args = {
    'owner': 'me',
    'start_date': dt.datetime(2024, 4, 27),
    'retries': 1,
    'retry_delay': dt.timedelta(minutes=5)
}

# instantiating DAG object
dag=DAG('simple example',
        description='a simple example',
        default_args=default_args,
        schedule_interval=dt.timedelta(seconds=5),
        )

# defining tasks
task1 = BashOperator(
    task_id='print_hello',
    bash_command='echo \'Greetings. The date and time are \'',
    dag=dag,
)

task2 = BashOperator(
    task_id='print_date',
    bash_command='date',
    dag=dag,
)

# specifying the dependencies
task1 >> task2

'''
Submitting a DAG is as simple as copying the DAG python file into dags folder in the AIRFLOW_HOME directory.

Airflow searches for Python source files within the specified DAGS_FOLDER.
The location of DAGS_FOLDER can be located in the airflow.cfg file, where it has been configured as /home/project/airflow/dags.

Airflow will load the Python source files from this designated location.
It will process each file, execute its contents, and subsequently load any DAG objects present in the file.

Therefore, when submitting a DAG, it is essential to position it within this directory structure.
Alternatively, the AIRFLOW_HOME directory, representing the structure /home/project/airflow, can also be utilized for DAG submission.

1. Submit the DAG
cp airflow_DAG_example.py $AIRFLOW_HOME/dags

2. List existing DAGs
airflow dags list

3. Verify that airflow_DAG_example is a part of the output
airflow dags list|grep "airflow_DAG_example"

4. Run to list out all the tasks in airflow_DAG_example
airflow tasks list my-first-dag
'''