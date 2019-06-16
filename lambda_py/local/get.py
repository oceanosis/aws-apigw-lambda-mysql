#!/usr/local/bin/python3.6

import sys, math
import logging
import rds_config_local
import pymysql
import time, datetime
import json

#rds settings
rds_host  = rds_config_local.db_host
name = rds_config_local.db_username
password = rds_config_local.db_password
db_name = rds_config_local.db_name

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

def checkUsername(un):
    if un.isalpha():
        return True
    else:
        return False

def respond(err, res=None):
    return {
        'statusCode': '400' if err else '204',
        'body': {
            'message': res if res else 'No Content'
        },
        'headers': {
            'Content-Type': 'application/json',
        },
    }

def get_helloworld(event):
#def handler(event, context):
    """
    This function is for returning birthday message
    """

    print("Received event: " + json.dumps(event, indent=2))
    un = event['ResourceProperties']['username']

    try:
      if not checkUsername(un):
        logger.error("ERROR: Username must contain only letters. ")
        return respond(True, "Username must contain only letters. ")

      with conn.cursor() as cur:
        cur.execute('select unixepoch from birthday where username = "' + un + '" ')
        if cur.rowcount == 0:
            logger.error("ERROR: Username does not exist")
            return respond(True,"Username does not exist")
        for row in cur:
            logger.info("INFO: Username found. ")
            diff = findDiff(row[0])
            if diff == 365:
                logger.info("INFO: Happy Birthday"+ un)
                return respond(None,"Hello, "+ un +"! Happy birthday")
            else:
                logger.info("INFO: Birthday of "+ un +" is "+str(diff) +" later")
                return respond(None,"Hello, "+ un +"! Your birthday is in "+ str(diff) +" day(s)")
    except ValueError:
        logger.error('Value error occured.')
    except:
        logger.error("ERROR: An exception occured. ")
        return respond(True, "Lambda error")

def main(argv):
    event = {}
    event['ResourceProperties'] = {}
    event['ResourceProperties']['username'] = "test1"
    print(get_helloworld(event))
    

if __name__ == "__main__":
    main(sys.argv[1:])
