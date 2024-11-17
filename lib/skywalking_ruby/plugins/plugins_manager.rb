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
    class PluginsManager
      def initialize
        install_plugins
      end
      
      attr_reader :enabled_plugins

      def install_plugins
        @enabled_plugins = Plugin.plugin_names - @agent_config['disable_plugins'].split(',')
      end

      class SWPlugin
        include SkywalkingRuby::Log
        @plugin_names = []

        class << self
          attr_reader :plugin_names

          def inherited(subclass)
            @plugin_names << subclass.name
          end
        end

        def initialize
          @installed = false
        end

        def name
          raise NotImplementedError
        end

        def installed?
          @installed
        end

        def try_install(name)
          return unless version_valid?
          return if installed?
          begin
            install
            @installed = true
          rescue => e
            error "Plugin#try_install failed, plugin=%s, error=%s", name, e.message
          end
        end

        def version_valid?
          raise NotImplementedError
        end

        def install
          raise NotImplementedError
        end
      end
    end
  end
end