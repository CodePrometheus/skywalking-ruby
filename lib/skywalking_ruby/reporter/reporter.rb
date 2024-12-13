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

require_relative 'grpc'
require_relative 'Scheduler'

module SkywalkingRuby
  module Reporter
    class Reporter
      def initialize(config)
        @config = config
        @segment_queue = Queue.new

        init_proto
      end

      def init_proto
        case @config.report_protocol
        when 'grpc'
          @protocol = Grpc.new(@config)
        else
          raise "Unsupported report protocol: #{@config.report_protocol}"
        end
      end

      def init_reporter
        @scheduler_loop = Scheduler.new
        @background_worker_thread = Thread.new do
          init_worker_loop
          @scheduler_loop.run
        end
      end

      def init_worker_loop
        @scheduler_loop.subscribe(:report_heartbeat) { report_heartbeat }
        @scheduler_loop.trigger_timer(:report_heartbeat, @config.collector_heartbeat_period)
      end

      def stop
        @scheduler_loop.shutdown
        if @background_worker_thread.alive?
          @background_worker_thread.wakeup
          @background_worker_thread.join
        end
      end

      def report_heartbeat
        @protocol.report_heartbeat
      end

      def report_segment
        unless @segment_queue.empty?
          @protocol.report_segment(@segment_queue)
        end
      end
    end
  end
end
