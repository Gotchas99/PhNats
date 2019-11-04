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

{ #category : #action }
NatsStreamer >> close [
	| closeReq |
	nc
		ifNotNil: [ closeReq := CloseRequest new client_id: clientId.
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
				readFrom: (PBCodedReadStream on: (msg at: 'body') asByteArray readStream) ]
]

{ #category : #'event handler' }
NatsStreamer >> error: anAnnouncement [
	self halt.
]

{ #category : #'event handler' }
NatsStreamer >> heartbeat: msg [

	nc pub: (msg at: 'reply').
	nc logger info:'heartbeat'
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

{ #category : #'event handler' }
NatsStreamer >> msg: aMsg [
	
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
NatsStreamer >> pub: subject msg: aMsg [
	| msg |
	msg := PubMsg new
		client_id: clientId;
		guid: UUID new asString;
		subject: subject;
		data: aMsg asByteArray;
		conn_id: connId.
	self flag: 'ackHandler ?'.
	nc pub: subject payload: msg asBytes
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
	| sub |
	sub := NatsSubscription new
		nc: nc;
		sub_requests:connectResponse  sub_requests;
		subject: aSubject;
		queueGroup: aQueueGroup.
	sub subscribe.
	subscriptions at: sub inbox put sub.
	^ sub
]
