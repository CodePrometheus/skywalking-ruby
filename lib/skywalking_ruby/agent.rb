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
  # @api private
  class Agent
    class << self
      LOCK = Mutex.new

      def self.agent
        defined?(@agent) && @agent
      end

      def self.start(config)
        return @agent if @agent
        config ||= {}
        config = Configuration.new(config) unless config.is_a?(Configuration)

        LOCK.synchronize do
          return @agent if @agent
          @agent = new(config).start
          config.freeze
        end
        self
      end

      def self.stop
        LOCK.synchronize do
          return unless @agent
          @agent.shutdown
          @agent = nil
        end
      end
      
      def started?
        !!(defined?(@agent) && @agent)
      end
    end

    def initialize(config)
      @config = config
    end
    
    def start
      PluginsManager.new
    end
    
    def shutdown
    end
  end
end
