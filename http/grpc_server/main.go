// Package main starts the gRPC server.
package main

import (
	"context"
	"fmt"
	"log"
	"net"

	"github.com/brianvoe/gofakeit"
	"github.com/vashkevichjr/chat-server/pkg/chat_v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"google.golang.org/protobuf/types/known/emptypb"
)

const grpcPort = "50052"

type server struct {
	chat_v1.UnimplementedChatServiceServer
}

func (s *server) CreateChat(_ context.Context, _ *chat_v1.CreateChatRequest) (*chat_v1.CreateChatResponse, error) {
	return &chat_v1.CreateChatResponse{ChatId: gofakeit.Int64()}, nil
}

func (s *server) DeleteChat(_ context.Context, _ *chat_v1.DeleteChatRequest) (*emptypb.Empty, error) {
	return &emptypb.Empty{}, nil
}

func (s *server) SendMessage(_ context.Context, _ *chat_v1.SendMessageRequest) (*emptypb.Empty, error) {
	return &emptypb.Empty{}, nil
}

func main() {
	lis, err := net.Listen("tcp", fmt.Sprintf(":%s", grpcPort))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	reflection.Register(s)
	chat_v1.RegisterChatServiceServer(s, &server{})

	log.Printf("gRPC server listening on port %s", grpcPort)

	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
