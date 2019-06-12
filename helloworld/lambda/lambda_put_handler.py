import sys, os
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

def convert_timestamp(dateofbirth):
    return time.mktime(datetime.datetime.strptime(dateofbirth, "%Y-%m-%d").timetuple())

def handler(event, context):
    """
    This function ...
    un = "testuser"
    dob = "1983-10-26"
    """
    ts = str ( convert_timestamp(dob))
    put_status = 0

    with conn.cursor() as cur:
        cur.execute('select dateofbirth from birthday where username = "' + un + '" ')
        for row in cur:
            put_status = 2
        if put_status == 2:
            logger.error("ERROR: Username already exists. ")
            put_status = 0
        else:
            cur.execute('insert into birthday (username, dateofbirth, unixepoch) values("'+un+'", "'+dob+'",'+ts+')')
            logger.info("INFO: Added to RDS MySQL table ")
            put_status = 1
    conn.commit()

    return put_status


