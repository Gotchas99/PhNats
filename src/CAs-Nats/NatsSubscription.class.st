Class {
	#name : #NatsSubscription,
	#superclass : #Object,
	#instVars : [
		'stan',
		'onMessageBlock',
		'inbox',
		'ackInbox',
		'durableName',
		'subject',
		'queueGroup'
	],
	#category : #'CAs-Nats-Core'
}

{ #category : #'event handler' }
NatsSubscription >> ack: msg [
| ack |
ack:= Ack new sequence:msg sequence;subject:subject ;yourself.
self nc pub: ackInbox  payload: ack asBytes.
]

{ #category : #accessing }
NatsSubscription >> ackInbox: aString [ 
	ackInbox:= aString
]

{ #category : #accessing }
NatsSubscription >> inbox [
	^ inbox ifNil:[inbox:= self nc createInbox].
]

{ #category : #accessing }
NatsSubscription >> inbox:anInbox [
 inbox:=anInbox
]

{ #category : #initialization }
NatsSubscription >> initialize [
	super initialize.
	
]

{ #category : #'event handler' }
NatsSubscription >> msg: incoming [
	| msg |
	msg := MsgProto
		readFrom: (PBCodedReadStream on: (incoming at: 'body') asByteArray readStream).
	self nc logger debug: 'Msg sub in: ' , msg data asString.
	self ack: msg.
	onMessageBlock ifNotNil: [ onMessageBlock value: msg data ]
]

{ #category : #accessing }
NatsSubscription >> nc [
	^stan nc.
]

{ #category : #accessing }
NatsSubscription >> nc: aNatsClient [
	self halt.nc := aNatsClient
]

{ #category : #'event handler' }
NatsSubscription >> onMessage: aBlock [
	onMessageBlock:=aBlock
]

{ #category : #accessing }
NatsSubscription >> queueGroup: aQueueGroup [
	queueGroup := aQueueGroup 
]

{ #category : #accessing }
NatsSubscription >> stan: aStan [
stan:= aStan
]

{ #category : #accessing }
NatsSubscription >> subject: aSubject [
	subject:= aSubject
]

{ #category : #announcement }
NatsSubscription >> subscribe [
	self nc sub: self inbox action: [ :msg | self msg: msg ]
]

{ #category : #announcement }
NatsSubscription >> unsubscribe [
	| unsubReq |
	stan isNil
		ifTrue: [ ^ self ].
		stan nc unsub: inbox.
	unsubReq := UnsubscribeRequest new client_id: stan clientId;
	inbox: inbox;subject:subject;yourself.
	durableName ifNotNil: [ unsubReq durable_name: durableName ].
	self nc pub: stan unsub_requests payload: unsubReq asBytes.
	stan unsubscribe:inbox.
stan := nil
]
