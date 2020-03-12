Class {
	#name : #ConnectResponse,
	#superclass : #PBMessage,
	#instVars : [
		'pub_prefix',
		'sub_requests',
		'unsub_requests',
		'close_requests',
		'error',
		'sub_close_requests',
		'ping_requests',
		'ping_interval',
		'ping_max_out',
		'protocol',
		'public_key'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #initialization }
ConnectResponse >> clear [
	"Reset all Protobuf fields to their default values."

	pub_prefix := ''.
	sub_requests := ''.
	unsub_requests := ''.
	close_requests := ''.
	error := ''.
	sub_close_requests := ''.
	ping_requests := ''.
	ping_interval := 0.
	ping_max_out := 0.
	protocol := 0.
	public_key := ''
]

{ #category : #accessing }
ConnectResponse >> close_requests [
	"string close_requests = 4"
	^ close_requests
]

{ #category : #accessing }
ConnectResponse >> close_requests: aString [
	"string close_requests = 4"
	close_requests := aString
]

{ #category : #accessing }
ConnectResponse >> error [
	"string error = 5"
	^ error
]

{ #category : #accessing }
ConnectResponse >> error: aString [
	"string error = 5"
	error := aString
]

{ #category : #initialization }
ConnectResponse >> initialize [
	super initialize.
	self clear
]

{ #category : #accessing }
ConnectResponse >> ping_interval [
	"int32 ping_interval = 8"
	^ ping_interval
]

{ #category : #accessing }
ConnectResponse >> ping_interval: anInteger [
	"int32 ping_interval = 8"
	ping_interval := anInteger
]

{ #category : #accessing }
ConnectResponse >> ping_max_out [
	"int32 ping_max_out = 9"
	^ ping_max_out
]

{ #category : #accessing }
ConnectResponse >> ping_max_out: anInteger [
	"int32 ping_max_out = 9"
	ping_max_out := anInteger
]

{ #category : #accessing }
ConnectResponse >> ping_requests [
	"string ping_requests = 7"
	^ ping_requests
]

{ #category : #accessing }
ConnectResponse >> ping_requests: aString [
	"string ping_requests = 7"
	ping_requests := aString
]

{ #category : #accessing }
ConnectResponse >> protocol [
	"int32 protocol = 10"
	^ protocol
]

{ #category : #accessing }
ConnectResponse >> protocol: anInteger [
	"int32 protocol = 10"
	protocol := anInteger
]

{ #category : #accessing }
ConnectResponse >> pub_prefix [
	"string pub_prefix = 1"
	^ pub_prefix
]

{ #category : #accessing }
ConnectResponse >> pub_prefix: aString [
	"string pub_prefix = 1"
	pub_prefix := aString
]

{ #category : #accessing }
ConnectResponse >> public_key [
	"string public_key = 100"
	^ public_key
]

{ #category : #accessing }
ConnectResponse >> public_key: aString [
	"string public_key = 100"
	public_key := aString
]

{ #category : #'input-output' }
ConnectResponse >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ pub_prefix := pbReadStream readString ];
		add: 18 -> [ sub_requests := pbReadStream readString ];
		add: 26 -> [ unsub_requests := pbReadStream readString ];
		add: 34 -> [ close_requests := pbReadStream readString ];
		add: 42 -> [ error := pbReadStream readString ];
		add: 50 -> [ sub_close_requests := pbReadStream readString ];
		add: 58 -> [ ping_requests := pbReadStream readString ];
		add: 64 -> [ ping_interval := pbReadStream readInt32 ];
		add: 72 -> [ ping_max_out := pbReadStream readInt32 ];
		add: 80 -> [ protocol := pbReadStream readInt32 ];
		add: 802 -> [ public_key := pbReadStream readString ];
		yourself.

	self clear.
	done := false.
	[ done ] whileFalse: [
		| tag |
		tag := pbReadStream readTag.
		(dict at: tag ifAbsent: [ self readUnknownField: tag from: pbReadStream ]) value.
		done := pbReadStream atEnd ]
]

{ #category : #accessing }
ConnectResponse >> sub_close_requests [
	"string sub_close_requests = 6"
	^ sub_close_requests
]

{ #category : #accessing }
ConnectResponse >> sub_close_requests: aString [
	"string sub_close_requests = 6"
	sub_close_requests := aString
]

{ #category : #accessing }
ConnectResponse >> sub_requests [
	"string sub_requests = 2"
	^ sub_requests
]

{ #category : #accessing }
ConnectResponse >> sub_requests: aString [
	"string sub_requests = 2"
	sub_requests := aString
]

{ #category : #accessing }
ConnectResponse >> unsub_requests [
	"string unsub_requests = 3"
	^ unsub_requests
]

{ #category : #accessing }
ConnectResponse >> unsub_requests: aString [
	"string unsub_requests = 3"
	unsub_requests := aString
]

{ #category : #'input-output' }
ConnectResponse >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 string: pub_prefix;
		writeField: 2 string: sub_requests;
		writeField: 3 string: unsub_requests;
		writeField: 4 string: close_requests;
		writeField: 5 string: error;
		writeField: 6 string: sub_close_requests;
		writeField: 7 string: ping_requests;
		writeField: 8 int32: ping_interval;
		writeField: 9 int32: ping_max_out;
		writeField: 10 int32: protocol;
		writeField: 100 string: public_key
]
