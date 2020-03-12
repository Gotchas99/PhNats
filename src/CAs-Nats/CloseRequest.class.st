Class {
	#name : #CloseRequest,
	#superclass : #PBMessage,
	#instVars : [
		'client_id'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #initialization }
CloseRequest >> clear [
	"Reset all Protobuf fields to their default values."

	client_id := ''
]

{ #category : #accessing }
CloseRequest >> client_id [
	"string client_id = 1"
	^ client_id
]

{ #category : #accessing }
CloseRequest >> client_id: aString [
	"string client_id = 1"
	client_id := aString
]

{ #category : #initialization }
CloseRequest >> initialize [
	super initialize.
	self clear
]

{ #category : #'input-output' }
CloseRequest >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ client_id := pbReadStream readString ];
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
CloseRequest >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 string: client_id
]
