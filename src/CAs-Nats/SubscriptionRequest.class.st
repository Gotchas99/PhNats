Class {
	#name : #SubscriptionRequest,
	#superclass : #PBMessage,
	#instVars : [
		'client_id',
		'subject',
		'q_group',
		'inbox',
		'max_in_flight',
		'ack_wait_in_secs',
		'durable_name',
		'start_position',
		'start_sequence',
		'start_time_delta'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #accessing }
SubscriptionRequest >> ack_wait_in_secs [
	"int32 ack_wait_in_secs = 6"
	^ ack_wait_in_secs
]

{ #category : #accessing }
SubscriptionRequest >> ack_wait_in_secs: anInteger [
	"int32 ack_wait_in_secs = 6"
	ack_wait_in_secs := anInteger
]

{ #category : #initialization }
SubscriptionRequest >> clear [
	"Reset all Protobuf fields to their default values."

	client_id := ''.
	subject := ''.
	q_group := ''.
	inbox := ''.
	max_in_flight := 0.
	ack_wait_in_secs := 0.
	durable_name := ''.
	start_position := nil.
	start_sequence := 0.
	start_time_delta := 0
]

{ #category : #accessing }
SubscriptionRequest >> client_id [
	"string client_id = 1"
	^ client_id
]

{ #category : #accessing }
SubscriptionRequest >> client_id: aString [
	"string client_id = 1"
	client_id := aString
]

{ #category : #accessing }
SubscriptionRequest >> durable_name [
	"string durable_name = 7"
	^ durable_name
]

{ #category : #accessing }
SubscriptionRequest >> durable_name: aString [
	"string durable_name = 7"
	durable_name := aString
]

{ #category : #accessing }
SubscriptionRequest >> inbox [
	"string inbox = 4"
	^ inbox
]

{ #category : #accessing }
SubscriptionRequest >> inbox: aString [
	"string inbox = 4"
	inbox := aString
]

{ #category : #initialization }
SubscriptionRequest >> initialize [
	super initialize.
	self clear
]

{ #category : #accessing }
SubscriptionRequest >> max_in_flight [
	"int32 max_in_flight = 5"
	^ max_in_flight
]

{ #category : #accessing }
SubscriptionRequest >> max_in_flight: anInteger [
	"int32 max_in_flight = 5"
	max_in_flight := anInteger
]

{ #category : #accessing }
SubscriptionRequest >> q_group [
	"string q_group = 3"
	^ q_group
]

{ #category : #accessing }
SubscriptionRequest >> q_group: aString [
	"string q_group = 3"
	q_group := aString
]

{ #category : #'input-output' }
SubscriptionRequest >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ client_id := pbReadStream readString ];
		add: 18 -> [ subject := pbReadStream readString ];
		add: 26 -> [ q_group := pbReadStream readString ];
		add: 34 -> [ inbox := pbReadStream readString ];
		add: 40 -> [ max_in_flight := pbReadStream readInt32 ];
		add: 48 -> [ ack_wait_in_secs := pbReadStream readInt32 ];
		add: 58 -> [ durable_name := pbReadStream readString ];
		add: 82 -> [ start_position := pbReadStream readMessage: StartPosition ];
		add: 88 -> [ start_sequence := pbReadStream readUint64 ];
		add: 96 -> [ start_time_delta := pbReadStream readInt64 ];
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
SubscriptionRequest >> start_position [
	"StartPosition start_position = 10"
	^ start_position
]

{ #category : #accessing }
SubscriptionRequest >> start_position: anObject [
	"StartPosition start_position = 10"
	start_position := anObject
]

{ #category : #accessing }
SubscriptionRequest >> start_sequence [
	"uint64 start_sequence = 11"
	^ start_sequence
]

{ #category : #accessing }
SubscriptionRequest >> start_sequence: anInteger [
	"uint64 start_sequence = 11"
	start_sequence := anInteger
]

{ #category : #accessing }
SubscriptionRequest >> start_time_delta [
	"int64 start_time_delta = 12"
	^ start_time_delta
]

{ #category : #accessing }
SubscriptionRequest >> start_time_delta: anInteger [
	"int64 start_time_delta = 12"
	start_time_delta := anInteger
]

{ #category : #accessing }
SubscriptionRequest >> subject [
	"string subject = 2"
	^ subject
]

{ #category : #accessing }
SubscriptionRequest >> subject: aString [
	"string subject = 2"
	subject := aString
]

{ #category : #'input-output' }
SubscriptionRequest >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 string: client_id;
		writeField: 2 string: subject;
		writeField: 3 string: q_group;
		writeField: 4 string: inbox;
		writeField: 5 int32: max_in_flight;
		writeField: 6 int32: ack_wait_in_secs;
		writeField: 7 string: durable_name;
		writeField: 10 message: start_position;
		writeField: 11 uint64: start_sequence;
		writeField: 12 int64: start_time_delta
]
