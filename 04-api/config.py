import logging
import os
import time
from contextlib import contextmanager

import hvac
import pulsar

os.environ['TZ'] = 'UTC'


def setup_logger(level: int = logging.INFO) -> logging.Logger:
    tz = time.strftime('%z')
    logging.config = logging.basicConfig(
        format=(f'[%(asctime)s.%(msecs)03d {tz}] '
                '[%(process)s] [%(pathname)s L%(lineno)d] '
                '[%(levelname)s] %(message)s'),
        level=level,
        datefmt='%Y-%m-%d %H:%M:%S')
    logger = logging.getLogger(__name__)
    return logger


# set logger
logger = setup_logger()

# clearly for dev purposes only
vault_client = hvac.Client(url="http://vault:8200", token="root")
vault_read_response = vault_client.secrets.kv.v2.read_secret_version(
    path='pulsar_proxy_ip')
pulsar_proxy_ip = vault_read_response.get('data',
                                          {}).get('data',
                                                  {}).get('pulsar_proxy_ip')


@contextmanager
def pulsar_client():
    client = pulsar.Client(f"pulsar://{pulsar_proxy_ip}:6650")
    yield client
    client.close()
