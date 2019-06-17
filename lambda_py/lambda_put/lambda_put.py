import sys
import logging
import rds_config
import pymysql
import time, datetime
import json

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


def respond(err=False, res=None):

    return {
        'isBase64Encoded': False,
        'statusCode': '400' if err else '204',
        'body': json.dumps(res),
        'headers': {
            'Content-Type': 'application/json'
        },
    }


def handler(event, context):
    """
    This function is for putting new username and dateOfBirth
    """
    #print("Received event: " + json.dumps(event, indent=2))

    try:
        if event['queryStringParameters']['dateOfBirth']:
            dob = event['queryStringParameters']['dateOfBirth']
        if event['pathParameters']['proxy']:
            un = event['pathParameters']['proxy']

        if not checkUsername(un):
            msg = "Username must contain only letters."
            logger.error("ERROR:  " + msg)
            return respond(True, msg)
        if not checkDate(convert_timestamp(dob)):
            msg = "Date must be a date before the today date"
            logger.error("ERROR:  " + msg)
            return respond(True, msg)

        with conn.cursor() as cur:
            cur.execute('select dateofbirth from birthday where username = "' + un + '" ')
            for row in cur:
                if cur.rowcount > 0:
                    msg = "Username already exists"
                    logger.error("ERROR:  " + msg)
                    return respond(True, msg)

            cur.execute('insert into birthday (username, dateofbirth, unixepoch) values("'+un+'", "'+dob+'",'+ str ( convert_timestamp(dob)) +')')
            conn.commit()
        logger.info("INFO: Added to RDS MySQL table ")
        conn.commit()
        return respond(False,"No Content")
    except KeyError:
        logger.error('Username or dateOfBirth was not passed')
        return respond(True, "Username or dateOfBirth was not passed")
    except ValueError:
        logger.error('Value error occured.')
        return respond(True, "Value error")
    except:
        logger.error("ERROR: An exception occured. ")
        return respond(True, "Lambda function error")


