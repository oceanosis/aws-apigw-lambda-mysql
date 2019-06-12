#!/usr/local/bin/python3.6

import sys, os, math
import logging
import rds_config
import pymysql
import time, datetime

#rds settings
rds_host  = rds_config.db_host
name = rds_config.db_username
password = rds_config.db_password
db_name = rds_config.db_name

logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    conn = pymysql.connect(rds_host, user=name, passwd=password, db=db_name, connect_timeout=5)
except:
    logger.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
    sys.exit()

logger.info("SUCCESS: Connection to RDS MySQL instance succeeded")

def findDiff(ts):
    currentDT = time.mktime(datetime.datetime.now().timetuple())
    diff = int(currentDT) - int(ts)
    return math.ceil( 365 - ((diff / 60 /60 / 24) % 365.25))

def get_helloworld():
#def handler(event, context):
    """
    This function ...
    """
    un = "test10"
    diff = -1

    with conn.cursor() as cur:
        cur.execute('select unixepoch from birthday where username = "' + un + '" ')
        for row in cur:
            logger.info("INFO: Username found. ")
            diff = findDiff(row[0])
            if diff == 365:
               print ("Happy birthday" )
               diff = 0
            else:
               print ("Hello, diff is " + str(diff) )

    return diff

def main(argv):
    print(get_helloworld()) 
    
   
 
if __name__ == "__main__":
   main(sys.argv[1:])
