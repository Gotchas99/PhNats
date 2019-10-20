Class {
	#name : #PubMsg,
	#superclass : #PBMessage,
	#instVars : [
		'client_id',
		'guid',
		'subject',
		'reply',
		'data',
		'conn_id',
		'sha256'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #initialization }
PubMsg >> clear [
	"Reset all Protobuf fields to their default values."

	client_id := ''.
	guid := ''.
	subject := ''.
	reply := ''.
	data := #[].
	conn_id := #[].
	sha256 := #[]
]

{ #category : #accessing }
PubMsg >> client_id [
	"string client_id = 1"
	^ client_id
]

{ #category : #accessing }
PubMsg >> client_id: aString [
	"string client_id = 1"
	client_id := aString
]

{ #category : #accessing }
PubMsg >> conn_id [
	"bytes conn_id = 6"
	^ conn_id
]

{ #category : #accessing }
PubMsg >> conn_id: aByteArray [
	"bytes conn_id = 6"
	conn_id := aByteArray
]

{ #category : #accessing }
PubMsg >> data [
	"bytes data = 5"
	^ data
]

{ #category : #accessing }
PubMsg >> data: aByteArray [
	"bytes data = 5"
	data := aByteArray
]

{ #category : #accessing }
PubMsg >> guid [
	"string guid = 2"
	^ guid
]

{ #category : #accessing }
PubMsg >> guid: aString [
	"string guid = 2"
	guid := aString
]

{ #category : #initialization }
PubMsg >> initialize [
	super initialize.
	self clear
]

{ #category : #'input-output' }
PubMsg >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ client_id := pbReadStream readString ];
		add: 18 -> [ guid := pbReadStream readString ];
		add: 26 -> [ subject := pbReadStream readString ];
		add: 34 -> [ reply := pbReadStream readString ];
		add: 42 -> [ data := pbReadStream readBytes ];
		add: 50 -> [ conn_id := pbReadStream readBytes ];
		add: 82 -> [ sha256 := pbReadStream readBytes ];
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
PubMsg >> reply [
	"string reply = 4"
	^ reply
]

{ #category : #accessing }
PubMsg >> reply: aString [
	"string reply = 4"
	reply := aString
]

{ #category : #accessing }
PubMsg >> sha256 [
	"bytes sha256 = 10"
	^ sha256
]

{ #category : #accessing }
PubMsg >> sha256: aByteArray [
	"bytes sha256 = 10"
	sha256 := aByteArray
]

{ #category : #accessing }
PubMsg >> subject [
	"string subject = 3"
	^ subject
]

{ #category : #accessing }
PubMsg >> subject: aString [
	"string subject = 3"
	subject := aString
]

{ #category : #'input-output' }
PubMsg >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 string: client_id;
		writeField: 2 string: guid;
		writeField: 3 string: subject;
		writeField: 4 string: reply;
		writeField: 5 bytes: data;
		writeField: 6 bytes: conn_id;
		writeField: 10 bytes: sha256
]
