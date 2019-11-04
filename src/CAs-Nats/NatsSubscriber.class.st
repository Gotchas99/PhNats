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

{ #category : #accessing }
NatsSubscriber >> id: aString [ 
	id:= aString
]

{ #category : #action }
NatsSubscriber >> start [
	nc := NatsClient openOnHostNamed: 'ux5'.

]

{ #category : #action }
NatsSubscriber >> stop [
	nc close
]

{ #category : #action }
NatsSubscriber >> sub [
	sid := nc
		sub: 'foo'
		action: [ :msg | 
			Transcript
				cr;
				show: id , ':GOT MESSAGE:' , msg ] 
]

{ #category : #action }
NatsSubscriber >> unsub [
	nc unsub: sid.
]
