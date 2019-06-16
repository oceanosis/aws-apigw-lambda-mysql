import datetime
import json
import logging
import pymysql
import rds_config
import sys
import time
import math

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


def find_diff(ts):
    current_date = time.mktime(datetime.datetime.now().timetuple())
    diff = int(current_date) - int(ts)
    return math.ceil( 365 - ((diff / 60 /60 / 24) % 365.25))


def check_username(un):
    if un.isalpha():
        return True
    else:
        return False


def respond(err=False, res=None):
    return {
        'isBase64Encoded': False,
        'statusCode': '400' if err else '200',
        'body': json.dumps(res),
        'headers': {
            'Content-Type': 'application/json'
        },
    }


def handler(event, context):
    """
    This function is for returning birthday message
    """

    #print("Received event: " + json.dumps(event, indent=2))
    un = event['pathParameters']['proxy']

    try:
        if not check_username(un):
            logger.error("ERROR: Username must contain only letters. ")
            return respond(True, "Username must contain only letters. ")

        with conn.cursor() as cur:
            cur.execute('select unixepoch from birthday where username = "' + un + '" ')
            if cur.rowcount == 0:
                logger.error("ERROR: Username does not exist")
                return respond(True,"Username does not exist")
            for row in cur:
                logger.info("INFO: Username found. ")
                diff = find_diff(row[0])
                if diff == 365:
                    logger.info("INFO: Happy Birthday"+ un)
                    return respond(False,"Hello, "+ un +"! Happy birthday")
                else:
                    logger.info("INFO: Birthday of "+ un +" is "+str(diff) +" later")
                    return respond(False,"Hello, "+ un +"! Your birthday is in "+ str(diff) +" day(s)")
    except ValueError:
        logger.error('Value error occured.')
    except:
        logger.error("ERROR: An exception occured. ")
        return respond(True, "Lambda function error")

