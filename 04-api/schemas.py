from datetime import datetime

from pydantic import UUID4, BaseModel, root_validator


class ItemBase(BaseModel):
    name: str
    description: str


class ItemCreate(ItemBase):
    created_at: datetime = None
    updated_at: datetime = None

    @root_validator(pre=True)
    def set_timestamps(cls, values: dict) -> dict:
        now = datetime.now()
        values['created_at'] = now
        values['updated_at'] = now
        return values


class ItemUpdate(ItemBase):
    updated_at: datetime

    @root_validator(pre=True)
    def set_timestamps(cls, values: dict) -> dict:
        now = datetime.now()
        values['updated_at'] = now
        return values


class Item(ItemBase):
    id: UUID4
    created_at: datetime
    updated_at: datetime


class MessageBase(BaseModel):
    data: str


class MessageCreate(MessageBase):
    created_at: datetime = None

    @root_validator(pre=True)
    def set_timestamps(cls, values: dict) -> dict:
        now = datetime.now()
        values['created_at'] = now
        return values


class Message(MessageBase):
    data: str
    created_at: datetime
