"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestCAsNats,
	#superclass : #PackageManifest,
	#category : #'CAs-Nats-Manifest'
}

{ #category : #'code-critics' }
ManifestCAsNats class >> ruleRBBadMessageRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#NatsClient #processControl: #false)) #'2019-07-26T19:20:03.654695+02:00') )
]
