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
  module Plugins
    class Redis < PluginsManager::SWPlugin
      module RedisIntercept
        def call_v(command)
          orig_command = command[0]
          return super if orig_command == :auth
          
        end
      end

      def version_valid?
        version = Gem::Version.new(::Redis::VERSION) rescue nil
        version && version >= Gem::Version.new("5.0.0")
      end

      def install
        SkywalkingRuby.info "Plugin Redis Instrumenting"
        if ::Redis::Client.method_defined?(:call_v)
          ::Redis::Client.include SkywalkingRuby::Tracing
          ::Redis::Client.prepend RedisIntercept
        end
      end
      
      register :redis
    end
  end
end
