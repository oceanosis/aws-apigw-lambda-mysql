#!/usr/local/bin/python3.6
import sys
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

print('Loading function')

try:
    conn = pymysql.connect(rds_host, user=name, passwd=password, db=db_name, connect_timeout=5)
except:
    logger.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
    sys.exit()

logger.info("SUCCESS: Connection to RDS MySQL instance succeeded")

def convert_timestamp(dateofbirth):
    return time.mktime(datetime.datetime.strptime(dateofbirth, "%Y-%m-%d").timetuple())

def checkDate(ts):
    currentDT = time.mktime(datetime.datetime.now().timetuple())
    diff = int(currentDT) - int(ts)
    if diff < 0:
        return False
    else:
        return True

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

def put_helloworld(event):
#def handler(event, context):
    """
    This function fetches content from MySQL RDS instance
    """

    print("Received event: " + json.dumps(event, indent=2))
    un = event['ResourceProperties']['username']
    dob = event['ResourceProperties']['dateOfBirth']
    try:
      if not checkUsername(un):
        logger.error("ERROR: Username must contain only letters. ")
        return respond(True, "Username must contain only letters. ")
      if not checkDate(convert_timestamp(dob)):
        logger.error("ERROR: Date must be a date before the today date. ")
        return respond(True, "Date must be a date before the today date")

      with conn.cursor() as cur:
        cur.execute('select dateofbirth from birthday where username = "' + un + '" ')
        for row in cur:
            if cur.rowcount > 0:
               logger.error("ERROR: Username already exists with " + row[0] +" date ")
               return respond(True,"Username already exists")

        cur.execute('insert into birthday (username, dateofbirth, unixepoch) values("'+un+'", "'+dob+'",'+ str ( convert_timestamp(dob)) +')')
        logger.info("INFO: Added to RDS MySQL table ")
        conn.commit()
        return respond(None,None)

    except ValueError:
        logger.error('Value error occured.')
    except:
        logger.error("ERROR: An exception occured. ")
        return respond(True, "Lambda error")

def main(argv):
    event = {}
    event['ResourceProperties'] = {}
    event['ResourceProperties']['username'] = "testusera"
    event['ResourceProperties']['dateOfBirth'] = "2018-08-01"
    print(put_helloworld(event))
    
if __name__ == "__main__":
  main(sys.argv[1:])
