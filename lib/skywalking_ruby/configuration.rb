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

require "yaml"

module SkywalkingRuby
  class Configuration
    DEFAULTS = {
      'service_name' => [:string, 'Your_ApplicationName'],
      'instance_name' => [:string, 'Your_InstanceName'],
      'collector_discard' => [:bool, false],
      'collector_backend_service' => [:string, '127.0.0.1:11800'],
      'config_file' => [:string, 'config/skywalking_ruby.yaml'],
      'log_file' => [:string, 'skywalking_ruby.log'],
      'log_file_path' => [:string, 'STDOUT'],
      'log_level' => [:string, 'info'],
    }.freeze

    # @api private
    attr_reader :agent_config, :root_path

    def initialize(opts = {})
      @agent_config = {}
      initialize_config(opts)
    end

    def initialize_config(opts)
      # from the default value
      merge_config(DEFAULTS.transform_values { |v| v[1] })
      merge_config(opts)
      # from the custom config file
      merge_config(override_config_by_file)
      merge_config(override_config_by_env)
    end

    def merge_config(new_config)
      return if new_config.nil?
      new_config.each do |k, v|
        agent_config[k.to_s] = v
      end
    end

    def override_config_by_file
      config_yaml = @agent_config['config_file']
      unless File.exist?(config_yaml)
        p "No config file found at #{config_yaml}"
        return
      end

      error = nil
      begin
        raw_file = File.read(config_yaml)
        erb_file = ERB.new(raw_file).result(binding)
        loaded_yaml = YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(erb_file) :
                        YAML.load(erb_file, permitted_classes: [], permitted_symbols: [], aliases: true)
        error = "Invalid format in config file" if loaded_yaml && !loaded_yaml.is_a?(Hash)
      rescue Exception => e
        error = e.message
        nil
      end

      raise Exception, "Error loading config file: #{config_yaml} - #{error}" if error
      loaded_yaml
    end

    def override_config_by_env
      new_config = {}
      DEFAULTS.each do |env_key, env_schema|
        env_value = ENV[key_to_env_key(env_key)]
        next if env_value.nil?
        type = env_schema[0]
        case type
        when :string
          new_config[env_key] = env_value.to_s
        when :bool
          new_config[env_key] = !%w[0 false].include?(env_value.strip.downcase)
        else
          env_value
        end
      end
      new_config
    end

    def key_to_env_key(key)
      'SW_AGENT_' + key.upcase
    end

    def freeze
      super
      agent_config.freeze
      agent_config.transform_values(&:freeze)
      self
    end
  end
end
