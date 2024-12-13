#  Licensed to the Apache Software Foundation (ASF) under one or more
#  contributor license agreements.  See the NOTICE file distributed with
#  this work for additional information regarding copyright ownership.
#  The ASF licenses this file to You under the Apache License, Version 2.0
#  (the "License"); you may not use this file except in compliance with
#  the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

require_relative 'protocol'
require_relative './client/grpc_client'

module SkywalkingRuby
  module Reporter
    class Grpc < Protocol
      def initialize(config)
        @ms_client = SkywalkingRuby::Reporter::Client::GrpcClient::ManagementServiceGrpc.new(config)
        @trace_client = SkywalkingRuby::Reporter::Client::GrpcClient::TraceSegmentReportServiceGrpc.new(config)
        @properties_submitted = false
      end

      def report_heartbeat
        unless @properties_submitted
          @ms_client.report_instance_properties
          @properties_submitted = true
        end

        @ms_client.report_heartbeat
      end

      def report_segment(segment_obj)
        @trace_client.report_segment(segment_obj)
      end
    end
  end
end
