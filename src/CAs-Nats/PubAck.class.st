Class {
	#name : #PubAck,
	#superclass : #PBMessage,
	#instVars : [
		'guid',
		'error'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #initialization }
PubAck >> clear [
	"Reset all Protobuf fields to their default values."

	guid := ''.
	error := ''
]

{ #category : #accessing }
PubAck >> error [
	"string error = 2"
	^ error
]

{ #category : #accessing }
PubAck >> error: aString [
	"string error = 2"
	error := aString
]

{ #category : #accessing }
PubAck >> guid [
	"string guid = 1"
	^ guid
]

{ #category : #accessing }
PubAck >> guid: aString [
	"string guid = 1"
	guid := aString
]

{ #category : #initialization }
PubAck >> initialize [
	super initialize.
	self clear
]

{ #category : #'input-output' }
PubAck >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ guid := pbReadStream readString ];
		add: 18 -> [ error := pbReadStream readString ];
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
PubAck >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 string: guid;
		writeField: 2 string: error
]
