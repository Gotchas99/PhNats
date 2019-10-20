Class {
	#name : #NatsProtoBuf,
	#superclass : #Object,
	#category : #'CAs-Nats-Core'
}

{ #category : #private }
NatsProtoBuf >> executeRefactoring: refactoring [
	
	[ refactoring execute ]
		on: RBRefactoringError
		do: [ :e | UIManager default alert: e messageText ]
]

{ #category : #generate }
NatsProtoBuf >> pbGen [
	| pp msgDef refactoring newClass updateRefactoring model |
	model := RBNamespace new.
	pp := PBProtobufParser parse: self proto.
pp messages do:[:msgNode |
	msgDef := (PBSmalltalkMessageType on: msgNode)
		packageName: 'CAs-Nats-PB';
		yourself.
	refactoring := PBAddMessageClassRefactoring addClassFor: msgDef.
	refactoring model: model.
	self executeRefactoring: refactoring.
	newClass := refactoring model classNamed: msgDef className.
	updateRefactoring := PBUpdateMessageClassRefactoring
		messageType: msgDef
		class: newClass.
	updateRefactoring model: model.
	self executeRefactoring: updateRefactoring].
]

{ #category : #generate }
NatsProtoBuf >> pbRemove [
	| pkg classNames model |
	model := RBNamespace new.
	pkg := RPackage organizer packageNamed: 'CAs-Nats'.
	classNames := (pkg classTagNamed: 'PB') classNames.
	(RBRemoveClassRefactoring model: model classNames: classNames) execute 
]

{ #category : #'grammar-toplevel' }
NatsProtoBuf >> proto [ 
^'// Copyright 2016-2018 The NATS Authors
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Uses https://github.com/gogo/protobuf
// compiled via `protoc -I=. -I=$GOPATH/src  --gogofaster_out=. protocol.proto`

syntax = "proto3";
package pb;

// import "github.com/gogo/protobuf/gogoproto/gogo.proto";

// option (gogoproto.marshaler_all) = true;
// option (gogoproto.sizer_all) = true;
// option (gogoproto.unmarshaler_all) = true;
// option (gogoproto.goproto_getters_all) = false;

// How messages are delivered to the STAN cluster
message PubMsg {
  string client_id = 1;  // ClientID
  string guid      = 2;  // guid
  string subject   = 3;  // subject
  string reply     = 4;  // optional reply
  bytes  data      = 5;  // payload
  bytes  conn_id   = 6;  // Connection ID. For servers that know about this field, clientID can be omitted

  bytes  sha256    = 10; // optional sha256 of data
}

// Used to ACK to publishers
message PubAck {
  string guid  = 1; // guid
  string error = 2; // err string, empty/omitted if no error
}

// Msg struct. Sequence is assigned for global ordering by
// the cluster after the publisher has been acknowledged.
message MsgProto {
  uint64 sequence    = 1;  // globally ordered sequence number for the subject''s channel
  string subject     = 2;  // subject
  string reply       = 3;  // optional reply
  bytes  data        = 4;  // payload
  int64  timestamp   = 5;  // received timestamp
  bool   redelivered = 6;  // Flag specifying if the message is being redelivered

  uint32 CRC32       = 10; // optional IEEE CRC32
}

// Ack will deliver an ack for a delivered msg.
message Ack {
  string subject  = 1; // Subject
  uint64 sequence = 2; // Sequence to acknowledge
}

// Connection Request
message ConnectRequest {
  string client_id       = 1;  // Client name/identifier.
  string heartbeat_inbox = 2;  // Inbox for server initiated heartbeats.
  int32  protocol        = 3;  // Protocol the client is at.
  bytes  conn_id         = 4;  // Connection ID, a way to uniquely identify a connection (no connection should ever have the same)
  int32  ping_interval   = 5;  // Interval at which client wishes to send PINGs (expressed in seconds).
  int32  ping_max_out    = 6;  // Maximum number of PINGs without a response after which the connection can be considered lost.
}

// Response to a client connect
message ConnectResponse {
  string pub_prefix         = 1;   // Prefix to use when publishing to this STAN cluster
  string sub_requests       = 2;   // Subject to use for subscription requests
  string unsub_requests     = 3;   // Subject to use for unsubscribe requests
  string close_requests     = 4;   // Subject for closing the stan connection
  string error              = 5;   // err string, empty/omitted if no error
  string sub_close_requests = 6;   // Subject to use for subscription close requests
  string ping_requests      = 7;   // Subject to use for PING requests
  int32  ping_interval      = 8;   // Interval at which client should send PINGs (expressed in seconds).
  int32  ping_max_out       = 9;   // Maximum number of PINGs without a response after which the connection can be considered lost
  int32  protocol           = 10;  // Protocol version the server is at

  string public_key         = 100; // Possibly used to sign acks, etc.
}

// PING from client to server
message Ping {
  bytes conn_id    = 1;  // Connection ID
}

// PING response from the server
message PingResponse {
  string error    = 1;  // Error string, empty/omitted if no error
}

// Enum for start position type.
enum StartPosition {
    new_only         = 0;
    last_received    = 1;
    time_delta_start = 2;
    sequence_start   = 3;
    first            = 4;
  }

// Protocol for a client to subscribe
message SubscriptionRequest {
  string        client_id        = 1;  // ClientID
  string        subject          = 2;  // Formal subject to subscribe to, e.g. foo.bar
  string        q_group          = 3;  // Optional queue group
  string        inbox            = 4;  // Inbox subject to deliver messages on
  int32         max_in_flight    = 5;  // Maximum inflight messages without an ack allowed
  int32         ack_wait_in_secs = 6;  // Timeout for receiving an ack from the client
  string        durable_name     = 7;  // Optional durable name which survives client restarts
  StartPosition start_position   = 10; // Start position
  uint64        start_sequence   = 11; // Optional start sequence number
  int64         start_time_delta = 12; // Optional start time
}

// Response for SubscriptionRequest and UnsubscribeRequests
message SubscriptionResponse {
  string ack_inbox = 2; // ackInbox for sending acks
  string error     = 3; // err string, empty/omitted if no error
}

// Protocol for a clients to unsubscribe. Will return a SubscriptionResponse
message UnsubscribeRequest {
  string client_id    = 1; // ClientID
  string subject      = 2; // subject for the subscription
  string inbox        = 3; // Inbox subject to identify subscription
  string durable_name = 4; // Optional durable name which survives client restarts
}

// Protocol for a client to close a connection
message CloseRequest {
  string client_id = 1;  // Client name provided to Connect() requests
}

// Response for CloseRequest
message CloseResponse {
  string error = 1; // err string, empty/omitted if no error
}'
]