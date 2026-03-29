// Minimal protobuf message stubs for auth service gRPC.
// In production, regenerate with: protoc --go_out=. --go-grpc_out=. proto/auth.proto

package auth

// ValidateTokenRequest is the request message for ValidateToken RPC.
type ValidateTokenRequest struct {
	Token string `protobuf:"bytes,1,opt,name=token,proto3" json:"token,omitempty"`
}

func (x *ValidateTokenRequest) Reset()         { *x = ValidateTokenRequest{} }
func (x *ValidateTokenRequest) String() string { return x.Token }
func (x *ValidateTokenRequest) ProtoMessage()  {}

func (x *ValidateTokenRequest) GetToken() string {
	if x != nil {
		return x.Token
	}
	return ""
}

// ValidateTokenResponse is the response message for ValidateToken RPC.
type ValidateTokenResponse struct {
	UserId string `protobuf:"bytes,1,opt,name=user_id,json=userId,proto3" json:"user_id,omitempty"`
	Valid  bool   `protobuf:"varint,2,opt,name=valid,proto3" json:"valid,omitempty"`
}

func (x *ValidateTokenResponse) Reset()         { *x = ValidateTokenResponse{} }
func (x *ValidateTokenResponse) String() string { return x.UserId }
func (x *ValidateTokenResponse) ProtoMessage()  {}

func (x *ValidateTokenResponse) GetUserId() string {
	if x != nil {
		return x.UserId
	}
	return ""
}

func (x *ValidateTokenResponse) GetValid() bool {
	if x != nil {
		return x.Valid
	}
	return false
}
