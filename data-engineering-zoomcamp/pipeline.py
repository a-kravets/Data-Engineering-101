import pandas as pd 
import sys

# [0] is the name of the file
# all others are free to use
day = sys.argv[1]

# we'll be able to run docker run -it test:pandas 2023-12-31
print(f'job is finished successfully for day = {day}')