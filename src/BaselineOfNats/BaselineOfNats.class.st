Class {
	#name : #BaselineOfNats,
	#superclass : #BaselineOf,
	#category : #BaselineOfNats
}

{ #category : #baseline }
BaselineOfNats >> baseline: spec [
	<baseline>
	spec
		for: #(common)
		do: [ "Dependencies"
			self stick: spec.
			self neoJSON: spec.
			self protoBuf: spec.
			"Packages"
			spec
				package: 'CAs-Nats' with: [ spec requires: #('NeoJSON' 'Stick') ];
				package: 'CAs-Nats-Tests' with: [ spec requires: 'CAs-Nats' ].	
					"Groups"
			spec group: 'default' with: #('CAs-Nats').
			spec group: 'tests' with: #('CAs-Nats-Tests').
			spec group: 'development' with: #('default' 'tests') ]
]

{ #category : #baseline }
BaselineOfNats >> manualLoading [
	Metacello new
		baseline: 'Stick';
		repository: 'github://mumez/Stick/repository';
		load.
	Metacello new
		repository: 'github://svenvc/NeoJSON/repository';
		baseline: 'NeoJSON';
		load.Metacello new
   baseline: 'Protobuf';
   repository: 'github://jvdsandt/protobuf-smalltalk';
   load.
]

{ #category : #dependencies }
BaselineOfNats >> neoJSON: spec [
	spec
		baseline: 'NeoJSON'
		with: [ spec repository: 'github://svenvc/NeoJSON/repository' ]
]

{ #category : #dependencies }
BaselineOfNats >> protoBuf: spec [
	spec
		baseline: 'ProtoBuf'
		with: [ spec repository: 'github://jvdsandt/protobuf-smalltalk/' ]
]

{ #category : #dependencies }
BaselineOfNats >> stick: spec [
	spec
		baseline: 'Stick'
		with: [ spec
				repository: 'github://mumez/Stick/repository' ]
]
