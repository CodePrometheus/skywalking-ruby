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

require 'skywalking_ruby/agent'
require 'skywalking_ruby/configuration'

module SkywalkingRuby
  class << self
    attr_reader :configuration
    
    def start(opts = {})
      if started?
        p 'SkywalkingRuby has already started'
        return
      end
      
      p 'SkywalkingRuby starting...'
  
      Agent.start(opts)
    end

    def started?
      defined?(@started) ? @started : false
    end
    
    def configure(root_path = nil)
      if started?
        p 'SkywalkingRuby has already started'
        return
      end
      
      @configuration = Configuration.new(root_path || Configuration.determine_file_path)
      custom_config = Configuration::CustomConfig.new(config)
      return unless block_given?
      yield custom_config
      configuration.merge_custom_options(custom_config.custom_options)
    end
    
    def stop
      Agent.stop
    end
  end
end
