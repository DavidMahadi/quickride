import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from .models import Conversation, Message


class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.convo_id   = self.scope['url_route']['kwargs']['convo_id']
        self.group_name = f'chat_{self.convo_id}'
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive(self, text_data):
        data   = json.loads(text_data)
        text   = data.get('text', '')
        user   = self.scope['user']
        msg    = await self.save_message(user, text)
        await self.channel_layer.group_send(self.group_name, {
            'type':       'chat_message',
            'id':         str(msg.id),
            'sender_id':  str(user.id),
            'sender_name':user.full_name,
            'text':       text,
            'created_at': str(msg.created_at),
        })

    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event))

    @database_sync_to_async
    def save_message(self, user, text):
        convo = Conversation.objects.get(pk=self.convo_id)
        return Message.objects.create(conversation=convo, sender=user, text=text)
