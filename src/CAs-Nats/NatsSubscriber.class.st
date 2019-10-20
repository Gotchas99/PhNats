Class {
	#name : #NatsSubscriber,
	#superclass : #Object,
	#instVars : [
		'id',
		'nc',
		'sid'
	],
	#category : #'CAs-Nats-Sample'
}

{ #category : #'as yet unclassified' }
NatsSubscriber >> id: aString [ 
	id:= aString
]

{ #category : #accessing }
NatsSubscriber >> start [
	nc := NatsClient openOnHostNamed: 'ux5'.

]

{ #category : #accessing }
NatsSubscriber >> stop [
	nc close
]

{ #category : #accessing }
NatsSubscriber >> sub [
	sid := nc
		sub: 'foo'
		action: [ :msg | 
			Transcript
				cr;
				show: id,':GOT MESSAGE:' , msg ]
]

{ #category : #accessing }
NatsSubscriber >> unsub [
	nc unsub: sid.
]
