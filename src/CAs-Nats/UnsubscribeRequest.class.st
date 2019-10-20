Class {
	#name : #UnsubscribeRequest,
	#superclass : #PBMessage,
	#instVars : [
		'client_id',
		'subject',
		'inbox',
		'durable_name'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #initialization }
UnsubscribeRequest >> clear [
	"Reset all Protobuf fields to their default values."

	client_id := ''.
	subject := ''.
	inbox := ''.
	durable_name := ''
]

{ #category : #accessing }
UnsubscribeRequest >> client_id [
	"string client_id = 1"
	^ client_id
]

{ #category : #accessing }
UnsubscribeRequest >> client_id: aString [
	"string client_id = 1"
	client_id := aString
]

{ #category : #accessing }
UnsubscribeRequest >> durable_name [
	"string durable_name = 4"
	^ durable_name
]

{ #category : #accessing }
UnsubscribeRequest >> durable_name: aString [
	"string durable_name = 4"
	durable_name := aString
]

{ #category : #accessing }
UnsubscribeRequest >> inbox [
	"string inbox = 3"
	^ inbox
]

{ #category : #accessing }
UnsubscribeRequest >> inbox: aString [
	"string inbox = 3"
	inbox := aString
]

{ #category : #initialization }
UnsubscribeRequest >> initialize [
	super initialize.
	self clear
]

{ #category : #'input-output' }
UnsubscribeRequest >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ client_id := pbReadStream readString ];
		add: 18 -> [ subject := pbReadStream readString ];
		add: 26 -> [ inbox := pbReadStream readString ];
		add: 34 -> [ durable_name := pbReadStream readString ];
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
UnsubscribeRequest >> subject [
	"string subject = 2"
	^ subject
]

{ #category : #accessing }
UnsubscribeRequest >> subject: aString [
	"string subject = 2"
	subject := aString
]

{ #category : #'input-output' }
UnsubscribeRequest >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 string: client_id;
		writeField: 2 string: subject;
		writeField: 3 string: inbox;
		writeField: 4 string: durable_name
]
