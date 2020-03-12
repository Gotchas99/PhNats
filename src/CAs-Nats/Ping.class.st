Class {
	#name : #Ping,
	#superclass : #PBMessage,
	#instVars : [
		'conn_id'
	],
	#category : #'CAs-Nats-PB'
}

{ #category : #initialization }
Ping >> clear [
	"Reset all Protobuf fields to their default values."

	conn_id := #[]
]

{ #category : #accessing }
Ping >> conn_id [
	"bytes conn_id = 1"
	^ conn_id
]

{ #category : #accessing }
Ping >> conn_id: aByteArray [
	"bytes conn_id = 1"
	conn_id := aByteArray
]

{ #category : #initialization }
Ping >> initialize [
	super initialize.
	self clear
]

{ #category : #'input-output' }
Ping >> readFrom: pbReadStream [
	"Read this Protobuf message from the stream."

	| dict done |

	dict := IdentityDictionary new
		add: 10 -> [ conn_id := pbReadStream readBytes ];
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
Ping >> writeTo: pbWriteStream [
	"Serialize this Protobuf message to the stream."

	pbWriteStream
		writeField: 1 bytes: conn_id
]
