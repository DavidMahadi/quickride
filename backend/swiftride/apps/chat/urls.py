from django.urls import path
from . import views

urlpatterns = [
    path('',                                 views.ConversationListView.as_view(), name='conversations'),
    path('<uuid:convo_pk>/messages/',        views.MessageListView.as_view(),      name='messages'),
]
