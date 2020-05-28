from contextlib import contextmanager

import psycopg2
from config import logger, vault_client
from psycopg2.extras import RealDictCursor


@contextmanager
def db_connection():
    vault_read_response = vault_client.secrets.kv.v2.read_secret_version(
        path='crdb_url')
    crdb_url = vault_read_response.get('data', {}).get('data',
                                                       {}).get('crdb_url')
    conn = psycopg2.connect(crdb_url)
    try:
        yield conn.cursor(cursor_factory=RealDictCursor)
        conn.commit()
    except Exception as e:
        logger.exception(e)
        conn.rollback()
