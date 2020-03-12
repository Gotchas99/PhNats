"
Copied/transcribed from NATS server javascript code in:

https://github.com/nats-io/node-nuid/blob/master/lib/nuid.js
"
Class {
	#name : #Nuid,
	#superclass : #Object,
	#instVars : [
		'digits',
		'base',
		'preLen',
		'seqLen',
		'maxSeq',
		'minInc',
		'maxInc',
		'totalLen',
		'buf',
		'seq',
		'inc'
	],
	#classVars : [
		'Default',
		'Rnd'
	],
	#category : #'CAs-Nats-Core'
}

{ #category : #'system startup' }
Nuid class >> default [
^Default ifNil:[Default:= self new].
]

{ #category : #'class initialization' }
Nuid class >> initialize [
	self startUp: true.
	SessionManager default registerUserClassNamed: self name
]

{ #category : #'system startup' }
Nuid class >> reset [
	Default := nil
]

{ #category : #'system startup' }
Nuid class >> shutDown: isImageQuitting [
	"Pharo is shutting down. If this platform requires specific shutdown code, this is a great place to put it."

	
]

{ #category : #'system startup' }
Nuid class >> startUp: isImageStarting [
	isImageStarting
		ifFalse: [ ^ self ].
	Rnd := Random new.
	Default := nil
]

{ #category : #initialization }
Nuid >> fillSeq [
	| n |
	n := seq.
	totalLen to: preLen + 1 by: -1 do: [ :ix | buf at: ix put: (digits at: ((n \\ base)+1)) asciiValue. n:= (n/base)floor ]
]

{ #category : #initialization }
Nuid >> initSeqAndInc [
	seq := (Rnd next * maxSeq) floor.
	inc := ((Rnd next * (maxInc - minInc)) + minInc) floor
]

{ #category : #initialization }
Nuid >> initialize [
	digits := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
	base := 36.
	preLen := 12.
	seqLen := 10.
	maxSeq := 3656158440062976.	"base^seqLen == 36^10"
	minInc := 33.
	maxInc := 333.
	totalLen := preLen + seqLen.
	buf := ByteArray new: totalLen.
	self setPre.
	self initSeqAndInc.self fillSeq
]

{ #category : #accessing }
Nuid >> next [
	seq := seq + inc.
	seq > maxSeq
		ifTrue: [ self setPre.
			self initSeqAndInc ].
		self fillSeq.
		^buf asString
]

{ #category : #initialization }
Nuid >> setPre [
	| di |
	1 to: preLen do: [ :ix | 
		di := 1+((Rnd nextInt: 255) \\ base).
		buf at: ix put: (digits at: di) asciiValue]
]
