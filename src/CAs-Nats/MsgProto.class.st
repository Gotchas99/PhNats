Class {
	#name : #MsgProto,
	#superclass : #PBMessage,
	#instVars : [
		'sequence',
		'subject',
		'reply',
		'data',
		'timestamp',
		'redelivered',
		'cRC32'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #accessing }
MsgProto >> cRC32 [
	"uint32 CRC32 = 10"
	^ cRC32
]

{ #category : #accessing }
MsgProto >> cRC32: anInteger [
	"uint32 CRC32 = 10"
	cRC32 := anInteger
]

{ #category : #initialization }
MsgProto >> clear [
	"Reset all Protobuf fields to their default values."

	sequence := 0.
	subject := ''.
	reply := ''.
	data := #[].
	timestamp := 0.
	redelivered := false.
	cRC32 := 0
]

{ #category : #accessing }
MsgProto >> data [
	"bytes data = 4"
	^ data
]

{ #category : #accessing }
MsgProto >> data: aByteArray [
	"bytes data = 4"
	data := aByteArray
]

{ #category : #initialization }
MsgProto >> initialize [
	super initialize.
	self clear
]

{ #category : #'input-output' }
MsgProto >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 8 -> [ sequence := pbReadStream readUint64 ];
		add: 18 -> [ subject := pbReadStream readString ];
		add: 26 -> [ reply := pbReadStream readString ];
		add: 34 -> [ data := pbReadStream readBytes ];
		add: 40 -> [ timestamp := pbReadStream readInt64 ];
		add: 48 -> [ redelivered := pbReadStream readBool ];
		add: 80 -> [ cRC32 := pbReadStream readUint32 ];
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
MsgProto >> redelivered [
	"bool redelivered = 6"
	^ redelivered
]

{ #category : #accessing }
MsgProto >> redelivered: aBoolean [
	"bool redelivered = 6"
	redelivered := aBoolean
]

{ #category : #accessing }
MsgProto >> reply [
	"string reply = 3"
	^ reply
]

{ #category : #accessing }
MsgProto >> reply: aString [
	"string reply = 3"
	reply := aString
]

{ #category : #accessing }
MsgProto >> sequence [
	"uint64 sequence = 1"
	^ sequence
]

{ #category : #accessing }
MsgProto >> sequence: anInteger [
	"uint64 sequence = 1"
	sequence := anInteger
]

{ #category : #accessing }
MsgProto >> subject [
	"string subject = 2"
	^ subject
]

{ #category : #accessing }
MsgProto >> subject: aString [
	"string subject = 2"
	subject := aString
]

{ #category : #accessing }
MsgProto >> timestamp [
	"int64 timestamp = 5"
	^ timestamp
]

{ #category : #accessing }
MsgProto >> timestamp: anInteger [
	"int64 timestamp = 5"
	timestamp := anInteger
]

{ #category : #'input-output' }
MsgProto >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 uint64: sequence;
		writeField: 2 string: subject;
		writeField: 3 string: reply;
		writeField: 4 bytes: data;
		writeField: 5 int64: timestamp;
		writeField: 6 bool: redelivered;
		writeField: 10 uint32: cRC32
]
