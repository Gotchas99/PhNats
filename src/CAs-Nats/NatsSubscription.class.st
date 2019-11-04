Class {
	#name : #NatsSubscription,
	#superclass : #Object,
	#instVars : [
		'nc',
		'subject',
		'queueGroup',
		'onMessageBlock',
		'inbox',
		'sub_requests'
	],
	#category : #'CAs-Nats-Core'
}

{ #category : #accessing }
NatsSubscription >> inbox [
^inbox
]

{ #category : #'event handler' }
NatsSubscription >> msg:aMsg [
]

{ #category : #'event handler' }
NatsSubscription >> nc:aNatsClient [
nc:=aNatsClient 
]

{ #category : #accessing }
NatsSubscription >> onMessage: aBlock [
	onMessageBlock:=aBlock
]

{ #category : #accessing }
NatsSubscription >> queueGroup: aQueueGroup [
	queueGroup:= aQueueGroup
	
]

{ #category : #accessing }
NatsSubscription >> sub_requests: aSub_requests [
sub_requests:= aSub_requests
	
]

{ #category : #accessing }
NatsSubscription >> subject: aSubject [
	subject:= aSubject
]

{ #category : #announcement }
NatsSubscription >> subscribe [
	inbox := nc createInbox.
	nc sub: sub_requests action: onMessageBlock queueGroup: queueGroup
]
