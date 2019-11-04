Class {
	#name : #NatsError,
	#superclass : #NatsAnnouncement,
	#instVars : [
		'errorMsg'
	],
	#category : #'CAs-Nats-Announcement'
}

{ #category : #accessing }
NatsError >> errorMsg [
^	errorMsg
]

{ #category : #accessing }
NatsError >> errorMsg:aString [
errorMsg:=aString
]
