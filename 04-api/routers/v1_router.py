import base64
import json
from typing import List

from pydantic import UUID4

from config import logger, pulsar_client
from database import db_connection
from fastapi import APIRouter, Body, HTTPException, Response
from schemas import Item, ItemCreate, ItemUpdate, Message, MessageCreate

router = APIRouter()


@router.get('/healthcheck')
def health():
    return {"detail": "alive and kicking"}


@router.post('/items', response_model=ItemCreate)
def create_item(item_create: ItemCreate = Body(
    ...,
    example={
        "name": "An Item",
        "description": "What it is."
    },
)):
    dict_item = item_create.dict()
    keys, values = ', '.join(dict_item.keys()), ', '.join(
        map(lambda v: f"'{str(v)}'", dict_item.values()))
    with db_connection() as db:
        db.execute(f"insert into items ({keys}) values ({values})")
        return item_create


@router.get('/items', response_model=List[Item])
def get_items(response: Response, offset: int = 0, limit: int = 100):
    with db_connection() as db:
        db.execute(
            f"select * from items order by name offset {offset} limit {limit}")
        items = db.fetchall()
        if items:
            response.headers["Content-Range"] = str(len(items))
            return items
    response.headers["Content-Range"] = "0"
    return []


@router.get('/items/{item_id}', response_model=Item)
def get_item(item_id: UUID4):
    with db_connection() as db:
        db.execute(f"select * from items where id = '{item_id}'")
        item = db.fetchone()
        if item:
            return item
    raise HTTPException(status_code=400, detail="Item not found.")


@router.put('/items/{item_id}', response_model=ItemUpdate)
def update_item(item_id: UUID4,
                item_update: ItemUpdate = Body(
                    ...,
                    example={
                        "name": "An Updated Item",
                        "description": "What it is now."
                    })):
    item = None
    with db_connection() as db:
        db.execute(f"select * from items where id = '{item_id}'")
        item = db.fetchone()

    if not item:
        raise HTTPException(status_code=400, detail="Item not found.")

    with db_connection() as db:
        db.execute(
            f"update items set name = '{item_update.name}', "
            f"description = '{item_update.description}', "
            f"updated_at = '{item_update.updated_at}' where id = '{item_id}'")
        return item_update


@router.delete('/items/{item_id}')
def delete_item(item_id: UUID4):
    item = None
    with db_connection() as db:
        db.execute(f"select * from items where id = '{item_id}'")
        item = db.fetchone()

    if not item:
        raise HTTPException(status_code=400, detail="Item not found.")

    with db_connection() as db:
        db.execute(f"delete from items where id = '{item_id}'")
        return {"detail": f"Deleted item with id {item_id}"}


@router.post('/messages')
def send_message(
        message: MessageCreate = Body(..., example={"data":
                                                    "Hello world!"}), ):
    with pulsar_client() as pulsar:
        producer = pulsar.create_producer('default/pulsar/messages')
        encoded_bytes = base64.b64encode(message.json().encode('utf8'))
        producer.send(encoded_bytes)
    return {"detail": "Message sent!"}


@router.get('/messages', response_model=List[Message])
def read_messages(response: Response):
    messages = [message for message in pulsar_consumer_message_streamer()]
    if messages:
        response.headers["Content-Range"] = str(len(messages))
        return sorted(messages, key=lambda x: x["created_at"])
    else:
        response.headers["Content-Range"] = "0"
        return []


def pulsar_consumer_message_streamer() -> str:
    with pulsar_client() as pulsar:
        consumer = pulsar.subscribe('persistent://default/pulsar/messages',
                                    'messages')
        while True:
            message = None
            try:
                message = consumer.receive(timeout_millis=5_000)
                logger.info(f"Received message {message.data()}")
                yield json.loads(
                    base64.b64decode(message.data()).decode('utf8'))
                consumer.acknowledge(message)
            except Exception as e:
                logger.exception(e)
                if message:
                    consumer.negative_acknowledge(message)
                if "Pulsar error: TimeOut" in str(e):
                    logger.info("Stopping. No messages received "
                                "in a while.")
                    break
