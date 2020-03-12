Class {
	#name : #CloseResponse,
	#superclass : #PBMessage,
	#instVars : [
		'error'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #initialization }
CloseResponse >> clear [
	"Reset all Protobuf fields to their default values."

	error := ''
]

{ #category : #accessing }
CloseResponse >> error [
	"string error = 1"
	^ error
]

{ #category : #accessing }
CloseResponse >> error: aString [
	"string error = 1"
	error := aString
]

{ #category : #initialization }
CloseResponse >> initialize [
	super initialize.
	self clear
]

{ #category : #'input-output' }
CloseResponse >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ error := pbReadStream readString ];
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
CloseResponse >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 string: error
]
