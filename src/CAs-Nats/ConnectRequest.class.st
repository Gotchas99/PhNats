Class {
	#name : #ConnectRequest,
	#superclass : #PBMessage,
	#instVars : [
		'client_id',
		'heartbeat_inbox',
		'protocol',
		'conn_id',
		'ping_interval',
		'ping_max_out'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #initialization }
ConnectRequest >> clear [
	"Reset all Protobuf fields to their default values."

	client_id := ''.
	heartbeat_inbox := ''.
	protocol := 0.
	conn_id := #[].
	ping_interval := 0.
	ping_max_out := 0
]

{ #category : #accessing }
ConnectRequest >> client_id [
	"string client_id = 1"
	^ client_id
]

{ #category : #accessing }
ConnectRequest >> client_id: aString [
	"string client_id = 1"
	client_id := aString
]

{ #category : #accessing }
ConnectRequest >> conn_id [
	"bytes conn_id = 4"
	^ conn_id
]

{ #category : #accessing }
ConnectRequest >> conn_id: aByteArray [
	"bytes conn_id = 4"
	conn_id := aByteArray
]

{ #category : #accessing }
ConnectRequest >> heartbeat_inbox [
	"string heartbeat_inbox = 2"
	^ heartbeat_inbox
]

{ #category : #accessing }
ConnectRequest >> heartbeat_inbox: aString [
	"string heartbeat_inbox = 2"
	heartbeat_inbox := aString
]

{ #category : #initialization }
ConnectRequest >> initialize [
	super initialize.
	self clear
]

{ #category : #accessing }
ConnectRequest >> ping_interval [
	"int32 ping_interval = 5"
	^ ping_interval
]

{ #category : #accessing }
ConnectRequest >> ping_interval: anInteger [
	"int32 ping_interval = 5"
	ping_interval := anInteger
]

{ #category : #accessing }
ConnectRequest >> ping_max_out [
	"int32 ping_max_out = 6"
	^ ping_max_out
]

{ #category : #accessing }
ConnectRequest >> ping_max_out: anInteger [
	"int32 ping_max_out = 6"
	ping_max_out := anInteger
]

{ #category : #accessing }
ConnectRequest >> protocol [
	"int32 protocol = 3"
	^ protocol
]

{ #category : #accessing }
ConnectRequest >> protocol: anInteger [
	"int32 protocol = 3"
	protocol := anInteger
]

{ #category : #'input-output' }
ConnectRequest >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ client_id := pbReadStream readString ];
		add: 18 -> [ heartbeat_inbox := pbReadStream readString ];
		add: 24 -> [ protocol := pbReadStream readInt32 ];
		add: 34 -> [ conn_id := pbReadStream readBytes ];
		add: 40 -> [ ping_interval := pbReadStream readInt32 ];
		add: 48 -> [ ping_max_out := pbReadStream readInt32 ];
		yourself.

	self clear.
	done := false.
	[ done ] whileFalse: [
		| tag |
		tag := pbReadStream readTag.
		(dict at: tag ifAbsent: [ self readUnknownField: tag from: pbReadStream ]) value.
		done := pbReadStream atEnd ]
]

{ #category : #'input-output' }
ConnectRequest >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 string: client_id;
		writeField: 2 string: heartbeat_inbox;
		writeField: 3 int32: protocol;
		writeField: 4 bytes: conn_id;
		writeField: 5 int32: ping_interval;
		writeField: 6 int32: ping_max_out
]
