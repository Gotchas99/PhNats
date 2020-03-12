Class {
	#name : #NatsClient,
	#superclass : #Object,
	#instVars : [
		'stick',
		'serverInfo',
		'connectInfo',
		'controlStream',
		'msgStream',
		'progressObservers',
		'hostPort',
		'sid',
		'incomingMessagetypes',
		'subscriptions',
		'announcer'
	],
	#category : #'CAs-Nats-Core'
}

{ #category : #accessing }
NatsClient class >> defaultPortNumber [
	^4222
]

{ #category : #'instance creation' }
NatsClient class >> onHostNamed: aHostname [
	^ self onHostNamed: aHostname port: self defaultPortNumber
]

{ #category : #'instance creation' }
NatsClient class >> onHostNamed: aHostname port: aPortnumber [
	| instance |
	instance := self new.
	instance
		hostPort: aHostname , ':' , aPortnumber asString.
	^ instance
]

{ #category : #'instance creation' }
NatsClient class >> open [
	^self openOnHostNamed: 'localhost'
	
]

{ #category : #'instance creation' }
NatsClient class >> openOnHostNamed: aHostname [
	^ self openOnHostNamed:aHostname  port: self defaultPortNumber 
]

{ #category : #'instance creation' }
NatsClient class >> openOnHostNamed: aHostname port: aPortnumber [
	| instance |
	instance := self onHostNamed: aHostname port:  aPortnumber ;
		open.
	^ instance
]

{ #category : #accessing }
NatsClient >> announcer [
  ^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #api }
NatsClient >> close [
	stick
		ifNotNil: [ stick logger info: ' >>>Closing connection...'.
			self unregisterSubscriptions.
			announcer ifNotNil: [ announcer subscriptions reset ].
			stick release.
			stick := nil ]
]

{ #category : #protocol }
NatsClient >> connect [
	| json |
	json:= NeoJSONWriter toString: self connectionInfo .
	self sendCommand: 'CONNECT ',json
]

{ #category : #accessing }
NatsClient >> connectionInfo [
	
	^ connectInfo
]

{ #category : #actions }
NatsClient >> consumeBlock [
	^ [ :charcode | 
	charcode = 10
		ifTrue: [ stick onData: self controlBlock  ]
		ifFalse: [  ] ]
]

{ #category : #actions }
NatsClient >> controlBlock [
	^ [ :charcode | 
		stick logger debug: ' cntl#' , charcode asString , ' '.

	charcode = 10
		ifTrue: [ self processControl: controlStream contents asString.
			controlStream resetContents ]
		ifFalse: [ charcode = 13
				ifTrue: [ "just ignore CR" ]
				ifFalse: [ controlStream nextPut: charcode ] ] ]
]

{ #category : #api }
NatsClient >> createInbox [
^'_INBOX.' , Nuid default next
]

{ #category : #ops }
NatsClient >> err: aLine [
| msg |
msg:= ('''' split: aLine)second.
	self announcer
		announce:
			(NatsError  new
				errorMsg: msg;
				yourself).
]

{ #category : #accessing }
NatsClient >> hostPort: aHostPortString [
hostPort:=aHostPortString 
]

{ #category : #ops }
NatsClient >> info: aLine [
	| json |
	json := aLine asString withoutPrefix: 'INFO '.
	serverInfo := NeoJSONReader fromString: json.
	
	stick beSwitchyWithAll: self urls.
	self connect.
	self announcer announce: NatsConnect new.
]

{ #category : #initialization }
NatsClient >> initialize [
	sid := 0.
	connectInfo := {('verbose' -> false).
	('tls_required' -> false).
	('name' -> 'phnats').
	('version' -> '0.1').
	('protocol' -> 1)} asDictionary.
	serverInfo := Dictionary new.
	incomingMessagetypes := #('info:' 'msg:' 'ping:' 'pong:' 'err:' 'ok:').
	subscriptions := Dictionary new
]

{ #category : #actions }
NatsClient >> log: aString [
	self deprecated: 'use logger instead'.
	stick logger logLevel: aString
]

{ #category : #actions }
NatsClient >> logLevel: anInteger [
	stick logger logLevel: anInteger
]

{ #category : #actions }
NatsClient >> logger [
^	stick logger
]

{ #category : #ops }
NatsClient >> msg: aLine [
	| line reply |
	line := Character space split: aLine asString.
	line size = 5
		ifTrue: [ reply := line fourth ].
	stick logger debug: 'msg: with splits: ' , line asString.
	stick onData: (self msgBlockForSid: line third size: line last reply:reply)
]

{ #category : #actions }
NatsClient >> msgBlockForSid: aSid size: sz [
	^ [ :charcode | 
	stick logger debug: ' msg#' , charcode asString , ' '.
	[msgStream size < sz asInteger]
		whileTrue: [ msgStream nextPut: charcode ].
self
				processMessage: msgStream contents asString
				forSid: aSid
				size: sz.
			msgStream resetContents.
			stick onData: self controlBlock ] 
]

{ #category : #actions }
NatsClient >> msgBlockForSid: aSid size: sz reply: reply [
	^ [ :charcode | 
	stick logger debug: ' msg#' , charcode asString , ' '.
	( msgStream size < sz asInteger )
		ifTrue: [ msgStream nextPut: charcode ]
		ifFalse:[
	self
		processMessage: msgStream contents asString
		forSid: aSid
		reply: reply.
	msgStream resetContents.
	stick onData: self controlBlock ]]
]

{ #category : #accessing }
NatsClient >> nextSid [
	[ sid := sid + 1.
	subscriptions includesKey: sid asString ] whileTrue.
	^ sid asString 
]

{ #category : #ops }
NatsClient >> ok: aLine [
	"No-op"
]

{ #category : #api }
NatsClient >> open [
	self close.
	WorldState
		addDeferredUIMessage: [ self traceCr: ' >>>Opening connection...' ].
	stick := SkStick targetUrl: self urls first.
	stick logger logLevel: 3.
	stick
		onConnected: [ stick logger info: 'connected'.
			controlStream := ReadWriteStream on: ByteArray new.
			msgStream := ReadWriteStream on: ByteArray new.
			self registerSubscriptions ].
	stick onClosed: [ stick logger info: 'closed' ].
	stick
		onError: [ :ex | 
			stick logger error: 'error ' , ex printString.
			ex isReconnectEnded
				ifTrue: [ stick stick ] ].
	stick onData: self controlBlock.
	stick connect
]

{ #category : #api }
NatsClient >> ping [
	self sendCommand: 'PING'
]

{ #category : #ops }
NatsClient >> ping: aLine [
	self announcer announce: NatsPing new. 
	self sendCommand: 'PONG'
]

{ #category : #ops }
NatsClient >> pong: aLine [
	self announcer
		announce:
			(NatsAnnouncement new
				event: #pong;
				yourself)
	"reset heartbeat timer"
]

{ #category : #protocol }
NatsClient >> processControl: aLine [
	| op method |
	aLine isEmpty
		ifTrue: [ ^ self ].
	op := (aLine asString findTokens: Character separators) first
		onlyLetters asLowercase.
	method := (op , ':') asSymbol.
	(incomingMessagetypes includes: method)
		ifTrue: [ stick logger
				debug: 'processing cmd: ' , method , ', with line: ' , aLine.
			self perform: method with: aLine ]
		ifFalse: [ stick logger
				error: 'Invalid cmd: ' , method , ', with line: ' , aLine ]
]

{ #category : #protocol }
NatsClient >> processMessage: line forSid: aSid reply: reply [
	| action sub msg |
	stick logger
		debug: 'msg for sid: ' , sid asString , ', content:' , line.
	msg := Dictionary new
		at: 'body' put: line;
		at: 'reply' put: reply;
		yourself.
	sub := subscriptions at: aSid ifAbsent: [ ^ self ].
	action := sub at: 'action' ifAbsent: [ ^ self ].
	action value: msg
]

{ #category : #protocol }
NatsClient >> processMessage: line forSid: aSid size: sz [
	| action sub |
	stick logger
		debug: 'msg for sid: ' , sid asString , ', content:' , line.
	sub := subscriptions at: aSid ifAbsent: [ ^ self ].
	action := sub at: 'action' ifAbsent: [ ^ self ].
	action value: line
]

{ #category : #api }
NatsClient >> pub: subject [ 
	self pub: subject payload: '' 
]

{ #category : #api }
NatsClient >> pub: subject payload: aString [
self 	pub: subject payload: aString replyTo: nil
]

{ #category : #api }
NatsClient >> pub: subject payload: aString replyTo: inbox [
	| cmd |
	cmd := 'PUB ' , subject.
	inbox ifNotNil: [ cmd := cmd , ' ' , inbox ].
	cmd := cmd , ' ' , aString size asString
.	self sendCommand: cmd.
	self sendCommand: aString 
]

{ #category : #protocol }
NatsClient >> registerSubscriptions [
	subscriptions
		valuesDo: [ :sub | 
			self
				sub: (sub at: 'subject')
				action: (sub at: 'action'ifAbsent: [  ])
				queueGroup: (sub at: 'queueGroup' ifAbsent: [  ])
				sid: (sub at: 'sid') ]
]

{ #category : #api }
NatsClient >> requestOne: subject payload: aByteArray action: aBlock [
	| inbox |
	inbox := self createInbox.
	self
		sub: inbox
		action: [ :msg | 
			
			aBlock value: msg .self unsub: inbox.].
	self pub: subject payload: aByteArray replyTo: inbox
]

{ #category : #protocol }
NatsClient >> sendCommand: aCmd [
	| bytes |
	stick logger debug: 'sendCommand: ' , aCmd.
	bytes := (aCmd , String crlf) asByteArray.
	stick send: bytes
]

{ #category : #api }
NatsClient >> sub: subject [
^	self sub: subject queueGroup: nil
]

{ #category : #api }
NatsClient >> sub: subject action: aBlock [
	^self sub: subject action: aBlock queueGroup: nil
]

{ #category : #api }
NatsClient >> sub: subject action: aBlock queueGroup: aGrp [
^	self
		sub: subject
		action: aBlock
		queueGroup: aGrp
		sid: self nextSid asString
]

{ #category : #api }
NatsClient >> sub: subject action: aBlock queueGroup: aGrp sid: aSid [
	| cmd sub |
	cmd := 'SUB ' , subject.
	aGrp ifNotNil: [ cmd := cmd , ' ' , aGrp ].
	cmd := cmd , ' ' , aSid asString.
	self sendCommand: cmd.
	sub := {('sid' -> aSid).
	('subject' -> subject).
	('queueGroup' -> aGrp).
	('action' -> aBlock)} asDictionary.
	subscriptions at: aSid put: sub.^aSid
]

{ #category : #api }
NatsClient >> sub: subject queueGroup: aGrp [
	^self sub: subject queueGroup: aGrp sid: self nextSid asString
]

{ #category : #api }
NatsClient >> sub: subject queueGroup: aGrp sid: aSid [
^	self
		sub: subject
		action: nil
		queueGroup: aGrp
		sid: aSid
]

{ #category : #accessing }
NatsClient >> subscriptions [ ^subscriptions 
]

{ #category : #protocol }
NatsClient >> unregisterSubscriptions [
	subscriptions valuesDo: [ :sub | self unsub: (sub at:'sid') ]
]

{ #category : #api }
NatsClient >> unsub: aSid [
	self unsub: aSid maxMessages: nil
]

{ #category : #api }
NatsClient >> unsub: aSid maxMessages: max [
	| cmd |
	cmd := 'UNSUB ' , aSid asString .max
		ifNotNil: [ cmd := cmd , ' ' , max asString ].
	self sendCommand: cmd.
	"Note: does not take maxMessages into Account. 
	In case of reconnect it will not be resubscribed"
	subscriptions removeKey: aSid asString ifAbsent: [  ]
]

{ #category : #accessing }
NatsClient >> urls [
	| hps |
	hps := serverInfo at: 'connect_urls' ifAbsent: [ {hostPort} ].
	^ hps collect:[:hp|'async://' , hp ]
]
