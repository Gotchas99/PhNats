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
			spec
				baseline: 'NeoJSON'
				with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
			spec
				baseline: 'ProtoBuf'
				with: [ spec repository: 'github://jvdsandt/protobuf-smalltalk/' ].
			"Packages"
			spec
				package: 'CAs-Nats' with: [ spec requires: #('NeoJSON' 'Stick') ];
				package: 'CAs-Nats-Tests' with: [ spec requires: 'CAs-Nats' ].
			spec group: 'default' with: #('CAs-Nats' 'CAs-Nats-Tests').
			spec
				group: 'development'
				with: #('default' 'LibGit-Tests' 'LibGit-Patches' 'LibGit-GT').
			spec group: 'tests' with: #('LibGit-Tests') ]
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
  load.
]

{ #category : #baseline }
BaselineOfNats >> stick: spec [
	spec
		baseline: 'Stick'
		with: [ spec
				repository: 'github://mumez/Stick/repository' ]
]
