Class {
	#name : #NatsStreamer,
	#superclass : #Object,
	#instVars : [
		'hostname',
		'port',
		'nc',
		'clusterId',
		'clientId',
		'announcer',
		'ackSubject',
		'heartbeatInbox',
		'pingInbox',
		'connId',
		'connectResponse',
		'subscriptions'
	],
	#category : #'CAs-Nats-Core'
}

{ #category : #'instance creation' }
NatsStreamer class >> onHostNamed: aHostname [
	^ (self new onHostNamed: aHostname) 
]

{ #category : #'instance creation' }
NatsStreamer class >> openOnHostNamed: aHostname [
	^ (self onHostNamed: aHostname )open
]

{ #category : #'event handler' }
NatsStreamer >> ack: aMsg [
	
]

{ #category : #accessing }
NatsStreamer >> ackSubject [
	^ackSubject 
]

{ #category : #accessing }
NatsStreamer >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #initialization }
NatsStreamer >> clientId [
^clientId
]

{ #category : #initialization }
NatsStreamer >> clientId:aClientId [
 clientId:= aClientId
]

{ #category : #action }
NatsStreamer >> close [
	| closeReq |
	nc
		ifNotNil: [ subscriptions valuesDo: [ :sub | sub unsubscribe ].subscriptions := Dictionary new.
			closeReq := CloseRequest new client_id: clientId.
			nc pub: connectResponse close_requests payload: closeReq asBytes.
			nc close.
			nc := nil ]
]

{ #category : #'event handler' }
NatsStreamer >> connect: anAnnouncement [
	| connReq discover |
	connId := Nuid default next asByteArray.
	heartbeatInbox := nc createInbox.
	nc sub: heartbeatInbox action: [ :msg | self heartbeat: msg ].
	pingInbox := nc createInbox.
	nc sub: pingInbox action: [ :msg | self pong: msg ].
	nc sub: ackSubject action: [ :msg | self ack: msg ].
	discover := '_STAN.discover.' , clusterId.
	connReq := ConnectRequest new
		client_id: clientId;
		heartbeat_inbox: heartbeatInbox;
		protocol: 1;
		conn_id: connId;
		ping_interval: 5;
		ping_max_out: 3.
	nc
		requestOne: discover
		payload: connReq asBytes
		action: [ :msg | 
			connectResponse := ConnectResponse
				readFrom: (PBCodedReadStream on: (msg at: 'body') asByteArray readStream).
			connectResponse error isEmptyOrNil
				ifTrue: [ self announcer announce: NatsConnect  new..nc logger info: 'Connected' ]
				ifFalse: [ connectResponse inspect ] ]
]

{ #category : #'event handler' }
NatsStreamer >> error: anAnnouncement [
	self halt.
]

{ #category : #'event handler' }
NatsStreamer >> heartbeat: msg [
	nc pub: (msg at: 'reply').
	"nc logger info: 'heartbeat'"
]

{ #category : #'event handler' }
NatsStreamer >> inbox: aMsg [
	
]

{ #category : #initialization }
NatsStreamer >> initialize [
	super initialize.
	clusterId := 'test-cluster'.
	clientId := 'phnats-streaming-client'.
	ackSubject := '_STAN.acks.' , Nuid default next.
	subscriptions:= Dictionary new.
]

{ #category : #testing }
NatsStreamer >> isOpen [ 	
^nc isNotNil
]

{ #category : #'event handler' }
NatsStreamer >> msg: aMsg [
	self halt.
]

{ #category : #accessing }
NatsStreamer >> nc [
	^ nc
]

{ #category : #initialization }
NatsStreamer >> onHostNamed: aHostname [
	hostname := aHostname.port:=nil
]

{ #category : #initialization }
NatsStreamer >> onHostNamed: aHostname port: aPortnumber [
	hostname := aHostname
.port:=	aPortnumber
]

{ #category : #action }
NatsStreamer >> open [
self close
.	nc  := port
		ifNil: [ NatsClient onHostNamed: hostname ]
		ifNotNil: [ NatsClient onHostNamed: hostname port: port ].
	nc announcer when: NatsConnect send: #connect: to: self.
	nc announcer when: NatsReconnect send: #reconnect: to: self.
	nc announcer when: NatsError send: #error: to: self.
	nc open
]

{ #category : #api }
NatsStreamer >> ping [
	| pingReq |
	pingReq := Ping new conn_id: connId ..
	nc
		pub: pingInbox
		payload: pingReq asBytes
	
]

{ #category : #'event handler' }
NatsStreamer >> pong: aMsg [
	| pingResponse |
	pingResponse := PingResponse
		readFrom: (PBCodedReadStream on: (aMsg at: 'body') asByteArray readStream).
	pingResponse error asByteArray = connId
		ifFalse: [ self halt ].
			nc logger info: 'pong'
]

{ #category : #api }
NatsStreamer >> processMsg: incoming [
	| msg |
	msg := MsgProto
		readFrom: (PBCodedReadStream on: (incoming at: 'body') asByteArray readStream).
		 nc logger info: 'Msg in: ', msg data asString
]

{ #category : #api }
NatsStreamer >> pub: innerSubject msg: aMsg [
	| pubReq subject |
	subject := connectResponse pub_prefix , '.' , innerSubject.
	pubReq := PubMsg new
		client_id: clientId;
		guid: UUID new asString;
		subject: innerSubject;
		data: aMsg asByteArray;
		conn_id: connId.
	nc
		requestOne: subject
		payload: pubReq asBytes
		action: [ :msg | 
			| pubResp |
			pubResp := PubAck
				readFrom: (PBCodedReadStream on: (msg at: 'body') asByteArray readStream).
			pubResp error isEmptyOrNil
				ifTrue: [ nc logger debug: 'Pubs ack' ]
				ifFalse: [ pubResp inspect ] ]
]

{ #category : #'event handler' }
NatsStreamer >> reconnect: anAnnouncement [

]

{ #category : #api }
NatsStreamer >> subscribe: subject [
	^self subscribe: subject queueGroup: nil
]

{ #category : #api }
NatsStreamer >> subscribe: aSubject queueGroup: aQueueGroup [
	| sub subReq |
	sub := NatsSubscription new
		stan: self;
		subject: aSubject;queueGroup: aQueueGroup;subscribe;
		yourself.
	
	subReq := SubscriptionRequest new
		client_id: clientId;
		subject: aSubject;
		inbox: sub inbox;
		max_in_flight: 16384;
		ack_wait_in_secs: 30;
		start_position: (StartPosition new value: 0).
	aQueueGroup ifNotNil: [ subReq q_group: aQueueGroup ].
	nc
		requestOne: connectResponse sub_requests
		payload: subReq asBytes
		action: [ :msg | 
			| subResp |
			subResp := SubscriptionResponse
				readFrom: (PBCodedReadStream on: (msg at: 'body') asByteArray readStream).
			subResp error isEmptyOrNil
				ifTrue: [ subscriptions at: sub inbox put: sub.
					sub ackInbox: subResp ack_inbox.
					self announcer announce: NatsSubscribe new.
					nc logger info: 'Subscription confirmed' ]
				ifFalse: [ subResp inspect ] ].
	^ sub
]

{ #category : #accessing }
NatsStreamer >> unsub_requests [
	^ connectResponse unsub_requests
]

{ #category : #api }
NatsStreamer >> unsubscribe: anInbox [
	subscriptions removeKey: anInbox ifAbsent:[]
]
