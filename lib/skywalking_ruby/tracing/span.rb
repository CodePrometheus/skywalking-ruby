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

module SkywalkingRuby
  module Tracing
    class Span
      attr_accessor :operation, :inherit, :component

      attr_reader :context, :span_type, :id, :parent_id, :peer, :layer, :kind,
                  :depth, :tags, :logs, :refs, :start_time, :end_time, :error_occurred

      def initialize(opts)
        @context = opts[:context]
        @operation = opts[:operation]
        @span_type = opts[:span_type] || ''
        @id = opts[:id] || -1
        @parent_id = opts[:parent_id] || -1
        @peer = opts[:peer] || ''
        @layer = opts[:layer] || Tracing::Layer::Unknown
        @kind = opts[:kind]
        @component = opts[:component] || Tracing::Component::Unknown

        @depth = 0
        @inherit = Tracing::Component::Unknown
        @tags = []
        @logs = []
        @refs = []
        @start_time = 0
        @end_time = 0
        @error_occurred = false
      end

      def start
        @depth += 1
        if @depth != 1
          return
        end
        @start_time = (Time.now.to_f * 1000).to_i
        @context.start(self)
      end

      def stop
        @depth -= 1
        if @depth == 0
          @context.stop(self)
        end
      end

      def finish(segment)
        @end_time = (Time.now.to_f * 1000).to_i
        segment.archive(self)
        true
      end

      def self.inject
        raise 'can only inject context carrier into ExitSpan, this may be a potential bug in the agent, ' +
                'please report this in https://github.com/apache/skywalking/issues if you encounter this. '
      end

      def self.extract(carrier)
        return self if carrier.nil?
        @context.segment.relate(carrier.trace_id)
        @context.correlation = carrier.correlation_carrier.correlation

        return self unless carrier.valid?

        ref = SegmentRef.new(carrier)
        @refs << ref unless @refs.include?(ref)
        self
      end
    end
  end
end
