Class {
	#name : #SubscriptionResponse,
	#superclass : #PBMessage,
	#instVars : [
		'ack_inbox',
		'error'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #accessing }
SubscriptionResponse >> ack_inbox [
	"string ack_inbox = 2"
	^ ack_inbox
]

{ #category : #accessing }
SubscriptionResponse >> ack_inbox: aString [
	"string ack_inbox = 2"
	ack_inbox := aString
]

{ #category : #initialization }
SubscriptionResponse >> clear [
	"Reset all Protobuf fields to their default values."

	ack_inbox := ''.
	error := ''
]

{ #category : #accessing }
SubscriptionResponse >> error [
	"string error = 3"
	^ error
]

{ #category : #accessing }
SubscriptionResponse >> error: aString [
	"string error = 3"
	error := aString
]

{ #category : #initialization }
SubscriptionResponse >> initialize [
	super initialize.
	self clear
]

{ #category : #'input-output' }
SubscriptionResponse >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 18 -> [ ack_inbox := pbReadStream readString ];
		add: 26 -> [ error := pbReadStream readString ];
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
SubscriptionResponse >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 2 string: ack_inbox;
		writeField: 3 string: error
]
