# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: common/Command.proto

require 'google/protobuf'

require_relative '../common/Common_pb'


descriptor_data = "\n\x14\x63ommon/Command.proto\x12\rskywalking.v3\x1a\x13\x63ommon/Common.proto\"K\n\x07\x43ommand\x12\x0f\n\x07\x63ommand\x18\x01 \x01(\t\x12/\n\x04\x61rgs\x18\x02 \x03(\x0b\x32!.skywalking.v3.KeyStringValuePair\"4\n\x08\x43ommands\x12(\n\x08\x63ommands\x18\x01 \x03(\x0b\x32\x16.skywalking.v3.CommandB\x83\x01\n+org.apache.skywalking.apm.network.common.v3P\x01Z2skywalking.apache.org/repo/goapi/collect/common/v3\xaa\x02\x1dSkyWalking.NetworkProtocol.V3b\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool
pool.add_serialized_file(descriptor_data)

module Skywalking
  module V3
    Command = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.Command").msgclass
    Commands = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("skywalking.v3.Commands").msgclass
  end
end
