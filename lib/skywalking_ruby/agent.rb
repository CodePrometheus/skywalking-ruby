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

      def self.instance
        defined?(@instance) && @instance
      end

      def self.start(opts)
        return @instance if @instance
        config = Configuration.new(opts) unless opts.is_a?(Configuration)

        LOCK.synchronize do
          return @instance if @instance
          @instance = new(config).start
          config.freeze
        end
      end

      def self.stop
        LOCK.synchronize do
          return unless @instance
          @instance.stop
          @instance = nil
        end
      end
    end

    def initialize(config)
      @config = config
    end
    
    def start
    end
    
    def stop
    end
  end
end
