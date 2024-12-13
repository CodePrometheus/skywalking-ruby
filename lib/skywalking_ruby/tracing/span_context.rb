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
    class SpanContext < Context
      attr_accessor :segment, :span_id, :correlation, :n_spans, :create_time, :finished

      def initialize
        @segment = Tracing::Segment.new
        @span_id = 0
        @correlation = {}
        @n_spans = 0
        @create_time = (Time.now.to_f * 1000).to_i
        @finished = false
        @config = Configuration.config
      end

      def self.ignore_check(operation, carrier = nil)
        if @config.re_ignore_operation.match?(operation) || (carrier&.suppressed?)
          return Tracing::NoopSpan
        end
        nil
      end

      def self.peek(raise_if_none: false)
        spans = ContextManager.spans
        return spans.last unless spans.empty?

        raise Exception 'No active span' if raise_if_none
        nil
      end

      def new_span(span_klass, parent, operation)
        context = !@finished ? self : SpanContext.new
        span = span_klass.new(
          id: context.span_id += 1,
          parent_id: @finished ? -1 : (parent&.id || -1),
          context: context,
          operation: operation
        )

        if @finished && parent
          carrier = Carrier.new(
            trace_id: parent.context.segment.related_traces[0],
            segment_id: parent.context.segment.segment_id,
            span_id: parent.id,
            service: @config.service_name,
            service_instance: @config.instance_name,
            endpoint: parent.operation,
            peer: parent.peer,
            correlation: parent.context.correlation
          )
          Span.extract(carrier)
        end

        span
      end

      def new_entry_span(operation, carrier = nil, inherit = nil)
        span = self.class.ignore_check(operation)
        return span if span

        parent = self.class.peek(raise_if_none: false)
        SkywalkingRuby.info 'create new entry span'
        if !@finished && parent && parent.kind == Tracing::SpanType::Entry && inherit == parent.component
          span = parent
          span.operation = operation
        else
          span = new_span(Tracing::SpanType::Entry, parent, operation)
          span.extract(carrier) if carrier&.valid?
        end
      end

      def new_local_span(operation)
        span = self.class.ignore_check(operation)
        return span if span

        parent = self.class.peek(raise_if_none: false)
        SkywalkingRuby.info 'create new local span'
        new_span(Tracing::SpanType::Local, parent, operation)
      end

      def new_exit_span(operation, carrier, component = nil, inherit = nil)
        span = self.class.ignore_check(operation, carrier)
        return span if span

        parent = self.class.peek(raise_if_none: false)
        SkywalkingRuby.info 'create new exit span'

        if !@finished && parent && parent.kind == Tracing::SpanType::Exit && inherit == parent.inherit
          span = parent
          span.operation = operation
          span.peer = peer
          span.component = component
        else
          span = new_span(Tracing::SpanType::Exit, parent, operation)
        end

        span.inherit = inherit if inherit
        span
      end

      def start(span)
        @n_spans += 1
        spans = ContextManager.spans_dup
        spans << span unless spans.include?(span)
      end

      def stop?(span)
        spans = ContextManager.spans_dup
        span.finish(@segment)
        spans.delete(span)
        @n_spans -= 1
        if @n_spans.zero?
          @finished = true
        end

        @n_spans.zero?
      end

      def active_span
        self.class.peek(raise_if_none: false)
      end
    end
  end
end
