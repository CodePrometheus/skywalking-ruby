# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: profile/Profile.proto for package 'skywalking.v3'
# Original file comments:
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#

require 'grpc'
require_relative 'Profile_pb'

module Skywalking
  module V3
    module ProfileTask
      class Service

        include ::GRPC::GenericService

        self.marshal_class_method = :encode
        self.unmarshal_class_method = :decode
        self.service_name = 'skywalking.v3.ProfileTask'

        # query all sniffer need to execute profile task commands
        rpc :getProfileTaskCommands, ::Skywalking::V3::ProfileTaskCommandQuery, ::Skywalking::V3::Commands
        # collect dumped thread snapshot
        rpc :collectSnapshot, stream(::Skywalking::V3::ThreadSnapshot), ::Skywalking::V3::Commands
        # report profiling task finished
        rpc :reportTaskFinish, ::Skywalking::V3::ProfileTaskFinishReport, ::Skywalking::V3::Commands
      end

      Stub = Service.rpc_stub_class
    end
  end
end
