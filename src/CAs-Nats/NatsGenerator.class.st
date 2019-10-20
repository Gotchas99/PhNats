Class {
	#name : #NatsGenerator,
	#superclass : #Object,
	#instVars : [
		'nc',
		'running'
	],
	#category : #'CAs-Nats-Sample'
}

{ #category : #accessing }
NatsGenerator >> msg [
	^ 'Again another message'
]

{ #category : #accessing }
NatsGenerator >> running [
^	running
]

{ #category : #accessing }
NatsGenerator >> start [
	nc := NatsClient openOnHostNamed: 'ux5'.
	running := true.
	[ [ self running ]
		whileTrue: [ nc pub: 'foo' payload: self msg.
			5 seconds wait ].
	nc close ] forkAt: Processor userBackgroundPriority
]

{ #category : #accessing }
NatsGenerator >> stop [
	running := false
]
