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
	^ 'Again another message at ',Time now print24
]

{ #category : #accessing }
NatsGenerator >> running [
^	running
]

{ #category : #action }
NatsGenerator >> start [
	nc := NatsClient openOnHostNamed: 'ux5'.
	running := true.
	[ [ self running ]
		whileTrue: [ nc pub: 'foo' payload: self msg.
			5 seconds wait ].
	nc close ] forkAt: Processor userBackgroundPriority
]

{ #category : #action }
NatsGenerator >> stop [
	running := false
]
