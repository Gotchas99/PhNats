Class {
	#name : #Ack,
	#superclass : #PBMessage,
	#instVars : [
		'subject',
		'sequence'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #initialization }
Ack >> clear [
	"Reset all Protobuf fields to their default values."

	subject := ''.
	sequence := 0
]

{ #category : #initialization }
Ack >> initialize [
	super initialize.
	self clear
]

{ #category : #'input-output' }
Ack >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ subject := pbReadStream readString ];
		add: 16 -> [ sequence := pbReadStream readUint64 ];
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
Ack >> sequence [
	"uint64 sequence = 2"
	^ sequence
]

{ #category : #accessing }
Ack >> sequence: anInteger [
	"uint64 sequence = 2"
	sequence := anInteger
]

{ #category : #accessing }
Ack >> subject [
	"string subject = 1"
	^ subject
]

{ #category : #accessing }
Ack >> subject: aString [
	"string subject = 1"
	subject := aString
]

{ #category : #'input-output' }
Ack >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 string: subject;
		writeField: 2 uint64: sequence
]
